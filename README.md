# Expanto

A desktop tool for AutoHotkey v2 **hotstrings** — text shortcuts that expand short triggers into longer phrases. Organize phrases in files, categories and tags, and insert them wherever you type. On top of plain expansion you get a searchable WebView2 GUI, a live hint popup, dynamic placeholder fields, coupled fields with value memory, spell checking, optional AES-256-GCM encryption, optional AI assistance, usage statistics and a bilingual (English/Swedish) interface.

Expanto is a **general-purpose** writing tool — suitable for any kind of repetitive text: support replies, code snippets, letters, form fields, boilerplate answers and much more.

---

## Contents

- [Requirements and installation](#requirements-and-installation)
- [Core concepts](#core-concepts)
- [Phrase files and format](#phrase-files-and-format)
- [The main window](#the-main-window)
  - [The toolbar](#the-toolbar)
  - [Sidebar and navigation panels](#sidebar-and-navigation-panels)
  - [The phrase list](#the-phrase-list)
  - [The editor panel](#the-editor-panel)
- [Context menus](#context-menus)
- [Keyboard shortcuts](#keyboard-shortcuts)
- [Dynamic fields](#dynamic-fields)
- [Coupled fields](#coupled-fields)
- [Step-by-step insertion](#step-by-step-insertion)
- [Hint popup](#hint-popup)
- [Undo](#undo)
- [AI features](#ai-features-optional)
- [Spell checking and word lists](#spell-checking-and-word-lists)
- [Per-file settings](#per-file-settings)
- [App restriction](#app-restriction)
- [Encryption](#encryption)
- [File watching](#file-watching)
- [Backups](#backups)
- [Statistics](#statistics)
- [Settings and data location](#settings-and-data-location)
- [Privacy and security](#privacy-and-security)
- [Optional content packs](#optional-content-packs)
- [File structure](#file-structure)

---

## Requirements and installation

### Option A — portable exe (no AutoHotkey needed)

1. Download the latest `Expanto-x.y.z.zip` from the [Releases page](https://github.com/ibst1/expanto/releases).
2. Unpack anywhere and run **`Expanto.exe`**.

`Expanto.exe` is the unmodified official AutoHotkey v2 interpreter, renamed —
when started it loads the `Expanto.ahk` script beside it. All application code
ships as readable text, and the binary is byte-identical to the official
AutoHotkey release (which also keeps antivirus false positives away).

### Option B — run from source

1. Windows with **[AutoHotkey v2](https://www.autohotkey.com/)** installed.
2. Run **`Expanto.ahk`**.

Both need the **Microsoft Edge WebView2 Runtime** — already present on Windows 10/11 if Edge is installed; otherwise download it from Microsoft.

On first start, `settings.ini` is created automatically in `%APPDATA%\Expanto\`. Open the window (tray icon menu → **Show Expanto**, or your configured shortcut) and go to **Settings → Phrase folders** to add one or more **phrase folders**.

---

## Core concepts

| Concept | Meaning |
|---|---|
| **Trigger** | the abbreviation you type (e.g. `btw`) |
| **Phrase** | the text it expands into (e.g. `by the way`) |
| **Alias** | an extra trigger for the same phrase |
| **Phrase file** | an `.ahk` or `.enc` file holding many definitions |
| **Phrase folder** | a folder of phrase files; several folders can be active at once |

Every phrase carries: trigger, phrase text, hotstring options, category, tags, comment, language, optional app restrictions and an optional link/URL.

---

## Phrase files and format

A phrase file is a plain `.ahk` text file. Every non-comment line is a definition:

```
:options:trigger::replacement ; cat=…|tags=…|comment=…|lang=…|aliases=…|disabled=0|…
```

- **`options`** — AutoHotkey hotstring options. Common ones: `*` (no ending key needed), `?` (triggers inside a word), `C` (case sensitive), `B0` (don't erase the trigger). Leave empty for defaults.
- **`trigger`** — the abbreviation (case-adaptive unless `C` is used).
- **`replacement`** — the phrase; line breaks are stored as `` `n ``.
- **Metadata** after ` ; ` (pipe-separated): `cat`, `tags`, `comment`, `lang`, `aliases`, `apps`, `url`, `lastupdated`, `priority`, `disabled` (`1` disables the phrase).
- Lines starting with `;` are comments. The top of a file may contain `; @expanto key: value` headers for per-file settings (see [Per-file settings](#per-file-settings)).

**Case adaptation** works automatically — `apx` → `appendix`, `Apx` → `Appendix`, `APX` → `APPENDIX`. Add the `C` option to disable it.

The file format is simple and git-friendly; you normally edit phrases through the GUI.

---

## The main window

### The toolbar

| Control | Function |
|---|---|
| 🔍 search box | substring search across trigger, phrase, category, comment, file, tags |
| **Fuzzy** checkbox | approximate, typo-tolerant ranked search |
| ≣ slider | how many lines of each phrase are shown per list row (1–20) |
| **＋ New phrase** | open an empty phrase in the editor panel |
| phrase counter | number of phrases currently visible |
| 🕐 **Recent** | toggle "recently used" mode |
| **≡** | toggle compact (dense) row layout |
| **◀** | hide/show the sidebar |
| **⚙ Settings** | open the settings panel |
| **📄 File settings** | open per-file settings for the selected file |
| **🔒 Locked** | shown while encrypted files are locked — click to unlock |

### Sidebar and navigation panels

The sidebar holds four **navigation panels** — **Files**, **Categories**, **Tags**, **Languages** — that filter the phrase list. Which panels are shown, and in what order, is configured in **Settings → General**.

#### Layout modes

| Mode | Description |
|---|---|
| **Tabs** | one panel at a time; switch with the tab buttons at the top |
| **Stacked** | all panels stacked vertically; drag dividers to resize |
| **Side by side** | all panels horizontally; drag dividers |
| **Grid (2 col)** | all panels in a two-column grid |

In **Stacked** mode each section header can be clicked to collapse/expand. Divider sizes persist between sessions.

#### The Files panel

Each file row shows the file name, phrase count and three badges:

| Badge | Meaning |
|---|---|
| **H** | hotstrings from this file are active |
| **T** | the file feeds the **trigger hint** popup |
| **P** | the file feeds the **phrase hint** popup |

Click a badge to toggle it for that file. The **H / T / P** badges on the "all files" row at the top toggle the setting for **all visible (non-hidden) files** at once.

Click a file row (not a badge) to **filter** the phrase list to that file only. **Ctrl-click** adds another file to the selection — the list then shows phrases from all selected files. Multi-file selection also applies to context menus.

### The phrase list

Each row shows the row number, trigger, phrase text and any metadata columns (category, tags, etc.). Click a row to open the phrase in the editor panel; double-click to insert it directly.

- **Columns** can be reordered by dragging their headers, resized with the drag handles, filtered per column, and shown/hidden via the header right-click menu.
- **Grouping:** right-click a column header to group the list by that column. Grouped rows collapse under clickable group headers; a ▤ badge in the column header marks the active grouping. Single-phrase groups render as ordinary rows.
- The ≣ **slider** in the toolbar sets how many lines of each phrase are visible per row — handy for long phrases.

### The editor panel

Holds fields for trigger, phrase text, options, category, tags, comment, language, aliases, apps and URL/link. A **preview box** shows the phrase after dynamic expansion. **Save** writes the change to the file; **Save & insert** also inserts the phrase into the previously active window.

If a phrase carries a link, a small dialog appears right after the phrase is inserted, offering to open the link — web addresses in the browser, file paths directly or in Explorer.

---

## Context menus

Right-clicking in the sidebar or phrase list opens a context menu. The menu is **edge-aware**: it measures its own dimensions after rendering and always stays inside the window.

### File menu

| Section | Options |
|---|---|
| **Preset settings** (submenu) | Spell check · Abbreviations · Long phrases — applies a preset combination of H/T/P |
| **Detailed settings** (submenu) | Toggle **H**, **T**, **P** individually |
| — | **File settings** — open per-file settings |
| — | **Open in editor** — open in an external editor (`.ahk` only) |
| — | **Backups** — view/restore file backups |
| — | **Encrypt (.ahk → .enc)** — encrypt the file in place |
| — | **Decrypt (.enc → .ahk)** — decrypt the file in place |
| — | **Hide file / Show file** |

**Multi-file selection:** with two or more files selected, **Preset settings** and **Detailed settings** apply to all of them at once.

### Folder menu

Right-click a folder header: open the folder in Explorer, hide/show the folder, create a new file, apply a preset to every file in the folder.

### Phrase menu

Right-click a phrase row: select all visible phrases, or enter/leave multi-select mode (checkboxes). In multi-select mode you get bulk delete, bulk move, bulk copy and bulk tagging.

---

## Keyboard shortcuts

All shortcuts are configured in **Settings → Shortcuts** (leave empty to disable). Modifier syntax: `+` Shift · `^` Ctrl · `!` Alt · `#` Win · `<^>!` AltGr · `CapsLock & x`. Click **🎹 Capture key** and press your combination to record it.

### Global shortcuts

| Shortcut | Function |
|---|---|
| **Open GUI** (default: `+Space`) | show/hide the Expanto window |
| **New phrase from previous word** | select the previous word in the source app and open Expanto to add it as a phrase. Press repeatedly to extend the selection one word at a time |
| **Step next** | insert the next segment during step-by-step insertion |
| **Undo** (default: `#z`) | undo the latest expansion |
| **Open last triggered** | jump to the most recently triggered phrase in Expanto |
| **Insert selected** | insert the phrase selected in Expanto directly into the source app |
| **Insert stepwise** | insert the selected phrase in step-by-step mode |

### In-window shortcuts

Active only while the Expanto window is in the foreground.

| Shortcut | Function |
|---|---|
| **New** | new phrase |
| **Update** | save changes |
| **Delete** | delete phrase |
| **Filter file** | filter by the selected phrase's file |
| **Filter category** | filter by the selected category |
| **Filter tag** | filter by the selected tag |
| **Assign category** | assign a category to the selected phrase(s) |
| **Assign tag** | assign a tag |
| **Switch field** | cycle focus between editor fields |
| **AI suggest** | run AI suggestions for the focused phrase |
| **Layout** | cycle the sidebar layout |
| **Always on top** | toggle always-on-top |
| **Move file** | move phrase(s) to another file |
| **Settings** | open the settings panel |
| **Edit file** | open the phrase file in an external editor |
| **Last edited** | jump to the most recently edited phrase |
| **Duplicates** | show semantic duplicates (AI) |
| **Panel** | switch focus to the sidebar |

### Quick select

An optional **modifier + digit 1–9** selects/deselects that row in a filter or assignment list without using the mouse.

### New phrase from previous word

This shortcut (configured under Shortcuts, default `AltGr+Space`) works like this:

1. **First press** — sends `Ctrl+Shift+Left` to the active program to select the previous word, copies the selection and opens Expanto with the word pre-filled in the search box.
2. **Repeated presses** — return to the source program, extend the selection one more word to the left and update Expanto. Continue until the whole phrase you want to add is selected.
3. **Cancel** — press `Escape` in the Expanto window, or close the window.

### CapsLock capture

If **Handle CapsLock internally** is enabled (default), Expanto sets CapsLock to `AlwaysOff` so the key doesn't accidentally toggle capitals when used as a modifier. Turn this off if another script already manages CapsLock.

---

## Dynamic fields

Put placeholders in a phrase; they resolve when the phrase is inserted.

### Built-in fields

| Placeholder | Result |
|---|---|
| `{date}` / `{datum}` | today's date (YYYY-MM-DD) |
| `{time}` / `{tid}` | current time (HH:mm) |
| `{week}` / `{vecka}` / `{veckonummer}` | ISO week number |
| `{clipboard}` | current clipboard contents |
| `{cursor}` | caret position after insertion |
| `{run:command}` | runs the command after the insert — never typed (see below) |

Date, time and week fields take an optional offset and an optional
[FormatTime](https://www.autohotkey.com/docs/v2/lib/FormatTime.htm) format:

```
{datum:yyMMdd}      260826          {tid:HHmm}      2214
{datum+1}           tomorrow        {datum-1:yyMMdd} yesterday, short
{vecka}             35              {vecka+2}       two weeks ahead
```

Offsets are days for date, hours for time and weeks for week. The **{…}
button** next to the phrase field inserts any of these (and the other field
types) at the caret — and when the current file has **file-specific fields**,
they are listed at the top of the menu.

### Run fields

`{run:command}` starts a program when the phrase is inserted. The field itself is
stripped from the typed text, and the command runs **after** the insertion has
finished, so a program stealing focus cannot swallow the phrase text. A phrase
can be nothing but a run field — a trigger that only launches something:

```
{run:"C:\Tools\Encore\Encore.exe" "Rapportmall"}
```

…and typing that trigger plays the [Encore](https://github.com/ibst1/encore)
macro `Rapportmall`. `{date}`, `{time}` and `{clipboard}` are resolved inside
the command before it runs; other dynamic fields are not.

**Safety**: phrases can come from downloaded phrase packs, so a command is
never executed silently — the first time a given command line runs, Expanto
asks for confirmation (once per command per session). Cancelling a field
dialog also cancels the phrase's run fields. The command cannot contain a
`}` character.

### Free-text fields

`{fieldname}` prompts the user for a value. The field name is shown as the label in the dialog.

### Choice fields

```
{fieldname=[option1/option2/*option3]}
```

Shows a dropdown. `*` marks the default choice. The field name is optional:

```
{[yes/no]}            ; options only, no label
{Priority=[low/high]} ; with a label
```

Slash notation without brackets also works: `{low/high}`.

### Pre-filled custom fields

```
{fieldname=value}
```

Fills the field with a default value the user can override in the dialog — useful for standard answers that occasionally change.

### Fill modes

Choose in **Settings → Dynamic fields** (with per-app overrides):

| Mode | Behaviour |
|---|---|
| **auto** | a single plain field is filled inline with caret placement; multiple fields or choice fields open a dialog |
| **dialog** | always show the dialog |
| **inline** | the first field gets the caret, the rest are cleared |

**Insertion method** — `auto` / `paste` / `send`: whether text is pasted via the clipboard (fast, preserves the original clipboard) or typed character by character. `auto` picks based on text length (configurable threshold).

### Reactive cascade in the dialog

If a field's value depends on another field (via coupled fields — see below), dependent fields fill in automatically as soon as the key field changes, without clicking OK.

---

## Coupled fields

Coupled fields let phrases in the same file **share dynamic field values** through a common key field. A value is entered once and reused automatically every time the same key value appears. Everything lives in RAM only — values are never written to disk and reset when Expanto restarts.

### Configuration (per file)

Set in the per-file settings (the **📄 File settings** toolbar button):

| Setting | Description |
|---|---|
| **Group by** | comma-sep. name(s) of the key field(s), e.g. `customerid` or `customerid, orderid` |
| **Shared fields for \<key\>** | comma-sep. fields whose values are shared within the group, e.g. `name, issue` |

### How it works

1. A phrase triggers and contains `{issue}`.
2. Expanto checks whether `customerid` (the key field) is already known — from memory or from the window title.
3. If `issue` for that `customerid` value is in memory, it fills in automatically — no dialog.
4. Otherwise a dialog appears. The entered value is stored in memory, tied to the `customerid` value.
5. The next phrase using the same `customerid` value gets `issue` pre-filled automatically.

### Reactive dialog

If the key field and dependent fields appear in the same dialog, dependent fields fill in automatically as soon as the key field changes — before OK is clicked.

### The special `trigger` field

`trigger` is a built-in pseudo-field that automatically takes the value of the hotstring that fired the phrase (what you actually typed to trigger the expansion).

**Usage:** write `trigger` in **Group by**. Fields listed under **Shared fields for trigger** are copied straight from the trigger text — no dialog, no memory, the value is always known.

**Example:**

```
The phrase is triggered by the hotstring "case123".
Group by:                  trigger
Shared fields for trigger: caseid

→ {caseid} in the phrase fills automatically with "case123"
```

**Combined example** — the trigger provides an ID, the window title provides name and department:

```
Group by:                  trigger
Shared fields for trigger: caseid
Title fields:              name, department
Title pattern:             Customer: (.+?) / (.+)

→ {caseid} = the hotstring text, {name} and {department} = from the window title
   No manual input needed.
```

### Auto-fill from the window title

Complement coupled fields by extracting values from the active window's title with a regular expression:

| Setting | Description |
|---|---|
| **Title fields** | comma-sep. field names matching the capture groups in order |
| **Title pattern** | regex applied to the window title; each `(...)` fills one title field |

**Example:** the title is `Program - [ID 12345 Anna Berg]`
Title fields: `id, name`
Title pattern: `\[ID (\d+) (.+?)\]`
→ `id = 12345`, `name = Anna Berg`

Works with any program that shows relevant values in its window title (e.g. ticketing or CRM systems).

### Identity-switch warning

If an identity field (e.g. `customerid`) is read from the window title and its value changes within 5 minutes, a warning dialog appears before insertion — protection against accidentally inserting text belonging to one record into another.

---

## Step-by-step insertion

The **▶** button (and a global shortcut) inserts a phrase **one segment at a time**, pausing in between — useful when the target form has separate fields.

- Phrases split at blank lines, at labelled lines (`Label: …` — two or more are required, so ordinary prose never splits), or at `|`.
- **Settings → Dynamic fields → Step labels** optionally restricts which labels count; with a whitelist, a single matching label is enough.
- Dynamic fields are prompted per segment as it is inserted.
- Press the shortcut to paste the next segment; **Escape** cancels.

---

## Hint popup

While you type, an optional floating popup suggests matching phrases. Configure in **Settings → Popup**:

| Setting | Description |
|---|---|
| Enabled | popup on/off |
| Fuzzy matching | approximate search |
| Minimum characters | how many characters before suggestions appear |
| Timeout | seconds without a keypress before the popup closes |
| Insert key | key that inserts the highlighted suggestion |
| Up/Down keys | navigate the list |
| Digit key | modifier + digit for direct selection of rows 1–9 |

- **Left-click** a suggestion to insert it.
- **Right-click** opens the phrase in the Expanto window.
- Navigating with the Up/Down keys **pins** the popup — the inactivity timeout no longer closes it until you insert a suggestion, keep typing past a match, or press **Escape**.
- Choose which files feed the popup via the **T** and **P** badges in the Files panel:
  - **T** — trigger hint: matches what you type against known triggers
  - **P** — phrase hint: matches against words in the phrase texts

---

## Undo

### Undo the latest expansion

Right after insertion, a small undo popup appears (non-activating overlay). Click **Undo**, or press the **Undo** shortcut (default: `Win+Z`), to remove the inserted text and restore the trigger.

### Open the last triggered phrase

The **Open last triggered** shortcut jumps straight to the phrase that last expanded, so you can edit it quickly.

### Undo delete

Deleting takes a snapshot of the affected lines. Restore via right-click → **Restore deleted phrase** in the phrase list (works for encrypted files too).

### Collision warning

If you try to save a trigger that already exists you are warned and can cancel.

### Draft recovery

An unsaved phrase survives a reload — the draft is restored automatically the next time Expanto starts.

---

## AI features (optional)

Disabled by default. Enable in **Settings → AI** with an [Anthropic API key](https://console.anthropic.com) (billed separately). A local LLM backend can be used instead.

### Per phrase — ✨ Suggest

Suggests category, tags, file, comment and language for the focused phrase. Apply or adjust manually.

### Auto-fill for new phrases

The new-phrase panel has an **✨ Fill in metadata with AI** checkbox (on by default when AI is enabled). While you type the trigger and phrase, a suggestion is requested in the background and fills category, tags, comment and language **as you write** — but never overwrites anything you typed yourself. If you save before the suggestion arrives, the fields are completed right after saving instead. Encrypted files are never sent to the AI, and the checkbox is disabled for them.

### Maintenance (🛠)

Batch operations for the whole phrase library:

- **Batch tagging** — AI suggests tags for all visible phrases.
- **Semantic duplicate detection** — finds phrases with similar meaning and offers merging.
- **Move phrases** — AI suggests the right file for each phrase.
- A backup is taken automatically before any batch change.

### Semantic search

Search by meaning rather than substrings — find phrases about a topic even when they don't contain the exact word you searched for.

### Limits and cost control

- Token usage and estimated cost are shown and can be reset.
- Rate limiting: Expanto honours `retry-after` headers and throttles batch runs automatically.
- Encrypted `.enc` files are never sent to the API.
- Individual files and folders can be excluded manually in the settings.

---

## Spell checking and word lists

Phrase text is spell-checked live in the editor panel. Triggers that match real words are flagged with a warning (they may fire accidentally).

- New words can be added to your personal word list straight from the editor panel.
- Every `*.txt` file in an enabled word-list folder is loaded; manage folders in **Settings → Spell check**.
- **Compound words** — when enabled, selected word lists are combined to validate compound spellings (configurable minimum length, default 12 characters).

Word lists are not bundled with Expanto; download them from [ibst1/wordlists](https://github.com/ibst1/wordlists).

---

## Per-file settings

Every phrase file can have an optional header section with settings in the form `; @expanto key: value`. Edit via the GUI (**📄 File settings**) or directly in the file.

| Key | Description |
|---|---|
| `label` | display name for the file in Expanto |
| `defaultCat` | default category for new phrases created in the file |
| `metaFields` | comma-sep. metadata fields shown/prompted when adding a phrase (e.g. `customer, issue`) |
| `groupField` | comma-sep. key fields for coupled fields |
| `sharedFields` | `key=field1,field2;key2=field3` — coupled fields per key |
| `titleFields` | comma-sep. field names for window-title capture groups |
| `titlePattern` | regex applied to the window title |
| `hidden` | `1` hides the file in the sidebar (still loaded) |

**Example file header:**

```ahk
; @expanto label: Support replies
; @expanto defaultCat: Customer cases
; @expanto groupField: customerid
; @expanto sharedFields: customerid=name,issue
; @expanto titleFields: customerid, customername
; @expanto titlePattern: Customer: (\d+) - (.+)
```

---

## App restriction

A phrase can be limited to (**whitelist**) or blocked from (**blacklist**) specific programs, matched on process name or window title.

- Set in the editor panel's **Apps** field.
- Process names: `word`, `chrome`, `notepad`.
- Title prefix: `title:Case #` matches any window whose title contains "Case #".
- Comma-separate multiple app rules.

---

## Encryption

`.enc` files in phrase folders are **AES-256-GCM** encrypted phrase files with PBKDF2-SHA256 (600 000 iterations) for key derivation.

- A shared password is asked for **once per session** and never written to disk.
- The **🔒** lock icon in the toolbar appears while encrypted files exist but are locked — click it to enter the password. A **Show password** button is available.
- **Encrypt:** right-click an `.ahk` file → **Encrypt (.ahk → .enc)**. The plaintext file is deleted after successful verification.
- **Decrypt:** right-click an `.enc` file → **Decrypt (.enc → .ahk)**.
- Encrypted files are always excluded from AI features and cannot be opened in an external editor.
- Manage the session password and import Excel files via **Settings → Encrypted phrases**.

---

## File watching

Expanto watches active phrase files and folders in the background. If a file changes externally (another editor, version control, or a colleague via a shared drive), phrases reload automatically. A discreet notice appears in the title bar.

- New files added to an enabled phrase folder are picked up automatically.
- Changes Expanto itself just saved are ignored (avoids needless reloads).

---

## Backups

Expanto automatically keeps up to **3 rolling backups** (`.bak1`, `.bak2`, `.bak3`) of every phrase file, with timestamps.

Restore via **right-click a file → Backups** → pick a slot → **Restore**. Works for encrypted `.enc` files too.

---

## Statistics

**📊** opens a usage report:

- Most and least used phrases.
- Breakdown per category and tag.
- "Dead" phrases (never used).
- Usage is tracked locally and can be reset.

---

## Settings and data location

Settings are stored **per machine** in `%APPDATA%\Expanto\settings.ini`, created automatically on first start. Because it lives under `%APPDATA%`, it does not travel with the app folder if you sync that between machines.

Settings categories:

| Category | Contents |
|---|---|
| **General** | theme, language, sidebar layout, navigation panels, font size, external editor, start minimized, start with Windows (Startup-folder shortcut), link to this documentation |
| **Phrase folders** | add/remove/enable/disable phrase folders (each row shows the folder's path and can open it in Explorer), download phrase packs |
| **Shortcuts** | all global and in-window shortcuts |
| **Popup** | hint-popup settings |
| **Dynamic fields** | default mode, step labels, per-app overrides, insertion method |
| **AI** | API key, excluded files/folders, cost display |
| **Maintenance** | semantic duplicate detection and merging |
| **Spell check** | word-list folders, compound-word checking |
| **Encrypted phrases** | session password, Excel import |

UI appearance settings (theme, language, font size, layout, list preferences) are stored in the WebView2 profile's `localStorage` and take effect immediately without a restart.

---

## Privacy and security

- Sensitive data (API key, folder paths, drafts) stays in `%APPDATA%`, outside synced folders.
- Only phrase text — never `.enc` content — is sent to the AI API.
- Encrypted files are excluded from AI automatically; other files can be excluded individually.
- The WebView2 renderer process is monitored: if it crashes, Expanto reinitializes itself within seconds without losing hotstrings.

---

## Optional content packs

### Phrase packs (optional download)

Ready-made phrase packs live in [ibst1/ahk-phrases](https://github.com/ibst1/ahk-phrases): autocorrection for English and Swedish (Wikipedia-derived, CC BY-SA 4.0), e-mail building blocks, date expressions, code snippets, special characters and generic clinical-note example templates.

Expanto offers these at **first run** and under **Settings → Phrase folders → Download phrase packs** — selected packs are downloaded and registered as phrase folders automatically. The target folder defaults to `%APPDATA%\Expanto\packs\` and can be changed with the folder picker next to the pack list. You can also clone the repo and add any folder manually.

### Word lists — `lib\words\` (optional download)

Word lists are **not** bundled. Download the ones you need from [ibst1/wordlists](https://github.com/ibst1/wordlists) and place them in `lib\words\`. See that repo's `SOURCES.md` for the full list of available dictionaries, sources and licenses.

---

## File structure

```
Expanto.ahk                  main script (WebView2 edition)
ComVar.ahk                   COM variant helper (required by WebView2.ahk)
Promise.ahk                  promise helper (required by WebView2.ahk)
reposettings.ini             first-run word-list bundle definitions (ships with the repo)
build.ps1                    builds the portable release zip into dist\
ui\
  index.html                 single-page app shell
  app.js                     all UI logic
  style.css                  all styles
lib\
  WebView2.ahk               WebView2 AHK wrapper
  WebView2Loader.dll         WebView2 loader (x64)
  JSON.ahk                   JSON encode/decode
  fuzzysearch.ahk            fuzzy search
  ai_wv2.ahk                 AI/LLM module
  local_llm.ahk              local LLM support
  enc_phrases.ahk            AES-256-GCM encryption module
  words\                     spell-check word lists (optional download, git-ignored)
  words_private\             your own word lists (git-ignored)
%APPDATA%\Expanto\
  settings.ini               your settings (auto-generated, per machine, not synced)
```

Third-party components keep their own licenses (WebView2.ahk, Promise.ahk and ComVar.ahk by thqby; WebView2Loader.dll by Microsoft).
