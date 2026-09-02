; ─────────────────────────────────────────────────────────────────────────────
; Encrypted phrase files (optional module) — ".enc" files hold the SAME text
; format as ordinary phrase files, wrapped in AES-256-GCM via Windows CNG
; (bcrypt.dll — nothing to install, works on locked-down machines).
;
; One shared password for all .enc files, asked once per session and kept only
; in memory (re-passed to the new process via the environment on Reload, never
; written to disk). Plaintext NEVER touches disk: decrypt on load, re-encrypt
; on every save. Wrong password / corrupt file is detected by the GCM auth tag.
;
; File format ("HSENC001"):  magic(8) + salt(16) + nonce(12) + tag(16) + cipher.
; Key = PBKDF2-SHA256(password, salt, 600 000 iterations) → 32 bytes.
; A fresh random salt + nonce is used for every write.
;
; The host script routes phrase-file IO through PhraseFileRead/-WriteAll/-Append,
; which only touch this module for .enc paths (via dynamic references), so the
; app loads and runs fine if this file is removed — .enc files are then ignored.
; .enc files are ALWAYS excluded from the AI features (see AIExcluded).
; ─────────────────────────────────────────────────────────────────────────────

global g_encLockedNow    := (EnvGet("HSENC_SKIP") = "1")   ; this start follows a deliberate Lock
global g_encPwStored     := false                ; the session pw came from the saved blob
global g_encPw           := EnvGet("HSENC_PW")   ; session password (set on unlock; survives Reload via env)
; Skip .enc by default when no session PW exists (fresh start or after lock).
; Only load when user explicitly unlocks (prompt in UI/toolbar).
global g_encSkip         := (EnvGet("HSENC_PW") = "") || (EnvGet("HSENC_SKIP") = "1")
global g_encKeyCache     := Map()                ; "salthex`npw" -> derived key (Buffer)
global g_encPromptActive := false                ; true while password dialog is open
if (g_encPw != "")
    try EnvSet("HSENC_PW")                   ; consume it — don't leave it in our env block
if (EnvGet("HSENC_SKIP") != "")
    try EnvSet("HSENC_SKIP")
OnExit(EncOnExit)

; ─────────────────────────────────────────────────────────────────────────────
; Automatic unlock at startup (opt-in, off by default)
;
; The password is stored through DPAPI (CryptProtectData), which encrypts it
; with the WINDOWS ACCOUNT's own key material — so the blob is readable only by
; this user on this machine, and an offline copy of the disk is no use without
; the account's credentials. It is written to %APPDATA%\Expanto, deliberately
; NOT to a phrase folder: the .enc files live under OneDrive and sync to the
; cloud, and that copy has to stay unreadable — which is the whole reason the
; phrases are encrypted in the first place.
;
; What this trades away, stated plainly: with auto-unlock on, anything running
; AS THIS USER on this machine can read the phrases without knowing the
; password. Locking the screen is what stands between someone at the keyboard
; and the phrases, exactly as it does for everything else already open.
;
; "Lås session" forgets the stored password as well as the session one, so a
; lock is a real lock and not something the next start undoes.
; ─────────────────────────────────────────────────────────────────────────────
EncAutoPath() => A_AppData "\Expanto\enc.dpapi"
; The module is included before the host declares `inifile`, so the path is
; built here rather than read from that global.
EncIniPath()  => A_AppData "\Expanto\settings.ini"
EncAutoEnabled() => (IniRead(EncIniPath(), "Encryption", "AutoUnlock", "0") != "0")

; DATA_BLOB is { DWORD cbData; BYTE *pbData } — 4 bytes, 4 of padding, then the
; pointer on x64.
_EncBlob(ptr, size) {
    b := Buffer(16, 0)
    NumPut("uint", size, b, 0)
    NumPut("ptr", ptr, b, 8)
    return b
}

; A fixed extra input to DPAPI, so this blob cannot be unwrapped as some other
; program's and vice versa. Not a secret — it is right here in the source; it
; only separates this use from every other one on the machine.
_EncEntropy() {
    static e := 0
    if !e {
        s := "Expanto.enc.autounlock.v1"
        e := Buffer(StrPut(s, "UTF-8"), 0)
        StrPut(s, e, "UTF-8")
    }
    return e
}

EncAutoSave(pw) {
    try {
        pwBuf := Buffer(StrPut(pw, "UTF-8"), 0)
        StrPut(pw, pwBuf, "UTF-8")
        ent := _EncEntropy()
        out := Buffer(16, 0)
        ; CRYPTPROTECT_UI_FORBIDDEN (1): never put UI on screen from here.
        ok := DllCall("crypt32\CryptProtectData"
            , "ptr", _EncBlob(pwBuf.Ptr, pwBuf.Size - 1)     ; without the terminator
            , "wstr", "Expanto encrypted phrases"
            , "ptr", _EncBlob(ent.Ptr, ent.Size)
            , "ptr", 0, "ptr", 0, "uint", 1, "ptr", out, "int")
        if !ok
            return false
        size := NumGet(out, 0, "uint"), ptr := NumGet(out, 8, "ptr")
        blob := Buffer(size)
        DllCall("RtlMoveMemory", "ptr", blob, "ptr", ptr, "uptr", size)
        DllCall("LocalFree", "ptr", ptr)
        DirCreate(A_AppData "\Expanto")
        f := FileOpen(EncAutoPath(), "w")
        f.RawWrite(blob, size)
        f.Close()
        return true
    }
    return false
}

EncAutoLoad() {
    try {
        if !FileExist(EncAutoPath())
            return ""
        raw := FileRead(EncAutoPath(), "RAW")
        ent := _EncEntropy()
        out := Buffer(16, 0)
        ok := DllCall("crypt32\CryptUnprotectData"
            , "ptr", _EncBlob(raw.Ptr, raw.Size)
            , "ptr", 0
            , "ptr", _EncBlob(ent.Ptr, ent.Size)
            , "ptr", 0, "ptr", 0, "uint", 1, "ptr", out, "int")
        if !ok
            return ""                                  ; other account, other machine, or tampered
        size := NumGet(out, 0, "uint"), ptr := NumGet(out, 8, "ptr")
        buf := Buffer(size)
        DllCall("RtlMoveMemory", "ptr", buf, "ptr", ptr, "uptr", size)
        DllCall("LocalFree", "ptr", ptr)
        return StrGet(buf, size, "UTF-8")
    }
    return ""
}

EncAutoForget() {
    global g_encPwStored
    g_encPwStored := false
    try FileDelete(EncAutoPath())
}

; Tray toggle. Turning it on stores the password that is already unlocked, so
; it takes effect without asking for it again.
EncSetAuto(on) {
    global g_encPw
    try IniWrite(on ? 1 : 0, EncIniPath(), "Encryption", "AutoUnlock")
    if !on {
        EncAutoForget()
        return
    }
    if (g_encPw != "")
        EncAutoSave(g_encPw)
}

; The unlock itself, at module load: only on a normal start (not after a Lock),
; only when nothing was handed over by a Reload, and only if the setting is on.
if (g_encPw = "" && !g_encLockedNow && EncAutoEnabled()) {
    _autoPw := EncAutoLoad()
    if (_autoPw != "") {
        g_encPw       := _autoPw
        g_encSkip     := false
        g_encPwStored := true
    }
}

; Hand the session password to the reloaded instance. MUST be called BEFORE Reload()
; (the new process inherits our env at launch — i.e. before OnExit would run).
EncHandoff() {
    global g_encPw
    if (g_encPw != "")
        try EnvSet("HSENC_PW", g_encPw)
}

; Lock: forget the session password and reload with .enc loading skipped (so the
; encrypted phrases vanish from the list until the user unlocks again).
EncLock(*) {
    global g_encPw, g_wv2Ready, g_hkMarkWord
    EncAutoForget()          ; a lock the next start undoes is not a lock
    g_encPw    := ""
    g_wv2Ready := false
    if (g_hkMarkWord != "")
        try Hotkey(g_hkMarkWord, "Off")
    try EnvSet("HSENC_SKIP", "1")
    Reload()
}

; Unlock: prompt for password, then reload so .enc files are decrypted on load.
EncUnlock(*) {
    global g_encPw, g_encSkip, g_wv2Ready, g_hkMarkWord
    pw := EncPromptPw(false)
    if (pw = "")
        return
    g_encPw    := pw
    g_encSkip  := false
    if EncAutoEnabled()      ; keep the stored copy in step with the real one
        EncAutoSave(pw)
    g_wv2Ready := false
    if (g_hkMarkWord != "")
        try Hotkey(g_hkMarkWord, "Off")
    EncHandoff()
    Reload()
}

; Public API, consumed by the host via this marker global (IsSet(g_encModule) =
; "module present"). The host holds NO static references to this file, so it
; loads and runs without it.
global g_encModule := Map(
    "EncFileRead",    EncFileRead,
    "EncFileWrite",   EncFileWrite,
    "EncImportExcel", EncImportExcel,
    "EncLockFile",    EncLockFile,
    "EncLockPath",    EncLockPath,
    "EncUnlockFile",  EncUnlockFile,
    "EncLock",        EncLock,
    "EncUnlock",      EncUnlock,
    "EncSetAuto",     EncSetAuto,
    "EncAutoEnabled", EncAutoEnabled,
    "EncHandoff",     EncHandoff)

EncOnExit(reason, code) {
    global g_encPw
    if (reason = "Reload" && g_encPw != "")
        try EnvSet("HSENC_PW", g_encPw)      ; hand the session password to the new process
    return 0
}

; ── Password handling ────────────────────────────────────────────────────────

; Return the session password, prompting if needed. create=true → double-entry
; confirm (first .enc file). force=true → prompt even if the user skipped earlier
; (used for writes). Returns "" if the user declines.
EncEnsurePw(create := false, force := false) {
    global g_encPw, g_encSkip
    if (g_encPw != "")
        return g_encPw
    if (g_encSkip && !force && !create)
        return ""
    pw := EncPromptPw(create)
    if (pw != "") {
        g_encPw   := pw
        g_encSkip := false
    }
    return pw
}

_EncTogglePwShow(s, *) {
    c := s.chk.Value ? 0 : 42          ; 0 = show plain text, 42 = '*' mask
    SendMessage(0xCC, c, 0, s.pw)      ; EM_SETPASSWORDCHAR
    DllCall("InvalidateRect", "ptr", s.pw, "ptr", 0, "int", 1)
    if (s.cf) {
        SendMessage(0xCC, c, 0, s.cf)
        DllCall("InvalidateRect", "ptr", s.cf, "ptr", 0, "int", 1)
    }
}

; Modal password dialog. Returns the password or "" (skip/cancel).
EncPromptPw(create := false) {
    global g_encPromptActive
    dg := Gui("+AlwaysOnTop +ToolWindow +OwnDialogs", create ? "Välj lösenord för krypterade fraser" : "Lås upp krypterade fraser")
    dg.SetFont("s10", "Segoe UI")
    dg.AddText("xm w340", create
        ? "Välj ett lösenord för .enc-filerna (samma för alla).`nOBS: glömt lösenord kan INTE återställas."
        : "Ange lösenordet för de krypterade frasfilerna (.enc).")
    dg.AddText("xm y+10 w110 h22 +0x200", "Lösenord:")
    pwEdit := dg.AddEdit("x+6 yp w220 h22 Password")
    cfEdit := ""
    if (create) {
        dg.AddText("xm y+8 w110 h22 +0x200", "Upprepa:")
        cfEdit := dg.AddEdit("x+6 yp w220 h22 Password")
    }
    showChk := dg.AddCheckbox("xm y+6 w336", "Visa lösenord")
    _cfHwnd := (cfEdit != "") ? cfEdit.Hwnd : 0
    showChk.OnEvent("Click", _EncTogglePwShow.Bind({chk: showChk, pw: pwEdit.Hwnd, cf: _cfHwnd}))
    state := { done: false, pw: "" }
    finish(isOk, *) {
        if (isOk) {
            p := Trim(pwEdit.Value)
            if (p = "") {
                MsgBox "Lösenordet får inte vara tomt."
                return
            }
            if (pwEdit.Value != p)
                MsgBox "OBS: lösenordet innehöll inledande/avslutande blanksteg som togs bort automatiskt."
            if (create && Trim(cfEdit.Value) != p) {
                MsgBox "Lösenorden matchar inte — försök igen."
                return
            }
            state.pw := p
        }
        state.done := true
        dg.Destroy()
    }
    okBtn := dg.AddButton("xm y+10 w120 Default", "OK")
    okBtn.OnEvent("Click", finish.Bind(true))
    skipBtn := dg.AddButton("x+8 w160", create ? "Avbryt" : "Hoppa över (ladda inte)")
    skipBtn.OnEvent("Click", finish.Bind(false))
    dg.OnEvent("Escape", finish.Bind(false))
    dg.OnEvent("Close",  finish.Bind(false))
    g_encPromptActive := true
    dg.Show()
    pwEdit.Focus()
    while (!state.done)
        Sleep 30
    g_encPromptActive := false
    return state.pw
}

; ── Crypto primitives (Windows CNG / bcrypt.dll) ─────────────────────────────

EncRandom(n) {
    b := Buffer(n, 0)
    r := DllCall("bcrypt\BCryptGenRandom", "ptr", 0, "ptr", b, "uint", n, "uint", 2, "uint")  ; 2 = use system RNG
    if (r != 0)
        throw Error("BCryptGenRandom: " Format("0x{:08X}", r))
    return b
}

; PBKDF2-SHA256(pw, salt, 600k) → 32-byte AES key. Cached per (salt, pw) so the
; ~0.5 s derivation runs once per file generation, not per save.
EncDeriveKey(pw, salt) {
    global g_encKeyCache
    ck := ""
    Loop salt.Size
        ck .= Format("{:02X}", NumGet(salt, A_Index - 1, "uchar"))
    ck .= "`n" pw
    if g_encKeyCache.Has(ck)
        return g_encKeyCache[ck]
    hAlg := 0
    r := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", &hAlg, "wstr", "SHA256", "ptr", 0, "uint", 0x8, "uint")  ; 0x8 = HMAC
    if (r != 0)
        throw Error("BCryptOpenAlgorithmProvider(SHA256): " Format("0x{:08X}", r))
    pwBuf := Buffer(StrPut(pw, "UTF-8"))
    StrPut(pw, pwBuf, "UTF-8")
    key := Buffer(32, 0)
    r := DllCall("bcrypt\BCryptDeriveKeyPBKDF2", "ptr", hAlg, "ptr", pwBuf, "uint", pwBuf.Size - 1,
        "ptr", salt, "uint", salt.Size, "uint64", 600000, "ptr", key, "uint", 32, "uint", 0, "uint")
    DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlg, "uint", 0)
    DllCall("RtlZeroMemory", "ptr", pwBuf, "uptr", pwBuf.Size)
    if (r != 0)
        throw Error("BCryptDeriveKeyPBKDF2: " Format("0x{:08X}", r))
    g_encKeyCache[ck] := key
    return key
}

; AES-256-GCM encrypt/decrypt. Throws Error("WRONGPW") on auth-tag mismatch
; (wrong password or tampered file). tag: 16-byte Buffer (filled when encrypting).
EncGcmCrypt(encrypt, key, nonce, tag, inBuf) {
    if (A_PtrSize != 8)
        throw Error("Krypterade frasfiler kräver 64-bitars AutoHotkey.")
    hAlg := 0
    r := DllCall("bcrypt\BCryptOpenAlgorithmProvider", "ptr*", &hAlg, "wstr", "AES", "ptr", 0, "uint", 0, "uint")
    if (r != 0)
        throw Error("BCryptOpenAlgorithmProvider(AES): " Format("0x{:08X}", r))
    r := DllCall("bcrypt\BCryptSetProperty", "ptr", hAlg, "wstr", "ChainingMode",
        "wstr", "ChainingModeGCM", "uint", 32, "uint", 0, "uint")   ; 16 chars × 2 bytes incl. null
    if (r != 0) {
        DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlg, "uint", 0)
        throw Error("BCryptSetProperty(GCM): " Format("0x{:08X}", r))
    }
    hKey := 0
    r := DllCall("bcrypt\BCryptGenerateSymmetricKey", "ptr", hAlg, "ptr*", &hKey, "ptr", 0, "uint", 0,
        "ptr", key, "uint", key.Size, "uint", 0, "uint")
    if (r != 0) {
        DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlg, "uint", 0)
        throw Error("BCryptGenerateSymmetricKey: " Format("0x{:08X}", r))
    }
    ; BCRYPT_AUTHENTICATED_CIPHER_MODE_INFO (x64 layout, 88 bytes)
    info := Buffer(88, 0)
    NumPut("uint", 88, info, 0)              ; cbSize
    NumPut("uint", 1,  info, 4)              ; dwInfoVersion
    NumPut("ptr",  nonce.Ptr,  info, 8)      ; pbNonce
    NumPut("uint", nonce.Size, info, 16)     ; cbNonce
    NumPut("ptr",  tag.Ptr,    info, 40)     ; pbTag
    NumPut("uint", tag.Size,   info, 48)     ; cbTag
    out   := Buffer(inBuf.Size > 0 ? inBuf.Size : 1, 0)
    cbRes := 0
    fnc := encrypt ? "BCryptEncrypt" : "BCryptDecrypt"
    r := DllCall("bcrypt\" fnc, "ptr", hKey, "ptr", inBuf, "uint", inBuf.Size, "ptr", info,
        "ptr", 0, "uint", 0, "ptr", out, "uint", out.Size, "uint*", &cbRes, "uint", 0, "uint")
    DllCall("bcrypt\BCryptDestroyKey", "ptr", hKey)
    DllCall("bcrypt\BCryptCloseAlgorithmProvider", "ptr", hAlg, "uint", 0)
    if (r != 0) {
        if (!encrypt && (r & 0xFFFFFFFF) = 0xC000A002)   ; STATUS_AUTH_TAG_MISMATCH
            throw Error("WRONGPW")
        throw Error(fnc ": " Format("0x{:08X}", r))
    }
    return { buf: out, size: cbRes }
}

; ── .enc file IO ─────────────────────────────────────────────────────────────

EncMagic() {
    static m := ""
    if (m = "") {
        m := Buffer(8, 0)
        StrPut("HSENC001", m, 8, "CP0")
    }
    return m
}

; Encrypt text → path. Prompts for a password if none is set this session
; (double-entry when the file is being created). Aborts the current thread
; (no partial write) if the user declines.
EncFileWrite(path, text) {
    pw := EncEnsurePw(!FileExist(path), true)
    if (pw = "") {
        MsgBox "Inget lösenord angivet — åtgärden avbröts. Inget har sparats."
        Exit
    }
    salt  := EncRandom(16)
    nonce := EncRandom(12)
    tag   := Buffer(16, 0)
    n     := StrPut(text, "UTF-8") - 1               ; bytes without the null
    plain := Buffer(Max(n, 1), 0)
    if (n > 0)
        StrPut(text, plain, n, "UTF-8")
    plain.Size := n                                  ; exact size for GCM
    key := EncDeriveKey(pw, salt)
    res := EncGcmCrypt(true, key, nonce, tag, plain)
    f := FileOpen(path, "w")
    f.RawWrite(EncMagic())
    f.RawWrite(salt)
    f.RawWrite(nonce)
    f.RawWrite(tag)
    if (res.size > 0)
        f.RawWrite(res.buf, res.size)
    f.Close()
}

; Decrypt path → text. forWrite=true → must succeed (prompts even after an
; earlier skip; aborts the thread on cancel). Otherwise a skip/cancel returns ""
; and marks the session so remaining .enc files load silently as empty.
EncFileRead(path, forWrite := false) {
    global g_encPw, g_encSkip
    raw := FileRead(path, "RAW")
    if (raw.Size < 52 || StrGet(raw, 8, "CP0") != "HSENC001")
        throw Error("Inte en giltig krypterad frasfil: " path)
    salt := Buffer(16), nonce := Buffer(12), tag := Buffer(16)
    DllCall("RtlMoveMemory", "ptr", salt,  "ptr", raw.Ptr + 8,  "uptr", 16)
    DllCall("RtlMoveMemory", "ptr", nonce, "ptr", raw.Ptr + 24, "uptr", 12)
    DllCall("RtlMoveMemory", "ptr", tag,   "ptr", raw.Ptr + 36, "uptr", 16)
    cb := raw.Size - 52
    cipher := Buffer(Max(cb, 1), 0)
    if (cb > 0)
        DllCall("RtlMoveMemory", "ptr", cipher, "ptr", raw.Ptr + 52, "uptr", cb)
    cipher.Size := cb

    attempts := 0
    while true {
        pw := EncEnsurePw(false, forWrite)
        if (pw = "") {
            if (forWrite) {
                MsgBox "Inget lösenord angivet — åtgärden avbröts."
                Exit
            }
            g_encSkip := true
            return ""
        }
        key := EncDeriveKey(pw, salt)
        try {
            res := EncGcmCrypt(false, key, nonce, tag, cipher)
            return res.size > 0 ? StrGet(res.buf, res.size, "UTF-8") : ""
        } catch Error as e {
            if (e.Message != "WRONGPW")
                throw e
            ; A stored password that no longer fits (the files were re-encrypted
            ; with a new one) would otherwise be retried at every start and
            ; prompt every time. Drop it and let the prompt below replace it.
            if g_encPwStored
                EncAutoForget()
            g_encPw := ""                            ; wrong → forget and re-prompt
            attempts++
            SplitPath(path, &nm)
            if (attempts >= 3) {
                if (forWrite) {
                    MsgBox "Fel lösenord 3 gånger för " nm " — åtgärden avbröts."
                    Exit
                }
                g_encSkip := true
                MsgBox "Fel lösenord 3 gånger för " nm " — krypterade fraser laddas inte denna session.`n(Lås upp via Underhåll, eller ladda om skriptet.)"
                return ""
            }
            MsgBox "Fel lösenord för " nm " — försök igen."
        }
    }
}

; ── Tools: import / lock / unlock ───────────────────────────────────────────

EncFirstPhraseFolder() {
    global HS_folders_ALL
    return (IsSet(HS_folders_ALL) && HS_folders_ALL.Length) ? HS_folders_ALL[1].path : A_ScriptDir
}

; One-time import from a (password-protected) Excel workbook → a new .enc file.
; Reads sheet 1 via COM, asks which columns hold trigger/phrase (+ optional
; category/comment), builds ordinary hotstring lines and encrypts them.
EncImportExcel() {
    xlsx := FileSelect(1, , "Välj Excelfil att importera", "Excel (*.xlsx; *.xlsm; *.xls)")
    if (xlsx = "")
        return
    ib := InputBox("Excelfilens lösenord (lämna tomt om filen är oskyddad):", "Importera från Excel", "Password w380 h130")
    if (ib.Result != "OK")
        return
    xpw := ib.Value

    rows := 0, cols := 0, data := "", xl := "", wb := ""
    try {
        xl := ComObject("Excel.Application")
        xl.Visible       := false
        xl.DisplayAlerts := false
        if (xpw = "")
            wb := xl.Workbooks.Open(xlsx, 0, true)
        else
            wb := xl.Workbooks.Open(xlsx, 0, true, , xpw)
        ws   := wb.Worksheets(1)
        ur   := ws.UsedRange
        rows := ur.Rows.Count
        cols := ur.Columns.Count
        data := ur.Value2
        wb.Close(false)
        xl.Quit()
    } catch Error as e {
        try wb.Close(false)
        try xl.Quit()
        MsgBox "Kunde inte läsa Excelfilen:`n" e.Message "`n`n(Fel lösenord? Excel installerat?)"
        return
    }
    if (rows < 1 || cols < 2) {
        MsgBox "Hittade ingen användbar data (behöver minst två kolumner: trigger + fras)."
        return
    }

    ; column letters (A…), capped at Z — more than 26 columns is not a phrase list
    colNames := []
    Loop Min(cols, 26)
        colNames.Push(Chr(64 + A_Index))
    optNames := ["—"]
    for c in colNames
        optNames.Push(c)

    ; preview of the first rows
    prev := ""
    Loop Min(rows, 3) {
        r := A_Index, line := ""
        Loop Min(cols, 5) {
            v := ""
            try v := data[r, A_Index]
            line .= (A_Index > 1 ? "   |   " : "") Chr(64 + A_Index) ": " SubStr(v "", 1, 22)
        }
        prev .= line "`n"
    }

    dg := Gui("+AlwaysOnTop +ToolWindow +OwnDialogs", "Importera fraser från Excel (blad 1)")
    dg.SetFont("s10", "Segoe UI")
    dg.AddText("xm w500", "Förhandsvisning (första raderna):")
    dg.SetFont("s9", "Consolas")
    dg.AddText("xm y+2 w500 cGray", prev)
    dg.SetFont("s10", "Segoe UI")
    hdrCb := dg.AddCheckbox("xm y+8 Checked", "Första raden är rubriker (hoppa över den)")
    dg.AddText("xm y+10 w170 h22 +0x200", "Kolumn för TRIGGER:")
    tDDL := dg.AddDropDownList("x+6 yp w60 Choose1", colNames)
    dg.AddText("xm y+6 w170 h22 +0x200", "Kolumn för FRAS:")
    pDDL := dg.AddDropDownList("x+6 yp w60 Choose" (colNames.Length >= 2 ? 2 : 1), colNames)
    dg.AddText("xm y+6 w170 h22 +0x200", "Kategori (valfri kolumn):")
    cDDL := dg.AddDropDownList("x+6 yp w60 Choose1", optNames)
    dg.AddText("xm y+6 w170 h22 +0x200", "Kommentar (valfri kolumn):")
    mDDL := dg.AddDropDownList("x+6 yp w60 Choose1", optNames)
    dg.AddText("xm y+6 w170 h22 +0x200", "Hotstring-options:")
    oEdt := dg.AddEdit("x+6 yp w80 h22", "*")
    state := { done: false, ok: false, skipHdr: true, tCol: 1, pCol: 2, cCol: 0, mCol: 0, opts: "*" }
    finish(isOk, *) {
        if (isOk) {                                       ; capture BEFORE Destroy
            state.skipHdr := hdrCb.Value
            state.tCol := tDDL.Value, state.pCol := pDDL.Value
            state.cCol := cDDL.Value - 1, state.mCol := mDDL.Value - 1   ; 0 = "—" (none)
            state.opts := Trim(oEdt.Value)
        }
        state.ok := isOk, state.done := true
        dg.Destroy()
    }
    okBtn := dg.AddButton("xm y+14 w130 Default", "Importera…")
    okBtn.OnEvent("Click", finish.Bind(true))
    cancelBtn := dg.AddButton("x+8 w100", "Avbryt")
    cancelBtn.OnEvent("Click", finish.Bind(false))
    dg.OnEvent("Escape", finish.Bind(false))
    dg.OnEvent("Close",  finish.Bind(false))
    dg.Show()
    while (!state.done)
        Sleep 30
    if (!state.ok)
        return
    tCol := state.tCol, pCol := state.pCol
    cCol := state.cCol, mCol := state.mCol
    opts := state.opts
    if (tCol = pCol) {
        MsgBox "Trigger- och fras-kolumnen kan inte vara samma."
        return
    }

    ; build ordinary phrase-file lines
    out := "; Importerad från Excel " FormatTime(, "yyyy-MM-dd HH:mm")
    n := 0
    Loop rows {
        r := A_Index
        if (state.skipHdr && r = 1)
            continue
        trig := "", phr := ""
        try trig := Trim(data[r, tCol] "")
        try phr  := Trim(data[r, pCol] "")
        if (trig = "" || phr = "")
            continue
        cat := "", cmt := ""
        if (cCol > 0)
            try cat := Trim(data[r, cCol] "")
        if (mCol > 0)
            try cmt := Trim(data[r, mCol] "")
        meta := BuildMeta(cat, cmt, "", "", 0, 0)
        out .= "`n:" opts ":" trig g_ColCol Escape_CC(phr) " " g_Semi " " meta
        n++
    }
    if (n = 0) {
        MsgBox "Inga rader med både trigger och fras hittades."
        return
    }

    target := FileSelect("S16", EncFirstPhraseFolder() "\känsligt.enc",
        "Spara krypterad frasfil (måste ligga i en frasmapp för att laddas)", "Krypterad frasfil (*.enc)")
    if (target = "")
        return
    if (StrLower(SubStr(target, -4)) != ".enc")
        target .= ".enc"
    EncFileWrite(target, out)
    back := EncFileRead(target, true)                ; round-trip verification
    if (back != out) {
        FileDelete(target)
        MsgBox "Verifieringen misslyckades — filen togs bort. Inget importerades."
        return
    }
    if (MsgBox(n " fraser importerade och krypterade till:`n" target
        . "`n`nExcelfilen är orörd (behåll den som backup tills du verifierat allt)."
        . "`n`nLadda om appen nu så fraserna läses in?", "Import klar", "YesNo") = "Yes") {
        EncHandoff()
        Reload()
    }
}

; Encrypt an existing plain phrase file (.ahk → .enc) chosen via a file picker.
EncLockFile() {
    f := FileSelect(1, EncFirstPhraseFolder(), "Välj frasfil att kryptera (.ahk → .enc)", "Frasfiler (*.ahk)")
    if (f != "")
        EncLockPath(f)
}

; Encrypt a SPECIFIC plain phrase file (.ahk → .enc). Round-trip-verified before the
; plaintext original is deleted. Used by EncLockFile and the file-list right-click.
EncLockPath(f, *) {
    if (StrLower(SubStr(f, -4)) = ".enc") {
        MsgBox "Filen är redan krypterad."
        return
    }
    target := RegExReplace(f, "i)\.ahk$", ".enc")
    if FileExist(target) {
        MsgBox "Det finns redan en " target
        return
    }
    text := FileRead(f)
    EncFileWrite(target, text)
    back := EncFileRead(target, true)
    if (back != text) {
        FileDelete(target)
        MsgBox "Verifieringen misslyckades — avbröt. Originalfilen är orörd."
        return
    }
    FileDelete(f)                                    ; plaintext removed — that's the point
    if (MsgBox("Krypterad:`n" target "`n`nKlartextfilen är raderad. Ladda om appen nu?",
        "Kryptering klar", "YesNo") = "Yes") {
        EncHandoff()
        Reload()
    }
}

; Decrypt a .enc back to a plain phrase file (.enc → .ahk)
EncUnlockFile() {
    f := FileSelect(1, EncFirstPhraseFolder(), "Välj .enc-fil att dekryptera (.enc → .ahk)", "Krypterad frasfil (*.enc)")
    if (f = "")
        return
    target := RegExReplace(f, "i)\.enc$", ".ahk")
    if FileExist(target) {
        MsgBox "Det finns redan en " target
        return
    }
    text := EncFileRead(f, true)
    FileAppend(text, target, "UTF-8")
    FileDelete(f)
    if (MsgBox("Dekrypterad till:`n" target "`n`nOBS: fraserna ligger nu i KLARTEXT på disk. Ladda om appen nu?",
        "Dekryptering klar", "YesNo") = "Yes") {
        EncHandoff()
        Reload()
    }
}

EncUnlockPath(f, *) {
    if (StrLower(SubStr(f, -3)) != ".enc") {
        MsgBox "Filen är inte en krypterad fil (.enc)."
        return
    }
    target := RegExReplace(f, "i)\.enc$", ".ahk")
    if FileExist(target) {
        MsgBox "Det finns redan en " target
        return
    }
    text := EncFileRead(f, true)
    if (text = "")
        return
    FileAppend(text, target, "UTF-8")
    FileDelete(f)
    if (MsgBox("Dekrypterad till:`n" target "`n`nOBS: fraserna ligger nu i KLARTEXT på disk. Ladda om appen nu?",
        "Dekryptering klar", "YesNo") = "Yes") {
        EncHandoff()
        Reload()
    }
}
