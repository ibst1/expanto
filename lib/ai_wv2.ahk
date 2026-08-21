; ═══════════════════════════════════════════════════════════════════════════════
; ai_wv2.ahk  —  AI integration for Expanto WebView2 UI
; Depends on (from Expanto.ahk context):
;   lib\JSON.ahk, globals inifile/HS_ALL/g_ColCol/g_Semi/wv2Core,
;   FindHsById, RebuildAndReload, ReloadPhrases, BuildPhrasesJson,
;   SaveHotstring, RemoveHotstringFromFile, PhraseFileAppend, BuildMeta,
;   Escape_CC, ArrJoin
; ═══════════════════════════════════════════════════════════════════════════════

; ── Globals ───────────────────────────────────────────────────────────────────
global g_aiKey      := ""
global g_aiModel    := "claude-sonnet-4-6"
global g_aiEnabled  := false
global g_aiAutoTag  := false
global g_aiExclude  := []
global g_aiTokenLog := []
global g_lastBackup := ""

; ── Settings ──────────────────────────────────────────────────────────────────
LoadAISettings() {
    global inifile, g_aiKey, g_aiModel, g_aiEnabled, g_aiAutoTag, g_aiExclude
    g_aiKey     := IniRead(inifile, "ai", "api_key",  "")
    g_aiModel   := IniRead(inifile, "ai", "model",    "claude-sonnet-4-6")
    g_aiEnabled := (IniRead(inifile, "ai", "enabled",  "0") = "1")
    g_aiAutoTag := (IniRead(inifile, "ai", "auto_tag", "1") = "1")   ; default ON
    g_aiExclude := []
    for pat in StrSplit(IniRead(inifile, "ai", "exclude", ""), "|") {
        pat := Trim(pat)
        if (pat != "")
            g_aiExclude.Push(pat)
    }
}

AIExcluded(filepath) {
    global g_aiExclude
    fp := StrLower(filepath)
    if (SubStr(fp, -4) = ".enc")
        return true
    for pat in g_aiExclude
        if InStr(fp, StrLower(pat))
            return true
    return false
}

SaveAIExclude() {
    global inifile, g_aiExclude
    IniWrite(ArrJoin(g_aiExclude, "|"), inifile, "ai", "exclude")
}

; ── AI readiness check ────────────────────────────────────────────────────────
; Returns true if any AI backend is ready to use.
AIReady() {
    global g_aiEnabled, g_aiKey, g_llmEnabled
    if (IsSet(g_llmEnabled) && g_llmEnabled)
        return true
    return g_aiEnabled && Trim(g_aiKey) != ""
}

; ── HTTP / API core ───────────────────────────────────────────────────────────
; Dispatches to local LLM (if enabled) or Anthropic Claude.
AIRequest(systemPrompt, userPrompt, schema) {
    global g_llmEnabled
    if (IsSet(g_llmEnabled) && g_llmEnabled)
        return LLMRequest(systemPrompt, userPrompt, schema)
    return _AIRequestClaude(systemPrompt, userPrompt, schema)
}

_AIRequestClaude(systemPrompt, userPrompt, schema) {
    global g_aiKey, g_aiModel
    body := JSON.Dump(Map(
        "model",         g_aiModel,
        "max_tokens",    1024,
        "system",        systemPrompt,
        "messages",      [ Map("role", "user", "content", userPrompt) ],
        "output_config", Map("format", Map("type", "json_schema", "schema", schema))))
    AIThrottle(Round((StrLen(systemPrompt) + StrLen(userPrompt)) / 3))
    attempt := 0
    loop {
        attempt++
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", "https://api.anthropic.com/v1/messages", false)
        whr.SetRequestHeader("content-type",      "application/json")
        whr.SetRequestHeader("x-api-key",         g_aiKey)
        whr.SetRequestHeader("anthropic-version", "2023-06-01")
        whr.SetTimeouts(0, 60000, 60000, 60000)
        whr.Send(body)
        respText := AIDecodeUTF8(whr.ResponseBody)
        if (whr.Status = 200)
            break
        if ((whr.Status = 429 || whr.Status = 529) && attempt < 5) {
            Sleep AIRetryAfter(whr, attempt) * 1000
            continue
        }
        throw Error("API " whr.Status ": " SubStr(respText, 1, 300))
    }
    resp := JSON.Load(respText)
    AIRecordUsage(resp)
    AIRecordTokens(resp)
    txt := ""
    for blk in resp["content"]
        if (blk.Has("type") && blk["type"] = "text") {
            txt := blk["text"]
            break
        }
    if (txt = "")
        throw Error("Tomt svar från modellen.")
    return JSON.Load(txt)
}

AIDecodeUTF8(bodyBytes) {
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

AIModelPrices(model) {
    m := StrLower(model)
    if InStr(m, "haiku")
        return { in: 1.0, out: 5.0 }
    if InStr(m, "opus")
        return { in: 5.0, out: 25.0 }
    return { in: 3.0, out: 15.0 }
}

AINum(v) => (v != "" && IsNumber(v)) ? v + 0 : 0

AIRecordUsage(resp) {
    global inifile, g_aiModel
    if (!resp.Has("usage"))
        return
    u      := resp["usage"]
    inTok  := u.Has("input_tokens")  ? u["input_tokens"]  : 0
    outTok := u.Has("output_tokens") ? u["output_tokens"] : 0
    p      := AIModelPrices(g_aiModel)
    cost   := inTok / 1000000 * p.in + outTok / 1000000 * p.out
    IniWrite(AINum(IniRead(inifile, "ai", "used_in",    0)) + inTok,  inifile, "ai", "used_in")
    IniWrite(AINum(IniRead(inifile, "ai", "used_out",   0)) + outTok, inifile, "ai", "used_out")
    IniWrite(AINum(IniRead(inifile, "ai", "used_calls", 0)) + 1,      inifile, "ai", "used_calls")
    IniWrite(Format("{:.6f}", AINum(IniRead(inifile, "ai", "used_cost", "0")) + cost),
        inifile, "ai", "used_cost")
}

AIThrottle(estTokens) {
    global g_aiTokenLog
    budget := 45000
    loop {
        now := A_TickCount
        kept := [], used := 0
        for e in g_aiTokenLog
            if (now - e.t < 60000) {
                kept.Push(e)
                used += e.tokens
            }
        g_aiTokenLog := kept
        if (used + estTokens <= budget)
            return
        Sleep 1500
    }
}

AIRecordTokens(resp) {
    global g_aiTokenLog
    if (resp.Has("usage") && resp["usage"].Has("input_tokens"))
        g_aiTokenLog.Push({ t: A_TickCount, tokens: resp["usage"]["input_tokens"] })
}

AIRetryAfter(whr, attempt) {
    ra := ""
    try ra := whr.GetResponseHeader("retry-after")
    if (ra != "" && IsNumber(ra))
        return Min(Integer(ra) + 1, 65)
    return Min(2 ** attempt, 30)
}

AIUsageText() {
    global inifile
    inTok  := AINum(IniRead(inifile, "ai", "used_in",    0))
    outTok := AINum(IniRead(inifile, "ai", "used_out",   0))
    calls  := AINum(IniRead(inifile, "ai", "used_calls", 0))
    cost   := AINum(IniRead(inifile, "ai", "used_cost", "0"))
    return calls " anrop · " inTok " in + " outTok " ut tokens · ≈ $" Format("{:.4f}", cost)
}

AIResetUsage() {
    global inifile
    for k in ["used_in", "used_out", "used_calls", "used_cost"]
        IniWrite("0", inifile, "ai", k)
}

; ── Vocabulary, schemas, suggest ──────────────────────────────────────────────
AICollectVocab() {
    global HS_ALL
    cats := [], tags := [], files := []
    seenC := Map(), seenT := Map(), seenF := Map()
    for hs in HS_ALL {
        c := Trim(hs.category)
        if (c != "" && !seenC.Has(c))
            cats.Push(c), seenC[c] := true
        for t in hs.tags {
            tt := Trim(t)
            if (tt != "" && !seenT.Has(tt))
                tags.Push(tt), seenT[tt] := true
        }
        SplitPath(hs.filepath, &nm)
        if (nm != "" && !seenF.Has(nm))
            files.Push(nm), seenF[nm] := true
    }
    return { cats: cats, tags: tags, files: files }
}

AINewSchema() {
    str := Map("type", "string")
    return Map(
        "type", "object",
        "properties", Map(
            "category", str,
            "tags",     Map("type", "array", "items", Map("type", "string")),
            "file",     str,
            "comment",  str,
            "lang",     str),
        "required", ["category", "tags", "file", "comment", "lang"],
        "additionalProperties", JSON._false)
}

AISuggestFor(short, long, v) {
    sys := "Du organiserar textfraser (hotstrings) i ett bibliotek. För den givna frasen "
         . "ska du föreslå metadata.`n"
         . "ÅTERANVÄND befintliga kategorier och taggar i så stor utsträckning som möjligt — "
         . "de listas nedan. Matcha mot dem även vid liten skillnad i ordval (t.ex. singular/"
         . "plural, böjning, synonymer); använd EXAKT den befintliga stavningen när du matchar.`n"
         . "Kategori: välj alltid en befintlig om någon är rimlig; föreslå en ny endast om "
         . "ingen befintlig alls passar.`n"
         . "Taggar: föredra befintliga taggar. Du FÅR lägga till en eller flera NYA taggar när "
         . "de tillför något befintliga taggar saknar — men hitta inte på dubletter av sådant "
         . "som redan finns under annat namn.`n"
         . "Bedöm frastypen efter dess form: ett enstaka ord eller en kort term är en "
         . "förkortnings-/termexpansion — kategorisera den som förkortning/term eller ämnesmässigt, "
         . "ALDRIG som brev, mall eller annan dokumenttyp. Endast längre texter (hälsningsfras, "
         . "flera meningar) kan vara brev/mallar.`n"
         . "'file' MÅSTE vara ett av de befintliga filnamnen. Kommentaren ska vara mycket kort "
         . "(några ord). 'lang' MÅSTE alltid anges: frasens språk som ISO-kod (t.ex. sv eller en); "
         . "för ett enstaka fackord, ange språket ordet tillhör. "
         . "Svara enbart enligt schemat."
    user := "Befintliga kategorier: " ArrJoin(v.cats, ", ") "`n"
          . "Befintliga taggar: "     ArrJoin(v.tags, ", ") "`n"
          . "Befintliga filer: "      ArrJoin(v.files, ", ") "`n`n"
          . "Trigger: " short "`n"
          . "Fras: "    long
    return AIRequest(sys, user, AINewSchema())
}

AIMergeTags(existing, aiArr) {
    seen := Map(), out := []
    for t in existing {
        tt := Trim(t)
        if (tt != "" && !seen.Has(StrLower(tt))) {
            seen[StrLower(tt)] := true
            out.Push(tt)
        }
    }
    for t in aiArr {
        tt := Trim(t)
        if (tt != "" && !seen.Has(StrLower(tt))) {
            seen[StrLower(tt)] := true
            out.Push(tt)
        }
    }
    return ArrJoin(out, ",")
}

; ── WV2 message entry point (called from OnWebMessageReceived) ─────────────────
; Non-blocking: HTTP calls and native GUIs are deferred via SetTimer
WV2AIHandle(msg, sender) {
    action := msg["action"]
    if (action = "aiSuggest") {
        p := { id:      msg.Has("id")      ? msg["id"]      : "",
               trigger: msg.Has("trigger") ? msg["trigger"]  : "",
               phrase:  msg.Has("phrase")  ? msg["phrase"]   : "",
               file:    msg.Has("file")    ? msg["file"]     : "",
               live:    msg.Has("live")    ? msg["live"]     : 0,
               seq:     msg.Has("seq")     ? msg["seq"]      : 0 }
        SetTimer(() => _AIDoSuggest(p), -1)

    } else if (action = "aiBatch") {
        ids := msg["ids"]
        SetTimer(() => _AIDoEBatch(ids), -1)

    } else if (action = "aiMaintenance") {
        task := msg.Has("task") ? msg["task"] : ""
        SetTimer(() => _AIDoMaintenance(task), -1)

    } else if (action = "getAiSettings") {
        sender.ExecuteScriptAsync("window.receiveAiSettings(" BuildAISettingsJson() ")")

    } else if (action = "saveAiSettings") {
        _AISaveSettings(msg)
        sender.ExecuteScriptAsync("window.receiveAiSettings(" BuildAISettingsJson() ")")

    } else if (action = "saveAutoTag") {
        ; quick toggle from the new-phrase panel's AI checkbox
        global inifile, g_aiAutoTag
        g_aiAutoTag := msg.Has("on") && msg["on"]
        IniWrite(g_aiAutoTag ? "1" : "0", inifile, "ai", "auto_tag")

    } else if (action = "aiResetUsage") {
        AIResetUsage()
        sender.ExecuteScriptAsync("window.receiveAiSettings(" BuildAISettingsJson() ")")

    } else if (action = "aiSemanticSearch") {
        query   := msg.Has("query")   ? msg["query"]   : ""
        phrases := msg.Has("phrases") ? msg["phrases"] : []
        SetTimer(() => _AIDoSemanticSearch(query, phrases), -1)
    }
}

; ── Semantic search ───────────────────────────────────────────────────────────
_AIDoSemanticSearch(query, phrases) {
    global wv2Core
    if (!AIReady()) {
        wv2Core.ExecuteScriptAsync("window.receiveAiSearchResult(" JSON.Dump(Map("error", "AI inte aktiverat.")) ")")
        return
    }
    if (Trim(query) = "" || !IsObject(phrases) || !phrases.Length) {
        wv2Core.ExecuteScriptAsync("window.receiveAiSearchResult(" JSON.Dump(Map("ids", [])) ")")
        return
    }
    ; Cap at 150 phrases to avoid huge prompts
    cap := Min(phrases.Length, 150)
    list := ""
    Loop cap
        list .= A_Index ". [" (phrases[A_Index].Has("trigger") ? phrases[A_Index]["trigger"] : "") "] "
             . StrReplace(SubStr(phrases[A_Index].Has("phrase") ? phrases[A_Index]["phrase"] : "", 1, 120), "`n", " ") "`n"
    sys := "Du söker semantiskt i ett bibliotek med fraser. Givet en sökfråga, identifiera de fraser "
         . "som semantiskt matchar frågan — liknande betydelse, sammanhang eller syfte. Returnera "
         . "indexen (1-baserade) av de matchande fraserna, sorterade från bäst matchande, i schemat."
    user := "Sökfråga: " query "`n`nFraser:`n" list
    schema := Map("type", "object",
        "properties", Map("matches", Map("type", "array", "items", Map("type", "integer"))),
        "required", ["matches"], "additionalProperties", JSON._false)
    ; Use a faster Claude model for search; local LLM keeps its configured model.
    savedModel := ""
    if (!IsSet(g_llmEnabled) || !g_llmEnabled) {
        savedModel := g_aiModel
        g_aiModel  := "claude-haiku-4-5-20251001"
    }
    try {
        res := AIRequest(sys, user, schema)
    } catch as e {
        if (savedModel != "")
            g_aiModel := savedModel
        wv2Core.ExecuteScriptAsync("window.receiveAiSearchResult(" JSON.Dump(Map("error", e.Message)) ")")
        return
    }
    if (savedModel != "")
        g_aiModel := savedModel
    ; Map indices back to phrase IDs
    matchedIds := []
    if (res.Has("matches")) {
        for idx in res["matches"] {
            i := idx + 0
            if (i >= 1 && i <= cap && phrases[i].Has("id"))
                matchedIds.Push(phrases[i]["id"])
        }
    }
    wv2Core.ExecuteScriptAsync("window.receiveAiSearchResult && window.receiveAiSearchResult(" JSON.Dump(Map("ids", matchedIds)) ")")
    wv2Core.ExecuteScriptAsync("window.updateAiUsage && window.updateAiUsage(" JSON.Dump(AIUsageText()) ")")
}

; ── Single-phrase suggest (async via SetTimer) ────────────────────────────────
_AIDoSuggest(p) {
    global wv2Core
    if (!AIReady()) {
        wv2Core.ExecuteScriptAsync("window.receiveAiSuggestion(" JSON.Dump(Map("error", "AI inte aktiverat. Konfigurera nyckel under ⚙.", "live", p.live)) ")")
        return
    }
    if (p.file != "" && AIExcluded(p.file)) {
        wv2Core.ExecuteScriptAsync("window.receiveAiSuggestion(" JSON.Dump(Map("error", "Filen är exkluderad från AI.", "live", p.live)) ")")
        return
    }
    try {
        s := AISuggestFor(p.trigger, p.phrase, AICollectVocab())
    } catch as e {
        wv2Core.ExecuteScriptAsync("window.receiveAiSuggestion(" JSON.Dump(Map("error", e.Message, "live", p.live)) ")")
        return
    }
    result := Map(
        "id",      p.id,
        "live",    p.live,
        "seq",     p.seq,
        "cat",     s.Has("category") ? s["category"] : "",
        "tags",    s.Has("tags")     ? ArrJoin(s["tags"], ",") : "",
        "comment", s.Has("comment")  ? s["comment"]  : "",
        "lang",    s.Has("lang")     ? s["lang"]      : "")
    wv2Core.ExecuteScriptAsync("window.receiveAiSuggestion(" JSON.Dump(result) ")")
    ; Refresh usage display after the call
    wv2Core.ExecuteScriptAsync("window.updateAiUsage && window.updateAiUsage(" JSON.Dump(AIUsageText()) ")")
}

; ── Auto-fill metadata for a just-saved NEW phrase (quick-add AI checkbox) ────
; Runs deferred, after the file rebuild, so the phrase exists in HS_ALL.
; Fills ONLY fields the user left empty — never overwrites manual input.
_AIAutoFillNew(filepath, trigger) {
    global wv2Core
    if (!AIReady() || AIExcluded(filepath))
        return
    hs := FindHsById(filepath "|" trigger)
    if !IsObject(hs)
        return
    ; Nothing left to fill (the live suggestion got there first) → skip the API call
    if (Trim(hs.category) != "" && IsObject(hs.tags) && hs.tags.Length
        && Trim(hs.comment) != "" && Trim(hs.language) != "")
        return
    try
        s := AISuggestFor(hs.short, Unescape_CC(hs.long), AICollectVocab())
    catch
        return
    ändrad := false
    if (Trim(hs.category) = "" && s.Has("category") && s["category"] != "") {
        hs.category := s["category"]
        ändrad := true
    }
    if ((!IsObject(hs.tags) || !hs.tags.Length)
        && s.Has("tags") && IsObject(s["tags"]) && s["tags"].Length) {
        hs.tags := s["tags"]
        ändrad := true
    }
    if (Trim(hs.comment) = "" && s.Has("comment") && s["comment"] != "") {
        hs.comment := s["comment"]
        ändrad := true
    }
    if (Trim(hs.language) = "" && s.Has("lang") && s["lang"] != "") {
        hs.language := s["lang"]
        ändrad := true
    }
    if !ändrad
        return
    SaveHotstring(hs.filepath, hs.short, hs.options, Unescape_CC(hs.long), hs.category, hs.comment,
        ArrJoin(hs.aliases, ","), , ArrJoin(hs.apps, ","), ArrJoin(hs.tags, ","), hs.language, ,
        hs.disabled, , hs.customFields, hs.url, _HsAlts(hs), _HsAltNames(hs))
    _RebuildFileOnly(hs.filepath)
    if IsObject(wv2Core) {
        _SafeSend(wv2Core, "window.initData(" BuildPhrasesJson() ")")
        wv2Core.ExecuteScriptAsync("window.updateAiUsage && window.updateAiUsage(" JSON.Dump(AIUsageText()) ")")
    }
}

; ── Batch tag (async via SetTimer) ────────────────────────────────────────────
_AIDoEBatch(ids) {
    global wv2Core
    if (!AIReady()) {
        MsgBox "AI inte aktiverat. Konfigurera nyckel under ⚙."
        return
    }
    v   := AICollectVocab()
    changedFiles := Map(), done := 0, skipped := 0
    ts := FormatTime(, "yyyyMMddHHmmss")
    total := ids.Length
    for id in ids {
        hs := FindHsById(id)
        if (!hs || AIExcluded(hs.filepath)) {
            skipped++
            continue
        }
        wv2Core.ExecuteScriptAsync("window.setAiBatchStatus && window.setAiBatchStatus(" JSON.Dump(done + 1) "," total ")")
        try {
            s := AISuggestFor(hs.short, hs.long, v)
        } catch {
            skipped++
            continue
        }
        cat     := (s.Has("category") && Trim(s["category"]) != "") ? Trim(s["category"]) : hs.category
        cmt     := (s.Has("comment")  && Trim(s["comment"])  != "") ? Trim(s["comment"])  : hs.comment
        newTags := AIMergeTags(hs.tags, s.Has("tags") ? s["tags"] : [])
        SaveHotstring(hs.filepath, hs.short, hs.options, hs.long, cat, cmt,
            ArrJoin(hs.aliases, ","), ts, ArrJoin(hs.apps, ","), newTags, hs.language, , hs.disabled ? 1 : 0,
            , IsObject(hs.customFields) ? hs.customFields : Map(), hs.url, _HsAlts(hs), _HsAltNames(hs))
        changedFiles[hs.filepath] := true
        done++
    }
    for fp, _ in changedFiles
        RebuildAndReload(fp)
    wv2Core.ExecuteScriptAsync("window.initData(" BuildPhrasesJson() ")")
    wv2Core.ExecuteScriptAsync("window.setAiBatchStatus && window.setAiBatchStatus(0,0)")
    wv2Core.ExecuteScriptAsync("window.updateAiUsage && window.updateAiUsage(" JSON.Dump(AIUsageText()) ")")
    skippedMsg := skipped ? "`n" skipped " hoppades över (exkluderade eller API-fel)." : ""
    MsgBox done " fras(er) AI-taggade." skippedMsg
}

; ── Settings helpers ──────────────────────────────────────────────────────────
_AISaveSettings(msg) {
    global inifile
    if msg.Has("api_key")  IniWrite(msg["api_key"],               inifile, "ai", "api_key")
    if msg.Has("model")    IniWrite(msg["model"],                 inifile, "ai", "model")
    if msg.Has("enabled")  IniWrite(msg["enabled"] ? "1" : "0",  inifile, "ai", "enabled")
    if msg.Has("auto_tag") IniWrite(msg["auto_tag"] ? "1" : "0", inifile, "ai", "auto_tag")
    if msg.Has("exclude") {
        excl := StrReplace(StrReplace(StrReplace(msg["exclude"], "`r`n", "|"), "`n", "|"), "`r", "|")
        IniWrite(excl, inifile, "ai", "exclude")
    }
    LoadAISettings()
    if (IsSet(SaveLLMSettings))
        SaveLLMSettings(msg)
}

BuildAISettingsJson() {
    global g_aiKey, g_aiModel, g_aiEnabled, g_aiAutoTag, g_aiExclude
    ; Probe local LLM models (fast, cached in g_llmModels)
    if (IsSet(LLMProbeModels))
        LLMProbeModels()
    m := Map(
        "enabled",  g_aiEnabled  ? 1 : 0,
        "api_key",  g_aiKey,
        "model",    g_aiModel,
        "auto_tag", g_aiAutoTag ? 1 : 0,
        "exclude",  ArrJoin(g_aiExclude, "`n"),
        "usage",    AIUsageText())
    if (IsSet(BuildLLMSettingsJson)) {
        llm := JSON.Load(BuildLLMSettingsJson())
        for k, v in llm
            m[k] := v
    }
    return JSON.Dump(m)
}

; ── Maintenance dispatch (async via SetTimer) ─────────────────────────────────
_AIDoMaintenance(task) {
    if (!AIReady()) {
        MsgBox "Aktivera AI och ange API-nyckel i inställningspanelen."
        return
    }
    if (task = "tags") {
        MaintAICleanup("tags")
    } else if (task = "cats") {
        MaintAICleanup("category")
    } else if (task = "move") {
        MaintAIMove()
    } else if (task = "dupes") {
        MaintAISemanticDupes()
    } else if (task = "undo") {
        MaintUndo()
    }
}

; ── Maintenance: tag / category cleanup ──────────────────────────────────────
MaintAICleanup(field) {
    global HS_ALL
    scope := MsgBox("Städa " (field = "tags" ? "taggar" : "kategorier") " i HELA biblioteket?`n`nJa = alla filer    ·    Nej = välj filer", "Omfattning", "YesNoCancel")
    if (scope = "Cancel")
        return
    srcSet := ""
    if (scope = "No") {
        sel := MaintPickFiles(MaintFileList())
        if (sel = "" || !IsObject(sel) || !sel.Length)
            return
        srcSet := Map()
        for p in sel
            srcSet[p] := true
    }
    counts := Map()
    for hs in HS_ALL {
        if (srcSet != "" && !srcSet.Has(hs.filepath))
            continue
        items := (field = "tags") ? hs.tags : StrSplit(hs.category, ",")
        for it in items
            if ((v := Trim(it)) != "")
                counts[v] := counts.Has(v) ? counts[v] + 1 : 1
    }
    if (!counts.Count) {
        MsgBox "Inget att städa i den valda omfattningen."
        return
    }
    ToolTip("AI analyserar " counts.Count " " (field = "tags" ? "taggar" : "kategorier") "…")
    try {
        plan := AICleanupPlan(field, counts)
    } catch as e {
        ToolTip()
        MsgBox "AI-städning misslyckades:`n`n" e.Message
        return
    }
    ToolTip()
    MaintReviewAndApply(field, plan, counts, srcSet)
}

AICleanupPlan(field, counts) {
    noun := (field = "tags") ? "taggar" : "kategorier"
    list := ""
    for v, c in counts
        list .= "- " v " (" c ")`n"
    sys := "Du städar " noun " i ett svenskt hotstring-bibliotek. Identifiera (1) skräp/"
         . "meningslösa " noun " som bör tas bort helt och (2) grupper som betyder samma sak "
         . "och bör slås ihop till ETT kanoniskt namn. Var KONSERVATIV. Svara enbart enligt schemat."
    user := "Befintliga " noun " (med antal användningar):`n" list
    schema := Map(
        "type", "object",
        "properties", Map(
            "remove", Map("type", "array", "items", Map("type", "string")),
            "merge",  Map("type", "array", "items", Map("type", "object",
                "properties", Map(
                    "canonical", Map("type", "string"),
                    "aliases",   Map("type", "array", "items", Map("type", "string"))),
                "required", ["canonical", "aliases"],
                "additionalProperties", JSON._false))),
        "required", ["remove", "merge"],
        "additionalProperties", JSON._false)
    return AIRequest(sys, user, schema)
}

MaintReviewAndApply(field, plan, counts, srcSet := "") {
    noun := (field = "tags") ? "taggar" : "kategorier"
    rem := plan.Has("remove") ? plan["remove"] : []
    mrg := plan.Has("merge")  ? plan["merge"]  : []
    if (!rem.Length && !mrg.Length) {
        MsgBox "AI hittade inget att städa."
        return
    }
    rg := Gui("+AlwaysOnTop +OwnDialogs", "AI-städning: " noun)
    rg.SetFont("s10", "Segoe UI")
    rg.AddText("xm w560", "Rader med ☑ utförs när du klickar Tillämpa.")
    rg.AddText("xm y+12 w560 +0x200", "1. Ta bort dessa " noun " helt")
    rmLV := rg.AddListView("xm y+4 w560 h140 +LV0x0004", ["✓", (field = "tags" ? "Tagg" : "Kategori"), "Antal"])
    for t in rem
        rmLV.Add("Check", "", t, counts.Has(t) ? counts[t] : 0)
    rmLV.ModifyCol(1, 30), rmLV.ModifyCol(2, 400), rmLV.ModifyCol(3, 80)
    rg.AddText("xm y+12 w560 +0x200", "2. Slå ihop (byt namn)")
    mgLV := rg.AddListView("xm y+4 w560 h140 +LV0x0004", ["✓", "Ersätt", "→ med"])
    for grp in mrg {
        canon := grp.Has("canonical") ? grp["canonical"] : ""
        if (!grp.Has("aliases") || canon = "")
            continue
        for a in grp["aliases"] {
            if (Trim(a) = "" || StrLower(Trim(a)) = StrLower(canon))
                continue
            mgLV.Add("Check", "", a, canon)
        }
    }
    mgLV.ModifyCol(1, 30), mgLV.ModifyCol(2, 260), mgLV.ModifyCol(3, 260)
    mgLV.OnEvent("DoubleClick", (ctrl, row, *) => MaintEditCanonical(ctrl, row))
    rg.AddText("xm y+4 w560 cGray", "Tips: dubbelklicka för att ändra det gemensamma namnet.")
    MaintAddCheckRow(rg, rmLV, mgLV)
    state := { done: false }
    applyBtn := rg.AddButton("xm y+10 w150 Default", "Tillämpa")
    applyBtn.OnEvent("Click", (*) => (MaintApply(field, rmLV, mgLV, srcSet), state.done := true, rg.Destroy()))
    cancelBtn := rg.AddButton("x+8 w100", "Avbryt")
    cancelBtn.OnEvent("Click", (*) => (state.done := true, rg.Destroy()))
    rg.OnEvent("Escape", (*) => (state.done := true, rg.Destroy()))
    rg.OnEvent("Close",  (*) => (state.done := true, rg.Destroy()))
    rg.Show()
    while (!state.done)
        Sleep 50
}

MaintApply(field, rmLV, mgLV, srcSet := "") {
    global HS_ALL
    removeSet := Map(), r := 0
    while (r := rmLV.GetNext(r, "Checked"))
        removeSet[StrLower(rmLV.GetText(r, 2))] := true
    mergeMap := Map(), r := 0
    while (r := mgLV.GetNext(r, "Checked"))
        mergeMap[StrLower(mgLV.GetText(r, 2))] := mgLV.GetText(r, 3)
    if (!removeSet.Count && !mergeMap.Count) {
        MsgBox "Inget markerat."
        return
    }
    MaintBackupBegin()
    changedFiles := Map(), ts := FormatTime(, "yyyyMMddHHmmss"), changed := 0
    for hs in HS_ALL {
        if (srcSet != "" && !srcSet.Has(hs.filepath))
            continue
        items := (field = "tags") ? hs.tags : StrSplit(hs.category, ",")
        orig  := (field = "tags") ? ArrJoin(hs.tags, ",") : hs.category
        out := [], seen := Map()
        for it in items {
            v := Trim(it)
            if (v = "")
                continue
            key := StrLower(v)
            if removeSet.Has(key)
                continue
            if mergeMap.Has(key)
                v := mergeMap[key], key := StrLower(v)
            if !seen.Has(key) {
                seen[key] := true
                out.Push(v)
            }
        }
        newVal := ArrJoin(out, ",")
        if (newVal = orig)
            continue
        MaintBackupFile(hs.filepath)
        if (field = "tags")
            SaveHotstring(hs.filepath, hs.short, hs.options, hs.long, hs.category, hs.comment,
                ArrJoin(hs.aliases, ","), ts, ArrJoin(hs.apps, ","), newVal, hs.language, , hs.disabled ? 1 : 0,
                , IsObject(hs.customFields) ? hs.customFields : Map(), hs.url, _HsAlts(hs), _HsAltNames(hs))
        else
            SaveHotstring(hs.filepath, hs.short, hs.options, hs.long, newVal, hs.comment,
                ArrJoin(hs.aliases, ","), ts, ArrJoin(hs.apps, ","), ArrJoin(hs.tags, ","), hs.language, , hs.disabled ? 1 : 0,
                , IsObject(hs.customFields) ? hs.customFields : Map(), hs.url, _HsAlts(hs), _HsAltNames(hs))
        changedFiles[hs.filepath] := true
        changed++
    }
    ReloadPhrases()
    MsgBox changed " fras(er) uppdaterade."
}

; ── Maintenance: move phrases to right file ───────────────────────────────────
MaintAIMove() {
    global HS_ALL
    files := MaintFileList()
    if (files.Length < 2) {
        MsgBox "Behöver minst två filer."
        return
    }
    sel := MaintPickFiles(files)
    if (sel = "" || !IsObject(sel) || !sel.Length)
        return
    srcSet := Map()
    for p in sel
        srcSet[p] := true
    pool := []
    for hs in HS_ALL
        if (srcSet.Has(hs.filepath) && !AIExcluded(hs.filepath))
            pool.Push(hs)
    if (!pool.Length) {
        MsgBox "Inga fraser i de valda filerna."
        return
    }
    fileNames := [], nameToPath := Map()
    for f in files {
        fileNames.Push(f.name)
        nameToPath[StrLower(f.name)] := f.path
    }
    moves := [], total := pool.Length, i := 1
    while (i <= total) {
        batch := []
        Loop 25 {
            if (i > total)
                break
            batch.Push(pool[i])
            i++
        }
        ToolTip("AI placerar fraser… (" (i - 1) "/" total ")")
        try {
            res := AIPlacePhrases(batch, fileNames)
        } catch as e {
            ToolTip()
            MsgBox "AI-flytt misslyckades:`n`n" e.Message
            return
        }
        if (!res.Has("assignments"))
            continue
        for a in res["assignments"] {
            if (!a.Has("index") || !a.Has("file"))
                continue
            idx := a["index"]
            if (idx < 1 || idx > batch.Length)
                continue
            toName := Trim(a["file"])
            if (!nameToPath.Has(StrLower(toName)))
                continue
            hs := batch[idx]
            SplitPath(hs.filepath, &curName)
            if (StrLower(toName) = StrLower(curName))
                continue
            moves.Push({ hs: hs, toName: toName, toPath: nameToPath[StrLower(toName)] })
        }
    }
    ToolTip()
    if (!moves.Length) {
        MsgBox "AI föreslog inga flyttar."
        return
    }
    MaintReviewMoves(moves)
}

AIPlacePhrases(batch, fileNames) {
    sys := "Du sorterar textfraser till rätt fil efter BETYDELSE/ÄMNE. 'file' MÅSTE vara EXAKT ett av de listade filnamnen. Svara enbart enligt schemat."
    list := ""
    for i, hs in batch
        list .= i ". [" hs.short "] " StrReplace(SubStr(hs.long, 1, 200), "`n", " ") "`n"
    user := "Tillgängliga filer: " ArrJoin(fileNames, ", ") "`n`nFraser:`n" list
    schema := Map("type", "object",
        "properties", Map("assignments", Map("type", "array", "items",
            Map("type", "object",
                "properties", Map("index", Map("type", "integer"), "file", Map("type", "string")),
                "required", ["index", "file"], "additionalProperties", JSON._false))),
        "required", ["assignments"], "additionalProperties", JSON._false)
    return AIRequest(sys, user, schema)
}

MaintReviewMoves(moves) {
    rg := Gui("+AlwaysOnTop +Resize +OwnDialogs", "AI-flytt: granska")
    rg.SetFont("s10", "Segoe UI")
    rg.AddText("xm w620", "Rader med ☑ utförs när du klickar Tillämpa.")
    lv := rg.AddListView("xm y+8 w620 h300 +LV0x0004", ["✓", "Trigger", "Från fil", "→ Till fil"])
    for m in moves {
        SplitPath(m.hs.filepath, &fromName)
        lv.Add("Check", "", m.hs.short, fromName, m.toName)
    }
    lv.ModifyCol(1, 30), lv.ModifyCol(2, 160), lv.ModifyCol(3, 200), lv.ModifyCol(4, 200)
    lv.OnEvent("DoubleClick", (ctrl, row, *) => MaintEditMoveTarget(ctrl, row, moves))
    rg.AddText("xm y+4 w620 cGray", "Tips: dubbelklicka för att välja en annan målfil.")
    MaintAddCheckRow(rg, lv)
    state := { done: false }
    applyBtn := rg.AddButton("xm y+10 w160 Default", "Tillämpa flyttar")
    applyBtn.OnEvent("Click", (*) => (MaintApplyMoves(moves, lv), state.done := true, rg.Destroy()))
    cancelBtn := rg.AddButton("x+8 w100", "Avbryt")
    cancelBtn.OnEvent("Click", (*) => (state.done := true, rg.Destroy()))
    rg.OnEvent("Escape", (*) => (state.done := true, rg.Destroy()))
    rg.OnEvent("Close",  (*) => (state.done := true, rg.Destroy()))
    rg.Show()
    while (!state.done)
        Sleep 50
}

MaintApplyMoves(moves, lv) {
    global g_ColCol, g_Semi
    MaintBackupBegin()
    changedFiles := Map(), ts := FormatTime(, "yyyyMMddHHmmss"), done := 0
    r := 0
    while (r := lv.GetNext(r, "Checked")) {
        m  := moves[r]
        hs := m.hs
        if (hs.filepath = m.toPath)
            continue
        MaintBackupFile(hs.filepath)
        MaintBackupFile(m.toPath)
        RemoveHotstringFromFile(hs.filepath, hs.short)
        meta    := BuildMeta(hs.category, hs.comment, hs.language, ArrJoin(hs.tags, ","),
                             hs.disabled ? 1 : 0, 0, ArrJoin(hs.aliases, ","), ArrJoin(hs.apps, ","),
                             IsObject(hs.customFields) ? hs.customFields : Map(), hs.url, _HsAlts(hs), _HsAltNames(hs))
        newLine := "`n:" hs.options ":" hs.short g_ColCol Escape_CC(hs.long) " " g_Semi " " meta
        PhraseFileAppend(m.toPath, newLine)
        changedFiles[hs.filepath] := true
        changedFiles[m.toPath]    := true
        done++
    }
    ReloadPhrases()
    MsgBox done " fras(er) flyttade."
}

; ── Maintenance: semantic duplicates ─────────────────────────────────────────
MaintAISemanticDupes() {
    global HS_ALL
    files := MaintFileList()
    sel := MaintPickFiles(files)
    if (sel = "" || !IsObject(sel) || !sel.Length)
        return
    srcSet := Map()
    for p in sel
        srcSet[p] := true
    pool := []
    for hs in HS_ALL
        if (srcSet.Has(hs.filepath) && !AIExcluded(hs.filepath))
            pool.Push(hs)
    if (pool.Length < 2) {
        MsgBox "För få fraser."
        return
    }
    batchSize := 200, batched := (pool.Length > batchSize)
    groups := [], i := 1, total := pool.Length, failed := ""
    while (i <= total) {
        batch := [], offset := i - 1
        Loop batchSize {
            if (i > total)
                break
            batch.Push(pool[i])
            i++
        }
        ToolTip("AI letar semantiska dubbletter… (" (i - 1) "/" total ")")
        try {
            res := AISemanticDupes(batch)
        } catch as e {
            failed := e.Message
            break
        }
        if (res.Has("groups")) {
            for g in res["groups"] {
                if (!g.Has("indices"))
                    continue
                valid := []
                for idx in g["indices"]
                    if (idx >= 1 && idx <= batch.Length)
                        valid.Push(offset + idx)
                if (valid.Length >= 2)
                    groups.Push({ indices: valid, reason: g.Has("reason") ? g["reason"] : "" })
            }
        }
    }
    ToolTip()
    if (failed != "" && !groups.Length) {
        MsgBox "AI-sökningen misslyckades:`n`n" failed
        return
    }
    if (!groups.Length) {
        MsgBox "AI hittade inga semantiska dubbletter."
        return
    }
    if (failed != "")
        MsgBox "AI-sökningen avbröts:`n`n" failed "`n`n" groups.Length " grupp(er) hann hittas."
    MaintReviewDupes(pool, groups, batched)
}

AISemanticDupes(pool) {
    sys := "Du hittar SEMANTISKA dubbletter bland textfraser — grupper som betyder i princip "
         . "samma sak. Var KONSERVATIV. Svara enbart enligt schemat."
    list := ""
    for i, hs in pool
        list .= i ". " StrReplace(SubStr(hs.long, 1, 160), "`n", " ") "`n"
    user := "Fraser:`n" list
    schema := Map("type", "object",
        "properties", Map("groups", Map("type", "array", "items",
            Map("type", "object",
                "properties", Map(
                    "indices", Map("type", "array", "items", Map("type", "integer")),
                    "reason",  Map("type", "string")),
                "required", ["indices", "reason"], "additionalProperties", JSON._false))),
        "required", ["groups"], "additionalProperties", JSON._false)
    return AIRequest(sys, user, schema)
}

MaintReviewDupes(pool, groups, capped) {
    rg := Gui("+AlwaysOnTop +Resize +OwnDialogs", "AI: semantiska dubbletter")
    rg.SetFont("s10", "Segoe UI")
    rg.AddText("xm w640", "Bocka raderna som ska TAS BORT (förvalt: behåll första, ta bort resten).")
    lv := rg.AddListView("xm y+8 w640 h320 +LV0x0004", ["✓ ta bort", "Grupp", "Trigger", "Fras", "Fil"])
    rowHs := []
    gnum  := 1
    for g in groups {
        first := true
        for idx in g.indices {
            hs := pool[idx]
            SplitPath(hs.filepath, &fn)
            lv.Add(first ? "" : "Check", "", gnum, hs.short, StrReplace(SubStr(hs.long, 1, 90), "`n", " "), fn)
            rowHs.Push(hs)
            first := false
        }
        gnum++
    }
    lv.ModifyCol(1, 60), lv.ModifyCol(2, 45), lv.ModifyCol(3, 130), lv.ModifyCol(4, 310), lv.ModifyCol(5, 80)
    if (capped)
        rg.AddText("xm y+4 w640 cGray", "Obs: sökt i batchar om 200 fraser — dubbletter som ligger i olika batchar kan ha missats.")
    MaintAddCheckRow(rg, lv)
    state := { done: false }
    applyBtn := rg.AddButton("xm y+10 w180 Default", "Ta bort markerade")
    applyBtn.OnEvent("Click", (*) => (MaintApplyDupes(rowHs, lv), state.done := true, rg.Destroy()))
    cancelBtn := rg.AddButton("x+8 w100", "Avbryt")
    cancelBtn.OnEvent("Click", (*) => (state.done := true, rg.Destroy()))
    rg.OnEvent("Escape", (*) => (state.done := true, rg.Destroy()))
    rg.OnEvent("Close",  (*) => (state.done := true, rg.Destroy()))
    rg.Show()
    while (!state.done)
        Sleep 50
}

MaintApplyDupes(rowHs, lv) {
    n := 0, r := 0
    while (r := lv.GetNext(r, "Checked"))
        n++
    if (!n) {
        MsgBox "Inga rader markerade."
        return
    }
    if (MsgBox(n " fras(er) tas bort permanent. Fortsätt?", "Bekräfta", "YesNo") != "Yes")
        return
    MaintBackupBegin()
    changedFiles := Map(), done := 0
    r := 0
    while (r := lv.GetNext(r, "Checked")) {
        hs := rowHs[r]
        MaintBackupFile(hs.filepath)
        RemoveHotstringFromFile(hs.filepath, hs.short)
        changedFiles[hs.filepath] := true
        done++
    }
    ReloadPhrases()
    MsgBox done " fras(er) borttagna."
}

; ── Backup / undo ─────────────────────────────────────────────────────────────
MaintBackupBegin() {
    global g_lastBackup
    dir := A_ScriptDir "\_cleanup_backup"
    if DirExist(dir)
        Loop Files, dir "\*", "F"
            try FileDelete(A_LoopFileFullPath)
    g_lastBackup := { dir: dir, files: Map() }
}

MaintBackupFile(fp) {
    global g_lastBackup
    if (g_lastBackup = "" || !IsObject(g_lastBackup) || g_lastBackup.files.Has(fp) || !FileExist(fp))
        return
    if !DirExist(g_lastBackup.dir)
        DirCreate(g_lastBackup.dir)
    SplitPath(fp, &nm)
    bpath := g_lastBackup.dir "\" g_lastBackup.files.Count "_" nm
    try FileCopy(fp, bpath, true)
    g_lastBackup.files[fp] := bpath
}

MaintUndoAvailable() {
    global g_lastBackup
    return (g_lastBackup != "" && IsObject(g_lastBackup) && g_lastBackup.files.Count > 0)
}

MaintUndo() {
    global g_lastBackup
    if !MaintUndoAvailable() {
        MsgBox "Ingen städning att ångra."
        return
    }
    if (MsgBox(g_lastBackup.files.Count " fil(er) återställs. Fortsätt?", "Ångra städning", "YesNo") != "Yes")
        return
    n := 0
    for orig, bak in g_lastBackup.files
        if FileExist(bak) {
            try FileCopy(bak, orig, true)
            n++
        }
    g_lastBackup := ""
    MsgBox n " fil(er) återställda. Appen laddas om."
    Reload()
}

; ── Maintenance GUI helpers ───────────────────────────────────────────────────
MaintFileList() {
    global HS_ALL
    seen := Map()
    out  := []
    for hs in HS_ALL {
        if (!seen.Has(hs.filepath)) {
            seen[hs.filepath] := true
            if (!AIExcluded(hs.filepath)) {
                SplitPath(hs.filepath, &nm)
                out.Push({ path: hs.filepath, name: nm })
            }
        }
    }
    return out
}

MaintPickFiles(files) {
    pg := Gui("+AlwaysOnTop +OwnDialogs", "Välj filer")
    pg.SetFont("s10", "Segoe UI")
    pg.AddText("xm w460", "Markera filerna som ska bearbetas av AI.")
    lv := pg.AddListView("xm y+8 w460 h280 +LV0x0004", ["Fil"])
    for f in files
        lv.Add("Check", f.name)
    lv.ModifyCol(1, 440)
    sel := [], state := { done: false, ok: false }
    finish(isOk, *) {
        if (isOk) {
            r := 0
            while (r := lv.GetNext(r, "Checked"))
                sel.Push(files[r].path)
        }
        state.ok := isOk, state.done := true
        pg.Destroy()
    }
    pg.AddButton("xm y+10 w120 Default", "Fortsätt").OnEvent("Click", finish.Bind(true))
    pg.AddButton("x+8 w100",             "Avbryt"  ).OnEvent("Click", finish.Bind(false))
    pg.AddButton("x+8 w80",              "Alla"    ).OnEvent("Click", (*) => MaintCheckAll(lv, true))
    pg.AddButton("x+6 w80",              "Ingen"   ).OnEvent("Click", (*) => MaintCheckAll(lv, false))
    pg.OnEvent("Escape", finish.Bind(false))
    pg.OnEvent("Close",  finish.Bind(false))
    pg.Show()
    while (!state.done)
        Sleep 30
    return state.ok ? sel : ""
}

MaintCheckAll(lv, on) {
    Loop lv.GetCount()
        lv.Modify(A_Index, on ? "Check" : "-Check")
}

MaintLVSet(lv, action) {
    if (action = "invert") {
        chk := Map(), r := 0
        while (r := lv.GetNext(r, "Checked"))
            chk[r] := true
        Loop lv.GetCount()
            lv.Modify(A_Index, chk.Has(A_Index) ? "-Check" : "Check")
    } else
        Loop lv.GetCount()
            lv.Modify(A_Index, action = "all" ? "Check" : "-Check")
}

MaintAddCheckRow(gui, lvs*) {
    gui.AddText("xm y+8 w55 +0x200", "Bocka:")
    gui.AddButton("x+4 yp-4 w64", "Alla"    ).OnEvent("Click", (*) => MaintCheckRowApply(lvs, "all"))
    gui.AddButton("x+4 yp w64",   "Inga"    ).OnEvent("Click", (*) => MaintCheckRowApply(lvs, "none"))
    gui.AddButton("x+4 yp w80",   "Invertera").OnEvent("Click", (*) => MaintCheckRowApply(lvs, "invert"))
}

MaintCheckRowApply(lvs, action) {
    for lv in lvs
        MaintLVSet(lv, action)
}

MaintEditCanonical(lv, row) {
    if (row < 1) {
        return
    }
    cur := lv.GetText(row, 3)
    ib  := InputBox("Slå ihop till (kanoniskt namn):", "Redigera mål", "w340 h130", cur)
    if (ib.Result = "OK" && Trim(ib.Value) != "")
        lv.Modify(row, , lv.GetText(row, 1), lv.GetText(row, 2), Trim(ib.Value))
}

MaintEditMoveTarget(lv, row, moves) {
    if (row < 1 || row > moves.Length) {
        return
    }
    m := Menu()
    for f in MaintFileList()
        m.Add(f.name, ((nm, pth, *) => MaintSetMoveTarget(lv, row, moves, nm, pth)).Bind(f.name, f.path))
    m.Show()
}

MaintSetMoveTarget(lv, row, moves, name, path) {
    moves[row].toName := name
    moves[row].toPath := path
    lv.Modify(row, , lv.GetText(row, 1), lv.GetText(row, 2), lv.GetText(row, 3), name)
}
