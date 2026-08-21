; ════════════════════════════════════════════════════════════════════════════
; local_llm.ahk  —  OpenAI-compatible local LLM backend for Expanto
;
; Works with Ollama, LM Studio, llama.cpp server, Jan, and any other server
; that exposes an OpenAI-compatible /v1/chat/completions endpoint.
;
; Integration (in Expanto.ahk):
;   #Include "lib/local_llm.ahk"
;   ...
;   LoadLLMSettings()   ; call once at startup, after inifile is set
;
; Dependencies (provided by Expanto):
;   lib/JSON.ahk        — JSON.Dump / JSON.Load
;   global inifile      — path to settings.ini
; ════════════════════════════════════════════════════════════════════════════

global g_llmEnabled  := false
global g_llmEndpoint := "http://localhost:11434/v1"
global g_llmModel    := "llama3"
global g_llmApiKey   := ""
global g_llmModels   := []   ; cached list of models from last probe

; ── Settings ──────────────────────────────────────────────────────────────

LoadLLMSettings() {
    global inifile, g_llmEnabled, g_llmEndpoint, g_llmModel, g_llmApiKey
    g_llmEnabled  := IniRead(inifile, "localllm", "enabled",  "0") = "1"
    g_llmEndpoint := IniRead(inifile, "localllm", "endpoint", "http://localhost:11434/v1")
    g_llmModel    := IniRead(inifile, "localllm", "model",    "llama3")
    g_llmApiKey   := IniRead(inifile, "localllm", "api_key",  "")
}

SaveLLMSettings(msg) {
    global inifile
    if msg.Has("llm_enabled")  IniWrite(msg["llm_enabled"]  ? "1" : "0", inifile, "localllm", "enabled")
    if msg.Has("llm_endpoint") IniWrite(Trim(msg["llm_endpoint"]),        inifile, "localllm", "endpoint")
    if msg.Has("llm_model")    IniWrite(Trim(msg["llm_model"]),           inifile, "localllm", "model")
    if msg.Has("llm_api_key")  IniWrite(Trim(msg["llm_api_key"]),         inifile, "localllm", "api_key")
    LoadLLMSettings()
}

; Returns a JSON string with local LLM state, merged into BuildAISettingsJson().
BuildLLMSettingsJson() {
    global g_llmEnabled, g_llmEndpoint, g_llmModel, g_llmApiKey, g_llmModels
    return JSON.Dump(Map(
        "llm_enabled",  g_llmEnabled ? 1 : 0,
        "llm_endpoint", g_llmEndpoint,
        "llm_model",    g_llmModel,
        "llm_api_key",  g_llmApiKey,
        "llm_models",   g_llmModels,
        "llm_online",   g_llmModels.Length > 0 ? 1 : 0))
}

; ── Model discovery ────────────────────────────────────────────────────────

; Probes the server and returns an array of model-name strings.
; Updates g_llmModels as a side effect.
LLMProbeModels() {
    global g_llmEndpoint, g_llmApiKey, g_llmModels
    g_llmModels := []
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", RTrim(g_llmEndpoint, "/") "/models", false)
        whr.SetRequestHeader("Content-Type", "application/json")
        if (g_llmApiKey != "")
            whr.SetRequestHeader("Authorization", "Bearer " g_llmApiKey)
        whr.SetTimeouts(0, 3000, 6000, 6000)
        whr.Send()
        if (whr.Status != 200)
            return g_llmModels
        resp := JSON.Load(LLMDecodeUTF8(whr.ResponseBody))
        ; OpenAI format: { data: [ {id: "..."}, ... ] }
        if (resp.Has("data")) {
            for m in resp["data"]
                if (m.Has("id") && Trim(m["id"]) != "")
                    g_llmModels.Push(m["id"])
        }
        ; Ollama native format: { models: [ {name: "..."}, ... ] }
        if (resp.Has("models")) {
            for m in resp["models"] {
                id := m.Has("id") ? m["id"] : (m.Has("name") ? m["name"] : "")
                if (Trim(id) != "")
                    g_llmModels.Push(id)
            }
        }
    }
    return g_llmModels
}

; ── Core API call ──────────────────────────────────────────────────────────

; Drop-in replacement for ai_wv2.ahk's AIRequest() when local LLM is active.
;
; systemPrompt : string  — the system / context prompt
; userPrompt   : string  — the user message
; schema       : Map     — JSON Schema the response must conform to
;
; Returns a parsed Map/Array.  Throws Error on failure.
LLMRequest(systemPrompt, userPrompt, schema) {
    global g_llmEndpoint, g_llmModel, g_llmApiKey

    schemaJson   := JSON.Dump(schema)
    sysWithSchema := systemPrompt
        . "`n`n=== OUTPUT FORMAT ===`n"
        . "Reply with ONLY valid JSON that strictly matches this schema. "
        . "No explanations, no markdown fences, no extra keys.`n"
        . schemaJson

    endpoint := RTrim(g_llmEndpoint, "/") "/chat/completions"

    ; Try first with response_format:{type:"json_object"}, then without if server rejects it.
    Loop 2 {
        useFormat := (A_Index = 1)
        body := LLMBuildBody(g_llmModel, sysWithSchema, userPrompt, useFormat)
        Loop 3 {
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
            whr.Open("POST", endpoint, false)
            whr.SetRequestHeader("Content-Type", "application/json")
            if (g_llmApiKey != "")
                whr.SetRequestHeader("Authorization", "Bearer " g_llmApiKey)
            whr.SetTimeouts(0, 10000, 60000, 180000)
            try {
                whr.Send(body)
            } catch as e {
                if (A_Index < 3) {
                    Sleep(1500)
                    continue
                }
                throw Error("Kan inte ansluta till lokal LLM på " endpoint ": " e.Message)
            }
            respText := LLMDecodeUTF8(whr.ResponseBody)
            if (whr.Status = 200)
                return LLMParseResponse(respText)
            ; 400 with response_format → server doesn't support it, retry without
            if (whr.Status = 400 && useFormat)
                break
            if (A_Index < 3) {
                Sleep(1500)
                continue
            }
            throw Error("Lokal LLM svarade " whr.Status ": " SubStr(respText, 1, 300))
        }
    }
    throw Error("Lokal LLM: anslutning eller modellfel. Kontrollera att servern är igång.")
}

LLMBuildBody(model, sysPrompt, userPrompt, includeFormat := true) {
    m := Map(
        "model",       model,
        "messages",    [
            Map("role", "system", "content", sysPrompt),
            Map("role", "user",   "content", userPrompt)
        ],
        "temperature", 0,
        "stream",      JSON._false)
    if includeFormat
        m["response_format"] := Map("type", "json_object")
    return JSON.Dump(m)
}

LLMParseResponse(respText) {
    resp := JSON.Load(respText)
    txt  := ""
    if (resp.Has("choices") && resp["choices"].Length > 0) {
        ch := resp["choices"][1]
        if (ch.Has("message") && ch["message"].Has("content"))
            txt := Trim(ch["message"]["content"])
    }
    if (txt = "")
        throw Error("Tomt svar från lokal modell.")
    ; Strip markdown code fences if present
    txt := RegExReplace(txt, "(?s)^```(?:json)?\s*", "")
    txt := RegExReplace(txt, "(?s)\s*```$",           "")
    txt := Trim(txt)
    ; If model added prose before/after, extract the first JSON object or array
    if (!RegExMatch(txt, "^[{[]")) {
        if RegExMatch(txt, "(?s)(\{.*\}|\[.*\])", &m)
            txt := m[1]
    }
    try
        return JSON.Load(txt)
    catch
        throw Error("Ogiltig JSON från lokal modell:`n" SubStr(txt, 1, 400))
}

LLMDecodeUTF8(bodyBytes) {
    stream := ComObject("ADODB.Stream")
    stream.Type := 1
    stream.Open()
    stream.Write(bodyBytes)
    stream.Position := 0
    stream.Type    := 2
    stream.Charset := "utf-8"
    txt := stream.ReadText()
    stream.Close()
    return txt
}
