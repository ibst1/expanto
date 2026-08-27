; Expanto — v1.1.0 — AutoHotkey v2 hotstring manager with a WebView2 UI
#Requires AutoHotkey v2.0
#SingleInstance Force

; Per-monitor-DPI v2: utan detta låses skalan vid processtart, och när en
; skärm med annan skala kopplas in/ur bitmap-sträcks fönstret - fel skärpa
; och WebView2-klick som hamnar bredvid pekaren. Måste sättas före första
; fönstret. WM_DPICHANGED tar systemets föreslagna rect; Size-eventet
; storleksändrar sedan WebView2-ytan.
; OBS: process-nivån är LÅST av AutoHotkeys manifest (SYSTEM_AWARE) -
; SetProcessDpiAwarenessContext ger ACCESS_DENIED. Trådnivån går dock att
; ändra, och fönster ärver trådens kontext när de skapas. AHK kör allt på
; en enda OS-tråd, så ett anrop här täcker alla fönster skriptet skapar.
DllCall("SetThreadDpiAwarenessContext", "ptr", -4)

; Krascher ska lämna spår: utan OnError dör skriptet med en dialog och noll
; forensik. Loggar till error.log bredvid skriptet och låter tråden avslutas
; (returnerar 1 = ingen dialog) - resten av appen lever vidare.
OnError(_LogError)
_LogError(e, mode) {
    try FileAppend(FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") "  " e.Message
        . " (" e.File ":" e.Line ")" (e.Extra != "" ? "  [" e.Extra "]" : "") "`r`n"
        , A_ScriptDir "\error.log", "UTF-8")
    return 1
}
OnMessage(0x02E0, _WmDpiChanged)
_WmDpiChanged(wParam, lParam, msg, hwnd) {
    global wv2Ctrl
    x := NumGet(lParam, 0, "int"), y := NumGet(lParam, 4, "int")
    r := NumGet(lParam, 8, "int"), b := NumGet(lParam, 12, "int")
    DllCall("SetWindowPos", "ptr", hwnd, "ptr", 0, "int", x, "int", y
        , "int", r - x, "int", b - y, "uint", 0x0214)   ; NOZORDER|NOACTIVATE|FRAMECHANGED
    try SetTimer(() => ((IsSet(wv2Ctrl) && IsObject(wv2Ctrl)) ? wv2Ctrl.Fill() : 0), -80)   ; hängslen: fyll om WebView2-ytan
    return 0
}

try
    TraySetIcon(A_ScriptDir "\app.ico")

; CapsLock suppression is registered dynamically in InitGlobalHotkeys based on the
; "Läs CapsLock själv" setting — disable it if another script already handles CapsLock.

!f5::Reload()  ; Dev hotkey

; ── Libraries ────────────────────────────────────────────────────────────────
#Include "lib\WebView2.ahk"
#Include "lib\JSON.ahk"
#Include "lib\fuzzysearch.ahk"
#Include "lib\ai_wv2.ahk"
#Include "lib\local_llm.ahk"
#Include "lib\enc_phrases.ahk"

; ── Core globals (matching the legacy native build) ──────────────────────────
global inifile  := A_AppData "\Expanto\settings.ini"
; Fresh machine: the settings folder must exist before any IniWrite (IniWrite
; cannot create directories — first run failed on "Hoppa över" without this)
if !DirExist(A_AppData "\Expanto")
    try DirCreate(A_AppData "\Expanto")
global g_ColCol := Chr(58) . Chr(58)
global g_Semi   := Chr(59)

global HS_folders_ALL    := []
global HS_ALL            := []
global g_disabledFolders := []
global g_hiddenFolders   := []   ; loaded but hidden from the file list
global g_ignoreFolders   := []   ; subfolder names skipped when scanning a phrase folder
global g_pendingRuns     := []   ; {run:...} commands awaiting execution after an insert
global g_runApproved     := Map()  ; {run:...} commands confirmed by the user this session
global g_wv2Shown        := true
global g_prevWinId       := 0    ; hwnd of active window before Expanto was shown
global g_hkOpenGui       := ""   ; currently registered OpenGui hotkey string
global g_hkUndo          := ""   ; currently registered Undo hotkey string
global g_hkMarkWord      := ""
global g_markWordActive  := false  ; true while stepping backward with MarkWord hotkey
global g_wv2Ready        := false  ; set true on NavigationCompleted, false on ProcessFailed
global g_hkLastFired     := ""
global g_hkInsert        := ""   ; global hotkey: insert selected phrase
global g_hkInsertStep    := ""   ; global hotkey: insert selected phrase (step-through)
global g_selectedId      := ""   ; phrase ID last selected in the GUI
global g_hkGuiMap        := Map()  ; name → registered key for GUI-specific hotkeys
global g_dictPaths        := []
global g_compoundEnabled  := false
global g_compoundMinLen   := 12
global g_dynAppModes      := []   ; array of Maps {app, mode}
global g_fileMtimes       := Map() ; path → last-known mtime for file watcher
global g_folderMtimes     := Map() ; folder path → mtime for new-file detection
global g_lastSaveTimes    := Map() ; path → A_TickCount when Expanto last wrote it
global g_uiLang           := "sv"  ; "sv" or "en" — pushed from JS on ready/setLang
global g_firstRun         := !FileExist(inifile)

; ── Step-through globals ───────────────────────────────────────────────────────
global g_stepSegments     := []   ; phrase segments for current step-through (array of Maps {header,body})
global g_stepIdx          := 0    ; 1-based index of last pasted segment (0 = inactive)
global g_stepLabels       := []   ; label names loaded from INI (legacy | system)
global g_stepKey          := ""   ; hotkey string for legacy StepNext
global g_stepPrevKey      := ""   ; keyboard twin of the popup's "◄ Föregående"
global g_stepHs           := ""   ; hs object for undo reference
global g_stepKeepHeaders  := false ; popup toggle: keep section headers when inserting
global g_stepKeepSpacing  := true  ; popup toggle: blank line between inserted steps
global g_stepPopup        := unset

; ── Undo popup ────────────────────────────────────────────────────────────────
global g_undoPopup := unset

; ── Usage tracking ────────────────────────────────────────────────────────────
global g_usageMap  := Map()   ; phraseId → ISO timestamp of last use
global g_usageFile := ""      ; path to usage JSON log

; ── Per-file hotstring / hint settings ────────────────────────────────────────
global g_fileHsOff    := []   ; fullpaths where hotstrings are disabled
global g_fileHintTOff := []   ; fullpaths where trigger-hints are disabled
global g_fileHintPOff := []   ; fullpaths where phrase-hints are disabled

; ── Expansion globals ─────────────────────────────────────────────────────────
global g_pasteMode   := StrLower(IniRead(inifile, "dynamic", "paste_mode",    "auto"))
global g_pasteMinLen := IniRead(inifile, "dynamic", "paste_min_len", 30) + 0
; Diagnostic line per expansion (see _InsertLog): trigger, sizes and timings only —
; never phrase text or window titles. [Debug] insert_log=0 in the ini turns it off.
global g_insertLog   := IniRead(inifile, "Debug", "insert_log", 0) + 0
global g_dbgPhase    := ""   ; per-expansion timing breakdown, emptied by each HsFire
; The clipboard backup is the most expensive step of a paste insert. Cache it against
; the OS clipboard sequence number: after we restore our own backup the clipboard is
; byte-for-byte what we saved, so the next paste can skip ClipboardAll entirely — and
; a heavy hotstring user pastes many times between actual copies.
global g_clipSeq     := 0
global g_clipSaved   := ""
global g_clipText    := ""   ; text form of the cached snapshot, re-checked before reuse
global g_dynMode     := IniRead(inifile, "dynamic", "mode",          "auto")
global g_lastFired   := ""
global g_lastSent    := ""
global g_lastCaretBack := 0
global g_typedBuf    := ""

; ── Coupled dynamic fields (per-key value memory; RAM only) ───────────────────
global g_coupleMem      := Map()   ; field → Map(keyValue → value)
global g_coupleIdentity := ""      ; identity value (e.g. a customer number) of the current context
global g_coupleIdName   := ""      ; display name held for the current identity (for the safety prompt)
global g_coupleVolatile := Map()   ; field → true for "today"/"clipboard" sourced fields (cleared on identity change)
global g_coupleLastTick := 0       ; A_TickCount of the last resolve, to gate the identity-switch warning
global g_coupleCfgCache := Map()   ; filepath → parsed coupling config (cleared on reload)

; ── Hint popup globals ────────────────────────────────────────────────────────
global g_hintsEnabled := IniRead(inifile, "Popup", "Enabled", 1) != "0"
global g_hintTriggers := []
global g_hintWords    := []
global g_hintGui      := ""
global g_hintLV       := ""
global g_hintMatches  := []
global g_hintSuppressed := false
global g_hintWord     := ""
global g_hintMinLen   := Integer(IniRead(inifile, "Popup", "Chars",   2))
global g_hintTimeout  := Integer(IniRead(inifile, "Popup", "Timeout", 5))
global g_hintPinned   := false   ; set once the user navigates the popup — no auto-close until hidden
global g_hintMaxRows  := 8
global g_hintFuzzy    := IniRead(inifile, "Popup", "Fuzzy", 0) != "0"
global g_hintInsertKey := ""
global g_hintUpKey     := ""
global g_hintDownKey   := ""
global g_hintNumMod    := ""

; ── Load phrase data + register hotstrings ────────────────────────────────────
LoadDisabledFolders()
LoadHiddenFolders()
LoadIgnoreFolders()
populate_HS_files_ALL()
Build_HS_ALL()
init_hotstrings()
FileWatcherInit()
LoadAISettings()
LoadLLMSettings()
LoadFileSettings()   ; must run before BuildHintIndex so per-file hint flags are respected
BuildHintIndex()
LoadDictSettings()
LoadPopupSettings()
LoadDynamicSettings()
InitStepKey()
InitGlobalHotkeys()
LoadUsage()
StartTypedBuffer()
CreateHintPopup()
LoadPopupHotkeys()

; ── AHK-side i18n (strings that can't go through the JS T() system) ──────────
_AT(key) {
    global g_uiLang
    static tbl := Map(
        "undo.none",       ["Inget att ångra",              "Nothing to undo"],
        "watcher.updated", ["Frasfil uppdaterad externt ↺", "Phrase file updated externally ↺"],
        "prompt.title",    ["Fyll i fält",                  "Fill in fields"],
        "prompt.cancel",   ["Avbryt",                       "Cancel"],
        "altpick.title",   ["Välj frastext",                "Choose phrase text"],
        "dup.dyn.title",   ["Dynamiska fält",               "Dynamic fields"],
        "dup.dyn.body",    ["Den här frasen innehåller dynamiska fält.`n`nVill du fylla i fälten nu?`n`nJa = fyll i värden    Nej = duplicera med tomma fält",
                            "This phrase contains dynamic fields.`n`nDo you want to fill them in now?`n`nYes = enter values    No = duplicate with empty fields"],
        "tray.show",       ["Visa Expanto",                 "Show Expanto"],
        "tray.reload",     ["Ladda om fraser",              "Reload phrases"],
        "tray.reloadapp",  ["Ladda om appen",                 "Reload app"],
        "tray.unlock",     ["🔓 Lås upp krypterade filer",  "🔓 Unlock encrypted files"],
        "tray.exit",       ["Avsluta",                      "Exit"],
        "url.title",       ["Länk till frasen",             "Phrase link"],
        "url.body",        ["Den här frasen har en länk:",  "This phrase has a link:"],
        "url.openLink",    ["Öppna länk",                   "Open link"],
        "url.openFile",    ["Öppna fil",                    "Open file"],
        "url.openFolder",  ["Öppna mapp",                   "Open folder"],
        "url.close",       ["Stäng",                        "Close"],
        "url.failed",      ["Kunde inte öppna:",            "Could not open:"],
        "run.confirm",     ["Frasen vill köra det här kommandot:", "The phrase wants to run this command:"],
        "run.fail",        ["Kunde inte köra:",             "Could not run:"],
    )
    if tbl.Has(key)
        return (g_uiLang = "en") ? tbl[key][2] : tbl[key][1]
    return key
}

_RebuildTrayMenu() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add(_AT("tray.show"),   (*) => ShowWv2Win())
    A_TrayMenu.Add(_AT("tray.reload"), (*) => ReloadPhrases())
    A_TrayMenu.Add(_AT("tray.reloadapp"), (*) => Reload())
    if (EncLoaded() && _HasLockedEncFiles()) {
        A_TrayMenu.Add()
        A_TrayMenu.Add(_AT("tray.unlock"), (*) => EncUnlock())
    }
    A_TrayMenu.Add()
    A_TrayMenu.Add(_AT("tray.exit"),   (*) => ExitApp())
    A_TrayMenu.Default := _AT("tray.show")
}

; True while the session is locked (no password) and at least one .enc phrase
; file exists — the only state where the tray unlock item is meaningful.
_HasLockedEncFiles() {
    global g_encPw, HS_folders_ALL
    if (g_encPw != "")
        return false
    for folder in HS_folders_ALL
        for file in folder.files
            if IsEncPhrasePath(file.fullpath)
                return true
    return false
}

; ── Tray menu ─────────────────────────────────────────────────────────────────
_RebuildTrayMenu()
OnMessage(0x404, OnTrayClick)   ; WM_TRAYICON — double-click opens window

OnTrayClick(wParam, lParam, *) {
    if (lParam = 0x203) {        ; WM_LBUTTONDBLCLK
        ShowWv2Win()
        if IsSet(wv2Core)
            _SafeSend(wv2Core, "window.openForSearch()")
    }
}

ShowWv2Win() {
    global wv2Win, wv2Ctrl, g_wv2Shown
    wv2Win.Show()
    g_wv2Shown := true
    ; When the window was hidden at startup (StartMinimized), WebView2 may have
    ; deferred rendering. Fill() re-syncs bounds and wakes up the renderer.
    if IsSet(wv2Ctrl)
        wv2Ctrl.Fill()
}

ReloadPhrases(sendInitData := true) {
    global wv2Core, g_wv2Ready, g_coupleCfgCache
    g_coupleCfgCache := Map()
    LoadDisabledFolders()
    populate_HS_files_ALL()
    Build_HS_ALL()
    init_hotstrings()
    BuildHintIndex()
    FileWatcherInit()
    _RebuildTrayMenu()
    if (IsSet(wv2Core) && g_wv2Ready && sendInitData) {
        _SafeSend(wv2Core,"window.initData(" BuildPhrasesJson() ")")
        _SafeSend(wv2Core,"window.receiveEncStatus(" BuildEncStatusJson() ")")
    }
}

; ── Gui window ────────────────────────────────────────────────────────────────
; Set unique AppUserModelID before any window is created so the taskbar button
; gets its own group with the correct icon rather than sharing AutoHotkey.exe's.
DllCall("shell32\SetCurrentProcessExplicitAppUserModelID", "str", "Expanto.Application.1")
global wv2Win := Gui("+Resize +MinSize600x400", "Expanto")
wv2Win.OnEvent("Close", (*) => (wv2Win.Hide(), g_wv2Shown := false))
wv2Win.OnEvent("Size",  OnWinResize)

; Always show with a real size first — WebView2 needs a properly-sized, visible
; window for Fill() to work. We hide it afterward if StartMinimized is set.
wv2Win.Show("w1200 h720")
InitGuiHotkeys()

; Dark title bar
DllCall("dwmapi\DwmSetWindowAttribute", "ptr", wv2Win.hwnd, "uint", 20, "int*", 1, "uint", 4)

; ── Create WebView2 controller ────────────────────────────────────────────────
global wv2Ctrl := WebView2.create(
    wv2Win.hwnd,          ; parent HWND
    ,                     ; no callback → synchronous .await()
    0,                    ; no pre-created environment
    "",                   ; default data dir
    "",                   ; auto-detect Edge runtime
    0,                    ; no environment options
    A_ScriptDir "\lib\WebView2Loader.dll"
)
wv2Ctrl.Fill()           ; size WebView2 to fill the window client area

; ── Set window icon + taskbar button icon ────────────────────────────────────
_iconPath := A_ScriptDir "\app.ico"
if FileExist(_iconPath)
    TraySetIcon(_iconPath)
ApplyWindowIcon()
SetWindowAppId(wv2Win.hwnd, "Expanto.Application.1", FileExist(_iconPath) ? _iconPath : "")
SetTimer(ApplyWindowIcon, -1000)  ; re-apply after 1 s when Chromium has fully settled


global wv2Core := wv2Ctrl.CoreWebView2
ApplyDictionaries()

; ── Wire up events before navigating ─────────────────────────────────────────
wv2Core.add_NavigationCompleted(OnNavigationCompleted)
wv2Core.add_WebMessageReceived(OnWebMessageReceived)
wv2Core.add_ProcessFailed(OnProcessFailed)

; ── Navigate to local UI ──────────────────────────────────────────────────────
wv2Core.Navigate("file:///" StrReplace(A_ScriptDir "\ui\index.html", "\", "/"))

; ── Apply StartMinimized after WebView2 is fully set up ──────────────────────
if IniRead(inifile, "General", "StartMinimized", "0") != "0" {
    wv2Win.Hide()
    g_wv2Shown := false
}

; ── Remember the last active non-Expanto window continuously, so a direct insert
;    (e.g. double-clicking a phrase) can return focus to it even when Expanto was
;    reached by Alt-Tab / clicking rather than via its hotkey. ──────────────────
SetTimer(TrackPrevWin, 250)

; ── Global hotkeys registered dynamically — see InitGlobalHotkeys() ──────────

; ── Step-through: Escape cancels active step ──────────────────────────────────
#HotIf StepActive()
Escape:: ClearStepState()
#HotIf

; Hint popup navigation hotkeys are registered dynamically — see LoadPopupHotkeys()

; ══════════════════════════════════════════════════════════════════════════════
; Event handlers
; ══════════════════════════════════════════════════════════════════════════════

ApplyWindowIcon() {
    global wv2Win
    iconPath := A_ScriptDir "\app.ico"
    if !FileExist(iconPath)
        return
    hBig := 0, hSmall := 0
    DllCall("Shell32\ExtractIconEx", "str", iconPath, "int", 0,
        "ptr*", &hBig, "ptr*", &hSmall, "uint", 1)
    if !hBig
        return
    ; Set instance icon (WM_SETICON: 1=big, 0=small)
    DllCall("SendMessage", "ptr", wv2Win.hwnd, "uint", 0x80, "uptr", 1, "ptr", hBig)
    if hSmall
        DllCall("SendMessage", "ptr", wv2Win.hwnd, "uint", 0x80, "uptr", 0, "ptr", hSmall)
    ; Also replace the window CLASS icon so WebView2 can't revert it
    DllCall("SetClassLongPtr", "ptr", wv2Win.hwnd, "int", -14, "ptr", hBig)    ; GCLP_HICON
    if hSmall
        DllCall("SetClassLongPtr", "ptr", wv2Win.hwnd, "int", -34, "ptr", hSmall) ; GCLP_HICONSM
    ; Force non-client repaint
    DllCall("SetWindowPos", "ptr", wv2Win.hwnd, "ptr", 0,
        "int", 0, "int", 0, "int", 0, "int", 0,
        "uint", 0x27)  ; SWP_NOSIZE|SWP_NOMOVE|SWP_NOZORDER|SWP_FRAMECHANGED
}

SetWindowAppId(hwnd, appId, iconPath := "") {
    try {
        local iid := Buffer(16, 0)
        DllCall("ole32\CLSIDFromString", "str", "{886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99}", "ptr", iid)
        local pStore := 0
        DllCall("shell32\SHGetPropertyStoreForWindow", "ptr", hwnd, "ptr", iid, "ptr*", &pStore)
        if !pStore
            return

        ; PKEY_AppUserModel_ID (pid=5)
        local pk5 := Buffer(20, 0)
        DllCall("ole32\CLSIDFromString", "str", "{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}", "ptr", pk5)
        NumPut("uint", 5, pk5, 16)
        local pv5 := Buffer(24, 0)
        NumPut("ushort", 0x1F, pv5, 0)
        NumPut("ptr", StrPtr(appId), pv5, 8)
        ComCall(6, pStore, "ptr", pk5, "ptr", pv5)

        ; PKEY_AppUserModel_RelaunchIconResource (pid=3) — taskbar button icon
        if (iconPath != "") {
            local iconRes := iconPath ",0"
            local pk3 := Buffer(20, 0)
            DllCall("ole32\CLSIDFromString", "str", "{9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3}", "ptr", pk3)
            NumPut("uint", 3, pk3, 16)
            local pv3 := Buffer(24, 0)
            NumPut("ushort", 0x1F, pv3, 0)
            NumPut("ptr", StrPtr(iconRes), pv3, 8)
            ComCall(6, pStore, "ptr", pk3, "ptr", pv3)
        }

        ComCall(7, pStore)  ; IPropertyStore::Commit
        ObjRelease(pStore)
    }
}

OnWinResize(g, minMax, w, h) {
    global wv2Ctrl
    if (minMax = -1 || !IsSet(wv2Ctrl))
        return
    wv2Ctrl.Fill()
}

OnNavigationCompleted(sender, args) {
    global g_wv2Ready, g_hkMarkWord, g_firstRun
    g_wv2Ready := true
    if (g_hkMarkWord != "")
        try Hotkey(g_hkMarkWord, "On")
    _SafeSend(sender,"window.initData(" BuildPhrasesJson() ")")
    _SafeSend(sender,"window.receiveEncStatus(" BuildEncStatusJson() ")")
    _SafeSend(sender,"window.receiveAiSettings(" BuildAISettingsJson() ")")
    _SafeSend(sender,"window.receiveDictSettings(" BuildDictSettingsJson() ")")
    _SafeSend(sender,"window.receiveHotkeySettings(" BuildHotkeySettingsJson() ")")
    _SafeSend(sender,"window.receivePopupSettings(" BuildPopupSettingsJson() ")")
    _SafeSend(sender,"window.receiveDynamicSettings(" BuildDynamicSettingsJson() ")")
    if (g_firstRun)
        _SafeSend(sender, "window.showFirstRun(" BuildFirstRunJson() ")")
    ApplyWindowIcon()
}

OnProcessFailed(sender, args) {
    global g_wv2Ready, g_hkMarkWord, wv2Core
    g_wv2Ready := false
    wv2Core := 0   ; replace dead COM proxy so _SafeSend's IsObject guard blocks any pending calls
    if (g_hkMarkWord != "")
        try Hotkey(g_hkMarkWord, "Off")
    local kind := 1
    try kind := args.ProcessFailedKind
    if (kind = 0)
        SetTimer(ReinitWebView2, -3000)
}

ReinitWebView2() {
    global wv2Core, wv2Ctrl, wv2Win, g_hkMarkWord
    wv2Core := 0   ; nullify before releasing old ctrl so no dangling COM pointer
    try {
        wv2Ctrl := WebView2.create(wv2Win.hwnd, , 0, "", "", 0, A_ScriptDir "\lib\WebView2Loader.dll")
        wv2Ctrl.Fill()
        wv2Core := wv2Ctrl.CoreWebView2
        wv2Core.add_NavigationCompleted(OnNavigationCompleted)
        wv2Core.add_WebMessageReceived(OnWebMessageReceived)
        wv2Core.add_ProcessFailed(OnProcessFailed)
        ApplyDictionaries()
        wv2Core.Navigate("file:///" StrReplace(A_ScriptDir "\ui\index.html", "\", "/"))
    } catch {
        if (g_hkMarkWord != "")
            try Hotkey(g_hkMarkWord, "On")
    }
}

OnWebMessageReceived(sender, args) {
    global g_ColCol, g_Semi, g_dictPaths, g_wv2Ready
    if (!g_wv2Ready)
        return
    raw := args.WebMessageAsJson
    try
        msg := JSON.Load(raw)
    catch
        return

    if !msg.Has("action")
        return
    action := msg["action"]

    if (action = "ready") {
        global g_uiLang
        if msg.Has("lang") && (msg["lang"] = "en" || msg["lang"] = "sv")
            g_uiLang := msg["lang"]
        _RebuildTrayMenu()
        _SafeSend(sender,"window.initData(" BuildPhrasesJson() ")")
        _SafeSend(sender,"window.receiveAiSettings(" BuildAISettingsJson() ")")
        _SafeSend(sender,"window.receiveEncStatus(" BuildEncStatusJson() ")")
        _SafeSend(sender,"window.receiveDictSettings(" BuildDictSettingsJson() ")")
        _SafeSend(sender,"window.receiveHotkeySettings(" BuildHotkeySettingsJson() ")")
        _SafeSend(sender,"window.receivePopupSettings(" BuildPopupSettingsJson() ")")
        _SafeSend(sender,"window.receiveDynamicSettings(" BuildDynamicSettingsJson() ")")

    } else if (action = "save") {
        global g_markWordActive, wv2Win, g_wv2Shown
        g_markWordActive := false
        p := msg["phrase"]
        if (msg.Has("insertAfterSave") && msg["insertAfterSave"]) {
            rawText := msg.Has("insertText") ? msg["insertText"] : ""
            pFile := p["file"]
            if (rawText != "") {
                ; Insert first (instant) — file I/O deferred so it never blocks the insert
                g_wv2Shown := false
                wv2Win.Hide()
                SetTimer(() => DoDirectInsertRaw(rawText), -1)
                SetTimer(() => _DeferredSave(p, pFile), -3000)
            } else if (IsObject(hs := FindHsById(p["id"]))) {
                ; Patch the in-memory phrase and insert IMMEDIATELY — the file
                ; write (SavePhraseFromJs) used to run first and stalled the
                ; insert noticeably on slow/synced disks
                hs.long         := Escape_CC(p["phrase"])
                hs.alts         := p.Has("alts") && IsObject(p["alts"]) ? p["alts"] : []
                hs.altNames     := p.Has("altNames") && IsObject(p["altNames"]) ? p["altNames"] : []
                if p.Has("customFields")
                    hs.customFields := p["customFields"]
                g_wv2Shown := false
                wv2Win.Hide()
                oldId := p["id"]
                SetTimer(() => DoDirectInsert(oldId), -1)
                SetTimer(() => _DeferredSave(p, pFile), -3000)
            } else {
                SavePhraseFromJs(p)
                g_wv2Shown := false
                wv2Win.Hide()
                newId := pFile "|" Trim(p["trigger"])
                SetTimer(() => DoDirectInsert(newId), -1)
                SetTimer(() => _RebuildAndNotify(pFile), -3000)
            }
        } else {
            SavePhraseFromJs(p)
            RebuildAndReload(p["file"])
            if (msg.Has("propagate") && ApplyPropagations(p["file"], msg["propagate"]))
                RebuildAndReload(p["file"])   ; reload again if group-mates were updated
            _SafeSend(sender, "window.initData(" BuildPhrasesJson() ")")
        }

    } else if (action = "delete") {
        id := msg["id"]
        hs := FindHsById(id)
        if !hs
            return
        RemoveHotstringFromFile(hs.filepath, hs.short)
        RebuildAndReload(hs.filepath)
        _SafeSend(sender,"window.initData(" BuildPhrasesJson() ")")

    } else if (action = "restorePhrase") {
        d := msg["data"]
        target  := d["file"]
        trigger := d["trigger"]
        phrase  := d["phrase"]
        opts    := d.Has("options") ? d["options"] : ""
        cat     := d.Has("cat")     ? d["cat"]     : ""
        comment := d.Has("comment") ? d["comment"] : ""
        lang    := d.Has("lang")    ? d["lang"]    : ""
        tags    := d.Has("tags")    ? d["tags"]    : ""
        aliases := d.Has("aliases") ? d["aliases"] : ""
        apps    := d.Has("apps")    ? d["apps"]    : ""
        cf      := d.Has("customFields") ? d["customFields"] : Map()
        dis     := d.Has("disabled") ? d["disabled"] : 0
        url     := d.Has("url") ? d["url"] : ""
        alts    := d.Has("alts") ? d["alts"] : ""
        altNm   := d.Has("altNames") ? d["altNames"] : ""
        newLine := BuildPhraseLine(opts, trigger, phrase, cat, comment, lang, tags
                                 , dis, aliases, apps, cf, url, alts, altNm)
        PhraseFileAppend(target, "`n" newLine)
        RebuildAndReload(target)
        _SafeSend(sender,"window.initData(" BuildPhrasesJson() ")")

    } else if (action = "bulkDelete") {
        ids := msg.Has("ids") ? msg["ids"] : []
        changedFiles := Map()
        for id in ids {
            hs := FindHsById(id)
            if !IsObject(hs)
                continue
            RemoveHotstringFromFile(hs.filepath, hs.short)
            changedFiles[hs.filepath] := true
        }
        for fp in changedFiles
            RebuildAndReload(fp)
        _SafeSend(sender,"window.initData(" BuildPhrasesJson() ")")

    } else if (action = "new") {
        target := msg.Has("file") ? msg["file"] : FirstWritableFile()
        if (target = "") {
            _SafeSend(sender,"alert('Ingen skrivbar frasfil hittades.')")
            return
        }
        trigger := msg["trigger"]
        phrase  := msg["phrase"]
        opts    := msg.Has("options") ? msg["options"] : ""
        cat     := msg.Has("cat")     ? msg["cat"]     : ""
        lang    := msg.Has("lang")    ? msg["lang"]    : ""
        comment := msg.Has("comment") ? msg["comment"] : ""
        tags    := msg.Has("tags")    ? msg["tags"]    : ""
        aliases := msg.Has("aliases")      ? msg["aliases"]      : ""
        apps    := msg.Has("apps")         ? msg["apps"]         : ""
        cf      := msg.Has("customFields") ? msg["customFields"] : Map()
        url     := msg.Has("url") ? msg["url"] : ""
        alts    := msg.Has("alts") ? msg["alts"] : ""
        altNm   := msg.Has("altNames") ? msg["altNames"] : ""
        newLine := BuildPhraseLine(opts, trigger, phrase, cat, comment, lang, tags
                                 , 0, aliases, apps, cf, url, alts, altNm)
        PhraseFileAppend(target, "`n" newLine)
        ; If this is a move, delete from source file now (fast); rebuild deferred
        moveFile := ""
        if (msg.Has("_moveSourceId") && msg["_moveSourceId"] != "") {
            srcHs := FindHsById(msg["_moveSourceId"])
            if IsObject(srcHs) {
                RemoveHotstringFromFile(srcHs.filepath, srcHs.short)
                moveFile := srcHs.filepath
            }
        }
        aiAuto := msg.Has("aiAuto") && msg["aiAuto"]
        if (msg.Has("insertAfterSave") && msg["insertAfterSave"]) {
            rawText := msg.Has("insertText") ? msg["insertText"] : ""
            if (rawText != "") {
                global wv2Win, g_wv2Shown
                g_wv2Shown := false
                wv2Win.Hide()
                SetTimer(() => DoDirectInsertRaw(rawText), -1)
                SetTimer(() => _RebuildAndNotify(target, moveFile), -3000)
            } else {
                ; Parse only this file into memory (no hotstring re-registration
                ; yet) so the insert starts immediately — the full rebuild used
                ; to re-register EVERY hotstring before inserting
                RebuildFileSimple(target)
                g_wv2Shown := false
                wv2Win.Hide()
                newId := target "|" trigger
                SetTimer(() => DoDirectInsert(newId), -1)
                SetTimer(() => _RebuildAndNotify(target, moveFile), -3000)
            }
        } else {
            RebuildAndReload(target)
            if (moveFile != "")
                RebuildAndReload(moveFile)
            _SafeSend(sender, "window.initData(" BuildPhrasesJson() ")")
        }
        if (aiAuto)
            SetTimer(() => _AIAutoFillNew(target, trigger), -3500)

    } else if (action = "movePhrase") {
        hs := FindHsById(msg["id"])
        if !IsObject(hs) {
            _SafeSend(sender, "alert('Fras hittades inte.')")
            return
        }
        targetFile := msg["targetFile"]
        if (hs.filepath = targetFile)
            return
        SaveHotstring(targetFile, hs.short, hs.options, hs.long,
            hs.category, hs.comment,
            ArrJoin(hs.aliases, ","), , ArrJoin(hs.apps, ","),
            ArrJoin(hs.tags, ","), hs.language, ,
            hs.disabled, , IsObject(hs.customFields) ? hs.customFields : Map(), hs.url, _HsAlts(hs), _HsAltNames(hs))
        RemoveHotstringFromFile(hs.filepath, hs.short)
        RebuildAndReload(targetFile)
        RebuildAndReload(hs.filepath)
        _SafeSend(sender, "window.initData(" BuildPhrasesJson() ")")

    } else if (action = "duplicateToFile") {
        ; Copy the given phrases into targetFile (originals stay). Same trigger as the
        ; source — mirrors the native GUI's BulkDuplicateToFile.
        ids        := msg.Has("ids") ? msg["ids"] : []
        targetFile := msg.Has("targetFile") ? msg["targetFile"] : ""
        if (targetFile = "")
            return
        for id in ids {
            hs := FindHsById(id)
            if !IsObject(hs)
                continue
            newLine := BuildPhraseLineFromHs(hs, hs.short, hs.long)
            PhraseFileAppend(targetFile, "`n" newLine)
        }
        RebuildAndReload(targetFile)
        _SafeSend(sender, "window.initData(" BuildPhrasesJson() ")")

    } else if (action = "moveToFile") {
        ; Move the given phrases into targetFile (removed from their source files).
        ids        := msg.Has("ids") ? msg["ids"] : []
        targetFile := msg.Has("targetFile") ? msg["targetFile"] : ""
        if (targetFile = "")
            return
        touched := Map(targetFile, true)
        for id in ids {
            hs := FindHsById(id)
            if !IsObject(hs)
                continue
            if (hs.filepath = targetFile)
                continue
            newLine := BuildPhraseLineFromHs(hs, hs.short, hs.long)
            PhraseFileAppend(targetFile, "`n" newLine)
            RemoveHotstringFromFile(hs.filepath, hs.short)
            touched[hs.filepath] := true
        }
        for f in touched
            RebuildAndReload(f)
        _SafeSend(sender, "window.initData(" BuildPhrasesJson() ")")

    } else if (action = "bulkDuplicate") {
        ; Duplicate the given phrases in their own files, each with a unique trigger.
        global HS_ALL
        ids  := msg.Has("ids") ? msg["ids"] : []
        used := Map()
        for h in HS_ALL
            used[h.short] := true
        touched := Map()
        for id in ids {
            hs := FindHsById(id)
            if !IsObject(hs)
                continue
            i  := 2
            nt := hs.short "_" i
            while (used.Has(nt)) {
                i++
                nt := hs.short "_" i
            }
            used[nt] := true
            newLine := BuildPhraseLineFromHs(hs, nt, hs.long)
            PhraseFileAppend(hs.filepath, "`n" newLine)
            touched[hs.filepath] := true
        }
        for f in touched
            RebuildAndReload(f)
        _SafeSend(sender, "window.initData(" BuildPhrasesJson() ")")

    } else if (action = "getFiles") {
        _SafeSend(sender,"window.receiveFiles(" BuildFilesJson() ")")

    } else if (action = "getSettings") {
        _SafeSend(sender,"window.receiveSettings(" BuildSettingsJson() ")")

    } else if (action = "addFolder") {
        path := DirSelect(, 3, "Välj frasmapp")
        if (path = "")
            return
        id := RegExReplace(path, "[^a-zA-Z0-9]", "_")
        IniWrite(path, inifile, "PhraseFolders", id)
        ReloadPhrases()
        _SafeSend(sender,"window.receiveSettings(" BuildSettingsJson() ")")

    } else if (action = "removeFolder") {
        id := msg["id"]
        IniDelete(inifile, "PhraseFolders", id)
        DisabledFoldersRemove(id)
        ReloadPhrases()
        _SafeSend(sender,"window.receiveSettings(" BuildSettingsJson() ")")

    } else if (action = "toggleFolder") {
        id      := msg["id"]
        enabled := msg["enabled"]
        if (enabled)
            DisabledFoldersRemove(id)
        else
            DisabledFoldersAdd(id)
        ReloadPhrases()
        _SafeSend(sender,"window.receiveSettings(" BuildSettingsJson() ")")

    } else if (action = "saveIgnoreFolders") {
        global g_ignoreFolders
        g_ignoreFolders := []
        for s in StrSplit(msg.Has("names") ? msg["names"] : "", "|")
            if ((s := Trim(s)) != "")
                g_ignoreFolders.Push(s)
        SaveIgnoreFolders()
        ReloadPhrases()
        _SafeSend(sender,"window.receiveSettings(" BuildSettingsJson() ")")

    } else if (action = "duplicate") {
        global HS_ALL, wv2Win
        id := msg["id"]
        hs := FindHsById(id)
        if !hs
            return
        ; Optional target file (duplicate to another file); defaults to the source file.
        target := (msg.Has("targetFile") && msg["targetFile"] != "") ? msg["targetFile"] : hs.filepath
        ; If the phrase has fillable dynamic fields, offer to fill them in for the
        ; copy (Yes), keep them empty (No), or abort (Cancel/closed dialog).
        dupLong := hs.long
        dynFields := _CollectManualDynFields(Unescape_CC(hs.long))
        if (dynFields.Length) {
            choice := MsgBox(_AT("dup.dyn.body"), _AT("dup.dyn.title"), "YesNoCancel Icon? Owner" wv2Win.Hwnd)
            if (choice = "Cancel")
                return
            if (choice = "Yes") {
                r := PromptDynamicFields(dynFields)
                if (!r.ok)
                    return                      ; field entry cancelled → no duplicate
                filled := Unescape_CC(hs.long)
                for name, val in r.vals
                    filled := StrReplace(filled, "{" name "}", val)
                dupLong := Escape_CC(filled)
            }
        }
        ; Find a unique trigger: trigger_2, trigger_3, …
        baseTrigger := hs.short
        i           := 2
        newTrigger  := baseTrigger "_" i
        Loop {
            found := false
            for h in HS_ALL
                if (h.short = newTrigger)
                    found := true
            if !found
                break
            i++
            newTrigger := baseTrigger "_" i
        }
        ; dupLong is already in on-disk escaped form (verbatim or filled-in)
        newLine := BuildPhraseLineFromHs(hs, newTrigger, dupLong, true)
        PhraseFileAppend(target, "`n" newLine)
        RebuildAndReload(target)
        ; Find the new HS to auto-select it in JS
        newHs := ""
        for h in HS_ALL
            if (h.short = newTrigger && h.filepath = target)
                newHs := h
        newIdJson := IsObject(newHs) ? JSON.Dump(newHs.id) : "null"
        _SafeSend(sender,"window.initData(" BuildPhrasesJson() "," newIdJson ")")

    } else if (action = "insertPhrase") {
        id := msg["id"]
        SetTimer(() => DoDirectInsert(id), -1)

    } else if (action = "browseLinkFile") {
        sel := ""
        try sel := FileSelect(, , _AT("url.title"))
        if (sel != "")
            _SafeSend(sender, "window.receiveLinkFile(" JSON.Dump(sel) ")")

    } else if (action = "openUrl") {
        u := msg.Has("url") ? msg["url"] : ""
        if (u != "")
            _OpenUrlTarget(u, msg.Has("folder") && msg["folder"])

    } else if (SubStr(action, 1, 2) = "ai" || action = "getAiSettings" || action = "saveAiSettings") {
        WV2AIHandle(msg, sender)

    } else if (action = "chooseDictDownloadFolder") {
        path := DirSelect(, 3, "Välj mapp för nedladdade ordlistor")
        if (path != "")
            _SafeSend(sender, "window.receiveWordlistFolder(" JSON.Dump(path) ")")

    } else if (action = "downloadWordlists") {
        files  := msg.Has("files")  ? msg["files"]  : []
        folder := msg.Has("folder") ? msg["folder"] : ""
        if (files.Length > 0 && folder != "")
            SetTimer(_DoWordlistDownload.Bind(files, folder, sender), -1)

    } else if (action = "downloadPhrasePacks") {
        packs := msg.Has("packs") ? msg["packs"] : []
        if (IsObject(packs) && packs.Length > 0)
            SetTimer(_DoPhrasePackDownload.Bind(packs, sender), -1)

    } else if (action = "getPackFolder") {
        _SafeSend(sender, "window.receivePackFolder(" JSON.Dump(_PackDir()) ")")

    } else if (action = "choosePackFolder") {
        global inifile
        chosen := DirSelect("*" _PackDir(), 3, "Välj mapp för nedladdade fraspaket")
        if (chosen != "") {
            IniWrite(chosen, inifile, "Content", "PackDir")
            _SafeSend(sender, "window.receivePackFolder(" JSON.Dump(chosen) ")")
        }

    } else if (action = "saveDictSettings") {
        raw := msg.Has("paths") ? msg["paths"] : ""
        g_dictPaths := []
        for s in StrSplit(raw, "`n", "`r")
            if ((s := Trim(s)) != "")
                g_dictPaths.Push(s)
        SaveDictSettings()
        ApplyDictionaries()
        _SafeSend(sender,"window.receiveDictSettings(" BuildDictSettingsJson() ")")

    } else if (action = "addDictFolder") {
        path := DirSelect(, 3, "Välj ordlistemapp")
        if (path = "")
            return
        for p in g_dictPaths
            if (p = path)
                return          ; already in list
        g_dictPaths.Push(path)
        SaveDictSettings()
        ApplyDictionaries()
        _SafeSend(sender,"window.receiveDictSettings(" BuildDictSettingsJson() ")")

    } else if (action = "removeDictFolder") {
        target := msg.Has("path") ? msg["path"] : ""
        newPaths := []
        for p in g_dictPaths
            if (p != target)
                newPaths.Push(p)
        g_dictPaths := newPaths
        SaveDictSettings()
        _SafeSend(sender,"window.receiveDictSettings(" BuildDictSettingsJson() ")")

    } else if (action = "getDictSettings") {
        _SafeSend(sender,"window.receiveDictSettings(" BuildDictSettingsJson() ")")

    } else if (action = "saveSpellEnabled") {
        global inifile
        IniWrite(msg.Has("enabled") ? msg["enabled"] : 1, inifile, "Spellcheck", "enabled")

    } else if (action = "saveCompoundSettings") {
        global g_compoundEnabled, g_compoundMinLen
        g_compoundEnabled := msg.Has("enabled") ? !!msg["enabled"] : false
        g_compoundMinLen  := msg.Has("minLen")   ? msg["minLen"]   : 12
        IniWrite(g_compoundEnabled ? 1 : 0, inifile, "Spellcheck", "compoundEnabled")
        IniWrite(g_compoundMinLen,           inifile, "Spellcheck", "compoundMinLen")

    } else if (action = "saveHotkeySettings") {
        _SaveHotkeySettings(msg)

    } else if (action = "savePopupSettings") {
        global inifile, g_hintsEnabled, g_hintFuzzy, g_hintMinLen, g_hintTimeout
        IniWrite(msg.Has("enabled")   ? msg["enabled"]   : 1, inifile, "Popup", "Enabled")
        IniWrite(msg.Has("fuzzy")     ? msg["fuzzy"]     : 0, inifile, "Popup", "Fuzzy")
        IniWrite(msg.Has("chars")     ? msg["chars"]     : 2, inifile, "Popup", "Chars")
        IniWrite(msg.Has("timeout")   ? msg["timeout"]   : 5, inifile, "Popup", "Timeout")
        IniWrite(msg.Has("insertKey") ? msg["insertKey"] : "^Space", inifile, "Popup", "InsertKey")
        IniWrite(msg.Has("upKey")     ? msg["upKey"]     : "Up",     inifile, "Popup", "UpKey")
        IniWrite(msg.Has("downKey")   ? msg["downKey"]   : "Down",   inifile, "Popup", "DownKey")
        IniWrite(msg.Has("numKey") && msg["numKey"] != "" ? msg["numKey"] : "off", inifile, "Popup", "NumKey")
        g_hintsEnabled := msg.Has("enabled") && msg["enabled"] ? true : false
        g_hintFuzzy    := msg.Has("fuzzy")   && msg["fuzzy"]   ? true : false
        g_hintMinLen   := msg.Has("chars")   ? msg["chars"]   : 2
        g_hintTimeout  := msg.Has("timeout") ? msg["timeout"] : 5
        LoadPopupHotkeys()
        _SafeSend(sender,"window.receivePopupSettings(" BuildPopupSettingsJson() ")")

    } else if (action = "saveDynamicSettings") {
        _SaveDynamicSettings(msg)
        _SafeSend(sender,"window.receiveDynamicSettings(" BuildDynamicSettingsJson() ")")

    } else if (action = "fileToggle") {
        path := msg.Has("path") ? msg["path"] : ""
        type := msg.Has("type") ? msg["type"] : ""
        if (path != "" && type != "") {
            FileSettingToggle(path, type)
        }

    } else if (action = "applyPreset") {
        preset := msg.Has("preset") ? msg["preset"] : ""
        paths  := msg.Has("paths")  ? msg["paths"]  : []
        if (preset = "" || paths.Length = 0)
            return
        hintT  := (preset = "phrases")
        hintP  := (preset = "phrases" || preset = "abbrev")
        hidden := (preset = "spellcheck" || preset = "abbrev")
        _FileSettingBatchApply("hs",    true,  paths)
        _FileSettingBatchApply("hintT", hintT, paths)
        _FileSettingBatchApply("hintP", hintP, paths)
        for p in paths {
            if FileExist(p) {
                s := ReadFileSettings(p)
                s["hidden"] := hidden ? "1" : ""
                WriteFileSettings(p, s)
            }
        }
        ; A preset that makes files visible must also lift a hidden folder
        ; above them — otherwise the files stay out of sight and the preset
        ; looks like it did nothing. The folder's other files stay hidden.
        foldersChanged := !hidden ? PromoteFilesOutOfHiddenFolder(paths) : false
        ReloadPhrases(false)
        _SafeSend(sender, "window.receiveFiles(" BuildFilesJson() ")")
        if foldersChanged
            _SafeSend(sender, "window.receiveSettings(" BuildSettingsJson() ")")

    } else if (action = "fileBatchSet") {
        type   := msg.Has("type")   ? msg["type"]   : ""
        enable := msg.Has("enable") ? !!msg["enable"] : false
        paths  := msg.Has("paths")  ? msg["paths"]  : []
        if (type != "" && paths.Length > 0) {
            _FileSettingBatchApply(type, enable, paths)
            if (type = "hs") {
                ReloadPhrases(false)
                _SafeSend(sender,"window.receiveFiles(" BuildFilesJson() ")")
            } else
                _SafeSend(sender,"window.receiveFiles(" BuildFilesJson() ")")
        }

    } else if (action = "firstRunSetup") {
        global g_firstRun
        ; Register phrase folder
        phraseFolder := msg.Has("phraseFolder") ? msg["phraseFolder"] : ""
        if (phraseFolder != "") {
            if !FileExist(phraseFolder)
                try DirCreate(phraseFolder)
            folderId := RegExReplace(phraseFolder, "[^a-zA-Z0-9]", "_")
            if (IniRead(inifile, "PhraseFolders", folderId, "") = "")
                IniWrite(phraseFolder, inifile, "PhraseFolders", folderId)
        }
        IniWrite("done", inifile, "meta", "first_run")
        g_firstRun := false
        ; Selected word lists and phrase packs may need downloading (the
        ; release zip ships without them) — finish deferred so the message
        ; pump stays alive
        selectedFiles := msg.Has("wordlistFiles") ? msg["wordlistFiles"] : []
        packs         := msg.Has("phrasePacks")   ? msg["phrasePacks"]   : []
        SetTimer(_FirstRunFinish.Bind(selectedFiles, packs, sender), -1)

    } else if (action = "browsePhraseFolder") {
        chosen := DirSelect("*" A_AppData "\Expanto", 1, "Välj mapp för frasfiler")
        if (chosen != "")
            _SafeSend(sender, "window.receiveFirstRunFolder(" JSON.Dump(chosen) ")")

    } else if (action = "getBackups") {
        path := msg.Has("path") ? msg["path"] : ""
        if (path = "")
            return
        slots := []
        Loop 3 {
            bakPath := path ".bak" A_Index
            if FileExist(bakPath)
                slots.Push(Map("slot", A_Index, "mtime", FormatTime(FileGetTime(bakPath, "M"), "yyyy-MM-dd HH:mm")))
        }
        _SafeSend(sender,"window.receiveBackups(" JSON.Dump(path) "," JSON.Dump(slots) ")")

    } else if (action = "restoreBackup") {
        path := msg.Has("path") ? msg["path"] : ""
        slot := msg.Has("slot") ? msg["slot"] : 0
        if (path = "" || slot < 1 || slot > 3)
            return
        bakPath := path ".bak" slot
        if FileExist(bakPath) {
            content := FileRead(bakPath, "UTF-8")
            PhraseFileWriteAll(path, content)
            RebuildAndReload(path)
            _SafeSend(sender,"window.initData(" BuildPhrasesJson() ")")
        }

    } else if (action = "getFileSettings") {
        path := msg.Has("path") ? msg["path"] : ""
        if FileExist(path)
            _SafeSend(sender,"window.receiveFileSettings(" BuildFileSettingsJson(path) ")")

    } else if (action = "saveFileSettings") {
        path := msg.Has("path") ? msg["path"] : ""
        if FileExist(path) {
            existing := ReadFileSettings(path)
            settings := Map(
                "label",        msg.Has("label")        ? msg["label"]        : "",
                "defaultCat",   msg.Has("defaultCat")   ? msg["defaultCat"]   : "",
                "metaFields",   msg.Has("metaFields")   ? msg["metaFields"]   : "",
                "groupField",   msg.Has("groupField")   ? msg["groupField"]   : "",
                "titleFields",  msg.Has("titleFields")  ? msg["titleFields"]  : "",
                "titlePattern", msg.Has("titlePattern") ? msg["titlePattern"] : "",
                "sharedFields", msg.Has("sharedFields") ? msg["sharedFields"] : "",
                "hidden",       existing.Has("hidden") ? existing["hidden"] : "")
            WriteFileSettings(path, settings)
            global g_coupleCfgCache
            if g_coupleCfgCache.Has(path)
                g_coupleCfgCache.Delete(path)
            _SafeSend(sender,"window.receiveFileSettings(" BuildFileSettingsJson(path) ")")
        }

    } else if (action = "setFileHidden") {
        path   := msg.Has("path")   ? msg["path"]   : ""
        hidden := msg.Has("hidden") && msg["hidden"] ? "1" : ""
        if FileExist(path) {
            s := ReadFileSettings(path)
            s["hidden"] := hidden
            WriteFileSettings(path, s)
            ; showing a file inside a hidden folder lifts the folder but keeps
            ; the folder's other files hidden
            foldersChanged := (hidden = "") ? PromoteFilesOutOfHiddenFolder([path]) : false
            _SafeSend(sender,"window.receiveFiles(" BuildFilesJson() ")")
            if foldersChanged
                _SafeSend(sender,"window.receiveSettings(" BuildSettingsJson() ")")
        }

    } else if (action = "setFolderHidden") {
        global g_hiddenFolders
        fid    := msg.Has("id")     ? msg["id"]     : ""
        hidden := msg.Has("hidden") && msg["hidden"]
        if (fid != "") {
            if (hidden) {
                found := false
                for h in g_hiddenFolders
                    if (h = fid) {
                        found := true
                        break
                    }
                if !found
                    g_hiddenFolders.Push(fid)
            } else {
                HiddenFoldersRemove([fid])
                ; "Show folder" means everything in it becomes visible — clear
                ; the per-file hidden flags too, or the folder stays empty.
                UnhideFilesInFolder(IniRead(inifile, "PhraseFolders", fid, ""))
            }
            SaveHiddenFolders()
            _SafeSend(sender,"window.receiveSettings(" BuildSettingsJson() ")")
            _SafeSend(sender,"window.receiveFiles(" BuildFilesJson() ")")
        }

    } else if (action = "setSelected") {
        global g_selectedId
        g_selectedId := msg.Has("id") ? msg["id"] : ""

    } else if (action = "directInsert") {
        id := msg.Has("id") ? msg["id"] : ""
        if (id != "")
            DoDirectInsert(id)

    } else if (action = "directInsertStep") {
        id := msg.Has("id") ? msg["id"] : ""
        if (id != "")
            DoDirectInsertStep(id)

    } else if (action = "openEditor") {
        global inifile
        path := msg.Has("path") ? msg["path"] : ""
        if (path = "" || !FileExist(path))
            return
        editorCmd := Trim(IniRead(inifile, "General", "EditorCmd", ""))
        if (editorCmd = "") {
            ; Notepad can't open folders — fall back to Explorer for those
            if InStr(FileExist(path), "D")
                Run("explorer.exe `"" path "`"")
            else
                Run("notepad.exe `"" path "`"")
        } else {
            cmd := StrReplace(editorCmd, "{file}", path)
            Run(cmd)
        }

    } else if (action = "openFolder") {
        path := msg.Has("path") ? msg["path"] : ""
        if (path != "")
            Run("explorer.exe `"" path "`"")

    } else if (action = "previewPhraseLine") {
        ; The status bar shows the line the editor is about to write. Built by the
        ; same BuildPhraseLine the save path uses, so "exactly" really means exactly.
        hs   := msg.Has("id") && msg["id"] != "" ? FindHsById(msg["id"]) : ""
        opts := msg.Has("options") ? msg["options"] : (hs ? hs.options : "")
        line := ""
        try line := BuildPhraseLine(opts
            , Trim(msg.Has("trigger") ? msg["trigger"] : "")
            , msg.Has("phrase")  ? msg["phrase"]  : ""
            , msg.Has("cat")     ? msg["cat"]     : ""
            , msg.Has("comment") ? msg["comment"] : ""
            , msg.Has("lang")    ? msg["lang"]    : ""
            , msg.Has("tags")    ? msg["tags"]    : ""
            , msg.Has("disabled") ? msg["disabled"] : 0
            , msg.Has("aliases")  ? msg["aliases"]  : ""
            , msg.Has("apps")     ? msg["apps"]     : ""
            , msg.Has("customFields") ? msg["customFields"] : Map()
            , msg.Has("url")      ? msg["url"]      : ""
            , msg.Has("alts")     ? msg["alts"]     : ""
            , msg.Has("altNames") ? msg["altNames"] : "")
        _SafeSend(sender,"window.receivePhraseLine(" JSON.Dump(Map("line", line)) ")")

    } else if (action = "getGeneralSettings") {
        global inifile
        editorCmd := Trim(IniRead(inifile, "General", "EditorCmd", ""))
        startMin  := IniRead(inifile, "General", "StartMinimized", "0") != "0"
        gen := _ReadPasteSettings()
        gen["editorCmd"] := editorCmd, gen["startMinimized"] := startMin, gen["autostart"] := _AutostartOn()
        gen["toolbarIconsOnly"] := IniRead(inifile, "General", "ToolbarIconsOnly", "0") != "0"
        _SafeSend(sender,"window.receiveGeneralSettings(" JSON.Dump(gen) ")")

    } else if (action = "setLang") {
        global g_uiLang
        g_uiLang := (msg.Has("lang") && msg["lang"] = "en") ? "en" : "sv"
        _RebuildTrayMenu()

    } else if (action = "saveGeneralSettings") {
        global inifile
        editorCmd := msg.Has("editorCmd") ? msg["editorCmd"] : ""
        startMin  := msg.Has("startMinimized") && msg["startMinimized"] ? "1" : "0"
        tbIcons   := msg.Has("toolbarIconsOnly") && msg["toolbarIconsOnly"] ? "1" : "0"
        IniWrite(editorCmd, inifile, "General", "EditorCmd")
        IniWrite(startMin,  inifile, "General", "StartMinimized")
        IniWrite(tbIcons,   inifile, "General", "ToolbarIconsOnly")
        _AutostartSet(msg.Has("autostart") && msg["autostart"])
        _SavePasteSettings(msg)
        startMinBool := startMin = "1"
        gen := _ReadPasteSettings()
        gen["editorCmd"] := editorCmd, gen["startMinimized"] := startMinBool, gen["autostart"] := _AutostartOn()
        gen["toolbarIconsOnly"] := tbIcons = "1"
        _SafeSend(sender,"window.receiveGeneralSettings(" JSON.Dump(gen) ")")

    } else if (action = "bulkSave") {
        ; 883 markerade fraser x läs-och-skriv-hela-filen tog minuter och
        ; frös UI:t (allt kördes synkront i meddelandehanteraren). Körs nu
        ; uppskjutet, med filvis batchning och förlopp i statusfältet.
        SetTimer(_BulkSaveRun.Bind(msg["ids"], msg["updates"]), -1)

    } else if (action = "checkTriggerInDict") {
        global g_dictPaths
        word    := msg.Has("word") ? Trim(msg["word"]) : ""
        matched := false
        if (word != "") {
            for dictPath in g_dictPaths {
                attr := FileExist(dictPath)
                files := []
                if (attr = "D")
                    loop files dictPath "\*.txt"
                        files.Push(A_LoopFileFullPath)
                else if (attr != "")
                    files.Push(dictPath)
                for f in files {
                    loop read f {
                        if (Trim(A_LoopReadLine) = word) {
                            matched := true
                            break 2
                        }
                    }
                }
            }
        }
        safeWord := StrReplace(StrReplace(word, "\", "\\"), "`"", "\`"")
        _SafeSend(sender,"window.receiveTriggerDictMatch(`"" safeWord "`"," (matched ? "true" : "false") ")")

    } else if (action = "closeGui") {
        global wv2Win, g_wv2Shown, g_markWordActive
        g_wv2Shown := false
        g_markWordActive := false
        wv2Win.Hide()

    } else if (action = "toggleOnTop") {
        global wv2Win
        cur := WinGetExStyle("ahk_id " wv2Win.hwnd)
        WinSetAlwaysOnTop((cur & 0x8) ? 0 : 1, "ahk_id " wv2Win.hwnd)
        _SafeSend(sender,"window.receiveOnTop(" ((cur & 0x8) ? 0 : 1) ")")

    } else if (action = "editFile") {
        path := msg.Has("path") ? msg["path"] : ""
        if (path != "" && FileExist(path))
            Run('notepad.exe "' path '"')

    } else if (action = "enc") {
        task := msg.Has("task") ? msg["task"] : ""
        path := msg.Has("path") ? msg["path"] : ""
        SetTimer(_EncDoTask.Bind(task, path), -1)

    } else if (action = "newFile") {
        SetTimer(() => _NewFileCreate(msg, sender), -1)

    } else if (action = "renameFile") {
        SetTimer(() => _RenameFile(msg, sender), -1)
    }
}

_SafeSend(core, script) {
    global g_wv2Ready
    if (!g_wv2Ready || !IsObject(core))
        return
    ; Yield one pump cycle so OnProcessFailed can fire and clear g_wv2Ready
    ; before we touch the COM proxy — prevents access-violation crash on dead proxy.
    Sleep(0)
    if (!g_wv2Ready || !IsObject(core))
        return
    try {
        core.ExecuteScriptAsync(script)
    } catch as _err {
        g_wv2Ready := false
    }
}

_NewFileCreate(msg, sender) {
    global g_encModule
    folder := msg.Has("folder") ? msg["folder"] : ""
    name   := msg.Has("name")   ? msg["name"]   : ""
    enc    := msg.Has("enc")    && msg["enc"]
    if (folder = "" || name = "") {
        _SafeSend(sender,"window.newFileError(" JSON.Dump("Ogiltigt mappnamn eller filnamn.") ")")
        return
    }
    ; Strip known extensions then re-add correct one
    name := RegExReplace(name, "i)\.(ahk|enc)$", "")
    ; Sanitize: strip unsafe filename characters
    name := RegExReplace(name, "[\\/:*?`"<>|]", "_")
    name := Trim(name)
    if (name = "") {
        _SafeSend(sender,"window.newFileError(" JSON.Dump("Filnamnet får inte vara tomt.") ")")
        return
    }
    ext  := enc ? ".enc" : ".ahk"
    path := folder "\" name ext
    if FileExist(path) {
        _SafeSend(sender,"window.newFileError(" JSON.Dump("Filen finns redan: " name ext) ")")
        return
    }
    if (enc) {
        if !IsSet(g_encModule) {
            _SafeSend(sender,"window.newFileError(" JSON.Dump("Krypteringsmodulen saknas.") ")")
            return
        }
        try {
            g_encModule["EncFileWrite"](path, "; Ny krypterad frasfil — skapad " FormatTime(, "yyyy-MM-dd") "`n")
        } catch as e {
            _SafeSend(sender,"window.newFileError(" JSON.Dump("Kunde inte skapa fil: " e.Message) ")")
            return
        }
    } else {
        try {
            FileAppend("; Ny frasfil — skapad " FormatTime(, "yyyy-MM-dd") "`n", path, "UTF-8")
        } catch as e {
            _SafeSend(sender,"window.newFileError(" JSON.Dump("Kunde inte skapa fil: " e.Message) ")")
            return
        }
    }
    ReloadPhrases()
    _SafeSend(sender,"window.receiveFiles(" BuildFilesJson() ")")
    _SafeSend(sender,"window.receiveEncStatus(" BuildEncStatusJson() ")")
    _SafeSend(sender,"window.newFileCreated(" JSON.Dump(path) ")")
}

; Rename a phrase file on disk, keeping it in the same folder and extension. The
; per-file settings live inside the file (; @expanto …) so they travel with it;
; here we also move the .bak backups and migrate path-keyed state (enable flags,
; usage timestamps whose id is "path|trigger").
_RenameFile(msg, sender) {
    global g_fileHsOff, g_fileHintTOff, g_fileHintPOff
    oldPath := msg.Has("path")    ? msg["path"]    : ""
    newName := msg.Has("newName") ? msg["newName"] : ""
    if (oldPath = "" || newName = "") {
        _SafeSend(sender, "window.renameFileError(" JSON.Dump("Ogiltigt filnamn.") ")")
        return
    }
    if !FileExist(oldPath) {
        _SafeSend(sender, "window.renameFileError(" JSON.Dump("Filen finns inte längre.") ")")
        return
    }
    SplitPath(oldPath, , &dir, &ext)
    ; strip a typed extension, sanitize unsafe characters, keep the original ext
    newName := RegExReplace(newName, "i)\.(ahk|enc)$", "")
    newName := RegExReplace(newName, "[\\/:*?`"<>|]", "_")
    newName := Trim(newName)
    if (newName = "") {
        _SafeSend(sender, "window.renameFileError(" JSON.Dump("Filnamnet får inte vara tomt.") ")")
        return
    }
    newPath := dir "\" newName "." ext
    if (newPath = oldPath) {
        _SafeSend(sender, "window.renameFileDone(" JSON.Dump(newPath) ")")
        return
    }
    if FileExist(newPath) {
        _SafeSend(sender, "window.renameFileError(" JSON.Dump("Det finns redan en fil som heter " newName "." ext) ")")
        return
    }
    try {
        FileMove(oldPath, newPath, 0)
    } catch as e {
        _SafeSend(sender, "window.renameFileError(" JSON.Dump("Kunde inte byta namn: " e.Message) ")")
        return
    }
    ; move rotating backups alongside the renamed file
    for suf in [".bak1", ".bak2", ".bak3"]
        if FileExist(oldPath suf)
            try FileMove(oldPath suf, newPath suf, 1)
    ; migrate path-keyed state
    _MigratePathInList(g_fileHsOff,    oldPath, newPath, "file_hs_off")
    _MigratePathInList(g_fileHintTOff, oldPath, newPath, "file_hint_t_off")
    _MigratePathInList(g_fileHintPOff, oldPath, newPath, "file_hint_p_off")
    _MigrateUsageKeys(oldPath, newPath)

    ReloadPhrases()
    _SafeSend(sender, "window.receiveFiles(" BuildFilesJson() ")")
    _SafeSend(sender, "window.initData(" BuildPhrasesJson() ")")
    _SafeSend(sender, "window.renameFileDone(" JSON.Dump(newPath) ")")
}

; Replace oldPath with newPath in a path list and persist it if it changed.
_MigratePathInList(list, oldPath, newPath, iniKey) {
    changed := false
    for i, v in list
        if (v = oldPath) {
            list[i] := newPath
            changed := true
        }
    if changed
        SavePathsToIni(iniKey, list)
}

; Usage ids are "filepath|trigger"; re-key the ones under oldPath to newPath.
_MigrateUsageKeys(oldPath, newPath) {
    global g_usageMap
    prefix := oldPath "|"
    plen   := StrLen(prefix)
    moved  := []
    for k, v in g_usageMap
        if (SubStr(k, 1, plen) = prefix)
            moved.Push({ old: k, new: newPath "|" SubStr(k, plen + 1), val: v })
    for m in moved {
        g_usageMap.Delete(m.old)
        g_usageMap[m.new] := m.val
    }
    if (moved.Length)
        _FlushUsage()
}

; ══════════════════════════════════════════════════════════════════════════════
; JSON helpers
; ══════════════════════════════════════════════════════════════════════════════

BuildPhrasesJson() {
    global HS_ALL, g_usageMap
    arr := []
    for hs in HS_ALL
        arr.Push(PhraseToMap(hs))
    return JSON.Dump(Map("phrases", arr, "usageTimes", g_usageMap))
}

BuildEncStatusJson() {
    global g_encPw, g_encSkip, HS_folders_ALL
    lockedCnt := 0
    if (g_encPw = "") {
        for folder in HS_folders_ALL
            for file in folder.files
                if IsEncPhrasePath(file.fullpath)
                    lockedCnt++
    }
    return JSON.Dump(Map(
        "unlocked",  (g_encPw != "") ? 1 : 0,
        "skipped",   g_encSkip ? 1 : 0,
        "encLocked", lockedCnt))
}

_EncDoTask(task, path := "") {
    if (task = "import") {
        EncImportExcel()
    } else if (task = "lockFile") {
        EncLockFile()
    } else if (task = "unlockFile") {
        EncUnlockFile()
    } else if (task = "lock") {
        EncLock()
    } else if (task = "unlock") {
        EncUnlock()
    } else if (task = "lockPath") {
        if (path != "")
            EncLockPath(path)
    } else if (task = "unlockPath") {
        if (path != "")
            EncUnlockPath(path)
    }
}

; ── Per-file settings ─────────────────────────────────────────────────────────

LoadFileSettings() {
    global inifile, g_fileHsOff, g_fileHintTOff, g_fileHintPOff
    g_fileHsOff    := PathListFromIni("file_hs_off")
    g_fileHintTOff := PathListFromIni("file_hint_t_off")
    g_fileHintPOff := PathListFromIni("file_hint_p_off")
}

PathListFromIni(key) {
    global inifile
    out := []
    for s in StrSplit(IniRead(inifile, "FileSettings", key, ""), "|")
        if ((s := Trim(s)) != "")
            out.Push(s)
    return out
}

SavePathsToIni(key, paths) {
    global inifile
    IniWrite(ArrJoin(paths, "|"), inifile, "FileSettings", key)
}

ToggleInList(list, item) {
    newList := []
    found := false
    for v in list {
        if (v = item) {
            found := true
        } else {
            newList.Push(v)
        }
    }
    if (!found) {
        newList.Push(item)
    }
    return newList
}

FileHsEnabled(path) {
    global g_fileHsOff
    for v in g_fileHsOff
        if (v = path)
            return false
    return true
}

FileHintTEnabled(path) {
    global g_fileHintTOff
    for v in g_fileHintTOff
        if (v = path)
            return false
    return true
}

FileHintPEnabled(path) {
    global g_fileHintPOff
    for v in g_fileHintPOff
        if (v = path)
            return false
    return true
}

FileSettingToggle(path, type) {
    global g_fileHsOff, g_fileHintTOff, g_fileHintPOff
    if (type = "hs") {
        g_fileHsOff := ToggleInList(g_fileHsOff, path)
        SavePathsToIni("file_hs_off", g_fileHsOff)
    } else if (type = "hintT") {
        g_fileHintTOff := ToggleInList(g_fileHintTOff, path)
        SavePathsToIni("file_hint_t_off", g_fileHintTOff)
    } else if (type = "hintP") {
        g_fileHintPOff := ToggleInList(g_fileHintPOff, path)
        SavePathsToIni("file_hint_p_off", g_fileHintPOff)
    }
    ReloadPhrases()
}

_FileSettingBatchApply(type, enable, paths) {
    global g_fileHsOff, g_fileHintTOff, g_fileHintPOff
    if (type = "hs") {
        for path in paths {
            isOn := FileHsEnabled(path)
            if (enable && !isOn)
                g_fileHsOff := ToggleInList(g_fileHsOff, path)
            else if (!enable && isOn)
                g_fileHsOff := ToggleInList(g_fileHsOff, path)
        }
        SavePathsToIni("file_hs_off", g_fileHsOff)
    } else if (type = "hintT") {
        for path in paths {
            isOn := FileHintTEnabled(path)
            if (enable && !isOn)
                g_fileHintTOff := ToggleInList(g_fileHintTOff, path)
            else if (!enable && isOn)
                g_fileHintTOff := ToggleInList(g_fileHintTOff, path)
        }
        SavePathsToIni("file_hint_t_off", g_fileHintTOff)
    } else if (type = "hintP") {
        for path in paths {
            isOn := FileHintPEnabled(path)
            if (enable && !isOn)
                g_fileHintPOff := ToggleInList(g_fileHintPOff, path)
            else if (!enable && isOn)
                g_fileHintPOff := ToggleInList(g_fileHintPOff, path)
        }
        SavePathsToIni("file_hint_p_off", g_fileHintPOff)
    }
}

; ── Spell-check dictionaries ──────────────────────────────────────────────────

LoadDictSettings() {
    global inifile, g_dictPaths, g_compoundEnabled, g_compoundMinLen
    g_dictPaths := []
    for s in StrSplit(IniRead(inifile, "Spellcheck", "dictionaries", ""), "|")
        if ((s := Trim(s)) != "")
            g_dictPaths.Push(s)
    g_compoundEnabled := IniRead(inifile, "Spellcheck", "compoundEnabled", 0) != "0"
    g_compoundMinLen  := Integer(IniRead(inifile, "Spellcheck", "compoundMinLen", 12))
}

SaveDictSettings() {
    global inifile, g_dictPaths
    IniWrite(ArrJoin(g_dictPaths, "|"), inifile, "Spellcheck", "dictionaries")
}

; The folder phrase packs are downloaded into (each pack gets a subfolder).
; Configurable via the folder picker on the Phrase folders settings page.
_PackDir() {
    global inifile
    return IniRead(inifile, "Content", "PackDir", A_AppData "\Expanto\packs")
}

; Download phrase packs from the ahk-phrases repo into _PackDir()\<pack>\ and
; register each pack folder as a phrase folder. packs = array of
; Map("name", <top folder>, "files", [repo-relative .ahk paths]). Returns an
; array of files that failed to download.
_PhrasePackDownloadCore(packs) {
    global inifile
    baseUrl := "https://raw.githubusercontent.com/ibst1/ahk-phrases/main/"
    failed  := []
    for pack in packs {
        name  := pack.Has("name")  ? pack["name"]  : ""
        files := pack.Has("files") ? pack["files"] : []
        if (name = "" || !IsObject(files) || !files.Length)
            continue
        destDir := _PackDir() "\" name
        if !DirExist(destDir)
            try DirCreate(destDir)
        okAny := false
        for relPath in files {
            SplitPath(StrReplace(relPath, "/", "\"), &fname)
            dest := destDir "\" fname
            if FileExist(dest) {
                okAny := true
                continue
            }
            try {
                Download(baseUrl relPath, dest)
                okAny := true
            } catch {
                failed.Push(relPath)
            }
        }
        if okAny {
            folderId := RegExReplace(destDir, "[^a-zA-Z0-9]", "_")
            if (IniRead(inifile, "PhraseFolders", folderId, "") = "")
                IniWrite(destDir, inifile, "PhraseFolders", folderId)
        }
    }
    return failed
}

; Settings → Phrase folders → "Download phrase packs"
_DoPhrasePackDownload(packs, sender) {
    global wv2Core
    failed := _PhrasePackDownloadCore(packs)
    ReloadPhrases()
    _SafeSend(sender, "window.phrasePackDone(" JSON.Dump(Map("failed", failed.Length)) ")")
    _SafeSend(wv2Core, "window.receiveFiles(" BuildFilesJson() ")")
    if (failed.Length > 0)
        MsgBox "Följande filer kunde inte laddas ner:`n" ArrJoin(failed, "`n"), "Nedladdning — fel", "Icon!"
}

; First-run: download any selected word lists that aren't on disk yet.
; selectedFiles holds wordlists-repo-relative paths (e.g. general/words_sv.txt
; or medicin/mesh_sv.txt); every file lands flat in lib\words\.
_FirstRunFinish(selectedFiles, packs, sender) {
    global g_dictPaths, inifile, wv2Core
    if (selectedFiles.Length > 0) {
        baseUrl := "https://raw.githubusercontent.com/ibst1/wordlists/master/"
        failed  := []
        for relPath in selectedFiles {
            SplitPath(StrReplace(relPath, "/", "\"), &fname)
            absPath := A_ScriptDir "\lib\words\" fname
            if !FileExist(absPath) {
                if !DirExist(A_ScriptDir "\lib\words")
                    try DirCreate(A_ScriptDir "\lib\words")
                try {
                    Download(baseUrl relPath, absPath)
                } catch {
                    failed.Push(relPath)
                    continue
                }
            }
            if (FileExist(absPath) && !_ArrayContains(g_dictPaths, absPath))
                g_dictPaths.Push(absPath)
        }
        SaveDictSettings()
        IniWrite(1, inifile, "Spellcheck", "enabled")
        ApplyDictionaries()
        if (failed.Length > 0)
            MsgBox "Följande ordlistor kunde inte laddas ner:`n" ArrJoin(failed, "`n"), "Nedladdning — fel", "Icon!"
    }
    if (IsObject(packs) && packs.Length > 0) {
        packFailed := _PhrasePackDownloadCore(packs)
        if (packFailed.Length > 0)
            MsgBox "Följande fraspaket-filer kunde inte laddas ner:`n" ArrJoin(packFailed, "`n"), "Nedladdning — fel", "Icon!"
    }
    ReloadPhrases()
    _SafeSend(sender, "window.closeFirstRun()")
    _SafeSend(wv2Core, "window.receiveFiles(" BuildFilesJson() ")")
    _SafeSend(wv2Core, "window.receiveDictSettings(" BuildDictSettingsJson() ")")
}

_DoWordlistDownload(files, folder, sender) {
    global g_dictPaths
    baseUrl := "https://raw.githubusercontent.com/ibst1/wordlists/master/"
    total   := files.Length
    failed  := []
    loop total {
        i       := A_Index
        relPath := files[i]
        url     := baseUrl relPath
        parts   := StrSplit(relPath, "/")
        if (parts.Length > 1) {
            subDir := folder "\" parts[1]
            if !DirExist(subDir)
                DirCreate(subDir)
            dest := subDir "\" parts[parts.Length]
        } else {
            dest := folder "\" relPath
        }
        _SafeSend(sender, "window.wordlistDownloadProgress(" i "," total "," JSON.Dump(relPath) ")")
        try {
            Download(url, dest)
        } catch {
            failed.Push(relPath)
        }
    }
    if (!_ArrayContains(g_dictPaths, folder)) {
        g_dictPaths.Push(folder)
        SaveDictSettings()
        ApplyDictionaries()
    }
    _SafeSend(sender, "window.wordlistDownloadDone(" JSON.Dump(folder) ")")
    if (failed.Length > 0)
        MsgBox "Följande filer kunde inte laddas ner:`n" ArrJoin(failed, "`n"), "Nedladdning — fel", "Icon!"
}

ApplyDictionaries() {
    global wv2Core, g_dictPaths
    if (!IsSet(wv2Core))
        return
    for path in g_dictPaths {
        attr := FileExist(path)
        if (attr = "D") {
            loop files path "\*.txt"
                try wv2Core.Profile.AddCustomDictionaryFile(A_LoopFileFullPath)
        } else if (attr != "") {
            try wv2Core.Profile.AddCustomDictionaryFile(path)
        }
    }
}

BuildDictSettingsJson() {
    global g_dictPaths, g_compoundEnabled, g_compoundMinLen
    loaded := 0
    for p in g_dictPaths {
        attr := FileExist(p)
        if (attr = "D") {
            loop files p "\*.txt"
                loaded++
        } else if (attr != "") {
            loaded++
        }
    }
    total  := g_dictPaths.Length
    status := total > 0 ? loaded " ordlista(or) hittad(e) i " total " mapp(ar)" : ""
    spellEnabled := IniRead(inifile, "Spellcheck", "enabled", 1)
    return JSON.Dump(Map(
        "paths",           g_dictPaths,
        "status",          status,
        "spellEnabled",    spellEnabled != "0" ? 1 : 0,
        "compoundEnabled", g_compoundEnabled ? 1 : 0,
        "compoundMinLen",  g_compoundMinLen))
}

; ── First-run ─────────────────────────────────────────────────────────────────

LoadRepoBundles() {
    repoIni := A_ScriptDir "\reposettings.ini"
    bundles := []
    n := 1
    loop {
        label := IniRead(repoIni, "bundle" n, "label", "")
        if (label = "")
            break
        files   := IniRead(repoIni, "bundle" n, "files",   "")
        default := IniRead(repoIni, "bundle" n, "default", "0")
        bundles.Push(Map("id", "bundle" n, "label", label, "files", files, "isDefault", default != "0"))
        n++
    }
    return bundles
}

BuildFirstRunJson() {
    defaultFolder := A_AppData "\Expanto\phrases"
    return JSON.Dump(Map("bundles", LoadRepoBundles(), "defaultFolder", defaultFolder))
}

_ArrayContains(arr, val) {
    for v in arr
        if (v = val)
            return true
    return false
}

; ── Hotkey settings ────────────────────────────────────────────────────────────

LoadHotkeySettings() {
    ; Hotkeys are read at startup by the hotkey-init code directly from INI.
    ; This function exists so BuildHotkeySettingsJson can be called consistently.
}

BuildHotkeySettingsJson() {
    global inifile
    keys := ["OpenGui","MarkWord","StepNext","Undo","LastFired","CapsCapture",
             "New","Update","Delete","FilterFile","FilterCat","FilterTag",
             "AssignCat","AssignTag","SwitchField","AiSuggest","Layout","OnTop",
             "MoveFile","Settings","EditFile","LastEdited","Dupes","Panel",
             "Insert","InsertStep",
             "QkFilterFile","QkFilterCat","QkFilterTag","QkMoveFile","QkAssignCat","QkAssignTag"]
    m := Map()
    for k in keys
        m[k] := _HkDisplay(k)   ; show the effective key (default-filled, or a disable sentinel), so the field reflects reality
    return JSON.Dump(m)
}

_SaveHotkeySettings(msg) {
    global inifile
    keys := ["OpenGui","MarkWord","StepNext","Undo","LastFired","CapsCapture",
             "New","Update","Delete","FilterFile","FilterCat","FilterTag",
             "AssignCat","AssignTag","SwitchField","AiSuggest","Layout","OnTop",
             "MoveFile","Settings","EditFile","LastEdited","Dupes","Panel",
             "Insert","InsertStep",
             "QkFilterFile","QkFilterCat","QkFilterTag","QkMoveFile","QkAssignCat","QkAssignTag"]
    for k in keys
        if msg.Has(k)
            IniWrite(msg[k], inifile, "Hotkeys", k)
    ; Apply hotkeys at runtime immediately
    InitGlobalHotkeys()
    InitGuiHotkeys()
    ; Re-init step key (may have changed)
    global g_stepKey
    newStepKey := _HkEffective("StepNext")
    if (g_stepKey != "" && g_stepKey != newStepKey)
        try Hotkey(g_stepKey, "Off")
    g_stepKey := newStepKey
    if (g_stepKey != "")
        try Hotkey(g_stepKey, StepNextHotkey, "On")
    ApplyStepPrevHotkey()
}

; ── Popup settings ─────────────────────────────────────────────────────────────

LoadPopupSettings() {
    ; Initial values already read inline when globals are declared. Nothing extra needed here.
}

LoadPopupHotkeys() {
    global g_hintInsertKey, g_hintUpKey, g_hintDownKey, g_hintNumMod, inifile
    HotIf((*) => HintShown())
    if (g_hintInsertKey != "")
        try Hotkey(g_hintInsertKey, "Off")
    if (g_hintUpKey != "")
        try Hotkey(g_hintUpKey, "Off")
    if (g_hintDownKey != "")
        try Hotkey(g_hintDownKey, "Off")
    try Hotkey("Escape", "Off")
    ; Turn off old digit hotkeys (bare digits for migration, plus any modifier variant)
    Loop 9 {
        try Hotkey(String(A_Index), "Off")
        if (g_hintNumMod != "")
            try Hotkey(g_hintNumMod . String(A_Index), "Off")
    }
    newInsert := Trim(IniRead(inifile, "Popup", "InsertKey", "^Space"))
    newUp     := Trim(IniRead(inifile, "Popup", "UpKey",     "Up"))
    newDown   := Trim(IniRead(inifile, "Popup", "DownKey",   "Down"))
    newNumMod := _ReadNumKeySetting()
    if (newInsert != "")
        try Hotkey(newInsert, (*) => HintInsert(), "On")
    if (newUp != "")
        try Hotkey(newUp, (*) => HintNav("Up"), "On")
    if (newDown != "")
        try Hotkey(newDown, (*) => HintNav("Down"), "On")
    try Hotkey("Escape", (*) => HintHide(), "On")
    if (newNumMod != "") {
        fn9 := (hk, *) => HintInsertByIndex(Integer(SubStr(hk, -1)))
        Loop 9
            try Hotkey(newNumMod . String(A_Index), fn9, "On")
    }
    HotIf()
    g_hintInsertKey := newInsert
    g_hintUpKey     := newUp
    g_hintDownKey   := newDown
    g_hintNumMod    := newNumMod
    global g_hintFootCtl
    if (IsSet(g_hintFootCtl) && IsObject(g_hintFootCtl))
        try g_hintFootCtl.Value := _HintFooterText()
}

; Popup footer reflecting the actual key bindings (e.g. "Ctrl+1-9: välj direkt")
_HintFooterText() {
    global g_hintNumMod, g_hintInsertKey
    t := " "
    if (g_hintNumMod != "")
        t .= _HkPretty(g_hintNumMod) "1-9: välj direkt  ·  "
    t .= _HkPretty(g_hintInsertKey != "" ? g_hintInsertKey : "^Space")
       . " / Klick: infoga  ·  ↑↓: bläddra  ·  Esc: stäng"
    return t
}

_HkPretty(k) {
    ; "+" must be replaced before every other pass — the others insert literal "+"
    ; separators, and a later +→Shift+ pass would mangle them
    ; ("^Space" → "Ctrl+Space" → "CtrlShift+Space")
    k := StrReplace(k, "+", "Shift+")
    k := StrReplace(k, "<^>!", "AltGr+")
    k := StrReplace(k, "^", "Ctrl+")
    k := StrReplace(k, "!", "Alt+")
    k := StrReplace(k, "#", "Win+")
    return k
}

BuildPopupSettingsJson() {
    global inifile
    return JSON.Dump(Map(
        "enabled",   Integer(IniRead(inifile, "Popup", "Enabled",   1)),
        "fuzzy",     Integer(IniRead(inifile, "Popup", "Fuzzy",     0)),
        "chars",     Integer(IniRead(inifile, "Popup", "Chars",     2)),
        "timeout",   Integer(IniRead(inifile, "Popup", "Timeout",   5)),
        "insertKey", IniRead(inifile, "Popup", "InsertKey", "^Space"),
        "upKey",     IniRead(inifile, "Popup", "UpKey",     "Up"),
        "downKey",   IniRead(inifile, "Popup", "DownKey",   "Down"),
        "numKey",    _ReadNumKeySetting()))
}

; Ctrl+digit is the default. "off" = explicitly disabled; a legacy EMPTY value
; (older builds wrote NumKey= when nothing was chosen) also gets the default.
_ReadNumKeySetting() {
    global inifile
    nk := Trim(IniRead(inifile, "Popup", "NumKey", "^"))
    return (nk = "off") ? "" : (nk = "" ? "^" : nk)
}

; ── Dynamic field settings ─────────────────────────────────────────────────────

LoadDynamicSettings() {
    global inifile, g_dynAppModes, g_stepLabels, g_stepKey
    g_dynAppModes := []
    raw := IniRead(inifile, "DynAppModes", "modes", "")
    for pair in StrSplit(raw, "|") {
        parts := StrSplit(pair, "=")
        if (parts.Length >= 2)
            g_dynAppModes.Push(Map("app", Trim(parts[1]), "mode", Trim(parts[2])))
    }
    g_stepLabels := []
    labelsRaw := IniRead(inifile, "DynamicFields", "StepLabels", "")
    for lbl in StrSplit(labelsRaw, "|")
        if ((lbl := Trim(lbl)) != "")
            g_stepLabels.Push(lbl)
    g_stepKey := _HkEffective("StepNext")
}

BuildDynamicSettingsJson() {
    global inifile, g_dynAppModes
    modesArr := []
    for row in g_dynAppModes
        modesArr.Push(Map("app", row["app"], "mode", row["mode"]))
    return JSON.Dump(Map(
        "defaultMode", IniRead(inifile, "DynamicFields", "DefaultMode", "auto"),
        "stepLabels",  IniRead(inifile, "DynamicFields", "StepLabels",  ""),
        "appModes",    modesArr))
}

_SaveDynamicSettings(msg) {
    global inifile, g_dynAppModes, g_stepLabels, g_dynMode, g_pasteMode, g_pasteMinLen
    IniWrite(msg.Has("defaultMode") ? msg["defaultMode"] : "auto", inifile, "DynamicFields", "DefaultMode")
    IniWrite(msg.Has("stepLabels")  ? msg["stepLabels"]  : "",     inifile, "DynamicFields", "StepLabels")
    ; Apply changes at runtime immediately
    g_dynMode := msg.Has("defaultMode") ? msg["defaultMode"] : "auto"
    g_stepLabels := []
    labelsRaw := msg.Has("stepLabels") ? msg["stepLabels"] : ""
    for lbl in StrSplit(labelsRaw, "|")
        if ((lbl := Trim(lbl)) != "")
            g_stepLabels.Push(lbl)
    g_dynAppModes := []
    if msg.Has("appModes") {
        for row in msg["appModes"] {
            app  := row.Has("app")  ? row["app"]  : ""
            mode := row.Has("mode") ? row["mode"] : "auto"
            if (app != "")
                g_dynAppModes.Push(Map("app", app, "mode", mode))
        }
    }
    parts := []
    for row in g_dynAppModes
        parts.Push(row["app"] "=" row["mode"])
    IniWrite(ArrJoin(parts, "|"), inifile, "DynAppModes", "modes")
}

; Insertion method — moved out of "Dynamic fields", where it never belonged: it
; governs every expansion, not only those with {fields}. The ini keys stay in the
; [dynamic] section so nobody's existing choice is silently reset.
_ReadPasteSettings() {
    global inifile
    return Map("pasteMode",   IniRead(inifile, "dynamic", "paste_mode",    "auto")
             , "pasteMinLen", IniRead(inifile, "dynamic", "paste_min_len", 30) + 0)
}

_SavePasteSettings(msg) {
    global inifile, g_pasteMode, g_pasteMinLen
    if msg.Has("pasteMode")
        g_pasteMode := StrLower(msg["pasteMode"])
    if msg.Has("pasteMinLen")
        g_pasteMinLen := Integer(msg["pasteMinLen"])
    IniWrite(g_pasteMode,   inifile, "dynamic", "paste_mode")
    IniWrite(g_pasteMinLen, inifile, "dynamic", "paste_min_len")
}

; ── Per-file settings (@expanto header) ───────────────────────────────────────

ReadFileSettings(filepath) {
    settings := Map("label", "", "metaFields", "", "defaultCat", "")
    try {
        text  := PhraseFileRead(filepath)
        lines := StrSplit(text, "`n", "`r")
        maxScan := Min(lines.Length, 30)
        loop maxScan {
            trimmed := Trim(lines[A_Index])
            if RegExMatch(trimmed, "^;\s*@expanto\s+(\w+):\s*(.*)", &m)
                settings[m[1]] := Trim(m[2])
        }
    }
    return settings
}

BuildFileSettingsJson(filepath) {
    s := ReadFileSettings(filepath)
    return JSON.Dump(Map(
        "path",          filepath,
        "label",         s["label"],
        "metaFields",    s["metaFields"],
        "defaultCat",    s["defaultCat"],
        "groupField",   s.Has("groupField")   ? s["groupField"]   : "",
        "titleFields",  s.Has("titleFields")  ? s["titleFields"]  : "",
        "titlePattern", s.Has("titlePattern") ? s["titlePattern"] : "",
        "sharedFields", s.Has("sharedFields") ? s["sharedFields"] : "",
        "hidden",       (s.Has("hidden") && s["hidden"] = "1") ? 1 : 0))
}

WriteFileSettings(filepath, settings) {
    try {
        text     := PhraseFileRead(filepath)
        lines    := StrSplit(text, "`n", "`r")
        cleaned  := []
        for line in lines
            if !RegExMatch(Trim(line), "^;\s*@expanto\s+")
                cleaned.Push(line)
        ; Remove leading blank lines from content
        while cleaned.Length && Trim(cleaned[1]) = ""
            cleaned.RemoveAt(1)
        ; Build header in fixed order
        orderedKeys := ["label", "defaultCat", "metaFields", "groupField", "titleFields", "titlePattern", "sharedFields", "hidden"]
        header := []
        for k in orderedKeys
            if (settings.Has(k) && Trim(settings[k]) != "")
                header.Push("; @expanto " k ": " settings[k])
        ; Assemble
        result := header
        if (header.Length && cleaned.Length)
            result.Push("")
        for l in cleaned
            result.Push(l)
        PhraseFileWriteAll(filepath, ArrJoin(result, "`n"))
    }
}

BuildFilesJson() {
    global HS_folders_ALL
    arr := []
    for folder in HS_folders_ALL {
        for file in folder.files {
            fs := ReadFileSettings(file.fullpath)
            arr.Push(Map(
                "path",       file.fullpath,
                "name",       file.name,
                "folder",     folder.id,
                "folderPath", folder.path,
                "hsOn",       FileHsEnabled(file.fullpath)    ? 1 : 0,
                "hintTOn",    FileHintTEnabled(file.fullpath) ? 1 : 0,
                "hintPOn",    FileHintPEnabled(file.fullpath) ? 1 : 0,
                "label",        fs["label"],
                "metaFields",   fs["metaFields"],
                "defaultCat",   fs["defaultCat"],
                "groupField",   fs.Has("groupField")   ? fs["groupField"]   : "",
                "titleFields",  fs.Has("titleFields")  ? fs["titleFields"]  : "",
                "titlePattern", fs.Has("titlePattern") ? fs["titlePattern"] : "",
                "sharedFields", fs.Has("sharedFields") ? fs["sharedFields"] : "",
                "hidden",       (fs.Has("hidden") && fs["hidden"] = "1") ? 1 : 0))
        }
    }
    return JSON.Dump(arr)
}

BuildSettingsJson() {
    global HS_folders_ALL, g_disabledFolders, g_hiddenFolders, g_ignoreFolders, inifile
    folders := []
    seen := Map()
    ; active folders (already parsed)
    for folder in HS_folders_ALL {
        seen[folder.id] := true
        folders.Push(Map("id", folder.id, "path", folder.path, "enabled", true))
    }
    ; disabled folders from ini
    for s in StrSplit(IniRead(inifile, "folders_disabled", "paths", ""), "|") {
        if ((s := Trim(s)) = "" || seen.Has(s))
            continue
        ; try to get the path from ini
        p := ""
        try p := IniRead(inifile, "PhraseFolders", s)
        folders.Push(Map("id", s, "path", p, "enabled", false))
    }
    return JSON.Dump(Map("folders", folders, "hiddenFolders", g_hiddenFolders
        , "ignoreFolders", ArrJoin(g_ignoreFolders, "|")))
}

DisabledFoldersAdd(id) {
    global inifile, g_disabledFolders
    for d in g_disabledFolders
        if (d = id)
            return
    g_disabledFolders.Push(id)
    SaveDisabledFolders()
}

DisabledFoldersRemove(id) {
    global g_disabledFolders
    newList := []
    for d in g_disabledFolders
        if (d != id)
            newList.Push(d)
    g_disabledFolders := newList
    SaveDisabledFolders()
}

SaveDisabledFolders() {
    global inifile, g_disabledFolders
    IniWrite(ArrJoin(g_disabledFolders, "|"), inifile, "folders_disabled", "paths")
}

PhraseToMap(hs) {
    m := Map()
    m["id"]       := hs.id
    m["opts"]     := (hs.options != "") ? ":" hs.options "::" : "::"
    m["options"]  := hs.options
    m["trigger"]  := hs.short
    ; hs.long keeps the on-disk escaped form (`n etc.); the editor needs real
    ; newlines, same as the insertion path which also Unescape_CC's hs.long.
    m["phrase"]   := Unescape_CC(hs.long)
    m["cat"]      := hs.category
    m["file"]     := hs.filepath
    m["tags"]     := ArrJoin(hs.tags, ",")
    m["comment"]  := hs.comment
    m["lang"]     := hs.language
    m["disabled"] := hs.disabled ? 1 : 0
    m["aliases"]      := ArrJoin(hs.aliases, ",")
    m["apps"]         := ArrJoin(hs.apps, ",")
    m["customFields"]  := IsObject(hs.customFields) ? hs.customFields : Map()
    m["lastupdated"]   := hs.lastupdated
    m["url"]           := hs.HasOwnProp("url") ? hs.url : ""
    m["alts"]          := _HsAlts(hs)
    m["altNames"]      := _HsAltNames(hs)
    return m
}

; ══════════════════════════════════════════════════════════════════════════════
; HS_ALL helpers
; ══════════════════════════════════════════════════════════════════════════════

FindHsById(id) {
    global HS_ALL
    for hs in HS_ALL
        if (hs.id = id)
            return hs
    return ""
}

FirstWritableFile() {
    global HS_folders_ALL
    for folder in HS_folders_ALL
        for file in folder.files
            if !IsEncPhrasePath(file.fullpath)
                return file.fullpath
    return ""
}

SavePhraseFromJs(p) {
    hs        := FindHsById(p["id"])
    origShort := hs ? hs.short : p["trigger"]
    newShort  := Trim(p["trigger"])
    options   := p.Has("options") ? p["options"] : (hs ? hs.options : "")
    disabled  := p.Has("disabled") ? p["disabled"] : 0
    aliases   := p.Has("aliases")  ? p["aliases"]  : ""
    apps      := p.Has("apps")     ? p["apps"]     : (hs ? ArrJoin(hs.apps, ",") : "")
    cf        := p.Has("customFields") ? p["customFields"] : Map()
    url       := p.Has("url") ? p["url"] : (hs ? (hs.HasOwnProp("url") ? hs.url : "") : "")
    alts      := p.Has("alts") ? p["alts"] : (hs ? _HsAlts(hs) : "")
    altNames  := p.Has("altNames") ? p["altNames"] : (hs ? _HsAltNames(hs) : "")
    SaveHotstring(p["file"], origShort, options,
        p["phrase"], p["cat"], p["comment"],
        aliases, FormatTime(, "yyyy-MM-dd'T'HH:mm:ss"), apps, p["tags"], p["lang"], , disabled, newShort, cf, url, alts, altNames)
    ; Refresh the in-memory copy too: "Spara & infoga" fires DoDirectInsert before the
    ; deferred file rebuild, so the variant picker/insert must not see stale text.
    if (hs) {
        hs.long     := Escape_CC(p["phrase"])
        hs.alts     := IsObject(alts) ? alts : []
        hs.altNames := IsObject(altNames) ? altNames : []
    }
}

; Phase 3: push changed shared-field values to group-mates (same key value, same file).
; Runs on a freshly reloaded HS_ALL, so the just-saved phrase already matches and is skipped.
ApplyPropagations(filepath, props) {
    global HS_ALL
    if (!IsObject(props))
        return false
    touched := false
    for prop in props {
        kf  := prop.Has("keyField") ? prop["keyField"] : ""
        kv  := prop.Has("keyValue") ? prop["keyValue"] : ""
        fld := prop.Has("field")    ? prop["field"]    : ""
        val := prop.Has("value")    ? prop["value"]    : ""
        if (kf = "" || kv = "" || fld = "")
            continue
        for hs in HS_ALL {
            if (hs.filepath != filepath || !IsObject(hs.customFields))
                continue
            if (hs.customFields.Has(kf) && hs.customFields[kf] = kv
                && (!hs.customFields.Has(fld) || hs.customFields[fld] != val)) {
                cf := hs.customFields.Clone()
                cf[fld] := val
                SaveHotstring(hs.filepath, hs.short, hs.options, hs.long, hs.category, hs.comment,
                    ArrJoin(hs.aliases, ","), , ArrJoin(hs.apps, ","), ArrJoin(hs.tags, ","), hs.language, ,
                    hs.disabled, , cf, hs.url, _HsAlts(hs), _HsAltNames(hs))
                touched := true
            }
        }
    }
    return touched
}

RebuildFileSimple(filepath) {
    global HS_ALL, HS_folders_ALL
    newList := []
    for hs in HS_ALL
        if (hs.filepath != filepath)
            newList.Push(hs)

    folderpath := "", folderid := ""
    for folder in HS_folders_ALL
        for file in folder.files
            if (file.fullpath = filepath) {
                folderpath := folder.path
                folderid   := folder.id
                break 2
            }

    try {
        hsList := ParseHotstringFile(filepath, folderpath, folderid)
        for hs in hsList
            newList.Push(hs)
    }
    HS_ALL := newList
}

; Rebuild one file in HS_ALL, then re-register all hotstrings
RebuildAndReload(filepath) {
    global HS_ALL
    ; Disable hotstrings from old data before rebuilding
    for hs in HS_ALL
        if (hs.filepath = filepath)
            try Hotstring(":" hs.options ":" hs.short, HsAction(hs), 0)
    RebuildFileSimple(filepath)
    init_hotstrings()
}

; Fast single-file rebuild: disables/re-registers only that file's hotstrings (not all)
_RebuildFileOnly(filepath) {
    global HS_ALL
    for hs in HS_ALL
        if (hs.filepath = filepath)
            try Hotstring(":" hs.options ":" hs.short, HsAction(hs), 0)
    RebuildFileSimple(filepath)
    en := FileHsEnabled(filepath) ? 1 : 0
    for hs in HS_ALL {
        if (hs.filepath != filepath || hs.disabled)
            continue
        try {
            Hotstring(":" hs.options ":" hs.short, HsAction(hs), en)
            for alias in hs.aliases
                Hotstring(":" hs.options ":" alias, HsAction(hs), en)
        }
    }
}

; Deferred save+rebuild for "Spara & infoga": runs after insert so file I/O never blocks UI
_DeferredSave(p, filepath) {
    global wv2Core
    SavePhraseFromJs(p)
    _RebuildFileOnly(filepath)
    if IsObject(wv2Core)
        _SafeSend(wv2Core, "window.initData(" BuildPhrasesJson() ")")
}

; Deferred rebuild used by fast insert path: called after window is hidden
_RebuildAndNotify(filepath, extraFile := "") {
    global wv2Core
    _RebuildFileOnly(filepath)
    if (extraFile != "")
        _RebuildFileOnly(extraFile)
    if IsObject(wv2Core)
        _SafeSend(wv2Core, "window.initData(" BuildPhrasesJson() ")")
}

; ══════════════════════════════════════════════════════════════════════════════
; File I/O — .enc paths routed through enc_phrases.ahk
; ══════════════════════════════════════════════════════════════════════════════

IsEncPhrasePath(path) => StrLower(SubStr(path, -4)) = ".enc"

EncLoaded() => IsSet(g_encModule)

PhraseFileRead(path, *) {
    if IsEncPhrasePath(path) {
        return EncFileRead(path)
    }
    return FileRead(path, "UTF-8")
}

_RotateBackups(path) {
    if FileExist(path ".bak2")
        try FileMove(path ".bak2", path ".bak3", 1)
    if FileExist(path ".bak1")
        try FileMove(path ".bak1", path ".bak2", 1)
    if FileExist(path)
        try FileCopy(path, path ".bak1", 1)
}

PhraseFileWriteAll(path, text) {
    if IsEncPhrasePath(path) {
        EncFileWrite(path, text)
        return
    }
    _RotateBackups(path)
    FileDelete(path)
    FileAppend(text, path, "UTF-8")
    _FileWatcherUpdateMtime(path)          ; don't let watcher react to our own write
}

PhraseFileAppend(path, text) {
    if IsEncPhrasePath(path) {
        existing := FileExist(path) ? EncFileRead(path, true) : ""
        EncFileWrite(path, existing . text)
        return
    }
    FileAppend(text, path, "UTF-8")
    _FileWatcherUpdateMtime(path)
}

; ══════════════════════════════════════════════════════════════════════════════
; File watcher — reload phrase files edited externally (e.g. in a text editor)
; ══════════════════════════════════════════════════════════════════════════════

FileWatcherInit() {
    global g_fileMtimes, g_folderMtimes, HS_ALL, HS_folders_ALL
    g_fileMtimes := Map()
    for hs in HS_ALL
        if !IsEncPhrasePath(hs.filepath) && !g_fileMtimes.Has(hs.filepath)
            g_fileMtimes[hs.filepath] := FileExist(hs.filepath) ? FileGetTime(hs.filepath, "M") : ""
    g_folderMtimes := Map()
    for folder in HS_folders_ALL
        g_folderMtimes[folder.path] := FileExist(folder.path) ? FileGetTime(folder.path, "M") : ""
    SetTimer(FileWatcherPoll, 3000)
}

_FileWatcherUpdateMtime(path) {
    global g_fileMtimes, g_folderMtimes, g_lastSaveTimes
    g_lastSaveTimes[path] := A_TickCount
    if g_fileMtimes.Has(path)
        g_fileMtimes[path] := FileExist(path) ? FileGetTime(path, "M") : ""
    ; _RotateBackups + FileDelete + FileAppend all change the parent folder's mtime;
    ; update the folder cache and record it in g_lastSaveTimes (covers cloud-sync mtime lag too)
    folderPath := SubStr(path, 1, InStr(path, "\",, -1) - 1)
    g_lastSaveTimes[folderPath] := A_TickCount
    if g_folderMtimes.Has(folderPath)
        g_folderMtimes[folderPath] := FileExist(folderPath) ? FileGetTime(folderPath, "M") : ""
}

FileWatcherPoll() {
    global g_fileMtimes, g_folderMtimes, wv2Core
    ; Detect new or deleted phrase files by checking folder mtimes
    for folderPath, oldMtime in g_folderMtimes {
        newMtime := FileExist(folderPath) ? FileGetTime(folderPath, "M") : ""
        if (newMtime != oldMtime) {
            g_folderMtimes[folderPath] := newMtime
            if g_lastSaveTimes.Has(folderPath) && (A_TickCount - g_lastSaveTimes[folderPath]) < 30000 {
                g_lastSaveTimes.Delete(folderPath)
                continue
            }
            ToolTip(_AT("watcher.updated"))
            SetTimer(() => ToolTip(), -2000)
            ReloadPhrases()
            return
        }
    }
    changed := []
    for path, oldMtime in g_fileMtimes {
        newMtime := FileExist(path) ? FileGetTime(path, "M") : ""
        if (newMtime != oldMtime) {
            g_fileMtimes[path] := newMtime
            ; Ignore mtime changes from our own recent writes (e.g. cloud-sync mtime lag)
            if g_lastSaveTimes.Has(path) && (A_TickCount - g_lastSaveTimes[path]) < 30000 {
                g_lastSaveTimes.Delete(path)
                continue
            }
            changed.Push(path)
        }
    }
    if (!changed.Length)
        return
    for path in changed
        _RebuildFileOnly(path)
    if IsSet(wv2Core)
        _SafeSend(wv2Core,"window.initData(" BuildPhrasesJson() ")")
    ToolTip(_AT("watcher.updated"))
    SetTimer(() => ToolTip(), -2000)
}

; ══════════════════════════════════════════════════════════════════════════════
; Phrase loading (extracted from Expanto.ahk)
; ══════════════════════════════════════════════════════════════════════════════

IniSectionLines(header) {
    global inifile
    out := [], inSec := false, text := ""
    try text := FileRead(inifile, "UTF-8")
    for raw in StrSplit(text, "`n", "`r") {
        line := Trim(raw)
        if (line = "" || SubStr(line, 1, 1) = ";")
            continue
        if (SubStr(line, 1, 1) = "[") {
            inSec := (line = header)
            continue
        }
        if inSec
            out.Push(line)
    }
    return out
}

PhraseFolderLines() => IniSectionLines("[PhraseFolders]")

LoadDisabledFolders() {
    global inifile, g_disabledFolders
    g_disabledFolders := []
    for s in StrSplit(IniRead(inifile, "folders_disabled", "paths", ""), "|")
        if ((s := Trim(s)) != "")
            g_disabledFolders.Push(s)
}

FolderDisabled(id) {
    global g_disabledFolders
    for d in g_disabledFolders
        if (d = id)
            return true
    return false
}

; Hiding works on two levels: a file can be hidden on its own, and a whole
; folder can be hidden. Both must be cleared for a file to reappear —
; otherwise "show folder" or a preset that makes files visible looks broken.
FolderIdOfFile(path) {
    dir := ""
    try dir := RegExReplace(path, "\\[^\\]+$", "")
    return dir = "" ? "" : RegExReplace(dir, "[^a-zA-Z0-9]", "_")
}

; Drops the given folder IDs from the hidden list. Returns true if anything
; changed (so the caller knows to save + push new settings).
HiddenFoldersRemove(ids) {
    global g_hiddenFolders
    keep := [], changed := false
    for h in g_hiddenFolders {
        drop := false
        for id in ids
            if (h = id) {
                drop := true
                break
            }
        if drop
            changed := true
        else
            keep.Push(h)
    }
    if changed
        g_hiddenFolders := keep
    return changed
}

FolderIsHidden(fid) {
    global g_hiddenFolders
    for h in g_hiddenFolders
        if (h = fid)
            return true
    return false
}

; Sets the per-file "hidden" flag on every phrase file in a folder except the
; given ones — used to push a hidden folder's state down onto its files.
HideFilesInFolderExcept(folderPath, keepPaths) {
    if (folderPath = "" || !DirExist(folderPath))
        return
    keep := Map()
    for k in keepPaths
        keep[StrLower(k)] := true
    for pattern in ["\*.ahk", "\*.enc"] {
        Loop Files, folderPath pattern, "R" {
            if PathHasIgnoredSegment(A_LoopFileFullPath, folderPath)
                continue
            if keep.Has(StrLower(A_LoopFileFullPath))
                continue
            s := ReadFileSettings(A_LoopFileFullPath)
            if (!s.Has("hidden") || s["hidden"] = "") {
                s["hidden"] := "1"
                WriteFileSettings(A_LoopFileFullPath, s)
            }
        }
    }
}

; Making individual files visible inside a hidden folder: the folder has to
; come out of hiding (or the files stay invisible), but its OTHER files must
; stay hidden — so the folder's hidden-ness is written down onto them first.
; Returns true when the hidden-folder list changed.
PromoteFilesOutOfHiddenFolder(paths) {
    global inifile
    ids := Map()
    for p in paths
        if ((fid := FolderIdOfFile(p)) != "")
            ids[fid] := true
    changed := false
    for fid in ids {
        if !FolderIsHidden(fid)
            continue
        HideFilesInFolderExcept(IniRead(inifile, "PhraseFolders", fid, ""), paths)
        if HiddenFoldersRemove([fid])
            changed := true
    }
    if changed
        SaveHiddenFolders()
    return changed
}

; Clears the per-file "hidden" setting for every phrase file in a folder.
UnhideFilesInFolder(folderPath) {
    if (folderPath = "" || !DirExist(folderPath))
        return
    for pattern in ["\*.ahk", "\*.enc"] {
        Loop Files, folderPath pattern, "R" {
            if PathHasIgnoredSegment(A_LoopFileFullPath, folderPath)
                continue
            s := ReadFileSettings(A_LoopFileFullPath)
            if (s.Has("hidden") && s["hidden"] != "") {
                s["hidden"] := ""
                WriteFileSettings(A_LoopFileFullPath, s)
            }
        }
    }
}

LoadHiddenFolders() {
    global inifile, g_hiddenFolders
    g_hiddenFolders := []
    for s in StrSplit(IniRead(inifile, "folders_hidden", "paths", ""), "|")
        if ((s := Trim(s)) != "")
            g_hiddenFolders.Push(s)
}

SaveHiddenFolders() {
    global inifile, g_hiddenFolders
    IniWrite(ArrJoin(g_hiddenFolders, "|"), inifile, "folders_hidden", "paths")
}

; Archive and backup subfolders sit next to the live phrase files and hold old
; copies of them. The folder scan is recursive, so without this every archived
; copy would load as a duplicate of the phrase it was a backup of.
LoadIgnoreFolders() {
    global inifile, g_ignoreFolders
    g_ignoreFolders := []
    for s in StrSplit(IniRead(inifile, "General", "IgnoreFolders", IgnoreFoldersDefault()), "|")
        if ((s := Trim(s)) != "")
            g_ignoreFolders.Push(s)
}

SaveIgnoreFolders() {
    global inifile, g_ignoreFolders
    IniWrite(ArrJoin(g_ignoreFolders, "|"), inifile, "General", "IgnoreFolders")
}

IgnoreFoldersDefault() {
    return "Backups|Backup|Archive|_archive|_gammalt"
}

; True when any directory level of path below root matches an ignored name.
; The last segment is the file name itself and is never matched.
PathHasIgnoredSegment(path, root) {
    global g_ignoreFolders
    if (g_ignoreFolders.Length = 0)
        return false
    rel := path
    if (root != "") {
        root := RTrim(root, "\")
        if (SubStr(path, 1, StrLen(root)) = root)
            rel := SubStr(path, StrLen(root) + 1)
    }
    parts := StrSplit(rel, "\")
    Loop (parts.Length - 1) {
        seg := Trim(parts[A_Index])
        if (seg = "")
            continue
        for ign in g_ignoreFolders
            if (seg = ign)
                return true
    }
    return false
}

populate_HS_files_ALL() {
    global HS_folders_ALL
    HS_folders_ALL := []
    for line in PhraseFolderLines() {
        if (Trim(line) = "")
            continue
        parts      := StrSplit(line, "=", , 2)
        folderId   := Trim(parts[1])
        folderPath := Trim(parts[2])
        if FolderDisabled(folderId)
            continue
        folderObj := { id: folderId, path: folderPath, files: [] }
        for pattern in ["\*.ahk", "\*.enc"] {
            Loop Files, folderPath pattern, "R" {
                if PathHasIgnoredSegment(A_LoopFileFullPath, folderPath)
                    continue
                folderObj.files.Push({ name: A_LoopFileName, fullpath: A_LoopFileFullPath })
            }
        }
        HS_folders_ALL.Push(folderObj)
    }
}

Build_HS_ALL() {
    global HS_ALL, HS_folders_ALL
    HS_ALL := []
    for folder in HS_folders_ALL
        for file in folder.files {
            try {
                hsList := ParseHotstringFile(file.fullpath, folder.path, folder.id)
                for hs in hsList
                    HS_ALL.Push(hs)
            }
        }
}

ParseHotstringFile(path, folderpath, folderid) {
    local m, mc, ml, mm, mt, md, ma, mapp, mf, mpos, mlu, murl, customFields, knownMeta, cfk
    out   := []
    text  := PhraseFileRead(path)
    lines := StrSplit(text, "`n")
    i     := 0
    while (i < lines.Length) {
        i++
        line := Trim(lines[i])
        if (line = "" || SubStr(line, 1, 1) = ";")
            continue
        if !RegExMatch(line, "^:([^:]*):([^:]+)::(.*?)(?:\s*;\s*(.*))?$", &m)
            continue

        options := m[1]
        short   := m[2]
        long    := Trim(m[3])
        meta    := m[4]

        ; Multi-line continuation block
        if (long = "" && i < lines.Length && Trim(lines[i + 1]) = "(") {
            i++
            longParts := []
            while (i < lines.Length) {
                i++
                contLine    := RTrim(lines[i], "`r")
                trimmedCont := Trim(contLine)
                if (SubStr(trimmedCont, 1, 1) = ")") {
                    if (meta = "" && RegExMatch(trimmedCont, "^\)\s*;\s*(.*)", &mc))
                        meta := Trim(mc[1])
                    break
                }
                longParts.Push(contLine)
            }
            long := ArrJoin(longParts, "`n")
        }

        category := "", language := "", comment := "", tags := [], aliases := [], apps := [], disabled := false, lastupdated := "", url := "", alts := [], altNames := []
        customFields := Map()

        if meta {
            if RegExMatch(meta, "cat=([^\s;|]+)", &mc)
                category := mc[1]
            if RegExMatch(meta, "lang=([^\s;|]+)", &ml)
                language := ml[1]
            if RegExMatch(meta, "comment=(.*?)(?=\||$)", &mm)
                comment := StrReplace(Trim(mm[1]), "``n", "`n")
            if RegExMatch(meta, "tags=([^|]*)", &mt)
                for t in StrSplit(mt[1], ",")
                    if ((t := Trim(t)) != "")
                        tags.Push(t)
            if RegExMatch(meta, "disabled=([01])", &md)
                disabled := (md[1] = "1")
            if RegExMatch(meta, "aliases=([^\s;|]+)", &ma)
                for a in StrSplit(ma[1], ",")
                    if ((a := Trim(a)) != "")
                        aliases.Push(a)
            if RegExMatch(meta, "apps=([^\s;|]+)", &mapp)
                for a in StrSplit(mapp[1], ",")
                    if ((a := Trim(a)) != "")
                        apps.Push(a)
            if RegExMatch(meta, "lastupdated=([^\s;|]+)", &mlu)
                lastupdated := mlu[1]
            ; Optional link (file path or URL); may contain spaces, so read up to | or end
            if RegExMatch(meta, "url=(.*?)(?=\||$)", &murl)
                url := Trim(murl[1])
            ; Alternative phrase texts (serialized — contains no raw | or =)
            if RegExMatch(meta, "(?:^|\|)alts=(.*?)(?=\||$)", &malts)
                alts := MetaToAlts(malts[1])
            ; Variant names (positional: 1 = main phrase, i+1 = alt i)
            if RegExMatch(meta, "(?:^|\|)altnames=(.*?)(?=\||$)", &mnames)
                altNames := MetaToNames(mnames[1])
            ; Collect unknown key=value pairs as custom fields
            ; Custom (per-file) fields are the meta pairs that aren't built in.
            ; Split on "|" and then on the FIRST "=" instead of scanning with a
            ; regex: a key pattern of \w+ silently dropped everything before a
            ; space ("SID lab" became "lab", so {SID lab} never resolved) and
            ; also cut values at the first space; \w is ASCII-only in AHK, so
            ; keys with åäö lost their first letter too.
            customFields := Map()
            knownMeta := Map("cat",1,"lang",1,"comment",1,"tags",1,"disabled",1,"priority",1,"aliases",1,"apps",1,"lastupdated",1,"url",1,"alts",1,"altnames",1)
            for part in StrSplit(meta, "|") {
                eq := InStr(part, "=")
                if !eq
                    continue
                cfk := Trim(SubStr(part, 1, eq - 1))
                if (cfk = "" || knownMeta.Has(StrLower(cfk)))
                    continue
                customFields[cfk] := SubStr(part, eq + 1)
            }
        }

        out.Push({
            id:           path "|" short,
            options:      options,
            short:        short,
            long:         long,
            category:     category,
            language:     language,
            comment:      comment,
            tags:         tags,
            aliases:      aliases,
            apps:         apps,
            disabled:     disabled,
            lastupdated:  lastupdated,
            url:          url,
            alts:         alts,
            altNames:     altNames,
            customFields: customFields,
            filepath:     path,
            folderpath:   folderpath,
            folderid:     folderid
        })
    }
    return out
}

; ══════════════════════════════════════════════════════════════════════════════
; Phrase write-back (extracted from Expanto.ahk)
; ══════════════════════════════════════════════════════════════════════════════

; THE line as it goes into the .ahk file. Both write sites in SaveHotstring call
; this, and so does the editor's status-bar preview — the preview is worthless the
; moment it becomes a second, drifting copy of the format.
BuildPhraseLine(options, writtenShort, phrase, category, comment, lang, tags
              , disabled := 0, aliases := "", apps := "", customFields := ""
              , url := "", alts := "", altNames := "", preEscaped := false) {
    global g_ColCol, g_Semi
    meta := BuildMeta(category, comment, lang, tags, disabled, 0, aliases, apps, customFields, url, alts, altNames)
    body := preEscaped ? phrase : Escape_CC(phrase)   ; duplicate/move already hold on-disk form
    return ":" options ":" writtenShort g_ColCol body " " g_Semi " " meta
}

; Same line, from a phrase as it lives in HS_ALL. Duplicate, move and rename all
; rewrite phrases they did not author, and each used to assemble the format by hand.
BuildPhraseLineFromHs(hs, trigger, body, preEscaped := false) {
    return BuildPhraseLine(hs.options, trigger, body
        , hs.category, hs.comment, hs.language, ArrJoin(hs.tags, ",")
        , hs.disabled, ArrJoin(hs.aliases, ","), ArrJoin(hs.apps, ",")
        , hs.customFields, hs.url, _HsAlts(hs), _HsAltNames(hs), preEscaped)
}

; Bulk-ändring av många fraser: EN läsning och EN skrivning per berörd fil
; i stället för en hel filomskrivning per fras (883 fraser i samma fil blev
; 883 omskrivningar av filen). Fraser som byter fil tas via den gamla
; per-fras-vägen (sällsynt). Förloppet skickas till statusfältet.
_BulkSaveRun(ids, upd) {
    global wv2Core
    setCat     := upd.Has("_setCat")     && upd["_setCat"]
    setLang    := upd.Has("_setLang")    && upd["_setLang"]
    setComment := upd.Has("_setComment") && upd["_setComment"]
    setFile    := upd.Has("_setFile")    && upd["_setFile"]
    newCatVal  := upd.Has("cat")     ? upd["cat"]     : ""
    newLangVal := upd.Has("lang")    ? upd["lang"]    : ""
    newCmtVal  := upd.Has("comment") ? upd["comment"] : ""
    newFile    := upd.Has("file")    ? upd["file"]    : ""
    tagAdd     := upd.Has("tagAdd")    ? upd["tagAdd"]    : []
    tagRemove  := upd.Has("tagRemove") ? upd["tagRemove"] : []

    NewTagsFor(hs) {
        curTags := []
        for t in hs.tags
            curTags.Push(t)
        for t in tagAdd {
            already := false
            for c in curTags
                if (c = t) {
                    already := true
                    break
                }
            if !already
                curTags.Push(t)
        }
        newTags := []
        for t in curTags {
            skip := false
            for r in tagRemove
                if (r = t) {
                    skip := true
                    break
                }
            if !skip
                newTags.Push(t)
        }
        return newTags
    }

    total := ids.Length, done := 0
    ; Statussignal OMEDELBART - både förlopps-UX och diagnostik: syns inte
    ; "Uppdaterar 0/N" i statusfältet kom jobbet aldrig ens hit.
    try wv2Core.ExecuteScriptAsync("window.setBulkStatus(0.1," total ")")
    try FileAppend(FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") "  bulk start: " total " fraser`r`n"
        , A_ScriptDir "\bulk.log", "UTF-8")
    changedFiles := Map()
    perFile := Map()     ; filväg -> Map(trigger -> hs)
    movers := []
    for id in ids {
        hs := FindHsById(id)
        if !IsObject(hs)
            continue
        if (setFile && newFile != "" && newFile != hs.filepath) {
            movers.Push(hs)
            continue
        }
        if !perFile.Has(hs.filepath)
            perFile[hs.filepath] := Map()
        perFile[hs.filepath][hs.short] := hs
    }

    for fp, byShort in perFile {
        text  := PhraseFileRead(fp, true)
        lines := StrSplit(text, "`n")
        out := [], i := 0
        while (i < lines.Length) {
            i++
            line := lines[i]
            trimmed := Trim(line)
            if (RegExMatch(trimmed, "^:([^:]*):([^:]+)::(.*)", &m) && byShort.Has(m[2])) {
                hs := byShort[m[2]]
                byShort.Delete(m[2])   ; ersätt bara första förekomsten, som SaveHotstring
                out.Push(BuildPhraseLine(hs.options, hs.short, hs.long
                    , setCat ? newCatVal : hs.category
                    , setComment ? newCmtVal : hs.comment
                    , setLang ? newLangVal : hs.language
                    , ArrJoin(NewTagsFor(hs), ",")
                    , hs.disabled, ArrJoin(hs.aliases, ","), ArrJoin(hs.apps, ",")
                    , IsObject(hs.customFields) ? hs.customFields : Map(), hs.url
                    , _HsAlts(hs), _HsAltNames(hs)))
                done++
                ; hoppa över gammalt fortsättningsblock, precis som SaveHotstring
                bodyPart := Trim(m[3])
                if ((bodyPart = "" || SubStr(bodyPart, 1, 1) = ";") && i < lines.Length && Trim(lines[i + 1]) = "(") {
                    i++
                    while (i < lines.Length) {
                        i++
                        if SubStr(Trim(lines[i]), 1, 1) = ")"
                            break
                    }
                }
            } else {
                out.Push(line)
            }
        }
        joined := ""
        for j, l in out
            joined .= (j = 1 ? "" : "`n") l
        PhraseFileWriteAll(fp, joined)
        changedFiles[fp] := true
        try wv2Core.ExecuteScriptAsync("window.setBulkStatus(" done "," total ")")
    }

    for hs in movers {
        SaveHotstring(newFile, hs.short, hs.options, hs.long,
            setCat     ? newCatVal  : hs.category,
            setComment ? newCmtVal  : hs.comment,
            ArrJoin(hs.aliases, ","), , ArrJoin(hs.apps, ","),
            ArrJoin(NewTagsFor(hs), ","),
            setLang    ? newLangVal : hs.language,
            , hs.disabled, , IsObject(hs.customFields) ? hs.customFields : Map(), hs.url, _HsAlts(hs), _HsAltNames(hs))
        RemoveHotstringFromFile(hs.filepath, hs.short)
        changedFiles[hs.filepath] := true
        changedFiles[newFile] := true
        done++
        if (Mod(done, 10) = 0)
            try wv2Core.ExecuteScriptAsync("window.setBulkStatus(" done "," total ")")
    }

    ; RebuildAndReload kör init_hotstrings() - omregistrering av SAMTLIGA
    ; hotstrings - per anrop. Med 15 ändrade filer blev det 15 fulla
    ; omregistreringar: en lång, tyst svans efter själva filskrivningarna.
    ; Gör det filvisa (inaktivera + parsa om filen) per fil, men registrera
    ; om hotstrings EN gång.
    global HS_ALL
    for fp, _ in changedFiles {
        for hs in HS_ALL
            if (hs.filepath = fp)
                try Hotstring(":" hs.options ":" hs.short, HsAction(hs), 0)
        RebuildFileSimple(fp)
    }
    init_hotstrings()
    try FileAppend(FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") "  bulk klar: " done "/" total
        . " i " changedFiles.Count " fil(er)`r`n", A_ScriptDir "\bulk.log", "UTF-8")
    try wv2Core.ExecuteScriptAsync("window.setBulkStatus(0,0)")
    try wv2Core.ExecuteScriptAsync("window.initData(" BuildPhrasesJson() ")")
}

SaveHotstring(filepath, short, options, phrase, category, comment,
              aliases := "", lastupdated := "", apps := "",
              tags := "", lang := "", customMeta := "", disabled := 0, newShort := "", customFields := "", url := "", alts := "", altNames := "") {
    global g_ColCol, g_Semi
    writtenShort := (newShort != "" && newShort != short) ? newShort : short
    text     := PhraseFileRead(filepath, true)
    lines    := StrSplit(text, "`n")
    newLines := [], replaced := false, i := 0

    while (i < lines.Length) {
        i++
        line    := lines[i]
        trimmed := Trim(line)
        if (!replaced && RegExMatch(trimmed, "^:([^:]*):([^:]+)::(.*)", &m) && m[2] = short) {
            newLines.Push(BuildPhraseLine(options, writtenShort, phrase, category, comment
                        , lang, tags, disabled, aliases, apps, customFields, url, alts, altNames))
            replaced := true
            ; Skip old continuation block if present
            bodyPart := Trim(m[3])
            if ((bodyPart = "" || SubStr(bodyPart, 1, 1) = ";") && i < lines.Length && Trim(lines[i + 1]) = "(") {
                i++
                while (i < lines.Length) {
                    i++
                    if SubStr(Trim(lines[i]), 1, 1) = ")"
                        break
                }
            }
        } else {
            newLines.Push(line)
        }
    }

    if !replaced
        newLines.Push(BuildPhraseLine(options, writtenShort, phrase, category, comment
                    , lang, tags, disabled, aliases, apps, customFields, url, alts, altNames))

    joined := ""
    for j, l in newLines
        joined .= (j = 1 ? "" : "`n") l
    PhraseFileWriteAll(filepath, joined)
}

RemoveHotstringFromFile(filepath, short) {
    text     := PhraseFileRead(filepath, true)
    lines    := StrSplit(text, "`n")
    newLines := [], i := 0

    while (i < lines.Length) {
        i++
        line    := lines[i]
        trimmed := Trim(line)
        if (RegExMatch(trimmed, "^:([^:]*):([^:]+)::(.*)", &m) && m[2] = short) {
            bodyPart := Trim(m[3])
            if ((bodyPart = "" || SubStr(bodyPart, 1, 1) = ";") && i < lines.Length && Trim(lines[i + 1]) = "(") {
                i++
                while (i < lines.Length) {
                    i++
                    if SubStr(Trim(lines[i]), 1, 1) = ")"
                        break
                }
            }
        } else {
            newLines.Push(line)
        }
    }

    joined := ""
    for j, l in newLines
        joined .= (j = 1 ? "" : "`n") l
    PhraseFileWriteAll(filepath, joined)
}

; ══════════════════════════════════════════════════════════════════════════════
; Utility (extracted from Expanto.ahk)
; ══════════════════════════════════════════════════════════════════════════════

BuildMeta(cat, comment, lang, tags, disabled := 0, priority := 0, aliases := "", apps := "", customFields := "", url := "", alts := "", altNames := "") {
    ; The comment may be multi-line in the UI but the meta row is one line —
    ; store newlines with the same `n escape the phrase body uses.
    comment := StrReplace(StrReplace(comment, "`r", ""), "`n", "``n")
    s := "cat=" cat "|lang=" lang "|comment=" comment "|tags=" tags
        . "|disabled=" disabled "|priority=" priority
    if (aliases != "")
        s .= "|aliases=" aliases
    if (apps != "")
        s .= "|apps=" apps
    if (url != "")
        s .= "|url=" url
    altsMeta := AltsToMeta(alts)
    if (altsMeta != "") {
        s .= "|alts=" altsMeta
        ; Names only make sense with >1 variant; skip when every slot is empty
        if (IsObject(altNames)) {
            hasName := false
            for nm in altNames
                if (nm != "")
                    hasName := true
            if (hasName)
                s .= "|altnames=" AltsToMeta(altNames)
        }
    }
    if (IsObject(customFields))
        for k, v in customFields
            if (v != "")
                s .= "|" k "=" v
    return s
}

Escape_CC(s) {
    s := StrReplace(s, "`r", "")
    s := StrReplace(s, "`n", "``n")
    s := StrReplace(s, Chr(58) Chr(58), Chr(58) "``" Chr(58))
    return s
}

; ── Alternative phrase texts (alts= meta field) ───────────────────────────────
; Serialized per alt: ` → `e first, then newline → `n, | → `b, = → `q; alts are
; joined with `a. After the ` escape no bare backtick precedes an "a", so `a is
; unambiguous — and with |, = and newlines gone the field can sit inside the
; one-line meta block without confusing any other meta regex.
AltsToMeta(alts) {
    if (!IsObject(alts) || !alts.Length)
        return ""
    parts := []
    for a in alts {
        s := StrReplace(a, "``", "``e")
        s := StrReplace(s, "`r", "")
        s := StrReplace(s, "`n", "``n")
        s := StrReplace(s, "|", "``b")
        s := StrReplace(s, "=", "``q")
        parts.Push(s)
    }
    return ArrJoin(parts, "``a")
}

MetaToAlts(s) {
    alts := []
    if (s = "")
        return alts
    for part in StrSplit(s, "``a") {
        p := StrReplace(part, "``q", "=")
        p := StrReplace(p, "``b", "|")
        p := StrReplace(p, "``n", "`n")
        p := StrReplace(p, "``e", "``")
        if (p != "")
            alts.Push(p)
    }
    return alts
}

; Variant names (altnames= meta field): same serialization as alts=, but the
; array is POSITIONAL — entry 1 names the main phrase, entry i+1 names alt i —
; so empty slots must survive the round trip (unlike MetaToAlts).
MetaToNames(s) {
    names := []
    if (s = "")
        return names
    for part in StrSplit(s, "``a") {
        p := StrReplace(part, "``q", "=")
        p := StrReplace(p, "``b", "|")
        p := StrReplace(p, "``n", "`n")
        p := StrReplace(p, "``e", "``")
        names.Push(p)
    }
    return names
}

_HsAlts(hs)     => (hs.HasOwnProp("alts")     && IsObject(hs.alts))     ? hs.alts     : []
_HsAltNames(hs) => (hs.HasOwnProp("altNames") && IsObject(hs.altNames)) ? hs.altNames : []

; Insertion sort (descending .score) — AHK v2 arrays have no built-in comparator sort
ArrSortByScore(arr) {
    Loop arr.Length - 1 {
        i := A_Index + 1
        key := arr[i]
        j := i - 1
        while (j >= 1 && arr[j].score < key.score) {
            arr[j + 1] := arr[j]
            j--
        }
        arr[j + 1] := key
    }
}

ArrJoin(arr, sep := ",") {
    out := ""
    for i, v in arr
        out .= (i = 1 ? "" : sep) . v
    return out
}

Unescape_CC(s) {
    s := StrReplace(s, "``n", "`n")
    s := StrReplace(s, "``t", "`t")
    s := StrReplace(s, "``b", "`b")
    return s
}

; ══════════════════════════════════════════════════════════════════════════════
; Hotstring registration + expansion (extracted from Expanto.ahk)
; ══════════════════════════════════════════════════════════════════════════════

init_hotstrings() {
    global HS_ALL
    for hs in HS_ALL {
        if hs.disabled
            continue
        en := FileHsEnabled(hs.filepath) ? 1 : 0
        try {
            Hotstring(":" hs.options ":" hs.short, HsAction(hs), en)
            for alias in hs.aliases
                Hotstring(":" hs.options ":" alias, HsAction(hs), en)
        }
    }
}

HsAction(hs) => HsFire.Bind(hs)

; Set to true to pop up the focused element's UIA class name on each static
; expansion — used to verify URL-bar (omnibox) detection. Leave false in normal use.
global g_omniboxDebug := false

; UIA's "focused element" is global and can lag behind or belong to another
; process — an Edge URL bar focused a moment ago still answers "OmniboxViewViews"
; while the user types in Notepad. Acting on that sent Ctrl+A into the document
; and the expansion then overwrote everything ("Guds" came out as "Gud" or "s",
; with Ctrl left down so the next key opened Spara som). Only trust the class
; name when a Chromium window is the ACTIVE one.
_ActiveIsChromium() {
    static BROWSERS := Map("msedge", 1, "chrome", 1, "brave", 1, "vivaldi", 1
                         , "opera", 1, "chromium", 1, "msedgewebview2", 1)
    exe := ""
    try exe := StrLower(RegExReplace(WinGetProcessName("A"), "i)\.exe$", ""))
    return BROWSERS.Has(exe)
}

; Shared IUIAutomation instance — creating one per expansion is expensive.
_UIA() {
    static uia := ""
    if !IsObject(uia)
        uia := ComObject("{ff48dba4-60ef-4201-aa87-54103eef594e}",   ; CLSID_CUIAutomation
                         "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")    ; IID_IUIAutomation
    return uia
}

; Return the UIA class name of the currently focused element, or "" on failure.
; Used to recognise Chromium browsers' URL bar ("OmniboxViewViews"), which has no
; child HWND and so is invisible to ControlGetFocus.
_FocusedUIAClassName() {
    try {
        el := 0
        ComCall(8, _UIA(), "ptr*", &el)         ; IUIAutomation::GetFocusedElement
        if !el
            return ""
        cls := ""
        try {
            bstr := 0
            ComCall(30, el, "ptr*", &bstr)      ; IUIAutomationElement::get_CurrentClassName
            if bstr {
                cls := StrGet(bstr, "UTF-16")
                DllCall("oleaut32\SysFreeString", "ptr", bstr)
            }
        }
        ObjRelease(el)
        return cls
    }
    return ""
}

; The text the focused edit control currently holds (UIA_ValueValuePropertyId), or
; "" when it exposes no value. Lets us see what Chromium's URL bar really contains
; after AHK's backspaces have fought with its inline autocomplete.
_FocusedUIAValue() {
    try {
        el := 0
        ComCall(8, _UIA(), "ptr*", &el)         ; IUIAutomation::GetFocusedElement
        if !el
            return ""
        txt := _UIAElementValue(el)
        ObjRelease(el)
        return txt
    }
    return ""
}

; Value property of one UIA element. Split out from _FocusedUIAValue so it can be
; exercised against an element fetched by HWND instead of by keyboard focus.
_UIAElementValue(el) {
    txt := ""
    try {
        var := Buffer(24, 0)                    ; VARIANT (x64)
        ComCall(10, el, "int", 30045, "ptr", var)   ; GetCurrentPropertyValue(UIA_ValueValuePropertyId)
        if (NumGet(var, 0, "ushort") = 8) {     ; VT_BSTR
            p := NumGet(var, 8, "ptr")
            if p
                txt := StrGet(p, "UTF-16")
        }
        DllCall("oleaut32\VariantClear", "ptr", var)
    }
    return txt
}

_IsOmniboxFocused() => _ActiveIsChromium() && InStr(_FocusedUIAClassName(), "Omnibox") > 0

; What the user actually typed. A phrase's aliases are registered against the SAME
; bound hs object, so hs.short can be a different string from the trigger that really
; fired; A_ThisHotkey carries the real one (":*:gud" → "gud"). The omnibox repair
; counts characters against this, so getting it wrong would trim the wrong amount.
_FiredTrigger(hs) {
    t := ""
    try t := RegExReplace(A_ThisHotkey, "^:[^:]*:", "")
    return t != "" ? t : hs.short
}

; Fast typing races the expansion. Everything between the hotstring firing and the
; text landing — the UIA queries in a browser, ClipboardAll, ClipWait, ^v — takes long
; enough for a quick typist to get two or three more characters into the app FIRST, so
; "uppdrag gud" arrived as "uppdrag gsGud rike" or "uppdrag gus riGud". An InputHook
; without the "V" option blocks text from reaching the window while collecting it, and
; it always ignores the script's own SendInput — so we can hold the user's keystrokes
; for the length of the insert and replay them right after, in order.
;
; Never wrap a dialog in this: while the guard is up the keyboard is deaf, so the
; alternative-phrase picker and the dynamic-field prompt must run outside it.
_TypeGuardStart() {
    ih := ""
    try {
        ih := InputHook()
        ; MUST be 1, not the default 0: at 0 the hook also collects the script's OWN
        ; SendInput, so the inserted phrase itself would be captured and replayed —
        ; every expansion would come out twice. Verified by test, not by reading docs.
        ih.MinSendLevel   := 1
        ih.VisibleNonText := true   ; Enter/arrows keep working normally
        ih.Timeout        := 3      ; a crash between start and stop must not deafen the keyboard
        ih.Start()
    }
    return ih
}

; Stop the guard and hand back what it held WITHOUT replaying it: the caller decides
; when those characters should land. They must never be replayed in front of a window
; the user is about to type into — the picker and the dynamic-field prompt both hand
; the keyboard back this way and the text waits until after the insert.
_TypeGuardTake(&ih) {
    if !IsObject(ih)
        return ""
    txt := ""
    try {
        txt := ih.Input
        ih.Stop()
    }
    ih := ""
    return txt
}

; `ours` is the text this expansion just sent. Belt and braces: MinSendLevel = 1 is
; supposed to keep the script's own SendInput out of the buffer, and physical keys
; were verified to still arrive — but the opposite half could not be tested without
; taking the keyboard away from the user, so guard against it here. If our own text
; turns up in the buffer, drop it instead of replaying the phrase on top of itself.
_TypeGuardReplay(held, ours := "") {
    held := _TypeGuardFilter(held, ours)
    if (held != "")
        SendInput("{Text}" held)
}

_TypeGuardFilter(pending, ours) {
    if (ours != "" && pending != "" && InStr(pending, ours, true))
        return StrReplace(pending, ours, , true)
    return pending
}

; Chromium's URL bar inline-autocompletes while AHK is erasing the trigger, and a
; Backspace that lands on the (selected) completion removes the completion instead
; of a character — so the trigger is often still partly there when we insert. The
; old remedy was Ctrl+A, but that selected everything typed BEFORE the trigger too
; and the insert then wiped it: "uppdrag Guds rike" came out as "Guds rike". Clear
; only what sits AFTER the caret, then remove whatever is left of the trigger.
_OmniboxPrepare(typed) {
    global g_dbgPhase
    t0 := A_TickCount
    ; Chromium keeps the inline completion SELECTED after the caret, so a plain
    ; Delete removes exactly that and nothing else. +{End}{Delete} was tried first
    ; and is too blunt: with the caret parked inside an existing URL it wipes the
    ; whole rest of the line, and a Shift that survives turns it into Shift+Delete,
    ; which deletes a Chromium history entry.
    SendInput("{Delete}")
    after := _OmniboxSettledValue()
    k     := (after == "") ? 0 : _OmniboxLeftover(after, typed)
    g_dbgPhase .= " omni=" (A_TickCount - t0) (after == "" ? "!" : "") "/k" k
    if (after == "")
        return                 ; can't read the box, or it never settled — do nothing
    if (k = 0 || !_OmniboxMayTrim(after, typed, k))
        return
    ; Ctrl+Backspace deletes a whole WORD. With Ctrl stuck down — exactly what happens
    ; when a hook eats the key-up of our own ^v — a one-character repair would eat the
    ; user's words instead. Never guess here.
    if (GetKeyState("LCtrl") || GetKeyState("RCtrl")
        || GetKeyState("LCtrl", "P") || GetKeyState("RCtrl", "P"))
        return
    SendInput("{BS " k "}")
    Sleep(20)
}

; AHK's own trigger backspaces are sent with SendInput and are still in flight when
; the bound function starts, so the first value we read can show the box as it was
; BEFORE them — trimming against that would delete characters the user wants to keep
; ("uppdrag " would become "uppdr"). Read until the box stops changing; if it never
; settles, return "" so the caller does nothing rather than act on a moving target.
_OmniboxSettledValue(timeoutMs := 120) {
    prev     := _FocusedUIAValue()
    deadline := A_TickCount + timeoutMs
    while (A_TickCount < deadline) {
        Sleep(20)
        cur := _FocusedUIAValue()
        if (cur == prev)
            return cur
        prev := cur
    }
    return ""
}

; Whether a surviving leftover is safe to delete. A whole surviving trigger always
; is — that is proof the backspaces never landed on characters at all. A partial
; one only when what sits in front of it is not a letter or digit: "uppdrag g" is
; plainly what is left of "gud", while the "g" in "og" may be the user's own word.
_OmniboxMayTrim(after, typed, k) {
    if (k >= StrLen(typed) || StrLen(after) <= k)
        return true
    pre := SubStr(after, StrLen(after) - k, 1)
    return !RegExMatch(pre, "[0-9A-Za-zÀ-ÖØ-öø-ÿ]")
}

; How many characters of the trigger are still sitting at the end of the URL bar
; after AHK's backspaces (0 = none). Longest leftover wins; the comparison is
; case-insensitive because hotstrings are, so "Gud" matches the trigger "gud".
_OmniboxLeftover(after, typed) {
    if (after == "" || typed == "")
        return 0
    Loop StrLen(typed) {
        k := StrLen(typed) - A_Index + 1
        if (StrLen(after) >= k && SubStr(after, -k) = SubStr(typed, 1, k))
            return k
    }
    return 0
}

; One line per expansion, written off the critical path so the measurement cannot
; itself slow down what it measures. It records the trigger, how many characters were
; inserted, how many the type guard had to hold back, and how long the whole thing
; took — and deliberately NOTHING else: no phrase text, no window titles, so the file
; can be read or sent on without carrying anything clinical.
_InsertLog(trigger, sentLen, heldLen, ms) {
    global g_insertLog
    if !g_insertLog
        return
    global g_dbgPhase
    line := FormatTime(, "HH:mm:ss") "  " trigger "  sent=" sentLen
          . "  held=" heldLen "  " ms " ms" g_dbgPhase
    SetTimer(_InsertLogWrite.Bind(line), -1)
}

; Append "label=<elapsed ms>" to the current expansion's breakdown.
_DbgMark(label, t) {
    global g_dbgPhase, g_insertLog
    if g_insertLog
        g_dbgPhase .= " " label "=" (A_TickCount - t)
}

_InsertLogWrite(line) {
    static path := A_AppData "\Expanto\insert_debug.log"
    try {
        if (FileExist(path) && FileGetSize(path) > 200000)
            FileDelete(path)
        FileAppend(line "`n", path, "UTF-8")
    }
}

HsFire(hs, *) {
    global g_lastFired, g_lastSent, g_lastCaretBack, g_stepLabels, g_omniboxDebug, g_dbgPhase
    t0    := A_TickCount
    g_dbgPhase := ""
    ec    := A_EndChar
    ; What is really on screen to be replaced — read here, while A_ThisHotkey is fresh.
    typed := _FiredTrigger(hs) ec
    ; Hold the user's next keystrokes from the FIRST line, not merely around the send.
    ; The identity guard's file check, WinGetTitle, the UIA probe and above all
    ; ClipboardAll are each slow enough for a fast typist to beat the insert into the
    ; window — "uppdrag gud" arrived as "uppdrag gus rikGud". Everything that opens a
    ; window of its own hands the keyboard back first (_TypeGuardTake) and the held
    ; characters wait until after the insert, so their order is preserved either way.
    guard := _TypeGuardStart()
    _DbgMark("guard", t0)
    held  := ""
    ours  := ""
    try {
        proceed := true
        tStage := A_TickCount
        try proceed := CoupleIdentityGuard(hs.filepath)   ; identity-switch safety
        _DbgMark("cig", tStage)
        if (!proceed)
            return
        ; App restriction: process name OR title: prefix for window title substring
        if (hs.apps.Length > 0) {
            activeExe   := ""
            activeTitle := ""
            try activeExe   := StrLower(RegExReplace(WinGetProcessName("A"), "\.exe$", ""))
            try activeTitle := StrLower(WinGetTitle("A"))
            allowed := false
            for entry in hs.apps {
                e := StrLower(Trim(entry))
                if SubStr(e, 1, 6) = "title:"
                    allowed := allowed || InStr(activeTitle, SubStr(e, 7))
                else
                    allowed := allowed || (e = activeExe)
            }
            if !allowed
                return
        }
        ; Alternative phrase texts: let the user pick one (popup only when alts exist)
        if (_HsAlts(hs).Length)
            held .= _TypeGuardTake(&guard)      ; the picker is a window: it needs the keyboard
        raw := PickPhraseText(hs)
        if (raw = "" && _HsAlts(hs).Length) {
            ; Picker cancelled — AHK already erased the typed trigger, so restore it
            SendInput("{Text}" typed)
            ours := typed
            return
        }
        if !IsObject(guard)
            guard := _TypeGuardStart()
        ; Pre-substitute stored custom field values
        unesc := PresubCustomFields(raw, hs.customFields)
        if (g_omniboxDebug)
            MsgBox("UIA-klass: [" _FocusedUIAClassName() "]`n"
                 . "omnibox=" (_IsOmniboxFocused() ? 1 : 0)
                 . "  paste=" (ShouldPasteInsert(unesc) ? 1 : 0)
                 . "  dyn=" (HasDynamicFields(unesc) ? 1 : 0))
        ; Step-through fill: split phrase on | when step labels are configured
        if (g_stepLabels.Length > 0 && InStr(unesc, "|")) {
            held .= _TypeGuardTake(&guard)      ; step-through runs its own popup and hotkeys
            if StartStepThrough(hs, unesc)
                return
            guard := _TypeGuardStart()
        }
        if (HasDynamicFields(unesc) || ShouldPasteInsert(unesc)) {
            g_lastSent := "", g_lastCaretBack := 0
            if HasDynamicFields(unesc)          ; the field prompt needs the keyboard
                held .= _TypeGuardTake(&guard)
            tStage := A_TickCount
            res := ExpandDynamic(unesc, hs.filepath, hs.short)
            _DbgMark("dyn", tStage)
            if !IsObject(guard)
                guard := _TypeGuardStart()
            sentEc := ""
            if (res.ok) {
                ; Conform case to what was typed (standard AHK behaviour) for paste/dynamic
                ; inserts too — not just the SendInput path below.
                noConform := InStr(hs.options, "C") && !InStr(hs.options, "C0")
                tStage := A_TickCount
                omni := _IsOmniboxFocused()
                _DbgMark("probe", tStage)
                if omni                  ; clear URL-bar autocomplete residue before insert
                    _OmniboxPrepare(typed)
                tStage := A_TickCount
                SendExpanded(noConform ? res.text : ConformCase(res.text, hs.short, ec))
                _DbgMark("send", tStage)
                ; Reproduce the ending char AHK swallowed — function hotstrings don't auto-send
                ; it. Skip when the caret was repositioned ({cursor}) so it can't land mid-text.
                sentEc := (ec != "" && !InStr(hs.options, "O", true) && g_lastCaretBack = 0) ? ec : ""
                if (sentEc != "")
                    SendInput("{Text}" sentEc)
                ours := g_lastSent sentEc
            }
            g_lastFired := { hs: hs, sent: g_lastSent, endChar: sentEc, caretBack: g_lastCaretBack, undoable: (g_lastSent != "") }
            RecordUsage(hs.id)
            SetTimer(ShowUndoPopup, -300)
            if (res.ok)
                SchedulePendingRuns(hs.filepath)   ; via timer — efter att typ-guarden släppt
            else
                ClearPendingRuns()                 ; avbruten fältdialog kör ingenting
        } else {
            noConform := InStr(hs.options, "C") && !InStr(hs.options, "C0")
            out := noConform ? unesc : ConformCase(unesc, hs.short, ec)
            sentEc := (ec != "" && !InStr(hs.options, "O", true)) ? ec : ""
            tStage := A_TickCount
            omni := _IsOmniboxFocused()
            _DbgMark("probe", tStage)
            if omni                  ; clear URL-bar autocomplete residue before insert
                _OmniboxPrepare(typed)
            tStage := A_TickCount
            SendInput("{Text}" out)
            _DbgMark("send", tStage)
            if (sentEc != "")
                SendInput("{Text}" sentEc)
            ours := out sentEc
            g_lastFired := { hs: hs, sent: out, endChar: sentEc, caretBack: 0, undoable: true }
            RecordUsage(hs.id)
            SetTimer(ShowUndoPopup, -300)
        }
    } finally {
        held .= _TypeGuardTake(&guard)
        _TypeGuardReplay(held, ours)
        _InsertLog(typed, StrLen(ours), StrLen(held), A_TickCount - t0)
    }
    _MaybePromptUrl(hs)
}

UndoLastExpansion(*) {
    global g_lastFired
    if (!IsObject(g_lastFired) || !g_lastFired.undoable) {
        ToolTip(_AT("undo.none"))
        SetTimer(() => ToolTip(), -1600)
        return
    }
    if (g_lastFired.caretBack > 0)
        SendInput("{Right " g_lastFired.caretBack "}")
    n := StrLen(g_lastFired.sent) + (g_lastFired.endChar != "" ? 1 : 0)
    if (n > 0)
        Send("{Backspace " n "}")
    SendInput("{Text}" g_lastFired.hs.short g_lastFired.endChar)
    g_lastFired := ""
}

HasDynamicFields(text) => RegExMatch(text, "\{[^}]+\}") > 0

; Named dynamic fields the user would fill in — same selection ExpandDynamic uses
; when prompting: skips reserved auto-fields ({date}/{time}/{clipboard}/{cursor})
; and already-resolved {key=value} placeholders. Returns [] when there's nothing
; to prompt for (so callers can skip the "fill in?" question).
_CollectManualDynFields(text) {
    reserved := Map("date", 1, "time", 1, "clipboard", 1, "cursor", 1)
    fields := [], seen := Map(), pos := 1
    while RegExMatch(text, "\{([^}]+)\}", &m, pos) {
        pos  := m.Pos + m.Len
        name := Trim(m[1])
        if (reserved.Has(StrLower(name)) || seen.Has(name))
            continue
        if (InStr(name, "=") && !ParseChoiceField(name).choice)   ; skip resolved {key=value}; KEEP {name=[a/b]} and {name=a/b} choices
            continue
        if _IsKeyCmd(name)   ; {BS 3}, {Left 28}, {U+…} are keystrokes, not fields
            continue
        if (StrLower(SubStr(name, 1, 4)) = "run:")   ; {run:...} is a command, not a field
            continue
        if _IsDateField(name)   ; {datum+1:yyMMdd} etc. resolve automatically
            continue
        seen[name] := true
        fields.Push(name)
    }
    return fields
}

PresubCustomFields(text, customFields) {
    if !IsObject(customFields)
        return text
    ; Replace {key=value} placeholders with embedded value directly.
    ; The key class must allow spaces and non-ASCII letters (\w is ASCII-only),
    ; or {SID lab=…} is never recognised; "=" itself is excluded so the first
    ; "=" still separates key from value.
    local mf, pos := 1
    while RegExMatch(text, "\{([^}=]+)=([^}]*)\}", &mf, pos) {
        ; A key that is not a plain word (i.e. it has spaces or non-ASCII
        ; letters) counts as a field ONLY when the phrase really has one by
        ; that name. Without this, braces around code or markup — {key = val},
        ; {font-size=12px} — would be collapsed to their right-hand side.
        if (!RegExMatch(mf[1], "^\w+$") && !customFields.Has(mf[1])) {
            pos := mf.Pos + mf.Len
            continue
        }
        ; Choice fields are prompted by ExpandDynamic, not substituted: {name=[a/b]}
        ; always, and the bracket-less {name=a/b} unless the key is a real stored
        ; custom field (whose value may legitimately contain slashes, e.g. a path).
        if (SubStr(Trim(mf[2]), 1, 1) = "["
            || (!customFields.Has(mf[1]) && ParseChoiceField(mf[1] "=" mf[2]).choice)) {
            pos := mf.Pos + mf.Len
            continue
        }
        text := SubStr(text, 1, mf.Pos - 1) mf[2] SubStr(text, mf.Pos + mf.Len)
        pos  := mf.Pos + StrLen(mf[2])
    }
    ; Replace {key} with value from customFields map
    for k, v in customFields
        if (v != "")
            text := StrReplace(text, "{" k "}", v)
    return text
}

ShouldPasteInsert(text) {
    global g_pasteMode, g_pasteMinLen
    if (g_pasteMode = "always")
        return true
    if (g_pasteMode = "never")
        return false
    return InStr(text, "`n") || StrLen(text) >= g_pasteMinLen
}

PasteText(text) {
    global g_dbgPhase, g_clipSeq, g_clipSaved, g_clipText
    t0    := A_TickCount
    ; Reuse the cached backup only when the sequence number is untouched AND the text
    ; form still matches. The sequence number alone leaves a race: if another app wrote
    ; the clipboard in the instant between our restore and our reading the number, we
    ; would later restore OUR snapshot over THEIR content.
    reuse := (g_clipSeq != 0 && _ClipSeq() = g_clipSeq && g_clipSaved != ""
              && A_Clipboard == g_clipText)
    tChk  := A_TickCount
    saved := reuse ? g_clipSaved : ClipboardAll()
    t1    := A_TickCount
    A_Clipboard := text
    ok := ClipWait(0.6)
    t2 := A_TickCount
    g_dbgPhase .= " clipchk=" (tChk - t0) " clipsave=" (t1 - tChk) (reuse ? "r" : "")
                . " clipwait=" (t2 - t1) (ok ? "" : "!")
    if !ok {
        ; The clipboard never took our text (another app is holding it open). Typing is
        ; slower but always available — better than silently inserting nothing.
        _SendTextDirect(text)
        return
    }
    t3 := A_TickCount
    SendInput("^v")
    ; Release Ctrl HERE, synchronously. Deferring it with SetTimer(-1) was tried as an
    ; optimisation and reopened the bug it was meant to fix: the timer fires after the
    ; caller's type guard has come down, so the user's next key lands in the window
    ; where Ctrl may still be held — Ctrl+S, Spara som. Inside the guard the keyboard is
    ; held, so those ~100 ms cost the user nothing but a slightly later insert; nothing
    ; they type is lost. Correctness beats latency here.
    _ReleaseCtrl()
    _DbgMark("ctrlv", t3)
    ; Slow paste consumers (Word with add-ins etc.) can read the clipboard well
    ; after ^v was sent — restoring after only 500 ms made them paste the OLD
    ; clipboard intermittently. Wait longer, and only restore while the
    ; clipboard still holds our text (never clobber something the user copied).
    SetTimer(_RestorePastedClipboard.Bind(saved, text), -1500)
}

_RestorePastedClipboard(saved, ourText) {
    global g_clipSeq, g_clipSaved, g_clipText
    try {
        if (A_Clipboard != ourText) {
            g_clipSeq := 0, g_clipSaved := "", g_clipText := ""   ; user copied — cache void
            return                                                ; leave their clipboard alone
        }
    }
    _RestoreClipboard(saved)
    ; Remember the restored snapshot against the clipboard's sequence number, so the
    ; next paste can skip ClipboardAll while nothing else has touched the clipboard.
    ; Big payloads (images, spreadsheet ranges) are not cached — holding those in
    ; memory costs more than re-reading them on the rare occasion they are current.
    try {
        if (saved != "" && saved.Size <= 2000000) {
            g_clipSaved := saved
            g_clipText  := A_Clipboard
            g_clipSeq   := _ClipSeq()
        } else {
            g_clipSeq := 0, g_clipSaved := "", g_clipText := ""
        }
    }
}

_ClipSeq() {
    n := 0
    try n := DllCall("GetClipboardSequenceNumber", "uint")
    return n
}

; A CapsLock→Ctrl remap (or any external keyboard hook) can swallow the key-up half of a
; synthetic Ctrl-combo (^v), leaving Ctrl stuck down after an insert — which then breaks
; every plain hotkey (Shift+Space no longer opens the GUI, since AHK now sees
; Ctrl+Shift+Space) and turns the next character the user types into a Ctrl-combo. With
; paste_mode=always every single expansion goes through ^v, so this fires constantly:
; typing "uppdrag Guds" in Edge's URL bar ended in Ctrl+S and the Spara som dialog.
; _ReleaseStuckMods only helps when AHK's OWN logical state shows Ctrl down; when the
; key-up is eaten further down the hook chain AHK believes Ctrl is up while the target
; app still holds it, and no GetKeyState check can see that. A key-up for a key that is
; not down is a no-op, so send it unconditionally — unless the user is physically holding
; Ctrl. Only Ctrl: a stray Alt-up can pop up the menu bar in some apps.
; Measured on this machine: every injected key event costs ~50 ms, because it has to
; travel a hook chain of eight AutoHotkey scripts plus HotKeyServiceUWP. So the number
; of events matters more than anything else here. An earlier version of this function
; sent five (two {Blind} sends plus three raw key-ups) and added ~250 ms to every
; paste. Two raw key-ups is enough: they carry no AutoHotkey marker, so no hook in the
; chain treats them as script input and swallows them — which is what made the
; AHK-level sends unreliable in the first place.
_ReleaseCtrl() {
    if (GetKeyState("LCtrl", "P") || GetKeyState("RCtrl", "P"))
        return                      ; the user is really holding it — leave it alone
    DllCall("keybd_event", "uchar", 0xA2, "uchar", 0, "uint", 2, "ptr", 0)  ; VK_LCONTROL up
    DllCall("keybd_event", "uchar", 0xA3, "uchar", 0, "uint", 2, "ptr", 0)  ; VK_RCONTROL up
}

; Release any modifier that is logically stuck down without being physically
; held — the cause of "Shift+Space suddenly stops opening the GUI": AHK then
; sees Ctrl+Shift+Space (or Alt+…) and the plain hotkey no longer matches.
; The physical check keeps a bidirectional CapsLock↔Ctrl remap in sync.
_ReleaseStuckMods() {
    for k in ["LCtrl", "RCtrl", "LAlt", "RAlt", "LShift", "RShift", "LWin", "RWin"] {
        if (GetKeyState(k) && !GetKeyState(k, "P"))
            SendInput("{Blind}{" k " Up}")
    }
}

; Restoring the clipboard can throw if the target app or a clipboard manager
; still holds it open right after the paste. Retry a few times, then give up
; silently — an unhandled error here runs in a timer thread and pops a crash
; dialog (the "Spara och infoga" error).
_RestoreClipboard(saved, attempt := 1) {
    try {
        A_Clipboard := saved
    } catch {
        if (attempt < 5)
            SetTimer(() => _RestoreClipboard(saved, attempt + 1), -150)
    }
}

; ── Embedded AHK key commands ({BS 3}, {Left 28}, {Enter}, {U+1F600}, …) ───────
; A curated whitelist of key tokens inside a phrase is sent as real keystrokes
; instead of literal text. Everything else still goes out verbatim via {Text}, so
; braces in code/JSON are untouched. Consistent with the {date}/{cursor} placeholders.
_KeyCmdPat() {
    static p := "(?:U\+[0-9A-Fa-f]+|BS|Backspace|Del|Delete|Left|Right|Up|Down|Home|End|PgUp|PgDn|Enter|Return|Tab|Space|Esc|Escape|Ins|Insert)(?:\s+\d+)?"
    return p
}
_IsKeyCmd(name)       => RegExMatch(name, "i)^" _KeyCmdPat() "$") > 0
_HasKeyCommands(text) => RegExMatch(text, "i)\{" _KeyCmdPat() "\}") > 0

; Send `text`, interpreting whitelisted {key} tokens as keystrokes and the rest
; as literal text (newlines handled by _SendTextDirect). Never pasted.
_SendKeysAndText(text) {
    tok := "i)^\{" _KeyCmdPat() "\}"
    buf := "", pos := 1, n := StrLen(text)
    while (pos <= n) {
        if (SubStr(text, pos, 1) = "{" && RegExMatch(SubStr(text, pos), tok, &m)) {
            if (buf != "") {
                _SendTextDirect(buf)
                buf := ""
            }
            SendInput(m[0])            ; AHK interprets e.g. {Left 28}, {BS 3}, {U+1F600}
            pos += m.Len[0]
        } else {
            buf .= SubStr(text, pos, 1)
            pos++
        }
    }
    if (buf != "")
        _SendTextDirect(buf)
}

SendExpanded(text) {
    global g_lastSent, g_lastCaretBack
    caretBack := 0
    if InStr(text, "{cursor}") {
        p         := StrSplit(text, "{cursor}", , 2)
        post      := StrReplace(p.Length > 1 ? p[2] : "", "{cursor}", "")
        text      := p[1] post
        caretBack := StrLen(post)
    }
    g_lastSent      := text
    g_lastCaretBack := caretBack
    if _HasKeyCommands(text) {
        g_lastSent := ""           ; caret-moving keys make text-length undo unsafe
        _SendKeysAndText(text)
    } else if ShouldPasteInsert(text)
        PasteText(text)
    else
        SendInput("{Text}" text)
    if (caretBack)
        SendInput("{Left " caretBack "}")
    _ReleaseStuckMods()   ; synthetic sends can leave a modifier logically stuck
}

ExpandAndSend(rawPhrase, filepath := "") {
    global g_dynMode
    res := ExpandDynamic(Unescape_CC(rawPhrase), filepath)
    if (res.ok) {
        SendExpanded(res.text)
        SchedulePendingRuns(filepath)
    } else
        ClearPendingRuns()
}

; ── {run:kommando} — fraser som startar program ───────────────────────────────
ClearPendingRuns() {
    global g_pendingRuns
    g_pendingRuns := []
}

; Snapshot av kölistan + körning via engångstimer: timern får sin egen tråd
; efter att insättningen (och typ-guarden) är helt klar, och en förhandsvisning
; eller nästa expansion kan inte hinna skriva över det som ska köras.
SchedulePendingRuns(filepath := "") {
    global g_pendingRuns
    if !g_pendingRuns.Length
        return
    runs := g_pendingRuns
    g_pendingRuns := []
    SetTimer(_RunFieldCmds.Bind(runs, filepath), -1)
}

; Fraser kan komma från nedladdade fraspaket, så ett kommando körs aldrig tyst
; första gången: varje distinkt kommandorad bekräftas en gång per session.
_RunFieldCmds(runs, filepath) {
    global g_runApproved
    for cmd in runs {
        if !g_runApproved.Has(cmd) {
            if (MsgBox(_AT("run.confirm") "`n`n" cmd
                    . (filepath != "" ? "`n`n(" filepath ")" : "")
                , "Expanto — {run}", "YesNo Icon?") != "Yes")
                continue
            g_runApproved[cmd] := true
        }
        try Run(cmd)
        catch {
            ToolTip(_AT("run.fail") "`n" cmd)
            SetTimer(() => ToolTip(), -2500)
        }
    }
}

; ── Coupled dynamic fields: config, title parsing, resolver, safety ───────────
; Generic (domain-agnostic). Per-file config in the "; @expanto …" file header:
;   groupField:   kundnr, ordernr           (comma-sep. grouping/key fields)
;   sharedFields: kundnr=namn,ärende,ordernr;ordernr=variant
;                 (per group: fields whose value is shared across that group)
;   titleFields / titlePattern:  optional auto-fill of fields from the window title
ParseCouplingConfig(filepath) {
    global g_coupleCfgCache
    if g_coupleCfgCache.Has(filepath)
        return g_coupleCfgCache[filepath]
    s := ReadFileSettings(filepath)
    pat := s.Has("titlePattern") ? s["titlePattern"] : ""
    tf := []
    if s.Has("titleFields")
        for f in StrSplit(s["titleFields"], ",")
            if ((f := Trim(f)) != "")
                tf.Push(f)
    titleSet := Map()
    for f in tf
        titleSet[f] := true
    groupFields := []
    if s.Has("groupField")
        for g in StrSplit(s["groupField"], ",")
            if ((g := Trim(g)) != "")
                groupFields.Push(g)
    ; sharedFields "group=f1,f2;group2=f3" → coupling  field ← group
    couplings := Map()
    if s.Has("sharedFields")
        for part in StrSplit(s["sharedFields"], ";") {
            eq := InStr(part, "=")
            if (!eq)
                continue
            g := Trim(SubStr(part, 1, eq - 1))
            if (g = "")
                continue
            for f in StrSplit(SubStr(part, eq + 1), ",")
                if ((f := Trim(f)) != "")
                    couplings[f] := { key: g, source: (titleSet.Has(f) ? "title" : "prompt") }
        }
    ; identity for the safety/reset = first group field that the title can supply
    ident := ""
    for g in groupFields
        if titleSet.Has(g) {
            ident := g
            break
        }
    cfg := { titlePattern: pat, titleFields: tf, identity: ident, couplings: couplings, groupFields: groupFields }
    g_coupleCfgCache[filepath] := cfg
    return cfg
}

; Human-readable label for the held identity = the non-identity title fields joined.
_CoupleDisplayName(cfg, vals) {
    name := ""
    for f in cfg.titleFields
        if (f != cfg.identity && vals.Has(f))
            name .= (name = "" ? "" : " ") vals[f]
    return name
}

ParseTitleIdentity(pattern, titleFields) {
    out := Map()
    if (pattern = "" || !titleFields.Length)
        return out
    title := ""
    try title := WinGetTitle("A")
    if (title = "")
        return out
    if RegExMatch(title, pattern, &mm)
        for i, name in titleFields {
            v := ""
            try v := mm[i]
            if (Trim(v) != "")
                out[name] := Trim(v)
        }
    return out
}

_CoupleResetOnIdentity(identity, idValue, idName) {
    global g_coupleMem, g_coupleIdentity, g_coupleIdName, g_coupleVolatile
    if (identity = "" || idValue = "" || g_coupleIdentity = idValue)
        return
    for f, _ in g_coupleVolatile      ; drop encounter-scoped (today/clipboard) memory
        if g_coupleMem.Has(f)
            g_coupleMem.Delete(f)
    g_coupleIdentity := idValue
    g_coupleIdName   := idName
}

; Resolve as many of `fields` as possible without prompting (cascade-safe, iterative).
ResolveCoupled(filepath, fields, trigger := "") {
    global g_coupleMem, g_coupleVolatile
    cfg := ParseCouplingConfig(filepath)
    if (!cfg.couplings.Count && !cfg.titleFields.Length)
        return { ctx: Map(), prompt: fields, store: [], identity: "", idValue: "", couplings: Map() }
    ctx := Map()
    for k, v in ParseTitleIdentity(cfg.titlePattern, cfg.titleFields)
        ctx[k] := v
    ; "trigger" is a reserved pseudo-field — pre-populate it with the hotstring trigger text.
    if (trigger != "")
        ctx["trigger"] := trigger
    idValue := (cfg.identity != "" && ctx.Has(cfg.identity)) ? ctx[cfg.identity] : ""
    _CoupleResetOnIdentity(cfg.identity, idValue, _CoupleDisplayName(cfg, ctx))

    ; full set = phrase fields + every key they (transitively) depend on
    need := Map(), queue := []
    for f in fields {
        need[f] := true
        queue.Push(f)
    }
    qi := 0
    while (qi < queue.Length) {
        qi++
        f := queue[qi]
        if cfg.couplings.Has(f) {
            k := cfg.couplings[f].key
            if !need.Has(k) {
                need[k] := true
                queue.Push(k)
            }
        }
    }

    store := []
    loop 6 {                          ; fixpoint passes propagate the cascade
        progressed := false
        for f, _ in need {
            if ctx.Has(f) || !cfg.couplings.Has(f)
                continue
            c := cfg.couplings[f]
            ; "trigger" as coupling key: field automatically equals the trigger text.
            if (c.key = "trigger" && ctx.Has("trigger")) {
                ctx[f] := ctx["trigger"]
                progressed := true
                continue
            }
            if (c.source = "today" || c.source = "clipboard")
                g_coupleVolatile[f] := true
            keyVal := ctx.Has(c.key) ? ctx[c.key] : ""
            if (keyVal != "" && g_coupleMem.Has(f) && g_coupleMem[f].Has(keyVal)) {
                ctx[f] := g_coupleMem[f][keyVal]
                progressed := true
            } else if (c.source = "today") {
                ctx[f] := FormatTime(, "yyyy-MM-dd")
                store.Push({ field: f, keyField: c.key })
                progressed := true
            } else if (c.source = "clipboard") {
                ctx[f] := A_Clipboard
                store.Push({ field: f, keyField: c.key })
                progressed := true
            }
        }
        if !progressed
            break
    }

    ; Everything still unknown must be prompted (phrase fields first, then dep-keys).
    promptOrder := [], seen := Map()
    for f in fields {
        if (!ctx.Has(f) && !seen.Has(f)) {
            promptOrder.Push(f), seen[f] := true
            if cfg.couplings.Has(f)
                store.Push({ field: f, keyField: cfg.couplings[f].key })
        }
    }
    for f, _ in need {
        if (!ctx.Has(f) && !seen.Has(f)) {
            promptOrder.Push(f), seen[f] := true
            if cfg.couplings.Has(f)
                store.Push({ field: f, keyField: cfg.couplings[f].key })
        }
    }
    return { ctx: ctx, prompt: promptOrder, store: store, identity: cfg.identity, idValue: idValue, couplings: cfg.couplings }
}

; After prompting, memorise coupled values keyed by their key field's resolved value.
StoreCoupledValues(store, ctx) {
    global g_coupleMem
    loop 3 {
        changed := false
        for e in store {
            if (!ctx.Has(e.field) || ctx[e.field] = "")
                continue
            keyVal := ctx.Has(e.keyField) ? ctx[e.keyField] : ""
            if (keyVal = "")
                continue
            if !g_coupleMem.Has(e.field)
                g_coupleMem[e.field] := Map()
            if (!g_coupleMem[e.field].Has(keyVal) || g_coupleMem[e.field][keyVal] != ctx[e.field]) {
                g_coupleMem[e.field][keyVal] := ctx[e.field]
                changed := true
            }
        }
        if !changed
            break
    }
}

; ── Autostart with Windows (shortcut in the user's Startup folder) ────────────
; State lives in the shortcut itself — nothing is written to settings.ini.
; A_ScriptFullPath works for both the .ahk (shell association) and compiled exe.
_AutostartLnk() => A_Startup "\Expanto.lnk"

_AutostartOn() => FileExist(_AutostartLnk()) ? 1 : 0

_AutostartSet(on) {
    if (on) {
        try FileCreateShortcut(A_ScriptFullPath, _AutostartLnk(), A_ScriptDir, ,
            "Expanto", A_ScriptDir "\app.ico")
    } else if FileExist(_AutostartLnk()) {
        try FileDelete(_AutostartLnk())
    }
}

; Identity-switch safety. Returns true to proceed, false to abort the insertion.
CoupleIdentityGuard(filepath) {
    global g_coupleIdentity, g_coupleIdName, g_coupleLastTick
    cfg := ParseCouplingConfig(filepath)
    if (cfg.identity = "")
        return true
    tv  := ParseTitleIdentity(cfg.titlePattern, cfg.titleFields)
    cur := tv.Has(cfg.identity) ? tv[cfg.identity] : ""
    held := g_coupleIdentity
    recent := (g_coupleLastTick != 0) && (A_TickCount - g_coupleLastTick < 300000)   ; 5 min
    if (held = "" || cur = "" || held = cur || !recent)
        return true
    curName := _CoupleDisplayName(cfg, tv)
    msg := "Identiteten i det aktiva fönstret verkar ha bytts sedan du började.`n`n"
         . "Du arbetade med:  " (g_coupleIdName != "" ? g_coupleIdName " (" held ")" : held) "`n"
         . "Fönstret visar nu:  " (curName != "" ? curName " (" cur ")" : cur) "`n`n"
         . "Vill du fortsätta infoga ändå?"
    return MsgBox(msg, "Identitet ändrad", "YesNo Icon!") = "Yes"
}

; ── Datum/tid/vecka-fält, svenska och engelska namn likvärdiga ────────────────
;   {date}/{datum}                dagens datum, yyyy-MM-dd
;   {datum:yyMMdd}                valfritt FormatTime-format
;   {datum+1} / {datum-1:yyMMdd}  offset i dagar (imorgon/igår)
;   {time}/{tid}, {tid:HHmm}      klockslag; offset i timmar ({tid+1})
;   {week}/{vecka}/{veckonummer}  ISO-veckonummer; offset i veckor ({vecka+2})
ResolveDateFields(phrase) {
    pos := 1
    while RegExMatch(phrase,
        "i)\{(date|datum|time|tid|week|vecka|veckonummer)([+-]\d+)?(?::([^}]+))?\}", &m, pos) {
        base := StrLower(m[1])
        off  := m[2] != "" ? Integer(m[2]) : 0
        fmt  := m[3]
        t := A_Now
        if (base = "time" || base = "tid") {
            if off
                t := DateAdd(t, off, "Hours")
            rep := FormatTime(t, fmt != "" ? fmt : "HH:mm")
        } else if (base = "date" || base = "datum") {
            if off
                t := DateAdd(t, off, "Days")
            rep := FormatTime(t, fmt != "" ? fmt : "yyyy-MM-dd")
        } else {   ; week/vecka/veckonummer
            if off
                t := DateAdd(t, off * 7, "Days")
            rep := fmt != "" ? FormatTime(t, fmt)
                 : LTrim(SubStr(FormatTime(t, "YWeek"), 5), "0")   ; ISO-vecka utan år
        }
        phrase := SubStr(phrase, 1, m.Pos - 1) rep SubStr(phrase, m.Pos + m.Len)
        pos := m.Pos + StrLen(rep)
    }
    return phrase
}

; Är {namn} ett datum/tid/vecka-automatfält (och alltså inget ifyllnadsfält)?
_IsDateField(name) =>
    RegExMatch(name, "i)^(date|datum|time|tid|week|vecka|veckonummer)([+-]\d+)?(:.+)?$") > 0

ExpandDynamic(phrase, filepath := "", trigger := "", forceMode := "") {
    global g_dynMode, g_dynAppModes, g_coupleLastTick, g_pendingRuns
    phrase := ResolveDateFields(phrase)
    ; Only touch the clipboard when the phrase actually asks for it. Reading
    ; A_Clipboard forces the OS to render CF_UNICODETEXT, which costs real time when
    ; something large is on the clipboard and can block outright while another app
    ; holds it open — paid on EVERY expansion before this check existed.
    if InStr(phrase, "{clipboard}")
        phrase := StrReplace(phrase, "{clipboard}", A_Clipboard)

    ; ── {run:kommando}: körs efter insättningen, skrivs aldrig ut ─────────────
    ; Extraheras EFTER {date}/{time}/{clipboard} ovan så de kan användas i
    ; kommandoraden. Körs INTE här utan via SchedulePendingRuns hos anroparen:
    ; dels ska ett avbrutet fältdialogsvar inte köra något, dels får ett
    ; program som tar fokus inte sno åt sig den text som är på väg in.
    g_pendingRuns := []
    while RegExMatch(phrase, "i)\{run:([^}]*)\}", &mr) {
        if (Trim(mr[1]) != "")
            g_pendingRuns.Push(Trim(mr[1]))
        phrase := SubStr(phrase, 1, mr.Pos - 1) SubStr(phrase, mr.Pos + mr.Len)
    }

    reserved := Map("date", 1, "time", 1, "clipboard", 1, "cursor", 1)
    fields := [], seen := Map(), pos := 1
    while RegExMatch(phrase, "\{([^}]+)\}", &m, pos) {
        pos  := m.Pos + m.Len
        name := Trim(m[1])
        if (reserved.Has(StrLower(name)) || seen.Has(name))
            continue
        if (InStr(name, "=") && !ParseChoiceField(name).choice)  ; {key=value} resolved by PresubCustomFields, but KEEP {name=[a/b]} and {name=a/b} choices
            continue
        if _IsKeyCmd(name)   ; {BS 3}, {Left 28}, {U+…} are keystrokes, not fields
            continue
        seen[name] := true
        fields.Push(name)
    }

    if (!fields.Length)
        return { ok: true, text: phrase }

    ; ── Coupled fields: fill from title / today / per-key memory before prompting ──
    coupleRc := "", coupleStore := []
    if (filepath != "") {
        try {
            rc := ResolveCoupled(filepath, fields, trigger)
            for cn, cv in rc.ctx
                phrase := StrReplace(phrase, "{" cn "}", cv)
            coupleRc := rc, fields := rc.prompt, coupleStore := rc.store
            g_coupleLastTick := A_TickCount
        }
        if (!fields.Length)
            return { ok: true, text: phrase }
    }

    ; Resolve mode: check per-app overrides first (process name or title: prefix)
    mode := g_dynMode
    activeExe   := ""
    activeTitle := ""
    try activeExe   := StrLower(RegExReplace(WinGetProcessName("A"), "\.exe$", ""))
    try activeTitle := StrLower(WinGetTitle("A"))
    for row in g_dynAppModes {
        e := StrLower(Trim(row["app"]))
        matched := SubStr(e, 1, 6) = "title:"
            ? InStr(activeTitle, SubStr(e, 7))
            : (e = activeExe)
        if matched {
            mode := row["mode"]
            break
        }
    }
    if (forceMode != "")
        mode := forceMode
    hasChoice := false
    for nm in fields {
        if ParseChoiceField(nm).choice
            hasChoice := true
    }

    if (mode = "auto")
        mode := (fields.Length = 1 && !hasChoice) ? "inline" : "dialog"
    if (mode = "inline" && hasChoice)
        mode := "dialog"
    if (mode = "inline") {
        ; A field used MORE THAN ONCE must be prompted — inline would replace
        ; every occurrence with the caret marker and blank all but the first
        ; (e.g. "BT {värde} … puls {värde}" lost its later fields).
        for nm in fields {
            cnt := 0
            StrReplace(phrase, "{" nm "}", , , &cnt)
            if (cnt > 1) {
                mode := "dialog"
                break
            }
        }
    }
    if (coupleStore.Length)            ; coupled prompts must be captured to be memorised
        mode := "dialog"

    if (mode = "inline") {
        for i, name in fields {
            phrase := StrReplace(phrase, "{" name "}", i = 1 ? "{cursor}" : "")
        }
        return { ok: true, text: phrase }
    }

    r := PromptDynamicFields(fields, IsObject(coupleRc) ? coupleRc.couplings : "")
    if (!r.ok)
        return { ok: false, text: "" }
    for name, val in r.vals
        phrase := StrReplace(phrase, "{" name "}", val)
    if (coupleStore.Length && IsObject(coupleRc)) {
        combined := coupleRc.ctx.Clone()
        for name, val in r.vals
            combined[name] := val
        try StoreCoupledValues(coupleStore, combined)
    }
    return { ok: true, text: phrase }
}

ParseChoiceField(content) {
    label := "", optsStr := ""
    if RegExMatch(content, "^\s*(.*?)\s*=\s*\[(.+)\]\s*$", &m) {
        label := Trim(m[1])
        optsStr := m[2]
    } else if RegExMatch(content, "^\s*\[(.+)\]\s*$", &m) {
        optsStr := m[1]
    } else if RegExMatch(content, "^\s*([^=]*?)\s*=\s*([^=]*/[^=]*)$", &m) {
        ; Labelled list without brackets: {kön=manlig/kvinnlig}. Matches the
        ; bracket-less form already accepted for unlabelled lists ({manlig/kvinnlig}).
        label := Trim(m[1])
        optsStr := m[2]
    } else if InStr(content, "/") {
        optsStr := content
    } else {
        return { choice: false, label: content, options: [] }
    }
    opts := [], defaultIdx := 1, i := 0
    for o in StrSplit(optsStr, "/") {
        if ((o := Trim(o)) = "")
            continue
        i++
        if (SubStr(o, 1, 1) = "*") {
            o := Trim(SubStr(o, 2))
            defaultIdx := i
        }
        opts.Push(o)
    }
    if (opts.Length < 2)
        return { choice: false, label: content, options: [] }
    return { choice: true, label: (label != "" ? label : optsStr), options: opts, chooseIdx: defaultIdx }
}

PromptDynamicFields(fields, couplings := "") {
    dg := Gui("+AlwaysOnTop +ToolWindow +OwnDialogs", _AT("prompt.title"))
    dg.SetFont("s10", "Segoe UI")
    ctrls := Map()
    for name in fields {
        cf := ParseChoiceField(name)
        dg.AddText("xm w130 h22 +0x200", (cf.choice ? cf.label : name) ":")
        if (cf.choice)
            ctrls[name] := { ctrl: dg.AddDropDownList("x+6 yp w240 Choose" cf.chooseIdx, cf.options), choice: true }
        else
            ctrls[name] := { ctrl: dg.AddEdit("x+6 yp w240 h22"), choice: false }
    }
    vals := Map(), state := { done: false, ok: false }
    depMap := Map()      ; keyField → [dependent fields shown in this dialog]
    finish(isOk, *) {
        if (isOk)
            for nm, c in ctrls
                vals[nm] := c.choice ? c.ctrl.Text : c.ctrl.Value
        state.ok := isOk, state.done := true
        dg.Destroy()
    }
    ; Reactive cascade: when a key field is filled, pull its dependents from memory.
    fillDeps(keyField, *) {
        global g_coupleMem
        if (!depMap.Has(keyField) || !ctrls.Has(keyField))
            return
        kv := Trim(ctrls[keyField].choice ? ctrls[keyField].ctrl.Text : ctrls[keyField].ctrl.Value)
        if (kv = "")
            return
        for dep in depMap[keyField] {
            if (ctrls.Has(dep) && !ctrls[dep].choice && Trim(ctrls[dep].ctrl.Value) = ""
                && g_coupleMem.Has(dep) && g_coupleMem[dep].Has(kv)) {
                ctrls[dep].ctrl.Value := g_coupleMem[dep][kv]
                fillDeps(dep)        ; cascade to deeper levels
            }
        }
    }
    if IsObject(couplings) {
        fieldSet := Map()
        for name in fields
            fieldSet[name] := true
        for name in fields
            if (couplings.Has(name) && fieldSet.Has(couplings[name].key)) {
                k := couplings[name].key
                if !depMap.Has(k)
                    depMap[k] := []
                depMap[k].Push(name)
            }
        for k, _d in depMap
            if (ctrls.Has(k) && !ctrls[k].choice)
                ctrls[k].ctrl.OnEvent("Change", fillDeps.Bind(k))
    }
    dg.AddButton("xm y+12 w110 Default", "OK").OnEvent("Click", finish.Bind(true))
    dg.AddButton("x+8 w110", _AT("prompt.cancel")).OnEvent("Click", finish.Bind(false))
    dg.OnEvent("Escape", finish.Bind(false))
    dg.OnEvent("Close",  finish.Bind(false))
    dg.Show()
    try WinActivate("ahk_id " dg.Hwnd)
    try ctrls[fields[1]].ctrl.Focus()
    while (!state.done)
        Sleep(30)
    return { ok: state.ok, vals: vals }
}

; ── Alternative phrase texts: pick one at insert time ─────────────────────────
; Returns the phrase text to insert (unescaped). When the phrase has alternative
; texts a ListBox popup lets the user choose; "" means the picker was cancelled.
PickPhraseText(hs) {
    alts := _HsAlts(hs)
    main := Unescape_CC(hs.long)
    if (!alts.Length)
        return main
    variants := [main]
    for a in alts
        variants.Push(a)
    return PromptPhraseVariant(variants, _HsAltNames(hs), hs.short)
}

; ListBox popup over the variant texts. Items are numbered, so typing a digit
; jumps to that entry (ListBox incremental search); Enter/dubbelklick picks it.
; `names` is positional (1 = main phrase) and may be shorter than `variants`.
PromptPhraseVariant(variants, names := "", trigger := "") {
    dg := Gui("+AlwaysOnTop +ToolWindow +OwnDialogs", _AT("altpick.title") (trigger != "" ? "  —  " trigger : ""))
    dg.SetFont("s10", "Segoe UI")
    items := []
    for i, v in variants {
        nm := (IsObject(names) && names.Length >= i) ? Trim(names[i]) : ""
        prev := Trim(RegExReplace(v, "\s+", " "))
        label := i ". " (nm != "" ? nm "  —  " : "") prev
        if (StrLen(label) > 90)
            label := SubStr(label, 1, 89) "…"
        items.Push(label)
    }
    lb := dg.AddListBox("xm w480 r" Min(variants.Length, 10) " Choose1", items)
    state := { done: false, idx: 0 }
    pick(*) {
        state.idx  := lb.Value
        state.done := true
        dg.Destroy()
    }
    cancel(*) {
        state.done := true
        dg.Destroy()
    }
    lb.OnEvent("DoubleClick", pick)
    dg.AddButton("xm y+10 w110 Default", "OK").OnEvent("Click", pick)
    dg.AddButton("x+8 w110", _AT("prompt.cancel")).OnEvent("Click", cancel)
    dg.OnEvent("Escape", cancel)
    dg.OnEvent("Close",  cancel)
    dg.Show()
    try WinActivate("ahk_id " dg.Hwnd)
    try lb.Focus()
    while (!state.done)
        Sleep(30)
    return (state.idx >= 1 && state.idx <= variants.Length) ? variants[state.idx] : ""
}

; ── Case conformity (reproduce AHK's built-in behaviour for function callbacks) ─

StartTypedBuffer() {
    ih := InputHook("VI")   ; V=visible (don't suppress), I=ignore AHK-sent keystrokes
    ih.NotifyNonText := true
    ih.OnChar    := TypedBufChar
    ih.OnKeyDown := TypedBufKey
    ih.Start()
}

TypedBufChar(ih, char) {
    global g_typedBuf, g_hintWord, g_hintMinLen, g_hintsEnabled, g_hintSuppressed
    g_typedBuf := SubStr(g_typedBuf char, -40)
    if (!g_hintsEnabled || g_hintSuppressed || !HintActiveOK())
        return
    if (char ~= "[\p{L}\p{N}_-]") {
        g_hintWord .= char
        if (StrLen(g_hintWord) >= g_hintMinLen)
            HintUpdate()
        else
            HintHide()
    } else {
        g_hintWord := "", HintHide()
    }
}

TypedBufKey(ih, vk, sc) {
    global g_hintWord, g_hintMinLen, g_hintsEnabled, g_hintSuppressed
    if (!g_hintsEnabled || g_hintSuppressed)
        return
    if (vk = 0x08) {                           ; Backspace
        if (g_hintWord != "")
            g_hintWord := SubStr(g_hintWord, 1, -1)
        if (StrLen(g_hintWord) >= g_hintMinLen)
            HintUpdate()
        else
            HintHide()
        return
    }
    ; modifier keys must not reset the word
    if (vk = 0x10 || vk = 0x11 || vk = 0x12 || vk = 0x14
        || vk = 0xA0 || vk = 0xA1 || vk = 0xA2 || vk = 0xA3 || vk = 0xA4 || vk = 0xA5
        || vk = 0x5B || vk = 0x5C)
        return
    ; nav keys are handled by the #HotIf block while the popup is visible
    if (HintShown() && (vk = 0x28 || vk = 0x26 || vk = 0x09 || vk = 0x1B || vk = 0x0D))
        return
    ; While the popup is shown, chorded keys (Ctrl/Alt/Win + key) are popup
    ; hotkeys (Ctrl+digit select, Ctrl+Space insert) or app shortcuts — never
    ; typing. Don't reset the word or hide the popup for them; previously this
    ; killed the popup before the digit-select hotkey could act.
    if (HintShown() && (GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P")
        || GetKeyState("LWin", "P") || GetKeyState("RWin", "P")))
        return
    g_hintWord := "", HintHide()
}

ConformCase(text, short, ec) {
    global g_typedBuf
    if (text = "" || short = "")
        return text
    buf := g_typedBuf
    if (ec != "" && SubStr(buf, -1) = ec)
        buf := SubStr(buf, 1, -1)
    typed := SubStr(buf, -StrLen(short))
    if (StrLower(typed) != StrLower(short))
        return text
    letters := RegExReplace(typed, "[^\p{L}]")
    if (letters = "")
        return text
    c1 := SubStr(letters, 1, 1)
    if (c1 == StrLower(c1))
        return text
    if (StrLen(letters) >= 2 && SubStr(letters, 2, 1) !== StrLower(SubStr(letters, 2, 1)))
        return StrUpper(text)
    return StrUpper(SubStr(text, 1, 1)) SubStr(text, 2)
}

; ══════════════════════════════════════════════════════════════════════════════
; Hint popup (autocomplete while typing)
; ══════════════════════════════════════════════════════════════════════════════

BuildHintIndex() {
    global HS_ALL, g_hintTriggers, g_hintWords, g_hintMinLen
    trigs := []
    words := []
    for hs in HS_ALL {
        if hs.disabled
            continue
        hintT := FileHintTEnabled(hs.filepath)
        hintP := FileHintPEnabled(hs.filepath)
        if (!hintT && !hintP)
            continue
        preview := SubStr(RegExReplace(hs.long, "\s+", " "), 1, 60)
        if (hintT) {
            for trig in HintTriggerList(hs) {
                if (trig != "")
                    trigs.Push({ key: StrLower(trig), trig: trig, preview: preview,
                                 insert: hs.long, src: hs.filepath, short: hs.short })
            }
        }
        if (hintP) {
            wseen := Map()
            for w in HintTokenize(hs.long) {
                parts := [w]
                if (InStr(w, "-") || InStr(w, "_"))
                    for p in StrSplit(w, ["-", "_"])
                        parts.Push(p)
                for token in parts {
                    lw := StrLower(token)
                    if (StrLen(token) >= g_hintMinLen && !wseen.Has(lw)) {
                        wseen[lw] := true
                        words.Push({ key: lw, word: token, preview: preview,
                                     insert: hs.long, src: hs.filepath, short: hs.short })
                    }
                }
            }
        }
    }
    g_hintTriggers := trigs
    g_hintWords    := words
}

HintTriggerList(hs) {
    out := [hs.short]
    for a in hs.aliases
        out.Push(a)
    return out
}

HintTokenize(text) {
    return StrSplit(Trim(RegExReplace(text, "[^\p{L}\p{N}_-]+", " ")), " ")
}

CreateHintPopup() {
    global g_hintGui, g_hintLV
    if (g_hintGui != "")
        return
    g := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000", "ExpantoHint")
    g.SetFont("s9", "Segoe UI")
    g.MarginX := 0, g.MarginY := 0
    g.BackColor := "2D2D30"
    lv := g.AddListView("w420 r8 -Hdr -Multi Background2D2D30 cCCCCCC", ["Trigger", "Expansion"])
    lv.OnEvent("Click", (*) => HintInsert())
    foot := g.AddText("xm w420 +0x200 Background252526", _HintFooterText())
    global g_hintFootCtl := foot
    foot.SetFont("s8 c858585")
    g_hintGui := g
    g_hintLV  := lv
}

HintActiveOK() {
    ; Uppstarten tar >10 s med tusentals fraser och hint-maskineriet är
    ; aktivt långt före fönsterskapandet - error.log 10:50 fångade racen.
    global wv2Win
    if !IsSet(wv2Win)
        return true
    return !WinActive("ahk_id " wv2Win.hwnd)
}

HintShown() {
    global g_hintGui
    return g_hintGui != "" && WinExist("ahk_id " g_hintGui.Hwnd)
        && DllCall("IsWindowVisible", "ptr", g_hintGui.Hwnd)
}

HintMatchScore(key, lw, n, base) {
    global g_hintFuzzy, g_hintWord
    if (g_hintFuzzy) {
        fs := FuzzyScore(g_hintWord, key)
        return fs ? base + fs : 0
    }
    return (SubStr(key, 1, n) = lw) ? base - (StrLen(key) - n) : 0
}

HintUpdate() {
    global g_hintWord, g_hintTriggers, g_hintWords, g_hintLV, g_hintMatches, g_hintMaxRows, g_hintFuzzy
    lw := StrLower(g_hintWord)
    n  := StrLen(lw)
    out := []
    for c in g_hintTriggers {
        sc := HintMatchScore(c.key, lw, n, 1000)
        if (sc)
            out.Push({ d1: c.trig, d2: "→ " c.preview, insert: c.insert,
                       prefix: g_hintWord, src: c.src, short: c.short, score: sc })
    }
    for c in g_hintWords {
        sc := HintMatchScore(c.key, lw, n, 500)
        if (sc)
            out.Push({ d1: c.word, d2: "→ " c.preview, insert: c.insert,
                       prefix: g_hintWord, src: c.src, short: c.short, score: sc })
    }
    if (!out.Length) {
        HintHide()
        return
    }
    byIns := Map()
    for m in out
        if (!byIns.Has(m.insert) || byIns[m.insert].score < m.score)
            byIns[m.insert] := m
    out := []
    for _, m in byIns
        out.Push(m)
    ArrSortByScore(out)

    srcs := Map()
    for m in out
        srcs[m.src] := true
    cap := Max(2, Ceil(g_hintMaxRows / Max(1, srcs.Count)))

    final := []
    perSrc := Map()
    for m in out {
        if (final.Length >= g_hintMaxRows)
            break
        cnt := perSrc.Has(m.src) ? perSrc[m.src] : 0
        if (cnt >= cap)
            continue
        perSrc[m.src] := cnt + 1
        m.added := true
        final.Push(m)
    }
    for m in out {
        if (final.Length >= g_hintMaxRows)
            break
        if (!m.HasOwnProp("added"))
            final.Push(m)
    }

    g_hintMatches := final
    g_hintLV.Opt("-Redraw")
    g_hintLV.Delete()
    for i, m in final
        g_hintLV.Add(, (i <= 9 ? i ". " : "   ") m.d1, m.d2)
    g_hintLV.ModifyCol(1, "AutoHdr")
    g_hintLV.ModifyCol(2, "AutoHdr")
    g_hintLV.Modify(1, "Select Focus")
    g_hintLV.Opt("+Redraw")
    HintShow()
}

HintShow() {
    global g_hintGui, g_hintTimeout, g_hintPinned
    if CaretGetPos(&cx, &cy)
        g_hintGui.Show("x" cx " y" (cy + 22) " NoActivate AutoSize")
    else {
        MouseGetPos(&mx, &my)
        g_hintGui.Show("x" mx " y" (my + 18) " NoActivate AutoSize")
    }
    if (g_hintTimeout > 0 && !g_hintPinned)
        SetTimer(HintAutoClose, -g_hintTimeout * 1000)
}

HintAutoClose() => HintHide()

HintHide() {
    global g_hintGui, g_hintPinned
    g_hintPinned := false
    SetTimer(HintAutoClose, 0)
    if (g_hintGui != "")
        try g_hintGui.Hide()
}

HintNav(dir) {
    global g_hintLV, g_hintPinned
    n := g_hintLV.GetCount()
    if (!n)
        return
    ; Navigating = actively choosing: pin the popup open (no auto-close)
    ; until it is dismissed manually or a suggestion is inserted.
    g_hintPinned := true
    SetTimer(HintAutoClose, 0)
    f := g_hintLV.GetNext(0, "F")
    if (!f)
        f := 1
    nf := (dir = "Down") ? (f >= n ? 1 : f + 1) : (f <= 1 ? n : f - 1)
    g_hintLV.Modify(0, "-Select -Focus")
    g_hintLV.Modify(nf, "Select Focus Vis")
}

HintInsert() {
    global g_hintLV, g_hintMatches, g_hintWord, g_hintSuppressed
    row := g_hintLV.GetNext(0, "F")
    if (!row)
        row := 1
    if (row < 1 || row > g_hintMatches.Length)
        return
    m := g_hintMatches[row]
    HintHide()
    Hotstring("Reset")
    g_hintWord := ""
    g_hintSuppressed := true
    ; Alternative phrase texts: pick before touching the typed prefix, so a
    ; cancelled picker leaves the user's text untouched.
    insert := m.insert
    hs := FindHsById(m.src "|" m.short)
    if (IsObject(hs) && _HsAlts(hs).Length) {
        txt := PickPhraseText(hs)
        if (txt = "") {
            g_hintSuppressed := false
            return
        }
        insert := Escape_CC(txt)
    }
    bs := StrLen(m.prefix)
    if (bs)
        SendEvent("{Backspace " bs "}")
    ExpandAndSend(insert, m.src)
    _ReleaseStuckMods()
    g_hintSuppressed := false
    _MaybePromptUrl(hs)
}

HintInsertByIndex(n, *) {
    global g_hintLV, g_hintMatches
    if (n < 1 || n > g_hintMatches.Length)
        return
    g_hintLV.Modify(0, "-Select -Focus")
    g_hintLV.Modify(n, "Select Focus Vis")
    HintInsert()
}

; ══════════════════════════════════════════════════════════════════════════════
; Step-through fill
; ══════════════════════════════════════════════════════════════════════════════

StepActive() {
    global g_stepIdx
    return g_stepIdx > 0
}

_StepCtx(*) => StepActive()

; The popup's ◄ Föregående / Nästa ► buttons get keyboard twins: the step key
; moves forward, Shift+step key steps back (Ctrl+step key when the step key
; already uses Shift). Registered under a StepActive context so the extra
; combination only exists while a step-through is running.
StepPrevKeyFor(stepKey) {
    if (stepKey = "")
        return ""
    if !InStr(stepKey, "+")
        return "+" stepKey
    return InStr(stepKey, "^") ? "" : "^" stepKey
}

ApplyStepPrevHotkey() {
    global g_stepKey, g_stepPrevKey
    newKey := StepPrevKeyFor(g_stepKey)
    if (newKey = g_stepPrevKey)
        return
    if (g_stepPrevKey != "") {
        HotIf(_StepCtx)
        try Hotkey(g_stepPrevKey, "Off")
        HotIf()
    }
    g_stepPrevKey := ""
    if (newKey = "")
        return
    HotIf(_StepCtx)
    try {
        Hotkey(newKey, (*) => _StepPopupPrev(), "On")
        g_stepPrevKey := newKey
    }
    HotIf()
}

InitStepKey() {
    global g_stepKey
    if (g_stepKey = "")
        return
    try {
        ; Always armed so an idle press starts step-insertion (not only advances mid-run).
        Hotkey(g_stepKey, StepNextHotkey, "On")
    } catch {
        g_stepKey := ""
    }
    ApplyStepPrevHotkey()
}

; Split a phrase into segments {header, body}.
; New style: splits at blank lines (\n\n), detecting section headers.
; Fallback: old-style | separator for backward compat.
SplitPhraseIntoSegments(text) {
    global g_stepLabels
    ; 1. Labelled lines: a line starting with "Etikett: …" opens a new segment.
    ;    With a configured whitelist (Stegetiketter) only those labels count;
    ;    without one, any label-looking line counts. Either way at least two
    ;    labelled lines are required, so ordinary prose is never split.
    lines := StrSplit(text, "`n", "`r")
    labelRe := "^\s*([A-Za-zÅÄÖåäöÜüÉé][A-Za-zÅÄÖåäöÜüÉé0-9 /().,\-]{0,39}?)\s*:\s*(?!/)"
    marks := [], hits := 0
    for line in lines {
        lbl := ""
        if (g_stepLabels.Length > 0) {
            for wl in g_stepLabels
                if RegExMatch(line, "i)^\s*\Q" wl "\E\s*:") {
                    lbl := wl
                    break
                }
        } else if RegExMatch(line, "i)" labelRe, &m)
            lbl := Trim(m[1])
        marks.Push(lbl)
        if (lbl != "")
            hits++
    }
    ; Explicit whitelist: one hit is enough (leading text becomes its own
    ; segment). Heuristic mode needs two so ordinary prose never splits.
    if (hits >= (g_stepLabels.Length > 0 ? 1 : 2)) {
        segs := [], curHeader := "", curBody := [], started := false
        for i, line in lines {
            lbl := marks[i]
            if (lbl != "") {
                if (started) {
                    body := Trim(ArrJoin(curBody, "`n"))
                    if (curHeader != "" || body != "")
                        segs.Push(Map("header", curHeader, "body", body))
                }
                started := true
                curHeader := lbl
                rest := Trim(RegExReplace(line, "i)^\s*\Q" lbl "\E\s*:\s*", "", , 1))
                curBody := rest != "" ? [rest] : []
            } else {
                if (!started) {
                    started := true
                    curHeader := ""
                    curBody := []
                }
                curBody.Push(line)
            }
        }
        body := Trim(ArrJoin(curBody, "`n"))
        if (curHeader != "" || body != "")
            segs.Push(Map("header", curHeader, "body", body))
        if (segs.Length >= 2)
            return segs
    }

    ; Try paragraph-based splitting on blank lines
    paragraphs := []
    for chunk in StrSplit(text, "`n`n", "`r")
        if (Trim(chunk, " `t`r") != "")
            paragraphs.Push(Trim(chunk, " `t`r"))

    if (paragraphs.Length >= 2) {
        ; Paragraph steps are pieces of ONE running text, so nothing may be
        ; dropped and the blank line between them has to come back on
        ; insertion. A heading-looking first line is only used as the popup's
        ; title ("hdrInBody") — it stays part of the inserted text, or a
        ; paragraph starting with e.g. "Sammanfattning:" or a "----" rule
        ; would silently lose its first line.
        segs := []
        for i, para in paragraphs {
            lines  := StrSplit(para, "`n", "`r")
            header := ""
            if (lines.Length >= 1) {
                firstLine := Trim(lines[1])
                nextLine  := lines.Length >= 2 ? Trim(lines[2]) : ""
                if IsSegmentHeader(firstLine, nextLine)
                    header := ExtractSegmentHeader(firstLine, nextLine)
            }
            body := Trim(para, " `t`r`n")
            if (body != "")
                segs.Push(Map("header", header, "body", body
                            , "hdrInBody", 1, "sep", i > 1 ? "`n`n" : ""))
        }
        if (segs.Length >= 2)
            return segs
    }

    ; Fallback: old-style | separator
    if InStr(text, "|") {
        segs := []
        for part in StrSplit(text, "|")
            if (Trim(part) != "")
                segs.Push(Map("header", "", "body", Trim(part)))
        if (segs.Length >= 2)
            return segs
    }
    return []
}

IsSegmentHeader(line, nextLine := "") {
    ; ATX markdown: # Heading
    if RegExMatch(line, "^#{1,6}\s")
        return true
    ; Setext markdown: line followed by === or ---
    if (nextLine != "" && RegExMatch(nextLine, "^[=\-]{2,}$"))
        return true
    ; Swedish label pattern: "Word:" or "Multi Word:" (ends with colon, word chars + spaces only)
    if RegExMatch(line, "^\w[\w\s]*:\s*$")
        return true
    return false
}

ExtractSegmentHeader(line, nextLine := "") {
    if RegExMatch(line, "^#{1,6}\s+(.*)", &m)
        return Trim(m[1])
    if (nextLine != "" && RegExMatch(nextLine, "^[=\-]{2,}$"))
        return Trim(line)
    return Trim(RegExReplace(line, ":\s*$", ""))
}

_BuildSegmentText(seg) {
    global g_stepKeepHeaders
    header := seg["header"]
    body   := seg["body"]
    ; "hdrInBody": the heading line is already part of the body (paragraph
    ; steps) — it must never be dropped, nor repeated on top of itself.
    if (seg.Has("hdrInBody") && seg["hdrInBody"])
        return body
    if (g_stepKeepHeaders && header != "")
        return header ":`n" body
    return body
}

; Insert one step segment: resolve its dynamic fields first (always via the
; dialog — inline caret placement doesn't fit the step flow), then type it.
; What to put in front of a step. Nothing before the first one; otherwise the
; separator the split recorded (a blank line for paragraph steps) or, when the
; user ticks "Behåll styckemellanrum", a blank line for label/pipe steps too.
_StepSeparatorFor(seg, idx) {
    global g_stepKeepSpacing
    if (idx <= 1)
        return ""
    own := seg.Has("sep") ? seg["sep"] : ""
    if (!g_stepKeepSpacing)
        return ""
    return own != "" ? own : "`n`n"
}

_StepInsertSegment(seg) {
    global g_stepHs, g_pasteMode, g_stepIdx
    txt := _BuildSegmentText(seg)
    fp := (IsSet(g_stepHs) && IsObject(g_stepHs)) ? g_stepHs.filepath : ""
    tr := (IsSet(g_stepHs) && IsObject(g_stepHs)) ? g_stepHs.short    : ""
    if HasDynamicFields(txt) {
        res := ""
        try res := ExpandDynamic(txt, fp, tr, "dialog")
        if (!IsObject(res) || !res.ok)
            return
        txt := StrReplace(res.text, "{cursor}", "")
    }
    if (txt = "")
        return
    ; Wait for the hotkey's own modifiers, then PASTE rather than type. Typing
    ; a step with per-character SendInput proved fragile on a machine running
    ; several keyboard hooks: a still-held Alt ate the first character, and an
    ; interrupted send produced runaway repeats ("nnnnnn…"). Paste is atomic —
    ; it is also what the ordinary Ctrl+Enter insert uses, which never garbled.
    _WaitModifiersReleased()
    ; The blank line between steps goes in as real Enter keystrokes, not as part
    ; of the pasted text. Notepad kept the leading newlines; Melior's note editor
    ; trims them off a paste, which is why the spacing kept vanishing there. The
    ; small sleeps are for that same editor — it drops keys sent back to back.
    sep := _StepSeparatorFor(seg, g_stepIdx)
    if (sep != "") {
        StrReplace(sep, "`n", "", , &nl)
        loop nl {
            SendInput("{Enter}")
            Sleep 15
        }
        Sleep 20
    }
    if (g_pasteMode != "never")
        PasteText(txt)
    else
        _SendTextDirect(txt)
}

; A hotkey such as Alt+V is still physically held when the insert starts, and
; with Alt down the first character reaches the app as a menu accelerator
; (Alt+B) and is swallowed — "Bästa kollega," arrived as "ästa kollega,".
; Wait (bounded) for the user to let go before typing.
_WaitModifiersReleased(timeoutMs := 700) {
    static MODS := ["LAlt", "RAlt", "LCtrl", "RCtrl", "LShift", "RShift", "LWin", "RWin"]
    deadline := A_TickCount + timeoutMs
    loop {
        held := false
        for k in MODS
            if (GetKeyState(k, "P") || GetKeyState(k)) {   ; physical AND logical
                held := true
                break
            }
        if !held {
            Sleep 15   ; let the app process the key-up before the text arrives
            return true
        }
        if (A_TickCount >= deadline)
            break
        Sleep 10
    }
    ; Timed out. A modifier that is logically down without being physically
    ; held is stuck (other scripts' hooks can swallow a key-up) — release it,
    ; or every insert from here on loses its first character.
    for k in MODS
        if (GetKeyState(k) && !GetKeyState(k, "P"))
            SendInput("{Blind}{" k " Up}")
    return false
}

_SendTextDirect(text) {
    if InStr(text, "`n") {
        parts := StrSplit(text, "`n")
        for i, part in parts {
            if (i > 1)
                SendInput("{Enter}")
            if (part != "")
                SendInput("{Text}" part)
        }
    } else if (text != "") {
        SendInput("{Text}" text)
    }
}

_DirectSendExpanded(text) {
    global g_lastSent, g_lastCaretBack
    caretBack := 0
    if InStr(text, "{cursor}") {
        p         := StrSplit(text, "{cursor}", , 2)
        post      := StrReplace(p.Length > 1 ? p[2] : "", "{cursor}", "")
        text      := p[1] post
        caretBack := StrLen(post)
    }
    g_lastSent      := text
    g_lastCaretBack := caretBack
    if _HasKeyCommands(text) {
        g_lastSent := ""           ; caret-moving keys make text-length undo unsafe
        _SendKeysAndText(text)
    } else if ShouldPasteInsert(text)
        PasteText(text)
    else
        _SendTextDirect(text)
    if (caretBack)
        SendInput("{Left " caretBack "}")
    _ReleaseStuckMods()   ; synthetic sends can leave a modifier logically stuck
}

; True when the split recorded blank lines between steps (the paragraph split
; does; the label and pipe splits do not, because those steps are meant for
; separate form fields where extra Enters would be wrong).
_SegsHaveSpacing(segs) {
    for s in segs
        if (s.Has("sep") && s["sep"] != "")
            return true
    return false
}

StartStepThrough(hs, rawPhrase) {
    global g_stepSegments, g_stepIdx, g_stepHs, g_stepKey, g_stepKeepSpacing
    segs := SplitPhraseIntoSegments(rawPhrase)
    if (segs.Length < 2)
        return false
    g_stepKeepSpacing := _SegsHaveSpacing(segs)   ; popup checkbox can override
    g_stepSegments := segs
    g_stepIdx      := 1
    g_stepHs       := hs
    if (g_stepKey != "")
        try Hotkey(g_stepKey, "On")
    _StepInsertSegment(segs[1])
    CreateStepPopup()
    ShowStepPopup()
    return true
}

StepNextHotkey(*) {
    global g_stepIdx
    if (g_stepIdx > 0)
        SetTimer(StepNext, -1)               ; mid step-through → next paragraph
    else
        SetTimer(DoGlobalInsertStep, -1)     ; idle → START step-insert of the selected phrase
}

StepNext() {
    global g_stepSegments, g_stepIdx
    if (g_stepIdx <= 0 || !g_stepSegments.Length)
        return
    nextIdx := g_stepIdx + 1
    if (nextIdx > g_stepSegments.Length) {
        ClearStepState(true)
        return
    }
    g_stepIdx := nextIdx
    _StepInsertSegment(g_stepSegments[nextIdx])
    if (g_stepIdx >= g_stepSegments.Length)
        ClearStepState(true)
    else
        ShowStepPopup()
}

ClearStepState(done := false) {
    global g_stepSegments, g_stepIdx, g_stepKey, g_stepPopup
    g_stepSegments := []
    g_stepIdx      := 0
    if (g_stepKey != "")
        try Hotkey(g_stepKey, "On")   ; stay armed so the key can start the next step-insert
    if !IsSet(g_stepPopup) || !IsObject(g_stepPopup)
        return
    if done {
        try {
            g_stepPopup["StepHeader"].Value   := "✓ Alla stycken infogade"
            g_stepPopup["StepProgress"].Value := ""
            g_stepPopup["StepPreview"].Value  := ""
            g_stepPopup.Show("NoActivate AutoSize")
        }
        SetTimer(HideStepPopup, -1500)
    } else {
        try g_stepPopup.Hide()
    }
}

HideStepPopup() {
    global g_stepPopup
    if IsSet(g_stepPopup) && IsObject(g_stepPopup)
        try g_stepPopup.Hide()
}

_StepPopupJump() {
    global g_stepPopup, g_stepIdx, g_stepSegments
    chosen := g_stepPopup["StepJump"].Value
    if (chosen >= 1 && chosen <= g_stepSegments.Length) {
        g_stepIdx := chosen - 1
        ShowStepPopup()
    }
}

_StepPopupPrev() {
    global g_stepIdx
    if (g_stepIdx > 0) {
        g_stepIdx--
        ShowStepPopup()
    }
}

_StepPopupNext() {
    global g_stepIdx, g_stepSegments
    if (g_stepIdx < g_stepSegments.Length)
        SetTimer(StepNext, -1)
}

_StepToggleKeepHeaders() {
    global g_stepPopup, g_stepKeepHeaders
    g_stepKeepHeaders := g_stepPopup["ChkKeepHeaders"].Value = 1
}

_StepToggleKeepSpacing() {
    global g_stepPopup, g_stepKeepSpacing
    g_stepKeepSpacing := g_stepPopup["ChkKeepSpacing"].Value = 1
}

CreateStepPopup() {
    global g_stepPopup, g_stepKeepHeaders, g_stepKeepSpacing
    if IsSet(g_stepPopup) && IsObject(g_stepPopup)
        return
    pg := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000", "ExpantoStep")
    pg.BackColor := "1E2127"
    pg.SetFont("s10", "Segoe UI")
    pg.MarginX := 12, pg.MarginY := 8
    pg.AddText("vStepHeader c98C379 w320 h20", "")
    pg.AddText("vStepProgress c5C6370 w320 y+2 h16", "")
    pg.AddText("vStepPreview cCCCCCC w320 y+4 h20", "")
    pg.AddText("xm y+6 w52 h22 c5C6370 +0x200", "Hoppa:")
    pg.AddDropDownList("x+4 yp vStepJump w264 h22", []).OnEvent("Change", (*) => _StepPopupJump())
    pg.AddButton("xm y+6 w132 vBtnStepPrev", "◄ Föregående").OnEvent("Click", (*) => _StepPopupPrev())
    pg.AddButton("x+4 yp w132 vBtnStepNext", "Nästa ►").OnEvent("Click", (*) => _StepPopupNext())
    cb := pg.AddCheckBox("xm y+6 cCCCCCC vChkKeepHeaders", "Behåll styckerubriker")
    cb.Value := g_stepKeepHeaders ? 1 : 0
    cb.OnEvent("Click", (*) => _StepToggleKeepHeaders())
    cs := pg.AddCheckBox("xm y+4 cCCCCCC vChkKeepSpacing", "Behåll styckemellanrum")
    cs.Value := g_stepKeepSpacing ? 1 : 0
    cs.OnEvent("Click", (*) => _StepToggleKeepSpacing())
    pg.AddText("vStepHint c5C6370 w320 y+6 h16", "")
    g_stepPopup := pg
}

ShowStepPopup() {
    global g_stepPopup, g_stepSegments, g_stepIdx, g_hkInsertStep
    if !IsSet(g_stepPopup) || !IsObject(g_stepPopup)
        return
    total   := g_stepSegments.Length
    nextIdx := g_stepIdx + 1
    if (nextIdx > total)
        return
    nextSeg := g_stepSegments[nextIdx]
    headerText  := nextSeg["header"] != "" ? "[" nextSeg["header"] "]" : "(Inget styckenamn)"
    bodyPreview := RegExReplace(nextSeg["body"], "\s+", " ")
    if (StrLen(bodyPreview) > 70)
        bodyPreview := SubStr(bodyPreview, 1, 70) "…"
    g_stepPopup["StepHeader"].Value   := headerText
    g_stepPopup["StepProgress"].Value := "Stycke " nextIdx " / " total
    g_stepPopup["StepPreview"].Value  := bodyPreview
    ; Rebuild jump dropdown (programmatic Choose does not trigger Change event)
    ddl := g_stepPopup["StepJump"]
    ddl.Delete()
    Loop total {
        lbl := g_stepSegments[A_Index]["header"] != "" ? g_stepSegments[A_Index]["header"] : "Stycke " A_Index
        ddl.Add([lbl])
    }
    ddl.Choose(nextIdx)
    ; Update hint with current key
    ; The hint is where the keyboard twins of the buttons are discovered
    global g_stepKey, g_stepPrevKey
    keyDisp := g_stepKey != "" ? g_stepKey
             : (g_hkInsertStep != "" ? g_hkInsertStep : "InsertStep-tangent")
    g_stepPopup["StepHint"].Value := (g_stepPrevKey != ""
        ? keyDisp " nästa  ·  " g_stepPrevKey " föregående  ·  Esc avbryt"
        : "Tryck " keyDisp " för nästa  ·  Esc avbryt")
    g_stepPopup["BtnStepPrev"].Enabled := (nextIdx > 1)
    global g_stepKeepSpacing
    try g_stepPopup["ChkKeepSpacing"].Value := g_stepKeepSpacing ? 1 : 0
    if CaretGetPos(&cx, &cy)
        g_stepPopup.Show("x" cx " y" (cy + 24) " NoActivate AutoSize")
    else {
        MouseGetPos(&mx, &my)
        g_stepPopup.Show("x" mx " y" (my + 24) " NoActivate AutoSize")
    }
}

; ══════════════════════════════════════════════════════════════════════════════
; Dynamic global hotkeys (OpenGui, Undo — configurable in Inställningar)
; ══════════════════════════════════════════════════════════════════════════════

ShowHideWv2Win(*) {
    global wv2Win, g_wv2Shown, g_prevWinId, g_markWordActive, g_hkOpenGui
    if !g_wv2Shown {
        ; Window hidden — show it and record where we came from
        try g_prevWinId := WinGetID("A")
        g_wv2Shown := true
        wv2Win.Show()
        WinWait("ahk_id " wv2Win.hwnd, , 1)
        try WinActivate("ahk_id " wv2Win.hwnd)
        if IsSet(wv2Core)
            _SafeSend(wv2Core, "window.openForSearch()")
        ; WinActivate is asynchronous — focus and any CapsLock side-effect may arrive late.
        ; Check immediately after the call AND in two deferred timers to cover async arrivals.
        if InStr(StrUpper(g_hkOpenGui), "CAPSLOCK") {
            _CapsResetIfOn()
            SetTimer(_CapsResetIfOn, -100)
            SetTimer(_CapsResetIfOn, -350)
        }
    } else if WinActive("ahk_id " wv2Win.hwnd) {
        ; Window already in foreground — hide it (toggle off)
        g_wv2Shown := false
        g_markWordActive := false
        wv2Win.Hide()
        if InStr(StrUpper(g_hkOpenGui), "CAPSLOCK")
            _CapsResetIfOn()
    } else {
        ; Window open but in background — just bring it to front
        try WinActivate("ahk_id " wv2Win.hwnd)
        if InStr(StrUpper(g_hkOpenGui), "CAPSLOCK") {
            _CapsResetIfOn()
            SetTimer(_CapsResetIfOn, -350)
        }
    }
}

; Poll the foreground window (4×/s) and remember it whenever it isn't one of
; Expanto's own windows. Keeps g_prevWinId pointing at the real target app so
; direct insert works no matter how the user got to Expanto.
TrackPrevWin() {
    global wv2Win, g_prevWinId
    static myPid := DllCall("GetCurrentProcessId", "uint")
    if !IsSet(wv2Win)
        return
    id := 0
    try id := WinGetID("A")
    if (!id || id = wv2Win.hwnd)
        return
    pid := 0
    try pid := WinGetPID("ahk_id " id)
    if (pid = myPid)                      ; any Expanto-owned window (popups, dialogs)
        return
    exe := ""
    try exe := WinGetProcessName("ahk_id " id)
    if (InStr(exe, "msedgewebview2"))     ; Expanto's WebView2 renderer process
        return
    g_prevWinId := id
}

; If the just-inserted phrase carries a link, offer to open it. Called AFTER the
; text is inserted so insertion is never blocked; deferred so focus settles first.
_MaybePromptUrl(hs) {
    if (IsObject(hs) && hs.HasOwnProp("url") && hs.url != "")
        SetTimer(_PromptUrl.Bind(hs.url), -250)
}

_PromptUrl(url) {
    isWeb := RegExMatch(url, "i)^[a-z][\w+.\-]*://") > 0
    g := Gui("+AlwaysOnTop +ToolWindow", _AT("url.title"))
    g.SetFont("s10")
    g.AddText("w400", _AT("url.body"))
    g.AddEdit("w400 ReadOnly", url)
    bOpen := g.AddButton("w120 Default", isWeb ? _AT("url.openLink") : _AT("url.openFile"))
    bOpen.OnEvent("Click", (*) => (g.Destroy(), _OpenUrlTarget(url, false)))
    if (!isWeb) {
        bFolder := g.AddButton("x+8 yp w120", _AT("url.openFolder"))
        bFolder.OnEvent("Click", (*) => (g.Destroy(), _OpenUrlTarget(url, true)))
    }
    bClose := g.AddButton("x+8 yp w90", _AT("url.close"))
    bClose.OnEvent("Click", (*) => g.Destroy())
    g.OnEvent("Escape", (*) => g.Destroy())
    g.OnEvent("Close",  (*) => g.Destroy())
    g.Show()
}

_OpenUrlTarget(url, folder) {
    try {
        if (folder)
            Run('explorer.exe /select,"' url '"')
        else
            Run(url)
    } catch as e {
        MsgBox(_AT("url.failed") "`n" url "`n`n" e.Message, _AT("url.title"), "Iconx")
    }
}

DoDirectInsert(id) {
    global g_prevWinId, g_stepLabels, g_lastFired, g_lastSent, g_lastCaretBack
    hs := FindHsById(id)
    if (!hs || g_prevWinId = 0)
        return
    try {
        WinActivate("ahk_id " g_prevWinId)
        WinWaitActive("ahk_id " g_prevWinId, , 1)
    } catch {
        return
    }
    Hotstring("Reset")
    raw := PickPhraseText(hs)      ; popup when the phrase has alternative texts
    if (raw = "" && _HsAlts(hs).Length)
        return                     ; picker cancelled — insert nothing
    unesc := PresubCustomFields(raw, hs.customFields)
    if (g_stepLabels.Length > 0 && InStr(unesc, "|")) {
        StartStepThrough(hs, unesc)
        return
    }
    pGuard := true
    try pGuard := CoupleIdentityGuard(hs.filepath)
    if (!pGuard)
        return
    g_lastSent := "", g_lastCaretBack := 0
    res := ExpandDynamic(unesc, hs.filepath, hs.short)
    if (res.ok)
        _DirectSendExpanded(res.text)
    g_lastFired := { hs: hs, sent: g_lastSent, endChar: "", caretBack: g_lastCaretBack, undoable: (g_lastSent != "") }
    RecordUsage(hs.id)
    SetTimer(ShowUndoPopup, -300)
    global wv2Win, g_wv2Shown, g_markWordActive
    g_wv2Shown := false
    g_markWordActive := false
    wv2Win.Hide()
    _MaybePromptUrl(hs)
}

; Insert arbitrary raw text (used when trim-on-save differs from inserted text)
DoDirectInsertRaw(text) {
    global g_prevWinId, g_lastFired, g_lastSent, g_lastCaretBack
    if (g_prevWinId = 0)
        return
    try {
        WinActivate("ahk_id " g_prevWinId)
        WinWaitActive("ahk_id " g_prevWinId, , 1)
    } catch {
        return
    }
    Hotstring("Reset")
    unesc := Unescape_CC(text)
    g_lastSent := "", g_lastCaretBack := 0
    res := ExpandDynamic(unesc)
    if (res.ok)
        _DirectSendExpanded(res.text)
    g_lastFired := { hs: {id: "", trigger: ""}, sent: g_lastSent, endChar: "", caretBack: g_lastCaretBack, undoable: (g_lastSent != "") }
    global wv2Win, g_wv2Shown, g_markWordActive
    g_wv2Shown := false
    g_markWordActive := false
    wv2Win.Hide()
}

; Force step-through using paragraph/| splitting (called from GUI Insert Step action)
DoDirectInsertStep(id) {
    global g_prevWinId, g_lastFired, g_lastSent, g_lastCaretBack
    hs := FindHsById(id)
    if (!hs || g_prevWinId = 0)
        return
    try {
        WinActivate("ahk_id " g_prevWinId)
        WinWaitActive("ahk_id " g_prevWinId, , 1)
    } catch {
        return
    }
    Hotstring("Reset")
    raw := PickPhraseText(hs)      ; popup when the phrase has alternative texts
    if (raw = "" && _HsAlts(hs).Length)
        return                     ; picker cancelled — insert nothing
    unesc := PresubCustomFields(raw, hs.customFields)
    segs := SplitPhraseIntoSegments(unesc)
    if (segs.Length >= 2) {
        StartStepThrough(hs, unesc)
        return
    }
    g_lastSent := "", g_lastCaretBack := 0
    res := ExpandDynamic(unesc, hs.filepath, hs.short)
    if (res.ok)
        _DirectSendExpanded(res.text)
    g_lastFired := { hs: hs, sent: g_lastSent, endChar: "", caretBack: g_lastCaretBack, undoable: (g_lastSent != "") }
    RecordUsage(hs.id)
    SetTimer(ShowUndoPopup, -300)
}

_GlobalInsertCore(forceStep) {
    global g_selectedId, wv2Win, g_prevWinId, g_stepLabels, g_lastFired, g_lastSent, g_lastCaretBack
    if (g_selectedId = "")
        return
    hs := FindHsById(g_selectedId)
    if !IsObject(hs)
        return
    ; If Expanto itself is the active window, switch to the previous target window
    if (WinActive("ahk_id " wv2Win.hwnd)) {
        if (g_prevWinId = 0)
            return
        try {
            WinActivate("ahk_id " g_prevWinId)
            WinWaitActive("ahk_id " g_prevWinId, , 1)
        } catch {
            return
        }
    }
    Hotstring("Reset")
    raw := PickPhraseText(hs)      ; popup when the phrase has alternative texts
    if (raw = "" && _HsAlts(hs).Length)
        return                     ; picker cancelled — insert nothing
    unesc := PresubCustomFields(raw, hs.customFields)
    useStep := false
    if (forceStep) {
        segs := SplitPhraseIntoSegments(unesc)
        useStep := segs.Length >= 2
    } else if (g_stepLabels.Length > 0 && InStr(unesc, "|")) {
        segs := SplitPhraseIntoSegments(unesc)
        useStep := segs.Length >= 2
    }
    if (useStep) {
        StartStepThrough(hs, unesc)
        return
    }
    g_lastSent := "", g_lastCaretBack := 0
    res := ExpandDynamic(unesc, hs.filepath, hs.short)
    if (res.ok)
        _DirectSendExpanded(res.text)
    g_lastFired := { hs: hs, sent: g_lastSent, endChar: "", caretBack: g_lastCaretBack, undoable: (g_lastSent != "") }
    RecordUsage(hs.id)
    SetTimer(ShowUndoPopup, -300)
}

DoGlobalInsert(*) => _GlobalInsertCore(false)

DoGlobalInsertStep(*) {
    global wv2Win, g_prevWinId
    if StepActive() {
        ; Already in step mode — switch to target window if needed, then advance
        if (WinActive("ahk_id " wv2Win.hwnd)) {
            if (g_prevWinId = 0)
                return
            try {
                WinActivate("ahk_id " g_prevWinId)
                WinWaitActive("ahk_id " g_prevWinId, , 1)
            } catch {
                return
            }
        }
        SetTimer(StepNext, -1)
    } else {
        _GlobalInsertCore(true)
    }
}

; Predicate for HotIf: global hotkeys are suppressed while CapsLock is physically held,
; so that CapsLock+modifier combos in other scripts (kbd nav) are never intercepted here.
_HkCondNoCaps(*) {
    return !GetKeyState("CapsLock", "P")
}

; Predicate for HotIf: fires only while CapsLock is physically held.
; Used to implement "CapsLock & X" without registering CapsLock as a compound prefix —
; registering it as compound would cause AHK to hold CapsLock events from other scripts'
; hooks, breaking kbd nav's own CapsLock compound hotkeys (CapsLock & j, k, l, …).
_HkCondCapsPhys(*) {
    return GetKeyState("CapsLock", "P")
}

; Guard used by GUI hotkeys: key passes through (~) but action is suppressed while CapsLock
; is physically held, so kbd nav's CapsLock+key combos work even when Expanto is active.
_GuardCaps(fn, p*) {
    if !GetKeyState("CapsLock", "P")
        fn(p*)
}

_WrapHkFn(newKey, fn) {
    return _GuardCaps.Bind(fn)
}

ApplyHotkeyPair(&stored, newKey, fn) {
    newKey := Trim(newKey)
    ; Normalize "CapsLock_Space" style (manual entry) → "CapsLock & Space" (AHK combination syntax)
    if RegExMatch(newKey, "^([^&+^!#<>\s]+)_([^&+^!#<>\s]+)$", &m)
        newKey := m[1] " & " m[2]
    isCaps := InStr(StrUpper(newKey), "CAPSLOCK")
    if (stored != "" && stored != newKey) {
        oldIsCaps := InStr(StrUpper(stored), "CAPSLOCK")
        if oldIsCaps {
            oldSuffix := RegExReplace(stored, "i)^.*CapsLock\s*&\s*", "")
            HotIf(_HkCondCapsPhys)
            try Hotkey(oldSuffix, "Off")
            HotIf()
            ; Also try legacy compound-hotkey registrations from earlier sessions
            try Hotkey("~" . stored, "Off")
            try Hotkey(stored, "Off")
        } else {
            HotIf(_HkCondNoCaps)
            try Hotkey(stored, "Off")
            HotIf()
        }
    }
    if (newKey != "") {
        if isCaps {
            ; Register just the suffix key (e.g. "Space") under _HkCondCapsPhys instead of
            ; a compound hotkey — AHK then never marks CapsLock as a prefix, so kbd nav's
            ; CapsLock & j / k / l / … hotkeys fire without any interference from Expanto.
            suffix := RegExReplace(newKey, "i)^.*CapsLock\s*&\s*", "")
            HotIf(_HkCondCapsPhys)
            try Hotkey(suffix, fn, "On")
            HotIf()
        } else {
            ; Use HotIf instead of ~ prefix: when CapsLock is held the condition fails and
            ; AHK never intercepts the key at all — the unmodified event reaches kbd nav.
            HotIf(_HkCondNoCaps)
            try Hotkey(newKey, fn, "On")
            HotIf()
        }
    }
    stored := newKey
}

_CapsCaptureAction(*) {
    SetCapsLockState "AlwaysOff"
}

_CapsResetIfOn(*) {
    if GetKeyState("CapsLock", "T")
        SetCapsLockState "Off"
}

; Default global hotkeys. These mirror the placeholder values shown in the
; settings UI (ui/index.html) so a blank or absent hotkey falls back to its
; placeholder instead of being silently disabled — "what the field shows is the
; key that fires". Keys not listed here default to "" (no hotkey).
; NOTE: the plain Insert ("Infoga vald fras") has no default on purpose — !v is
; owned by stegvis insertion (StepNext) and the same key can't drive two actions,
; so its UI placeholder was removed to keep placeholders honest.
_HkDef(key) {
    switch key, false {
        case "OpenGui":    return "+Space"
        case "MarkWord":   return "<^>!Space"
        case "StepNext":   return "!v"
        case "InsertStep": return "!+v"
    }
    return ""
}

; Disable sentinels — typing one of these in a hotkey field turns that command
; fully off: no key is registered AND the default is NOT applied. (A blank field
; still means "use the default".) Accepts sv/en variants; comparison is via "="
; which is case-insensitive in AHK v2.
_HkIsOff(val) {
    val := Trim(val)
    return (val = "av" || val = "off" || val = "none")
}

; Value to SHOW in the settings UI: the stored key (including a disable sentinel),
; or the effective default when the field is blank. This is what the field reads,
; so the box always reflects what actually fires.
_HkDisplay(key) {
    global inifile
    raw := Trim(IniRead(inifile, "Hotkeys", key, ""))
    return raw != "" ? raw : _HkDef(key)
}

; Value to REGISTER: "" when disabled via a sentinel; otherwise the stored key,
; or the default when blank. "" means no hotkey is registered.
_HkEffective(key) {
    global inifile
    raw := Trim(IniRead(inifile, "Hotkeys", key, ""))
    if _HkIsOff(raw)
        return ""
    return raw != "" ? raw : _HkDef(key)
}

InitGlobalHotkeys() {
    global inifile, g_hkOpenGui, g_hkUndo, g_hkMarkWord, g_hkLastFired, g_hkInsert, g_hkInsertStep
    if (IniRead(inifile, "Hotkeys", "CapsCapture", "1") = "1")
        Hotkey("~*CapsLock", _CapsCaptureAction, "On")
    else
        try Hotkey("~*CapsLock", _CapsCaptureAction, "Off")
    ApplyHotkeyPair(&g_hkOpenGui,    _HkEffective("OpenGui"),    ShowHideWv2Win)
    ApplyHotkeyPair(&g_hkUndo,       _HkEffective("Undo"),       UndoLastExpansion)
    ApplyHotkeyPair(&g_hkMarkWord,   _HkEffective("MarkWord"),   ExpandMarkedWord)
    ApplyHotkeyPair(&g_hkLastFired,  _HkEffective("LastFired"),  ShowLastFiredInGui)
    ApplyHotkeyPair(&g_hkInsert,     _HkEffective("Insert"),     DoGlobalInsert)
    ApplyHotkeyPair(&g_hkInsertStep, _HkEffective("InsertStep"), DoGlobalInsertStep)
}

InitGuiHotkeys() {
    global inifile, g_hkGuiMap, wv2Win
    static names := ["New","Update","Delete","FilterFile","FilterCat","FilterTag",
                     "AssignCat","AssignTag","SwitchField","AiSuggest","Layout","OnTop",
                     "MoveFile","Settings","EditFile","LastEdited","Dupes","Panel"]
    hwnd := wv2Win.hwnd
    HotIfWinActive("ahk_id " hwnd)
    for name in names {
        newKey := Trim(IniRead(inifile, "Hotkeys", name, ""))
        if _HkIsOff(newKey)
            newKey := ""   ; "av"/"off" disables the GUI hotkey instead of trying to register it as a key
        oldKey := g_hkGuiMap.Has(name) ? g_hkGuiMap[name] : ""
        if (oldKey != "" && oldKey != newKey) {
            try Hotkey("~" . oldKey, "Off")  ; current format
            try Hotkey(oldKey, "Off")          ; legacy: registered without ~ in older sessions
        }
        if (newKey != "")
            ; ~ lets the key pass through to kbd nav; _WrapHkFn/_GuardCaps suppresses the
            ; Expanto action when CapsLock is physically held (used as modifier in kbd nav).
            try Hotkey("~" . newKey, _WrapHkFn(newKey, _GuiHkFire.Bind(name)), "On")
        g_hkGuiMap[name] := newKey
    }
    ; Alt+V opens the new-phrase file picker (or focuses the bulk "move to file" list). That
    ; picker is a custom WebView control, so an HTML accesskey can't reliably activate it —
    ; drive it from AHK instead. No "~": we fully intercept Alt+V so it never reaches the
    ; WebView (whose accesskey path is what's broken) or the window's Alt-menu handling.
    try Hotkey("!v", _GuiHkFire.Bind("FilePicker"), "On")
    HotIfWinActive()
}

_GuiHkFire(name, *) {
    global wv2Core
    if IsSet(wv2Core)
        _SafeSend(wv2Core,"window.handleGuiHotkey(" JSON.Dump(name) ")")
}

ShowLastFiredInGui(*) {
    global wv2Core, g_lastFired, wv2Win
    if !IsObject(g_lastFired) || !IsObject(g_lastFired.hs)
        return
    ShowWv2Win()
    if IsSet(wv2Core)
        _SafeSend(wv2Core,"window.selectPhrase(" JSON.Dump(g_lastFired.hs.id) ")")
}

; ══════════════════════════════════════════════════════════════════════════════
; Undo popup — small non-activating overlay after every insertion
; ══════════════════════════════════════════════════════════════════════════════

CreateUndoPopup() {
    global g_undoPopup
    if IsSet(g_undoPopup) && IsObject(g_undoPopup)
        return
    p := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x08000000", "ExpantoUndo")
    p.BackColor := "1E2127"
    p.SetFont("s10", "Segoe UI")
    p.MarginX := 8, p.MarginY := 6
    p.AddButton("w76 h26 cWhite", "↩ Ångra").OnEvent("Click",   (*) => _DoUndoClick())
    p.AddButton("x+4 yp w76 h26 cWhite", "📋 Kopiera").OnEvent("Click", (*) => _DoCopyClick())
    p.AddButton("x+4 yp w76 h26 cWhite", "✎ Redigera").OnEvent("Click", (*) => _DoEditClick())
    p.OnEvent("Close", (*) => HideUndoPopup())
    g_undoPopup := p
}

ShowUndoPopup(*) {
    global g_undoPopup, g_lastFired
    if !IsObject(g_lastFired) || !g_lastFired.undoable
        return
    CreateUndoPopup()
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    g_undoPopup.Show("x" (mx + 12) " y" (my - 70) " NoActivate AutoSize")
    SetTimer(HideUndoPopup, -4000)
}

HideUndoPopup(*) {
    global g_undoPopup
    if IsSet(g_undoPopup) && IsObject(g_undoPopup)
        try g_undoPopup.Hide()
}

_DoUndoClick(*) {
    HideUndoPopup()
    UndoLastExpansion()
}

_DoCopyClick(*) {
    global g_lastFired
    HideUndoPopup()
    if IsObject(g_lastFired) && g_lastFired.sent != ""
        A_Clipboard := g_lastFired.sent
}

_DoEditClick(*) {
    HideUndoPopup()
    ShowLastFiredInGui()
}

; ══════════════════════════════════════════════════════════════════════════════
; Usage tracking — persist phrase usage timestamps to JSON
; ══════════════════════════════════════════════════════════════════════════════

LoadUsage() {
    global g_usageMap, g_usageFile, inifile
    g_usageFile := RegExReplace(inifile, "\.ini$", "") "_usage.json"
    if !FileExist(g_usageFile)
        return
    try {
        raw  := FileRead(g_usageFile, "UTF-8")
        data := JSON.Load(raw)
        if IsObject(data)
            for k, v in data
                g_usageMap[k] := v
    }
}

RecordUsage(id) {
    global g_usageMap
    g_usageMap[id] := FormatTime(, "yyyy-MM-dd'T'HH:mm:ss")
    SetTimer(_FlushUsage, -2000)
}

_FlushUsage(*) {
    global g_usageMap, g_usageFile
    if (g_usageFile = "")
        return
    try FileDelete(g_usageFile)
    try FileAppend(JSON.Dump(g_usageMap), g_usageFile, "UTF-8")
}

ExpandMarkedWord(*) {
    global wv2Win, wv2Core, g_wv2Shown, g_prevWinId, g_markWordActive, g_wv2Ready, g_encPromptActive
    ; Guard: skip if a modal AHK dialog (e.g. password prompt) is open — prevents key injection
    ; into the dialog and avoids using wv2Core during pre-Reload teardown.
    if (g_encPromptActive) {
        g_markWordActive := false
        return
    }
    ; Guard: skip entirely if Expanto or its WebView2 renderer is the active window,
    ; UNLESS we are already in repeat mode (then we need to switch back to source app).
    local _activeExe := ""
    try _activeExe := WinGetProcessName("A")
    local _activeId := 0
    try _activeId := WinGetID("A")
    if (_activeId = wv2Win.hwnd || InStr(_activeExe, "msedgewebview2")) {
        if (!g_markWordActive || g_prevWinId = 0) {
            g_markWordActive := false
            return
        }
    }
    if (g_markWordActive && g_wv2Shown && g_prevWinId != 0) {
        ; Subsequent press — switch to source app and extend selection one word left
        try {
            WinActivate("ahk_id " g_prevWinId)
            WinWaitActive("ahk_id " g_prevWinId, , 1)
        } catch {
            g_markWordActive := false
            return
        }
    } else {
        ; First press — record the source window
        g_prevWinId := _activeId
        g_markWordActive := false
    }
    savedClip := ClipboardAll()
    A_Clipboard := ""
    Send("^+{Left}")
    Sleep(30)
    Send("^c")
    ClipWait(0.8)
    word := Trim(A_Clipboard)
    A_Clipboard := savedClip
    if (word = "") {
        g_markWordActive := false
        return
    }
    g_markWordActive := true
    wv2Win.Show()
    g_wv2Shown := true
    WinActivate("ahk_id " wv2Win.hwnd)
    ; Pump the message loop so any pending ProcessFailed event can fire and clear g_wv2Ready
    Sleep(5)
    if (!g_wv2Ready)
        return
    safe := StrReplace(StrReplace(word, "\", "\\"), "`"", "\`"")
    try _SafeSend(wv2Core,"window.receiveMarkedWord(`"" safe "`")")
}

