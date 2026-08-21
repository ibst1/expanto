'use strict';

// ── i18n ──────────────────────────────────────────────────────────────────────
const LANG = {
  sv: {
    'search.ph': 'Sök trigger, fras, kategori…',
    'fuzzy': 'Fuzzy',
    'btn.new': '＋ Ny fras',
    'count': (n, t) => t != null ? `${n} / ${t} fraser` : `${n} fraser`,
    'btn.settings': '⚙ Inställningar',
    'btn.fileSettings': '📄 Filinst.',
    'btn.recent': '🕐 Senast',
    'lang.toggle': 'EN',
    'tab.files': 'Filer', 'tab.cats': 'Kateg.', 'tab.tags': 'Taggar', 'tab.lang': 'Språk',
    'chkShowHidden': 'Visa dolda',
    'allFilter': '— Alla —',
    'group.ungrouped': 'Övrigt',
    'group.by': n => `Gruppera efter ${n}`, 'group.off': 'Avgruppera',
    'group.ind': 'Grupperad på denna kolumn – högerklicka för att ändra',
    // — Toolbar tooltips & common —
    'tt.clearSearch': 'Rensa sök',
    'tt.compact': 'Kompakt läge',
    'tt.toggleSidebar': 'Dölj sidopanel',
    'tt.fileSettings': 'Filinställningar för vald fil',
    'tt.dragResize': 'Dra för att ändra bredd',
    'tt.swap': 'Byt plats på trigger ↔ fras',
    'tt.deselectAll': 'Avmarkera alla',
    'tt.add': 'Lägg till',
    'nav.settingsTip': 'Inställningar',
    'btn.saveReload': 'Spara & ladda om',
    'help.title': 'Hjälp',
    // — Frasmappar —
    'fr.more': 'Fler ordlistor från wordlists-repot',
    'fr.packs': 'Fraspaket att börja med (valfritt)',
    'packs.title': 'Ladda ner fraspaket',
    'packs.desc': 'Färdiga fraspaket från ahk-phrases-repot. Valda paket laddas ner och läggs automatiskt till som frasmappar.',
    'packs.none': 'Inga fraspaket hittades.',
    'packs.files': n => `${n} fil${n === 1 ? '' : 'er'}`,
    'packs.downloading': 'Laddar ner…',
    'packs.done': 'Klart — paketen har laddats ner och lagts till som frasmappar.',
    'packs.someFailed': n => `Klart, men ${n} fil(er) kunde inte laddas ner.`,
    'wl.fetching': 'Hämtar lista från GitHub…',
    'wl.none': 'Inga ordlistor hittades.',
    'wl.fetchErr': m => `Kunde inte hämta lista: ${m}`,
    'folders.desc': 'Alla .ahk- och .enc-filer i de valda mapparna laddas som frasfiler.',
    'folders.add': '＋ Lägg till mapp',
    'folders.delTip': 'Ta bort mapp',
    // — Kortkommandon —
    'hk.format': 'Tangentformat: <code>+</code> Shift &nbsp;·&nbsp; <code>^</code> Ctrl &nbsp;·&nbsp; <code>!</code> Alt &nbsp;·&nbsp; <code>#</code> Win &nbsp;·&nbsp; <code>&lt;^&gt;!</code> AltGr &nbsp;·&nbsp; CapsLock_',
    'hk.capture': '🎹 Fånga tangent',
    'hk.captureHint': 'Fokusera ett fält nedan, klicka knappen, tryck kombinationen',
    'hk.capsCap': 'Läs CapsLock själv när en hotkey använder den (stäng av om ett annat skript redan hanterar CapsLock)',
    'hk.emptyTip': '💡 Tomt fält = standardtangenten används. Skriv <b>av</b> i ett fält för att stänga av kommandot helt.',
    'hk.secGlobal': 'Globala kortkommandon',
    'hk.openGui': 'Öppna GUI:',
    'hk.markWord': 'Ny fras från föregående ord:',
    'hk.stepNext': 'Stegvis infogning av vald fras (starta + nästa stycke):',
    'hk.undo': 'Ångra senaste expansion:',
    'hk.lastFired': 'Öppna senaste avfyrade fras:',
    'hk.secGui': 'GUI-kortkommandon <span style="font-weight:400;text-transform:none">(aktiva när huvudfönstret är aktivt; tomt = av)</span>',
    'hk.new': 'Ny fras:',
    'hk.update': 'Uppdatera:',
    'hk.delete': 'Radera:',
    'hk.filtFile': 'Filter fil:',
    'hk.filtCat': 'Filter kat:',
    'hk.filtTag': 'Filter tagg:',
    'hk.assignCat': 'Tilldela kat:',
    'hk.assignTag': 'Tilldela tagg:',
    'hk.switchField': 'Växla fält:',
    'hk.aiSuggest': 'AI-förslag:',
    'hk.layout': 'Växla layout:',
    'hk.onTop': 'Always-on-top:',
    'hk.moveFile': 'Flytta till fil:',
    'hk.moveFileShort': 'Flytta fil:',
    'hk.settings': 'Inställningar:',
    'hk.editFile': 'Redigera fil:',
    'hk.lastEdited': 'Senast redigerad:',
    'hk.dupes': 'Dubbletter:',
    'hk.panel': 'Växla panel:',
    'hk.secInsert': 'Globala infogningskommandon',
    'hk.insert': 'Infoga vald fras:',
    'hk.insertStep': 'Infoga/Nästa stycke:',
    'hk.secQuick': 'Snabbval — prefix + siffra väljer rad 1–10; +Shift = 11–20',
    'hk.secFieldNav': 'Fältnavigation — Alt+bokstav hoppar till fält (edit- och bulk-panel)',
    'hk.fTrigger': 'Trigger:',
    'hk.fPhrase': 'Fras:',
    'hk.fCat': 'Kategori:',
    'hk.fTags': 'Taggar:',
    'hk.fApps': 'Appar:',
    'hk.fLang': 'Språk:',
    'hk.fComment': 'Kommentar:',
    'hk.bFile': 'Flytta (bulk):',
    // — Popup —
    'pop.secHint': 'Hint-popup medan du skriver',
    'pop.enable': 'Aktivera hint-popup',
    'pop.fuzzy': 'Fuzzy-matchning i popupen',
    'pop.chars': 'Antal tecken innan popup:',
    'pop.timeout': 'Popup stängs efter (sek, 0 = av):',
    'pop.secKeys': 'Popup-tangenter <span style="font-weight:400;text-transform:none">(+ Shift · ^ Ctrl · ! Alt)</span>',
    'pop.insert': 'Infoga förslag:',
    'pop.up': 'Bläddra upp:',
    'pop.down': 'Bläddra ner:',
    'pop.numKey': 'Val med siffertangent:',
    'pop.numKey.off': 'Av (standard)',
    'pop.numKey.ctrl': 'Ctrl+siffra (1–9)',
    'pop.numKey.alt': 'Alt+siffra (1–9)',
    'pop.numKey.shift': 'Shift+siffra (1–9)',
    'pop.tip': 'Tips: vänsterklick i popupen infogar förslaget; högerklick öppnar frasen i huvud-GUIt.',
    // — Dynamiska fält —
    'dyn.tokens': '<strong>Platshållare i frastexter</strong> — token fylls i automatiskt. {egna namn} efterfrågas vid infogning:<br><code>{date}</code> &nbsp;dagens datum (ÅÅÅÅ-MM-DD)<br><code>{time}</code> &nbsp;klockslag (HH:MM)<br><code>{clipboard}</code> &nbsp;innehållet i urklipp<br><code>{cursor}</code> &nbsp;här hamnar markören efter infogning<br><code>{valfritt namn}</code> &nbsp;ett fält som efterfrågas, t.ex. {namn}, {ärende}<br><code>{kön=han/hon}</code> &nbsp;dropdown med fasta alternativ (hakparenteser <code>{kön=[han/hon]}</code> går också bra); <code>*</code> markerar förvalt val, t.ex. {kön=*han/hon}',
    'dyn.defaultMode': 'Standardläge',
    'dyn.mode.auto': 'Auto — 1 fält → inline, flera → dialog',
    'dyn.mode.inline': 'Alltid inline',
    'dyn.mode.dialog': 'Alltid dialog',
    'dyn.mode.off': 'Av — fyll inte i fält automatiskt',
    'dyn.appMode': 'App-specifikt läge <span style="font-weight:400;text-transform:none">(klicka på en rad för att växla; Standard = använd standardläget)</span>',
    'dyn.appProcess': 'App-process',
    'dyn.appModeCol': 'Läge',
    'dyn.addApp': '＋ Lägg till app',
    'dynApp.appPh': 'process eller title:del',
    'dyn.stepLabels': 'Stegvis infogning — fältetiketter <span style="font-weight:400;text-transform:none">(vitlista, avgränsa med |)</span>',
    'dyn.stepLabels.desc': 'Frasen delas vid dessa etiketter; varje fält infogas separat och endast värdet klistras in (etiketten visas i panelen som guide).',
    'dyn.pasteMode': 'Infogningsmetod',
    'dyn.paste.auto': 'Auto — urklipp för långa texter, tangenter för korta',
    'dyn.paste.always': 'Alltid urklipp (snabbt)',
    'dyn.paste.never': 'Alltid tangenter (långsamt)',
    'dyn.pasteMinLen': 'Urklippsgräns (tecken)',
    'dyn.pasteMinLen.desc': 'Texter kortare än detta skickas tecken för tecken; längre klistras in via urklipp.',
    // — AI-sidan —
    'ai.enable': 'Aktivera AI-funktioner',
    'ai.apiKey': 'API-nyckel',
    'ai.model': 'Modell',
    'ai.model.sonnet': 'Sonnet 4.6 (rekommenderad)',
    'ai.model.haiku': 'Haiku 4.5 (snabb)',
    'ai.model.opus': 'Opus 4.8 (kraftfull)',
    'ai.autoTag': 'Auto-tagga nya fraser',
    'ai.exclude': 'Exkludera (ett mönster per rad)',
    'ai.exclude.ph': 't.ex. känslig_mapp',
    'ai.resetUsage': 'Nollställ statistik',
    'aidrop.single': 'AI för denna fras',
    'aidrop.bulk': 'AI för markerade fraser',
    'aidrop.batch': 'AI-tagga alla synliga',
    // — Stavningskontroll —
    'spell.enable': 'Aktivera inbyggd stavningskontroll i fras- och kommentarfälten',
    'spell.secDownload': 'Ladda ner ordlistor',
    'spell.dlDesc': 'Hämta valfria ordlistor från GitHub-repot <code>ibst1/wordlists</code>. Välj en målmapp — den läggs sedan automatiskt till som ordlistemapp i Expanto.',
    'spell.noFolder': '(ingen mapp vald)',
    'spell.chooseFolder': 'Välj mapp…',
    'spell.dlSelected': '↓ Ladda ner valda',
    'spell.refreshIndex': '↺ Uppdatera lista',
    'spell.dlProgress': (d, t, f) => `Laddar ner ${d}/${t}: ${f}…`,
    'spell.secFolders': 'Ordlistemappar',
    'spell.foldersDesc': 'Lägg till mappar med egna ordlistor (UTF-8, ett ord per rad). Alla .txt-filer i varje mapp laddas och läggs ovanpå webbläsarens inbyggda stavningskontroll. Används för facktermer och domänspecifika ord.',
    'spell.secCompound': 'Svenska sammansättningar',
    'spell.compound': 'Godkänn svenska sammansättningar i stavningskollen',
    'spell.compoundDesc': 'Långa okända ord som går att dela i kända ordlisteord (ev. med foge-s) flaggas inte som stavfel.',
    'spell.compoundMinLen': 'Minsta ordlängd att försöka dela',
    // — Krypterade fraser —
    'enc.import': 'Importera från Excel…',
    // — Filinställningspanelen —
    'fs.file': 'Fil',
    'fs.rename': 'Filnamn <span style="font-weight:400;text-transform:none">(byter namn på själva filen)</span>',
    'fs.renameBtn': 'Byt namn',
    'fs.label': 'Visningsnamn <span style="font-weight:400;text-transform:none">(valfritt)</span>',
    'fs.label.ph': 't.ex. Supportsvar',
    'fs.defaultCat': 'Standardkategori för nya fraser',
    'fs.defaultCat.ph': 't.ex. Kundärenden',
    'fs.metaFields': 'Metadatafält vid ny fras <span style="font-weight:400;text-transform:none">(komma-sep.)</span>',
    'fs.metaFields.ph': 't.ex. kund, ärende, produkt',
    'fs.metaFields.hint': 'Dessa fält visas och efterfrågas när en ny fras skapas i just den här filen.',
    'fs.preview': 'Förhandsgranskning',
    'fs.sharedTitle': 'Delade fält mellan relaterade fraser',
    'fs.sharedHint': 'Fraser med samma värde på ett grupperingsfält kan dela dynamiska fältvärden — fyll i en gång, återanvänds. Värdena hålls bara i minnet, aldrig på disk.',
    'fs.groupField': 'Gruppera på <span style="font-weight:400;text-transform:none">(komma-sep. fält)</span>',
    'fs.groupField.ph': 't.ex. kundnr, ordernr  ·  tänkare, epok  ·  parti, val',
    'fs.groupField.hint': 'Fraser med samma värde här grupperas i listan. För varje fält visas en rad nedan där du anger vilka fält som ska delas inom den gruppen.',
    'fs.titleTitle': 'Autofyll fält från fönstertiteln',
    'fs.titleHint': 'Valfritt. Fyller fält automatiskt från det aktiva fönstrets titel (t.ex. ett ID som redan visas i ett annat program). Håll muspekaren över ⓘ för exempel.',
    'fs.titleFields': 'Titelfält <span style="font-weight:400;text-transform:none">(fältnamn för capture-grupperna, i ordning)</span>',
    'fs.titlePattern': 'Titelmönster <span style="font-weight:400;text-transform:none">(regex mot fönstertiteln)</span>',
    'fs.helpTip': 'Visa hjälp',
    // — Hjälpmodaler —
    'help.sharedFields.html': '<p>Fraser i samma fil kan dela dynamiska fältvärden, kopplade till ett gemensamt <b>nyckelfält</b>. Värdet fylls i en gång och återanvänds automatiskt varje gång samma nyckelvärde dyker upp — tills Expanto startas om. Värdena sparas <b>aldrig</b> till disk.</p><h4>Konfiguration</h4><ul><li><b>Gruppera på</b> = fältet som fungerar som minnesnyckel.</li><li><b>Delade fält för &lt;nyckel&gt;</b> = komma-separerade fält vars värden delas inom gruppen.</li></ul><h4>Exempel 1 — kundärenden</h4><pre>Gruppera på:              kundnr\nDelade fält för kundnr:   namn, ärende</pre><p>Första gången du infogar en fras för kundnr ”10042” får du fylla i namn och ärende. Nästa fras med samma kundnr fylls de i automatiskt.</p><h4>Specialfältet ”trigger”</h4><p>Skriv <code>trigger</code> i <b>Gruppera på</b>. Det är ett inbyggt pseudofält som automatiskt får värdet av den hotstring (trigger) som utlöste frasen. Fält i ”Delade fält för trigger” kopieras direkt från triggertexten utan någon fråga.</p><h4>Exempel 2 — trigger som nyckel</h4><pre>Gruppera på:               trigger\nDelade fält för trigger:   SID</pre><p>Frasen triggas av hotstringen ”sid123” och innehåller <code>{SID}</code> → <code>{SID}</code> fylls automatiskt med ”sid123”.</p><p class="help-warn">⚠ Fältnamnet är <b>skiftlägeskänsligt</b>: <code>{SID}</code> i frastexten måste skrivas exakt likadant som namnet i ”Delade fält för trigger” (t.ex. båda <code>SID</code> eller båda <code>sid</code>). Annars frågas du efter värdet i stället för att det fylls i automatiskt.</p><h4>Exempel 3 — kombinerat</h4><pre>Gruppera på:               trigger\nDelade fält för trigger:   sid\nTitelfält:                 namn, avdelning\nTitelmönster:              Kund: (.+?) / (.+)</pre><p>Trigger ger sid, fönstertiteln ger namn och avdelning — inga manuella inmatningar behövs.</p><h4>Minnesregler</h4><ul><li>Värdena lever bara i RAM och nollställs vid omstart av Expanto.</li><li>Byte av nyckelvärde (ny kund, ny trigger) rensar flyktig data (today-/clipboard-kopplade fält) men behåller promptade värden för det gamla nyckelvärdet.</li><li>Fält kopplade till ”trigger” sparas aldrig — de deriveras alltid om från hotstringen.</li></ul>',
    'help.titleAutofill.html': '<p>Plockar fältvärden ur det <b>aktiva fönstrets titel</b> med ett reguljärt uttryck (regex). Varje capture-grupp <code>( )</code> fyller fältet med samma namn, i ordning.</p><h4>Exempel</h4><pre>Fönstertitel:   Program - [ID 12345 Anna Berg]\nTitelfält:      id, namn\nTitelmönster:   \\[ID (\\d+) (.+?)\\]</pre><p>→ <code>id</code> = 12345, <code>namn</code> = Anna Berg.</p><p>Fungerar mot vilket program som helst som visar värden i fönstertiteln.</p>',
    'toast.propagated': 'Delade fält uppdaterades på relaterade fraser',
    'scope.file': '▼ Begränsad till vald fil',
    'scope.cat': '▼ Begränsad till vald kategori',
    'scope.fileCat': '▼ Begränsad till vald fil/kategori',
    'nav.back': '← Tillbaka',
    'nav.general': 'Allmänt', 'nav.folders': 'Frasmappar', 'nav.hotkeys': 'Kortkommandon',
    'nav.popup': 'Popup', 'nav.dynamic': 'Dynamiska fält', 'nav.ai': 'AI (Claude)',
    'nav.aimaint': 'AI-underhåll', 'nav.spell': 'Stavningskontroll', 'nav.enc': 'Krypterade fraser',
    'col.nr': '#', 'col.trigger': 'Trigger', 'col.phrase': 'Fras',
    'col.cat': 'Kategori', 'col.tags': 'Taggar', 'col.lang': 'Språk', 'col.file': 'Fil',
    'field.trim': 'Trimma (ta bort inledande/avslutande blanksteg vid sparande)',
    'list.loading': 'Laddar fraser…', 'list.noMatch': 'Inga fraser matchar.',
    'list.recentUsed': 'Inga nyligen använda fraser.',
    'list.recentEdited': 'Inga nyligen redigerade fraser.',
    'detail.title': 'Detaljer', 'detail.new': 'Ny fras',
    'detail.moveTo': 'Flytta fras', 'detail.dupTo': 'Duplicera till',
    'field.file': 'Fil',
    'newfile.showHidden': n => '⋯ Visa dolda filer (' + n + ')',
    'newfile.hideHidden': '⋯ Dölj dolda filer',
    'newfile.hiddenTag': 'dold',
    'newfile.noFolder': '(utan mapp)',
    'newfile.empty': 'Inga filer',
    'newfile.aiAuto': '✨ Fyll i metadata med AI',
    'newfile.aiAuto.tip': 'Tomma fält (kategori, taggar, kommentar, språk) fylls i automatiskt av AI:n efter att frasen sparats.',
    'newfile.aiAuto.enc': 'Krypterade filer skickas aldrig till AI:t.',
    'toolbar.previewLines': 'Textrader per fras i listan',
    'field.trigger.html': '<span data-ak-text>Trigger</span> / Alias <span style="font-weight:400;text-transform:none">(komma-sep.; första = trigger, övriga = alias)</span>',
    'field.apps.html': '<span data-ak-text>Appar</span> <span style="font-weight:400;text-transform:none">(komma-sep; process utan .exe eller title:del­av­titel; tomt = alla)</span>',
    'field.phrase': 'Fras', 'field.cat': 'Kategori',
    'alt.add.tip': 'Lägg till en alternativ frastext (välj vilken vid infogning)',
    'alt.remove.tip': 'Ta bort denna alternativtext',
    'alt.ph': 'Alternativ frastext…',
    'alt.name.ph': 'Namn (valfritt), t.ex. Brev',
    'alt.name.main.ph': 'Namn på huvudfrasen (valfritt), t.ex. Formell',
    'field.tags.html': '<span data-ak-text>Taggar</span> <span style="font-weight:400;text-transform:none">(komma-sep.)</span>',
    'field.lang': 'Språk', 'field.comment': 'Kommentar', 'field.flags': 'Flaggor',
    'field.url': '🔗 Länk (fil eller webbadress)',
    'btn.urlBrowse.tip': 'Bläddra efter en fil att länka',
    'btn.urlOpen.tip': 'Öppna länken/filen',
    'urlIcon.tip': 'Den här frasen har en länk',
    'alert.noUrl': 'Ingen länk angiven.',
    'field.status': 'Status', 'field.info': 'Info',
    'flag.star': '* omedelbar', 'flag.q': '? inuti ord', 'flag.o': 'O behåll slut', 'flag.c': 'C skiftläge',
    'flag.star.title': 'Trigger direkt utan avslutningstecken',
    'flag.q.title': 'Trigga inuti ord (ingen ordgräns)',
    'flag.o.title': 'Sluttecknet skrivs med i texten',
    'flag.c.title': 'Skiftlägeskänslig trigger',
    'disabled': 'Inaktiverad',
    'btn.save': 'Spara & infoga', 'btn.saveOnly': 'Spara', 'btn.saveDrop': '▾',
    'btn.insert': 'Infoga', 'btn.close': 'Stäng',
    'gen.autosave': 'Autospara ändringar i fraser (då döljs Spara-knappen)',
    'btn.save.tip': 'Spara/uppdatera och infoga (Ctrl+Enter)', 'btn.saveOnly.tip': 'Spara/uppdatera (Alt+Enter)',
    'btn.ai': '✨ AI', 'btn.aiDrop': '▾',
    'btn.duplicate': 'Duplicera', 'btn.duplicateMore': '▾',
    'btn.cancel': 'Avbryt', 'btn.delete': 'Ta bort',
    'btn.noOtherFiles': 'Inga andra filer tillgängliga',
    'alert.triggerPhraseRequired': 'Trigger och fras krävs.',
    'confirm.deletePhrase': t => `Ta bort "${t}"?`,
    'confirm.bulkDelete': n => `Ta bort ${n} fraser? Åtgärden kan inte ångras.`,
    'toast.deleted': t => `"${t}" borttagen`, 'toast.undo': 'Ångra',
    'confirm.aiEnableFirst': 'Aktivera AI under Inställningar (⚙ i verktygsfältet).',
    'confirm.aiBatch': n => `AI-tagga ${n} synliga fraser? Det görs ett API-anrop per fras.`,
    'confirm.aiBulk': n => `AI-tagga ${n} markerade fraser?`,
    'bulk.title': n => `${n} fraser markerade`,
    'bulk.desc': 'Kryssa i fälten du vill ändra på alla markerade fraser.',
    'bulk.check.cat': 'Kategori', 'bulk.check.lang': 'Språk',
    'bulk.check.comment': 'Kommentar', 'bulk.check.file': 'Flytta till fil',
    'bulk.tags': 'Taggar', 'bulk.addTag': 'Lägg till tagg…',
    'bulk.save': 'Spara', 'bulk.ai': '✨ AI för markerade',
    'bulk.cancel': 'Avbryt', 'bulk.delete': 'Ta bort',
    'bulk.noField': 'Kryssa i minst ett fält att ändra, eller lägg till/ta bort taggar.',
    'tags.none': 'Inga taggar', 'tags.clearSelection': '✕ Rensa urval',
    'tags.chip.count': n => `${n} fraser`,
    'badge.hsActive': 'Hotstrings aktiva', 'badge.hsInactive': 'Hotstrings inaktiva',
    'badge.hintTActive': 'Trigger-popup aktiv', 'badge.hintTInactive': 'Trigger-popup inaktiv',
    'badge.hintPActive': 'Fras-popup aktiv', 'badge.hintPInactive': 'Fras-popup inaktiv',
    'badge.locked': 'låst',
    'ctx.selectAll': 'Välj alla synliga',
    'ctx.startCheckbox': 'Välj flera (kryssrutor)', 'ctx.exitCheckbox': 'Avsluta flerval',
    'ctx.duplicate': 'Duplicera',
    'ctx.dupToFile': 'Duplicera till annan fil',
    'ctx.moveToFile': 'Flytta till annan fil',
    'confirm.dupToFile': (n, f) => `Duplicera ${n} fras(er) till ${f}?`,
    'confirm.moveToFile': (n, f) => `Flytta ${n} fras(er) till ${f}?`,
    'toast.dupedToFile': (n, f) => `${n} fras(er) duplicerade till ${f}`,
    'toast.movedToFile': (n, f) => `${n} fras(er) flyttade till ${f}`,
    'toast.fileRenamed': 'Filen bytte namn',
    'ctx.fileSettings': 'Filinst. för denna fil…', 'ctx.openEditor': 'Öppna i redigerare',
    'ctx.newFile': 'Ny fil i denna mapp…',
    'ctx.enableHs': 'Aktivera hotstrings', 'ctx.disableHs': 'Avaktivera hotstrings',
    'ctx.enableHintT': 'Aktivera trigger-popup', 'ctx.disableHintT': 'Avaktivera trigger-popup',
    'ctx.enableHintP': 'Aktivera fras-popup', 'ctx.disableHintP': 'Avaktivera fras-popup',
    'ctx.hideFile': 'Dölj fil', 'ctx.showFile': 'Visa fil',
    'ctx.openFolder': 'Öppna mapp i Utforskaren',
    'ctx.hideFolder': 'Dölj mapp', 'ctx.showFolder': 'Visa mapp',
    'ctx.preset.spellcheck': 'Stavningskontroll', 'ctx.preset.abbrev': 'Förkortningar', 'ctx.preset.phrases': 'Långa fraser',
    'toast.preset': name => `"${name}" tillämpad`,
    'ctx.backups': 'Säkerhetskopior…',
    'ctx.encryptFile': 'Kryptera (.ahk → .enc)', 'ctx.decryptFile': 'Dekryptera (.enc → .ahk)',
    'ctx.presets': 'Standardinställningar', 'ctx.details': 'Detaljerade inställningar',
    'fr.title': 'Välkommen till Expanto!',
    'fr.wordlists': 'Välj ordlistor att aktivera',
    'fr.phraseFolder': 'Mapp för dina frasfiler',
    'fr.browse': 'Bläddra…',
    'fr.start': 'Kom igång!',
    'fr.skip': 'Hoppa över',
    'sp.spell.bundles': 'Inbyggda ordlistor (repo)',
    'sp.spell.bundles.desc': 'Dessa ordlistor medföljer Expanto. Välj vilka som ska vara aktiva i stavningskollen.',
    'btn.saveBundles': 'Spara',
    'backup.title': name => `Säkerhetskopior: ${name}`,
    'backup.none': 'Inga säkerhetskopior hittades.',
    'backup.slot': (n, t) => `Kopia ${n}  —  ${t}`,
    'backup.restore': 'Återställ',
    'toast.backupRestored': 'Säkerhetskopia återställd',
    'nf.title': 'Ny frasfil', 'nf.folder': 'Mapp',
    'nf.name.html': 'Filnamn <span style="font-weight:400;text-transform:none">(.ahk/.enc läggs till automatiskt)</span>',
    'nf.type': 'Typ', 'nf.type.ahk': '.ahk &nbsp;(klartext)', 'nf.type.enc': '.enc &nbsp;(krypterad)',
    'nf.create': 'Skapa', 'nf.cancel': 'Avbryt',
    'nf.err.name': 'Ange ett filnamn.', 'nf.err.folder': 'Välj en mapp.',
    'capture.focusFirst': 'Fokusera ett fält nedan först.',
    'capture.waiting': 'Tryck en tangentkombination…',
    'capture.btn.ready': '🎹 Fånga tangent', 'capture.btn.working': '⏳ Väntar…',
    'capture.captured': c => `Fångade: ${c}`,
    'capture.holdKey': k => `${k} hålls — tryck kombinationens andra tangent…`,
    'capture.aborted': 'Avbruten — håll tangenten och tryck en annan.',
    'enc.unlocked': 'Session olåst — .enc-filer laddade.',
    'enc.locked': n => `${n} krypterad${n>1?'e':''} fil${n>1?'er':''} är låst${n>1?'a':''}.`,
    'enc.none': 'Inga krypterade filer.',
    'enc.lockBtn': n => `${n} krypterad${n>1?'e':''} fil${n>1?'er':''} låst${n>1?'a':''} — klicka för att låsa upp`,
    'btn.unlock': 'Lås upp', 'btn.lockSession': 'Lås session',
    'customFields.title': 'Fil-specifika fält',
    'customFields.ph': 'Tomt = promptas vid infogning',
    'customFields.title.tip': f => `Tomt = efterfrågas vid infogning via {${f}}`,
    'customFields.applyMeta': '⇄ Applicera metadata',
    'customFields.applyMeta.title': 'Synka fältens värden med {fält=värde}-platshållare i frastexten',
    'fs.title': 'Filinställningar',
    'folders.empty': 'Inga mappar konfigurerade.',
    'folders.del.confirm': nm => `Ta bort mappen "${nm}" från Expanto? (Filerna berörs inte.)`,
    'dictFolders.empty': 'Inga ordlistemappar konfigurerade.',
    'dictFolders.del.confirm': nm => `Ta bort ordlistemappen "${nm}"? (Filerna berörs inte.)`,
    'onTop.on': 'Alltid överst: PÅ',
    'sp.general.title': 'Allmänt', 'sp.folders.title': 'Frasmappar',
    'sp.hotkeys.title': 'Kortkommandon', 'sp.popup.title': 'Popup-inställningar',
    'sp.dynamic.title': 'Dynamiska fält', 'sp.ai.title': 'AI (Claude)',
    'sp.aimaint.title': 'AI-underhåll', 'sp.spell.title': 'Stavningskontroll',
    'sp.enc.title': 'Krypterade fraser (.enc)',
    'trigDup': (v, f) => `⚠ "${v}" finns redan i ${f}`,
    'trigCollide': (v, t, f) => `⚠ "${v}" kolliderar med "${t}" i ${f} (prefixöverlapp)`,
    'trigDict': w => `ℹ "${w}" finns i ordlistan — triggern expanderar vanliga ord`,
    'dynApp.empty': 'Inga app-specifika lägen inställda.',
    'dynApp.mode.auto': 'Standard', 'dynApp.mode.inline': 'Inline',
    'dynApp.mode.dialog': 'Dialog', 'dynApp.mode.off': 'Av',
    'compound.saved': 'Sparat.',
    'ai.batch.progress': (d,t) => `✨ AI-taggar ${d}/${t}…`, 'ai.batch.idle': '✨ AI-tagga synliga fraser',
    'dtm.dup': 'Duplicera till', 'dtm.move': 'Flytta till',
    'recent.off': '🕐 Senast', 'recent.used': '🕐 Använda', 'recent.edited': '🕐 Redigerade',
    'recent.usedLabel': 'Senast använda', 'recent.editedLabel': 'Senast redigerade',
    'nav.maint': 'Underhåll', 'sp.maint.title': 'Underhåll',
    'maint.dupes.title': 'Dubblettdetektering',
    'maint.dupes.desc': 'Hitta fraser med samma trigger eller identiskt innehåll.',
    'maint.dupes.btn': '🔍 Kör dubblettdetektering',
    'maint.dupes.none': '✓ Inga dubbletter hittades.',
    'maint.dupes.triggers': n => `${n} dubbla trigger${n > 1 ? 's' : ''}`,
    'maint.dupes.phrases': n => `${n} identisk${n > 1 ? 'a' : ''} fras${n > 1 ? 'er' : ''}`,
    'maint.semdupes.title': 'Semantiska dubbletter (AI)',
    'maint.semdupes.desc': 'Använd AI för att hitta fraser med liknande betydelse.',
    'maint.semdupes.btn': '✨ Kör AI-analys',
    'maint.semdupes.noAi': 'Aktivera AI under Inställningar → AI (Claude).',
    'maint.stats.title': 'Statistik & döda fraser',
    'maint.stats.desc': 'Användningsstatistik baserad på lokalt sparade tider.',
    'maint.stats.btn': '📊 Visa statistik',
    'maint.stats.total': 'Totalt fraser', 'maint.stats.used': 'Använda fraser',
    'maint.stats.neverUsed': 'Aldrig använda',
    'maint.stats.dead30': 'Ej använda > 30 dagar', 'maint.stats.dead90': 'Ej använda > 90 dagar',
    'maint.stats.topFiles': 'Filer med flest fraser',
    'aiSearch.btn': '✨ AI-sök', 'aiSearch.searching': '⏳ Söker…', 'aiSearch.clear': '✨ Rensa AI-sök',
    'aiSearch.noQuery': 'Ange ett sökord i sökfältet först.', 'aiSearch.noAi': 'Aktivera AI under Inställningar (⚙).',
    'aiSearch.noMatch': 'Inga semantiska träffar.',
    'gen.theme': 'Tema', 'gen.theme.dark': 'Mörkt', 'gen.theme.light': 'Ljust', 'gen.theme.auto': 'Automatisk (system)',
    'gen.lang': 'Gränssnittsspråk',
    'gen.editor': 'Extern redigerare',
    'gen.editor.desc': 'Kommando som körs när du öppnar en fil via högerklick i fillistan. Använd {file} för sökvägen.',
    'gen.startMinimized': 'Starta minimerat till systemfältet',
    'gen.autostart': 'Starta med Windows',
    'gen.sidebar': 'Sidebar-layout',
    'gen.sidebar.tabs': 'Flikar',
    'gen.sidebar.stacked': 'Sammanslagen',
    'gen.sidebar.beside': 'Bredvid',
    'gen.sidebar.grid': 'Grid (2 kol)',
    'gen.navSections': 'Navigeringspaneler',
    'gen.fontsize': 'Textstorlek',
    'gen.fontsize.normal': '13px (standard)',
    'maint.ai.title': 'AI-funktioner',
    'maint.ai.desc': 'Kräver att AI (Claude) är aktiverat under Inställningar → AI (Claude).',
    'maint.ai.batchAll.label': '✨ AI-tagga synliga fraser',
    'maint.ai.batchAll.desc': 'Skickar alla synliga fraser till AI som automatiskt föreslår taggar och kategorier. Kräver ett API-anrop per fras.',
    'maint.ai.tags.label': '🏷 Städa taggar',
    'maint.ai.tags.desc': 'AI granskar alla befintliga taggar och föreslår sammanslagningar av synonymer samt borttagning av meningslösa taggar.',
    'maint.ai.tags.btn': 'Städa taggar…',
    'maint.ai.cats.label': '📁 Städa kategorier',
    'maint.ai.cats.desc': 'AI granskar kategorier och föreslår sammanslagningar eller omstrukturering för ett enhetligare system.',
    'maint.ai.cats.btn': 'Städa kategorier…',
    'maint.ai.move.label': '📦 Placera om fraser',
    'maint.ai.move.desc': 'AI föreslår vilka fraser som bör flyttas till en annan fil baserat på innehåll och befintlig filstruktur.',
    'maint.ai.move.btn': 'Placera om fraser…',
    'maint.ai.undo': '↺ Ångra senaste AI-städning',
    'ai.llm.title': 'Lokal LLM (OpenAI-kompatibelt)',
    'ai.llm.desc': 'Använd Ollama, LM Studio eller annan OpenAI-kompatibel server. Lokal LLM tar prioritet framför Claude när aktiverad.',
    'ai.llm.enable': 'Använd lokal LLM (åsidosätter Claude)',
    'ai.llm.endpoint': 'Endpoint',
    'ai.llm.model': 'Modell',
    'ai.llm.probe': '↺ Hämta modeller',
    'ai.llm.apikey': 'API-nyckel (valfritt)',
    'ai.llm.online': s => `✓ Ansluten — ${s} modell(er) tillgängliga`,
    'ai.llm.offline': 'Ingen server hittades på angiven endpoint.',
    'ai.llm.modelPick': 'Klicka på en modell för att välja den:',
  },
  en: {
    'search.ph': 'Search trigger, phrase, category…',
    'fuzzy': 'Fuzzy',
    'btn.new': '＋ New phrase',
    'count': (n, t) => t != null ? `${n} / ${t} phrases` : `${n} phrases`,
    'btn.settings': '⚙ Settings',
    'btn.fileSettings': '📄 File settings',
    'btn.recent': '🕐 Recent',
    'lang.toggle': 'SV',
    'tab.files': 'Files', 'tab.cats': 'Categ.', 'tab.tags': 'Tags', 'tab.lang': 'Lang.',
    'chkShowHidden': 'Show hidden',
    'allFilter': '— All —',
    'group.ungrouped': 'Other',
    'group.by': n => `Group by ${n}`, 'group.off': 'Ungroup',
    'group.ind': 'Grouped by this column – right-click to change',
    // — Toolbar tooltips & common —
    'tt.clearSearch': 'Clear search',
    'tt.compact': 'Compact mode',
    'tt.toggleSidebar': 'Hide sidebar',
    'tt.fileSettings': 'File settings for the selected file',
    'tt.dragResize': 'Drag to resize',
    'tt.swap': 'Swap trigger ↔ phrase',
    'tt.deselectAll': 'Deselect all',
    'tt.add': 'Add',
    'nav.settingsTip': 'Settings',
    'btn.saveReload': 'Save & reload',
    'help.title': 'Help',
    // — Phrase folders —
    'fr.more': 'More word lists from the wordlists repo',
    'fr.packs': 'Starter phrase packs (optional)',
    'packs.title': 'Download phrase packs',
    'packs.desc': 'Ready-made phrase packs from the ahk-phrases repo. Selected packs are downloaded and added as phrase folders automatically.',
    'packs.none': 'No phrase packs found.',
    'packs.files': n => `${n} file${n === 1 ? '' : 's'}`,
    'packs.downloading': 'Downloading…',
    'packs.done': 'Done — the packs were downloaded and added as phrase folders.',
    'packs.someFailed': n => `Done, but ${n} file(s) could not be downloaded.`,
    'wl.fetching': 'Fetching list from GitHub…',
    'wl.none': 'No word lists found.',
    'wl.fetchErr': m => `Could not fetch list: ${m}`,
    'folders.desc': 'All .ahk and .enc files in the selected folders are loaded as phrase files.',
    'folders.add': '＋ Add folder',
    'folders.delTip': 'Remove folder',
    // — Shortcuts —
    'hk.format': 'Key format: <code>+</code> Shift &nbsp;·&nbsp; <code>^</code> Ctrl &nbsp;·&nbsp; <code>!</code> Alt &nbsp;·&nbsp; <code>#</code> Win &nbsp;·&nbsp; <code>&lt;^&gt;!</code> AltGr &nbsp;·&nbsp; CapsLock_',
    'hk.capture': '🎹 Capture key',
    'hk.captureHint': 'Focus a field below, click the button, press the combination',
    'hk.capsCap': 'Handle CapsLock internally when a hotkey uses it (turn off if another script already manages CapsLock)',
    'hk.emptyTip': '💡 Empty field = the default key is used. Type <b>av</b> in a field to disable the command entirely.',
    'hk.secGlobal': 'Global shortcuts',
    'hk.openGui': 'Open GUI:',
    'hk.markWord': 'New phrase from previous word:',
    'hk.stepNext': 'Stepwise insertion of selected phrase (start + next segment):',
    'hk.undo': 'Undo latest expansion:',
    'hk.lastFired': 'Open last triggered phrase:',
    'hk.secGui': 'In-window shortcuts <span style="font-weight:400;text-transform:none">(active while the main window is focused; empty = off)</span>',
    'hk.new': 'New phrase:',
    'hk.update': 'Update:',
    'hk.delete': 'Delete:',
    'hk.filtFile': 'Filter file:',
    'hk.filtCat': 'Filter category:',
    'hk.filtTag': 'Filter tag:',
    'hk.assignCat': 'Assign category:',
    'hk.assignTag': 'Assign tag:',
    'hk.switchField': 'Switch field:',
    'hk.aiSuggest': 'AI suggest:',
    'hk.layout': 'Cycle layout:',
    'hk.onTop': 'Always-on-top:',
    'hk.moveFile': 'Move to file:',
    'hk.moveFileShort': 'Move file:',
    'hk.settings': 'Settings:',
    'hk.editFile': 'Edit file:',
    'hk.lastEdited': 'Last edited:',
    'hk.dupes': 'Duplicates:',
    'hk.panel': 'Toggle panel:',
    'hk.secInsert': 'Global insertion shortcuts',
    'hk.insert': 'Insert selected phrase:',
    'hk.insertStep': 'Insert/Next segment:',
    'hk.secQuick': 'Quick select — prefix + digit picks row 1–10; +Shift = 11–20',
    'hk.secFieldNav': 'Field navigation — Alt+letter jumps to a field (edit and bulk panel)',
    'hk.fTrigger': 'Trigger:',
    'hk.fPhrase': 'Phrase:',
    'hk.fCat': 'Category:',
    'hk.fTags': 'Tags:',
    'hk.fApps': 'Apps:',
    'hk.fLang': 'Language:',
    'hk.fComment': 'Comment:',
    'hk.bFile': 'Move (bulk):',
    // — Popup —
    'pop.secHint': 'Hint popup while typing',
    'pop.enable': 'Enable the hint popup',
    'pop.fuzzy': 'Fuzzy matching in the popup',
    'pop.chars': 'Characters before popup:',
    'pop.timeout': 'Popup closes after (sec, 0 = off):',
    'pop.secKeys': 'Popup keys <span style="font-weight:400;text-transform:none">(+ Shift · ^ Ctrl · ! Alt)</span>',
    'pop.insert': 'Insert suggestion:',
    'pop.up': 'Scroll up:',
    'pop.down': 'Scroll down:',
    'pop.numKey': 'Pick with digit key:',
    'pop.numKey.off': 'Off (default)',
    'pop.numKey.ctrl': 'Ctrl+digit (1–9)',
    'pop.numKey.alt': 'Alt+digit (1–9)',
    'pop.numKey.shift': 'Shift+digit (1–9)',
    'pop.tip': 'Tip: left-click in the popup inserts the suggestion; right-click opens the phrase in the main window.',
    // — Dynamic fields —
    'dyn.tokens': '<strong>Placeholders in phrase texts</strong> — tokens fill in automatically. {custom names} are prompted on insertion:<br><code>{date}</code> &nbsp;today\'s date (YYYY-MM-DD)<br><code>{time}</code> &nbsp;time of day (HH:MM)<br><code>{clipboard}</code> &nbsp;the clipboard contents<br><code>{cursor}</code> &nbsp;the caret lands here after insertion<br><code>{custom name}</code> &nbsp;a field that is prompted, e.g. {name}, {case}<br><code>{sex=he/she}</code> &nbsp;dropdown with fixed choices (brackets <code>{sex=[he/she]}</code> also work); <code>*</code> marks the default, e.g. {sex=*he/she}',
    'dyn.defaultMode': 'Default mode',
    'dyn.mode.auto': 'Auto — 1 field → inline, several → dialog',
    'dyn.mode.inline': 'Always inline',
    'dyn.mode.dialog': 'Always dialog',
    'dyn.mode.off': 'Off — do not fill fields automatically',
    'dyn.appMode': 'Per-app mode <span style="font-weight:400;text-transform:none">(click a row to toggle; Default = use the default mode)</span>',
    'dyn.appProcess': 'App process',
    'dyn.appModeCol': 'Mode',
    'dyn.addApp': '＋ Add app',
    'dynApp.appPh': 'process or title:part',
    'dyn.stepLabels': 'Stepwise insertion — field labels <span style="font-weight:400;text-transform:none">(whitelist, separate with |)</span>',
    'dyn.stepLabels.desc': 'The phrase splits at these labels; each field is inserted separately and only the value is pasted (the label shows in the panel as a guide).',
    'dyn.pasteMode': 'Insertion method',
    'dyn.paste.auto': 'Auto — clipboard for long texts, keystrokes for short',
    'dyn.paste.always': 'Always clipboard (fast)',
    'dyn.paste.never': 'Always keystrokes (slow)',
    'dyn.pasteMinLen': 'Clipboard threshold (characters)',
    'dyn.pasteMinLen.desc': 'Texts shorter than this are typed character by character; longer ones are pasted via the clipboard.',
    // — AI page —
    'ai.enable': 'Enable AI features',
    'ai.apiKey': 'API key',
    'ai.model': 'Model',
    'ai.model.sonnet': 'Sonnet 4.6 (recommended)',
    'ai.model.haiku': 'Haiku 4.5 (fast)',
    'ai.model.opus': 'Opus 4.8 (powerful)',
    'ai.autoTag': 'Auto-tag new phrases',
    'ai.exclude': 'Exclude (one pattern per line)',
    'ai.exclude.ph': 'e.g. sensitive_folder',
    'ai.resetUsage': 'Reset usage',
    'aidrop.single': 'AI for this phrase',
    'aidrop.bulk': 'AI for selected phrases',
    'aidrop.batch': 'AI-tag all visible',
    // — Spell check —
    'spell.enable': 'Enable built-in spell checking in the phrase and comment fields',
    'spell.secDownload': 'Download word lists',
    'spell.dlDesc': 'Fetch optional word lists from the GitHub repo <code>ibst1/wordlists</code>. Pick a target folder — it is then added automatically as a word-list folder in Expanto.',
    'spell.noFolder': '(no folder selected)',
    'spell.chooseFolder': 'Choose folder…',
    'spell.dlSelected': '↓ Download selected',
    'spell.refreshIndex': '↺ Refresh list',
    'spell.dlProgress': (d, t, f) => `Downloading ${d}/${t}: ${f}…`,
    'spell.secFolders': 'Word-list folders',
    'spell.foldersDesc': 'Add folders with your own word lists (UTF-8, one word per line). Every .txt file in each folder is loaded on top of the browser\'s built-in spell check. Useful for technical and domain-specific terms.',
    'spell.secCompound': 'Swedish compound words',
    'spell.compound': 'Accept Swedish compound words in the spell check',
    'spell.compoundDesc': 'Long unknown words that can be split into known list words (optionally with a linking-s) are not flagged as misspellings.',
    'spell.compoundMinLen': 'Minimum word length to try splitting',
    // — Encrypted phrases —
    'enc.import': 'Import from Excel…',
    // — File settings panel —
    'fs.file': 'File',
    'fs.rename': 'File name <span style="font-weight:400;text-transform:none">(renames the actual file)</span>',
    'fs.renameBtn': 'Rename',
    'fs.label': 'Display name <span style="font-weight:400;text-transform:none">(optional)</span>',
    'fs.label.ph': 'e.g. Support replies',
    'fs.defaultCat': 'Default category for new phrases',
    'fs.defaultCat.ph': 'e.g. Customer cases',
    'fs.metaFields': 'Metadata fields for new phrases <span style="font-weight:400;text-transform:none">(comma-sep.)</span>',
    'fs.metaFields.ph': 'e.g. customer, issue, product',
    'fs.metaFields.hint': 'These fields are shown and prompted when a new phrase is created in this particular file.',
    'fs.preview': 'Preview',
    'fs.sharedTitle': 'Shared fields between related phrases',
    'fs.sharedHint': 'Phrases with the same value in a grouping field can share dynamic field values — enter once, reused. Values are kept in memory only, never on disk.',
    'fs.groupField': 'Group by <span style="font-weight:400;text-transform:none">(comma-sep. fields)</span>',
    'fs.groupField.ph': 'e.g. customerid, orderid  ·  thinker, era  ·  party, election',
    'fs.groupField.hint': 'Phrases with the same value here are grouped in the list. Each field gets a row below where you set which fields are shared within that group.',
    'fs.titleTitle': 'Auto-fill fields from the window title',
    'fs.titleHint': 'Optional. Fills fields automatically from the active window\'s title (e.g. an ID already shown in another program). Hover the ⓘ for examples.',
    'fs.titleFields': 'Title fields <span style="font-weight:400;text-transform:none">(field names for the capture groups, in order)</span>',
    'fs.titlePattern': 'Title pattern <span style="font-weight:400;text-transform:none">(regex against the window title)</span>',
    'fs.helpTip': 'Show help',
    // — Help modals —
    'help.sharedFields.html': '<p>Phrases in the same file can share dynamic field values, tied to a common <b>key field</b>. A value is entered once and reused automatically every time the same key value appears — until Expanto restarts. Values are <b>never</b> written to disk.</p><h4>Configuration</h4><ul><li><b>Group by</b> = the field that acts as the memory key.</li><li><b>Shared fields for &lt;key&gt;</b> = comma-separated fields whose values are shared within the group.</li></ul><h4>Example 1 — customer cases</h4><pre>Group by:                    customerid\nShared fields for customerid: name, issue</pre><p>The first time you insert a phrase for customerid ”10042” you are asked for name and issue. The next phrase with the same customerid fills them in automatically.</p><h4>The special ”trigger” field</h4><p>Write <code>trigger</code> in <b>Group by</b>. It is a built-in pseudo-field that automatically takes the value of the hotstring (trigger) that fired the phrase. Fields under ”Shared fields for trigger” are copied straight from the trigger text without any prompt.</p><h4>Example 2 — trigger as key</h4><pre>Group by:                  trigger\nShared fields for trigger: SID</pre><p>The phrase is fired by the hotstring ”sid123” and contains <code>{SID}</code> → <code>{SID}</code> fills automatically with ”sid123”.</p><p class="help-warn">⚠ The field name is <b>case sensitive</b>: <code>{SID}</code> in the phrase text must be written exactly like the name under ”Shared fields for trigger” (e.g. both <code>SID</code> or both <code>sid</code>). Otherwise you are prompted for the value instead.</p><h4>Example 3 — combined</h4><pre>Group by:                  trigger\nShared fields for trigger: caseid\nTitle fields:              name, department\nTitle pattern:             Customer: (.+?) / (.+)</pre><p>The trigger provides caseid, the window title provides name and department — no manual input needed.</p><h4>Memory rules</h4><ul><li>Values live in RAM only and reset when Expanto restarts.</li><li>A new key value (new customer, new trigger) clears volatile data (today-/clipboard-sourced fields) but keeps prompted values for the old key value.</li><li>Fields tied to ”trigger” are never stored — they are always re-derived from the hotstring.</li></ul>',
    'help.titleAutofill.html': '<p>Extracts field values from the <b>active window\'s title</b> using a regular expression (regex). Each capture group <code>( )</code> fills the field with the same name, in order.</p><h4>Example</h4><pre>Window title:   Program - [ID 12345 Anna Berg]\nTitle fields:   id, name\nTitle pattern:  \\[ID (\\d+) (.+?)\\]</pre><p>→ <code>id</code> = 12345, <code>name</code> = Anna Berg.</p><p>Works with any program that shows values in its window title.</p>',
    'toast.propagated': 'Shared fields updated on related phrases',
    'scope.file': '▼ Filtered to selected file',
    'scope.cat': '▼ Filtered to selected category',
    'scope.fileCat': '▼ Filtered to selected file/category',
    'nav.back': '← Back',
    'nav.general': 'General', 'nav.folders': 'Phrase folders', 'nav.hotkeys': 'Shortcuts',
    'nav.popup': 'Popup', 'nav.dynamic': 'Dynamic fields', 'nav.ai': 'AI (Claude)',
    'nav.aimaint': 'AI maintenance', 'nav.spell': 'Spell check', 'nav.enc': 'Encrypted phrases',
    'col.nr': '#', 'col.trigger': 'Trigger', 'col.phrase': 'Phrase',
    'col.cat': 'Category', 'col.tags': 'Tags', 'col.lang': 'Language', 'col.file': 'File',
    'field.trim': 'Trim (remove leading/trailing whitespace when saving)',
    'list.loading': 'Loading phrases…', 'list.noMatch': 'No phrases match.',
    'list.recentUsed': 'No recently used phrases.',
    'list.recentEdited': 'No recently edited phrases.',
    'detail.title': 'Details', 'detail.new': 'New phrase',
    'detail.moveTo': 'Move phrase', 'detail.dupTo': 'Duplicate to',
    'field.file': 'File',
    'newfile.showHidden': n => '⋯ Show hidden files (' + n + ')',
    'newfile.hideHidden': '⋯ Hide hidden files',
    'newfile.hiddenTag': 'hidden',
    'newfile.noFolder': '(no folder)',
    'newfile.empty': 'No files',
    'newfile.aiAuto': '✨ Fill in metadata with AI',
    'newfile.aiAuto.tip': 'Empty fields (category, tags, comment, language) are filled in by the AI after the phrase is saved.',
    'newfile.aiAuto.enc': 'Encrypted files are never sent to the AI.',
    'toolbar.previewLines': 'Phrase preview lines in the list',
    'field.trigger.html': '<span data-ak-text>Trigger</span> / Alias <span style="font-weight:400;text-transform:none">(comma-sep.; first = trigger, rest = aliases)</span>',
    'field.apps.html': '<span data-ak-text>Apps</span> <span style="font-weight:400;text-transform:none">(comma-sep; process without .exe or title:parttitle; empty = all)</span>',
    'field.phrase': 'Phrase', 'field.cat': 'Category',
    'alt.add.tip': 'Add an alternative phrase text (choose which one on insert)',
    'alt.remove.tip': 'Remove this alternative text',
    'alt.ph': 'Alternative phrase text…',
    'alt.name.ph': 'Name (optional), e.g. Letter',
    'alt.name.main.ph': 'Name of the main phrase (optional), e.g. Formal',
    'field.tags.html': '<span data-ak-text>Tags</span> <span style="font-weight:400;text-transform:none">(comma-sep.)</span>',
    'field.lang': 'Language', 'field.comment': 'Comment', 'field.flags': 'Flags',
    'field.url': '🔗 Link (file or web address)',
    'btn.urlBrowse.tip': 'Browse for a file to link',
    'btn.urlOpen.tip': 'Open the link/file',
    'urlIcon.tip': 'This phrase has a link',
    'alert.noUrl': 'No link set.',
    'field.status': 'Status', 'field.info': 'Info',
    'flag.star': '* immediate', 'flag.q': '? inside word', 'flag.o': 'O keep end char', 'flag.c': 'C case sensitive',
    'flag.star.title': 'Trigger immediately without end character',
    'flag.q.title': 'Trigger inside words (no word boundary)',
    'flag.o.title': 'The end character is included in the text',
    'flag.c.title': 'Case-sensitive trigger',
    'disabled': 'Disabled',
    'btn.save': 'Save & insert', 'btn.saveOnly': 'Save', 'btn.saveDrop': '▾',
    'btn.insert': 'Insert', 'btn.close': 'Close',
    'gen.autosave': 'Auto-save phrase edits (hides the Save button)',
    'btn.save.tip': 'Save/update and insert (Ctrl+Enter)', 'btn.saveOnly.tip': 'Save/update only (Alt+Enter)',
    'btn.ai': '✨ AI', 'btn.aiDrop': '▾',
    'btn.duplicate': 'Duplicate', 'btn.duplicateMore': '▾',
    'btn.cancel': 'Cancel', 'btn.delete': 'Delete',
    'btn.noOtherFiles': 'No other files available',
    'alert.triggerPhraseRequired': 'Trigger and phrase are required.',
    'confirm.deletePhrase': t => `Delete "${t}"?`,
    'confirm.bulkDelete': n => `Delete ${n} phrases? This action cannot be undone.`,
    'toast.deleted': t => `"${t}" deleted`, 'toast.undo': 'Undo',
    'confirm.aiEnableFirst': 'Enable AI in Settings (⚙ in the toolbar).',
    'confirm.aiBatch': n => `AI-tag ${n} visible phrases? One API call per phrase.`,
    'confirm.aiBulk': n => `AI-tag ${n} selected phrases?`,
    'bulk.title': n => `${n} phrases selected`,
    'bulk.desc': 'Check the fields you want to change on all selected phrases.',
    'bulk.check.cat': 'Category', 'bulk.check.lang': 'Language',
    'bulk.check.comment': 'Comment', 'bulk.check.file': 'Move to file',
    'bulk.tags': 'Tags', 'bulk.addTag': 'Add tag…',
    'bulk.save': 'Save', 'bulk.ai': '✨ AI for selected',
    'bulk.cancel': 'Cancel', 'bulk.delete': 'Delete',
    'bulk.noField': 'Check at least one field to change, or add/remove tags.',
    'tags.none': 'No tags', 'tags.clearSelection': '✕ Clear selection',
    'tags.chip.count': n => `${n} phrases`,
    'badge.hsActive': 'Hotstrings active', 'badge.hsInactive': 'Hotstrings inactive',
    'badge.hintTActive': 'Trigger popup active', 'badge.hintTInactive': 'Trigger popup inactive',
    'badge.hintPActive': 'Phrase popup active', 'badge.hintPInactive': 'Phrase popup inactive',
    'badge.locked': 'locked',
    'ctx.selectAll': 'Select all visible',
    'ctx.startCheckbox': 'Select multiple (checkboxes)', 'ctx.exitCheckbox': 'Exit multi-select',
    'ctx.duplicate': 'Duplicate',
    'ctx.dupToFile': 'Duplicate to another file',
    'ctx.moveToFile': 'Move to another file',
    'confirm.dupToFile': (n, f) => `Duplicate ${n} phrase(s) to ${f}?`,
    'confirm.moveToFile': (n, f) => `Move ${n} phrase(s) to ${f}?`,
    'toast.dupedToFile': (n, f) => `${n} phrase(s) duplicated to ${f}`,
    'toast.movedToFile': (n, f) => `${n} phrase(s) moved to ${f}`,
    'toast.fileRenamed': 'File renamed',
    'ctx.fileSettings': 'File settings for this file…', 'ctx.openEditor': 'Open in editor',
    'ctx.newFile': 'New file in this folder…',
    'ctx.enableHs': 'Enable hotstrings', 'ctx.disableHs': 'Disable hotstrings',
    'ctx.enableHintT': 'Enable trigger popup', 'ctx.disableHintT': 'Disable trigger popup',
    'ctx.enableHintP': 'Enable phrase popup', 'ctx.disableHintP': 'Disable phrase popup',
    'ctx.hideFile': 'Hide file', 'ctx.showFile': 'Show file',
    'ctx.openFolder': 'Open folder in Explorer',
    'ctx.hideFolder': 'Hide folder', 'ctx.showFolder': 'Show folder',
    'ctx.preset.spellcheck': 'Spell check', 'ctx.preset.abbrev': 'Abbreviations', 'ctx.preset.phrases': 'Long phrases',
    'toast.preset': name => `"${name}" applied`,
    'ctx.backups': 'Backups…',
    'ctx.encryptFile': 'Encrypt (.ahk → .enc)', 'ctx.decryptFile': 'Decrypt (.enc → .ahk)',
    'ctx.presets': 'Default settings', 'ctx.details': 'Detailed settings',
    'fr.title': 'Welcome to Expanto!',
    'fr.wordlists': 'Select word lists to activate',
    'fr.phraseFolder': 'Folder for your phrase files',
    'fr.browse': 'Browse…',
    'fr.start': 'Get started!',
    'fr.skip': 'Skip',
    'sp.spell.bundles': 'Built-in word lists (repo)',
    'sp.spell.bundles.desc': 'These word lists are included with Expanto. Select which ones should be active in spell check.',
    'btn.saveBundles': 'Save',
    'backup.title': name => `Backups: ${name}`,
    'backup.none': 'No backups found.',
    'backup.slot': (n, t) => `Copy ${n}  —  ${t}`,
    'backup.restore': 'Restore',
    'toast.backupRestored': 'Backup restored',
    'nf.title': 'New phrase file', 'nf.folder': 'Folder',
    'nf.name.html': 'File name <span style="font-weight:400;text-transform:none">(.ahk/.enc added automatically)</span>',
    'nf.type': 'Type', 'nf.type.ahk': '.ahk &nbsp;(plain text)', 'nf.type.enc': '.enc &nbsp;(encrypted)',
    'nf.create': 'Create', 'nf.cancel': 'Cancel',
    'nf.err.name': 'Enter a file name.', 'nf.err.folder': 'Select a folder.',
    'capture.focusFirst': 'Focus a field below first.',
    'capture.waiting': 'Press a key combination…',
    'capture.btn.ready': '🎹 Capture key', 'capture.btn.working': '⏳ Waiting…',
    'capture.captured': c => `Captured: ${c}`,
    'capture.holdKey': k => `${k} held — press the second key of the combination…`,
    'capture.aborted': 'Aborted — hold the key and press another.',
    'enc.unlocked': 'Session unlocked — .enc files loaded.',
    'enc.locked': n => `${n} encrypted file${n>1?'s':''} locked.`,
    'enc.none': 'No encrypted files.',
    'enc.lockBtn': n => `${n} encrypted file${n>1?'s':''} locked — click to unlock`,
    'btn.unlock': 'Unlock', 'btn.lockSession': 'Lock session',
    'customFields.title': 'File-specific fields',
    'customFields.ph': 'Empty = prompted on insertion',
    'customFields.title.tip': f => `Empty = prompted on insertion via {${f}}`,
    'customFields.applyMeta': '⇄ Apply metadata',
    'customFields.applyMeta.title': 'Sync field values with {field=value} placeholders in phrase text',
    'fs.title': 'File settings',
    'folders.empty': 'No folders configured.',
    'folders.del.confirm': nm => `Remove the folder "${nm}" from Expanto? (Files are not affected.)`,
    'dictFolders.empty': 'No word list folders configured.',
    'dictFolders.del.confirm': nm => `Remove word list folder "${nm}"? (Files are not affected.)`,
    'onTop.on': 'Always on top: ON',
    'sp.general.title': 'General', 'sp.folders.title': 'Phrase folders',
    'sp.hotkeys.title': 'Keyboard shortcuts', 'sp.popup.title': 'Popup settings',
    'sp.dynamic.title': 'Dynamic fields', 'sp.ai.title': 'AI (Claude)',
    'sp.aimaint.title': 'AI maintenance', 'sp.spell.title': 'Spell check',
    'sp.enc.title': 'Encrypted phrases (.enc)',
    'trigDup': (v, f) => `⚠ "${v}" already exists in ${f}`,
    'trigCollide': (v, t, f) => `⚠ "${v}" collides with "${t}" in ${f} (prefix overlap)`,
    'trigDict': w => `ℹ "${w}" is in the word list — trigger expands common words`,
    'dynApp.empty': 'No app-specific modes configured.',
    'dynApp.mode.auto': 'Default', 'dynApp.mode.inline': 'Inline',
    'dynApp.mode.dialog': 'Dialog', 'dynApp.mode.off': 'Off',
    'compound.saved': 'Saved.',
    'ai.batch.progress': (d,t) => `✨ AI-tagging ${d}/${t}…`, 'ai.batch.idle': '✨ AI-tag visible phrases',
    'dtm.dup': 'Duplicate to', 'dtm.move': 'Move to',
    'recent.off': '🕐 Recent', 'recent.used': '🕐 Used', 'recent.edited': '🕐 Edited',
    'recent.usedLabel': 'Recently used', 'recent.editedLabel': 'Recently edited',
    'nav.maint': 'Maintenance', 'sp.maint.title': 'Maintenance',
    'maint.dupes.title': 'Duplicate detection',
    'maint.dupes.desc': 'Find phrases with the same trigger or identical content.',
    'maint.dupes.btn': '🔍 Run duplicate check',
    'maint.dupes.none': '✓ No duplicates found.',
    'maint.dupes.triggers': n => `${n} duplicate trigger${n > 1 ? 's' : ''}`,
    'maint.dupes.phrases': n => `${n} identical phrase${n > 1 ? 's' : ''}`,
    'maint.semdupes.title': 'Semantic duplicates (AI)',
    'maint.semdupes.desc': 'Use AI to find phrases with similar meaning.',
    'maint.semdupes.btn': '✨ Run AI analysis',
    'maint.semdupes.noAi': 'Enable AI under Settings → AI (Claude).',
    'maint.stats.title': 'Statistics & dead phrases',
    'maint.stats.desc': 'Usage statistics based on locally saved timestamps.',
    'maint.stats.btn': '📊 Show statistics',
    'maint.stats.total': 'Total phrases', 'maint.stats.used': 'Used phrases',
    'maint.stats.neverUsed': 'Never used',
    'maint.stats.dead30': 'Not used > 30 days', 'maint.stats.dead90': 'Not used > 90 days',
    'maint.stats.topFiles': 'Files with most phrases',
    'aiSearch.btn': '✨ AI search', 'aiSearch.searching': '⏳ Searching…', 'aiSearch.clear': '✨ Clear AI search',
    'aiSearch.noQuery': 'Enter a search term first.', 'aiSearch.noAi': 'Enable AI in Settings (⚙).',
    'aiSearch.noMatch': 'No semantic matches found.',
    'gen.theme': 'Theme', 'gen.theme.dark': 'Dark', 'gen.theme.light': 'Light', 'gen.theme.auto': 'Automatic (system)',
    'gen.lang': 'UI language',
    'gen.editor': 'External editor',
    'gen.editor.desc': 'Command run when you open a file via right-click in the file list. Use {file} for the path.',
    'gen.startMinimized': 'Start minimized to system tray',
    'gen.autostart': 'Start with Windows',
    'gen.sidebar': 'Sidebar layout',
    'gen.sidebar.tabs': 'Tabs',
    'gen.sidebar.stacked': 'Stacked',
    'gen.sidebar.beside': 'Side by side',
    'gen.sidebar.grid': 'Grid (2 col)',
    'gen.navSections': 'Navigation panels',
    'gen.fontsize': 'Text size',
    'gen.fontsize.normal': '13px (default)',
    'maint.ai.title': 'AI features',
    'maint.ai.desc': 'Requires AI (Claude) to be enabled under Settings → AI (Claude).',
    'maint.ai.batchAll.label': '✨ AI-tag visible phrases',
    'maint.ai.batchAll.desc': 'Sends all visible phrases to AI which automatically suggests tags and categories. Requires one API call per phrase.',
    'maint.ai.tags.label': '🏷 Clean up tags',
    'maint.ai.tags.desc': 'AI reviews all existing tags and suggests merging synonyms and removing meaningless tags.',
    'maint.ai.tags.btn': 'Clean up tags…',
    'maint.ai.cats.label': '📁 Clean up categories',
    'maint.ai.cats.desc': 'AI reviews categories and suggests merging or restructuring for a more consistent system.',
    'maint.ai.cats.btn': 'Clean up categories…',
    'maint.ai.move.label': '📦 Reorganize phrases',
    'maint.ai.move.desc': 'AI suggests which phrases should be moved to another file based on content and existing file structure.',
    'maint.ai.move.btn': 'Reorganize phrases…',
    'maint.ai.undo': '↺ Undo last AI cleanup',
    'ai.llm.title': 'Local LLM (OpenAI-compatible)',
    'ai.llm.desc': 'Use Ollama, LM Studio or any other OpenAI-compatible server. Local LLM takes priority over Claude when enabled.',
    'ai.llm.enable': 'Use local LLM (overrides Claude)',
    'ai.llm.endpoint': 'Endpoint',
    'ai.llm.model': 'Model',
    'ai.llm.probe': '↺ Fetch models',
    'ai.llm.apikey': 'API key (optional)',
    'ai.llm.online': s => `✓ Connected — ${s} model(s) available`,
    'ai.llm.offline': 'No server found at the given endpoint.',
    'ai.llm.modelPick': 'Click a model to select it:',
  },
};

let g_lang        = (() => { try { return localStorage.getItem('expanto_lang')         || 'sv';   } catch { return 'sv';   } })();
let g_theme       = (() => { try { return localStorage.getItem('expanto_theme')        || 'auto'; } catch { return 'auto'; } })();
let g_sidebarMode      = (() => { try { return localStorage.getItem('expanto_sidebar_mode')      || 'tabs';  } catch { return 'tabs';  } })();
let g_navSections      = (() => { try { return JSON.parse(localStorage.getItem('expanto_nav_sections') || 'null') || { files:true, cats:true, tags:true, lang:true }; } catch { return { files:true, cats:true, tags:true, lang:true }; } })();
let g_fontSize         = (() => { try { return parseInt(localStorage.getItem('expanto_font_size'))  || 13;     } catch { return 13;     } })();
let g_compactMode      = (() => { try { return localStorage.getItem('expanto_compact')             === '1';   } catch { return false;  } })();
let g_previewLines     = (() => { try { return Math.max(1, parseInt(localStorage.getItem('expanto_previewLines') || '1', 10) || 1); } catch { return 1; } })();
let g_sidebarCollapsed = (() => { try { return localStorage.getItem('expanto_sidebar_collapsed')   === '1';   } catch { return false;  } })();

function T(key, ...args) {
  const dict = LANG[g_lang] ?? LANG.sv;
  const val  = dict[key] ?? LANG.sv[key] ?? key;
  return typeof val === 'function' ? val(...args) : val;
}

function applyTranslations() {
  document.documentElement.lang = g_lang;
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const v = T(el.dataset.i18n); if (v !== el.dataset.i18n) el.textContent = v;
  });
  document.querySelectorAll('[data-i18n-html]').forEach(el => {
    const v = T(el.dataset.i18nHtml); if (v !== el.dataset.i18nHtml) el.innerHTML = v;
  });
  document.querySelectorAll('[data-i18n-ph]').forEach(el => {
    const v = T(el.dataset.i18nPh); if (v !== el.dataset.i18nPh) el.placeholder = v;
  });
  document.querySelectorAll('[data-i18n-title]').forEach(el => {
    const v = T(el.dataset.i18nTitle); if (v !== el.dataset.i18nTitle) el.title = v;
  });
  const r = document.getElementById(g_lang === 'sv' ? 'genLangSv' : 'genLangEn');
  if (r) r.checked = true;
  // Re-apply field-key underlines after labels have been re-translated
  applyFieldKeys();
}

function setLang(lang) {
  g_lang = lang;
  try { localStorage.setItem('expanto_lang', lang); } catch {}
  postToAhk({ action: 'setLang', lang });
  const r = document.getElementById(lang === 'sv' ? 'genLangSv' : 'genLangEn');
  if (r) r.checked = true;
  applyTranslations();
  renderListHeader();
  renderListFilters();
  populateSidebar();
  renderPhraseList();
}

function applyTheme(theme) {
  g_theme = theme;
  try { localStorage.setItem('expanto_theme', theme); } catch {}
  if (theme === 'auto') document.documentElement.removeAttribute('data-theme');
  else document.documentElement.setAttribute('data-theme', theme);
  const radioId = theme === 'dark' ? 'genThemeDark' : theme === 'light' ? 'genThemeLight' : 'genThemeAuto';
  const r = document.getElementById(radioId);
  if (r) r.checked = true;
}

function applyFontSize(size) {
  g_fontSize = parseInt(size) || 13;
  try { localStorage.setItem('expanto_font_size', g_fontSize); } catch(_) {}
  const zoom = (g_fontSize / 13).toFixed(4);
  document.body.style.zoom = zoom;
  // Compensate body height so zoomed content fills exactly 100vh (no black gap at bottom)
  document.body.style.height = (1300 / g_fontSize).toFixed(3) + 'vh';
  document.querySelectorAll('input[name="genFontSize"]').forEach(r => {
    r.checked = parseInt(r.value) === g_fontSize;
  });
}

function applyCompactMode(on) {
  g_compactMode = on;
  try { localStorage.setItem('expanto_compact', on ? '1' : '0'); } catch(_) {}
  document.getElementById('listArea')?.classList.toggle('layout-compact', on);
  const btn = document.getElementById('btnCompact');
  if (btn) btn.classList.toggle('active', on);
}

// How many lines of the phrase text each list row shows (1 = classic single
// line). Pure CSS (line-clamp), so changes apply instantly without re-render.
function applyPreviewLines(n) {
  g_previewLines = Math.max(1, parseInt(n, 10) || 1);
  try { localStorage.setItem('expanto_previewLines', String(g_previewLines)); } catch(_) {}
  const la = document.getElementById('listArea');
  if (la) {
    la.classList.toggle('preview-multi', g_previewLines > 1);
    la.style.setProperty('--preview-lines', g_previewLines);
  }
  const sl = document.getElementById('previewLinesSlider');
  if (sl) sl.value = String(g_previewLines);
  const vv = document.getElementById('previewLinesVal');
  if (vv) vv.textContent = String(g_previewLines);
}

function applySidebarCollapsed(on) {
  g_sidebarCollapsed = on;
  try { localStorage.setItem('expanto_sidebar_collapsed', on ? '1' : '0'); } catch(_) {}
  document.getElementById('sidebar')?.classList.toggle('sidebar-collapsed', on);
  const btn = document.getElementById('btnToggleSidebar');
  if (btn) { btn.textContent = on ? '▶' : '◀'; btn.title = on ? 'Visa sidopanel' : 'Dölj sidopanel'; }
}

function applySidebarMode(mode) {
  g_sidebarMode = mode;
  try { localStorage.setItem('expanto_sidebar_mode', mode); } catch(_) {}
  const nav = document.getElementById('filterNav');
  if (!nav) return;
  const radioId = { stacked: 'genSidebarStacked', beside: 'genSidebarBeside', tabs: 'genSidebarTabs', grid: 'genSidebarGrid' }[mode] || 'genSidebarTabs';
  const radio = document.getElementById(radioId);
  if (radio) radio.checked = true;
  // Reset all col inline styles and mode classes
  nav.querySelectorAll('.sidebar-col').forEach(col => { col.style.flex = ''; col.style.height = ''; col.style.width = ''; });
  nav.classList.remove('sidebar-stacked', 'sidebar-beside', 'sidebar-grid');
  if (mode === 'stacked' || mode === 'beside') {
    nav.classList.add(mode === 'stacked' ? 'sidebar-stacked' : 'sidebar-beside');
    ['panelFiles','panelCats','panelTags','panelLang'].forEach(id => document.getElementById(id)?.classList.add('active'));
    try {
      const saved = JSON.parse(localStorage.getItem('expanto_sidebar_sizes') || '{}');
      const fc = document.getElementById('panelFiles')?.closest('.sidebar-col');
      const cc = document.getElementById('panelCats')?.closest('.sidebar-col');
      const tc = document.getElementById('panelTags')?.closest('.sidebar-col');
      if (mode === 'stacked') {
        if (saved.files_h && fc) { fc.style.flex = 'none'; fc.style.height = saved.files_h; }
        if (saved.cats_h  && cc) { cc.style.flex = 'none'; cc.style.height = saved.cats_h;  }
        if (saved.tags_h  && tc) { tc.style.flex = 'none'; tc.style.height = saved.tags_h;  }
      } else {
        if (saved.files_w && fc) { fc.style.flex = 'none'; fc.style.width = saved.files_w; }
        if (saved.cats_w  && cc) { cc.style.flex = 'none'; cc.style.width = saved.cats_w;  }
        if (saved.tags_w  && tc) { tc.style.flex = 'none'; tc.style.width = saved.tags_w;  }
      }
    } catch(_) {}
    _restoreSidebarSectionState();
  } else if (mode === 'grid') {
    nav.classList.add('sidebar-grid');
    ['panelFiles','panelCats','panelTags','panelLang'].forEach(id => document.getElementById(id)?.classList.add('active'));
  } else {
    document.querySelectorAll('.sidebar-panel').forEach(p => p.classList.remove('active'));
    const activeTab = document.querySelector('.sidebar-tabs button:not(.col-hidden).active')
      || document.querySelector('.sidebar-tabs button:not(.col-hidden)');
    document.getElementById(activeTab?.dataset.panel || 'panelFiles')?.classList.add('active');
    if (activeTab && !activeTab.classList.contains('active')) {
      document.querySelectorAll('.sidebar-tabs button').forEach(b => b.classList.remove('active'));
      activeTab.classList.add('active');
    }
  }
}

function _applySectionVisibility() {
  const vis = g_navSections;
  ['files','cats','tags','lang'].forEach(sec => {
    const col = document.querySelector(`.sidebar-col[data-section="${sec}"]`);
    if (col) col.classList.toggle('col-hidden', !vis[sec]);
    const panelId = 'panel' + sec.charAt(0).toUpperCase() + sec.slice(1);
    const btn = document.querySelector(`.sidebar-tabs button[data-panel="${panelId}"]`);
    if (btn) btn.classList.toggle('col-hidden', !vis[sec]);
  });
  if (g_sidebarMode === 'tabs') {
    const activeBtn = document.querySelector('.sidebar-tabs button.active');
    if (!activeBtn || activeBtn.classList.contains('col-hidden')) {
      const first = document.querySelector('.sidebar-tabs button:not(.col-hidden)');
      if (first) { first.click(); }
    }
  }
  try { localStorage.setItem('expanto_nav_sections', JSON.stringify(vis)); } catch(_) {}
}

function _saveSidebarSizes() {
  try {
    const fc = document.getElementById('panelFiles')?.closest('.sidebar-col');
    const cc = document.getElementById('panelCats')?.closest('.sidebar-col');
    const tc = document.getElementById('panelTags')?.closest('.sidebar-col');
    localStorage.setItem('expanto_sidebar_sizes', JSON.stringify({
      files_h: fc?.style.height || '', cats_h: cc?.style.height || '', tags_h: tc?.style.height || '',
      files_w: fc?.style.width  || '', cats_w: cc?.style.width  || '', tags_w: tc?.style.width  || '',
    }));
  } catch(_) {}
}

function _bindVResize(handleId, topPanelId) {
  const handle = document.getElementById(handleId);
  if (!handle) return;
  handle.addEventListener('mousedown', e => {
    const mode = g_sidebarMode;
    if (mode !== 'stacked' && mode !== 'beside') return;
    e.preventDefault();
    const col    = document.getElementById(topPanelId)?.closest('.sidebar-col');
    if (!col) return;
    const horiz  = mode === 'beside';
    const startP = horiz ? e.clientX : e.clientY;
    const startS = horiz ? col.getBoundingClientRect().width : col.getBoundingClientRect().height;
    handle.classList.add('dragging');
    const onMove = ev => {
      const newS = Math.max(60, startS + (horiz ? ev.clientX : ev.clientY) - startP);
      col.style.flex = 'none';
      if (horiz) { col.style.width = newS + 'px'; col.style.height = ''; }
      else       { col.style.height = newS + 'px'; col.style.width = ''; }
    };
    const onUp = () => {
      handle.classList.remove('dragging');
      _saveSidebarSizes();
      document.removeEventListener('mousemove', onMove);
      document.removeEventListener('mouseup',   onUp);
    };
    document.addEventListener('mousemove', onMove);
    document.addEventListener('mouseup',   onUp);
  });
}

function _initSectionCollapseHandlers() {
  document.querySelectorAll('.sidebar-section-hdr').forEach(hdr => {
    hdr.addEventListener('click', () => {
      if (g_sidebarMode !== 'stacked') return;
      const col = hdr.closest('.sidebar-col');
      if (!col) return;
      col.classList.toggle('section-collapsed');
      const arrow = hdr.querySelector('.ssh-arrow');
      if (arrow) arrow.textContent = col.classList.contains('section-collapsed') ? '▸' : '▾';
      if (!col.classList.contains('section-collapsed')) {
        const sec = col.dataset.section;
        try {
          const saved = JSON.parse(localStorage.getItem('expanto_sidebar_sizes') || '{}');
          const hKey = sec + '_h';
          if (saved[hKey]) { col.style.flex = 'none'; col.style.height = saved[hKey]; }
          else { col.style.flex = '1'; col.style.height = ''; }
        } catch(_) { col.style.flex = '1'; col.style.height = ''; }
      }
      _saveSidebarSectionState();
    });
  });
}

function _saveSidebarSectionState() {
  const state = {};
  document.querySelectorAll('.sidebar-col[data-section]').forEach(col => {
    state[col.dataset.section] = col.classList.contains('section-collapsed');
  });
  try { localStorage.setItem('expanto_section_collapsed', JSON.stringify(state)); } catch(_) {}
}

function _restoreSidebarSectionState() {
  try {
    const state = JSON.parse(localStorage.getItem('expanto_section_collapsed') || '{}');
    document.querySelectorAll('.sidebar-col[data-section]').forEach(col => {
      const collapsed = !!state[col.dataset.section];
      col.classList.toggle('section-collapsed', collapsed);
      const arrow = col.querySelector('.ssh-arrow');
      if (arrow) arrow.textContent = collapsed ? '▸' : '▾';
    });
  } catch(_) {}
}

// ── State ─────────────────────────────────────────────────────────────────────
let g_phrases      = [];
let g_filtered     = [];
let g_selId        = null;
let g_selFiles     = new Set();
let g_selCats      = new Set();
let g_selTags      = new Set();
let g_selLangs     = new Set();
let g_fuzzy        = false;
let g_files        = [];   // [{path, name, folder, hsOn, hintTOn, hintPOn}]
let g_fileSettingsMap = {};
let g_aiEnabled    = false;
let g_llmEnabled   = false;
let g_encUnlocked  = false;
let g_newPhraseMode    = false;
let g_settingsMode     = false;
let g_settingsPage     = 'folders';
let g_capturingKey     = false;
let g_captureTarget    = null;
let g_dynAppModes      = [];  // [{app, mode}]
let g_fileSettingsFile = null;
let g_fileSettingsCache = {}; // path → {label, metaFields, defaultCat}

const COL_ORDER = [
  { key: 'nr',      label: '#',        sortKey: null,       defaultWidth: 26,   fixed: true },
  { key: 'trigger', label: 'Trigger',  sortKey: 'trigger',  defaultWidth: 200 },
  { key: 'phrase',  label: 'Fras',     sortKey: 'phrase',   defaultWidth: null }, // null = 1fr
  { key: 'cat',     label: 'Kategori', sortKey: 'cat',      defaultWidth: 130 },
  { key: 'tags',    label: 'Taggar',   sortKey: 'tags',     defaultWidth: 90  },
  { key: 'lang',    label: 'Språk',    sortKey: 'lang',     defaultWidth: 75,  defaultHidden: true },
  { key: 'file',    label: 'Fil',      sortKey: 'file',     defaultWidth: 130, defaultHidden: true },
];
let g_colOrder   = [];           // keys in display order (user-draggable); managed by syncColOrder()
function syncColOrder() {
  const allKeys = [...COL_ORDER, ...g_dynamicCols].map(c => c.key);
  const knownSet = new Set(allKeys);
  g_colOrder = g_colOrder.filter(k => knownSet.has(k));   // drop stale
  for (const k of allKeys)
    if (!g_colOrder.includes(k)) g_colOrder.push(k);      // append new
}
function allCols() {
  const known = new Map([...COL_ORDER, ...g_dynamicCols].map(c => [c.key, c]));
  return g_colOrder.map(k => known.get(k)).filter(Boolean);
}
let g_colWidths  = new Map();   // key → width (number or null=1fr)
let g_colVisible = new Set();   // set of visible column keys
let g_sortCol    = null;
let g_sortDir    = 'asc';
let g_colFilters = { trigger: '', phrase: '', cat: '', tags: '', lang: '', file: '' };
let g_dynamicCols = []; // file-specific custom field columns, rebuilt from g_fileSettingsCache
let g_moveSourceId = null;
let g_multiSel     = new Set();  // IDs selected for bulk edit
let g_undoDeletePhrase = null;   // phrase saved before deletion for undo toast
let g_showUndoToast    = false;  // flag: show undo toast on next initData
let g_undoToastTimer   = null;
let _ctxPresetPaths    = [];
let _ctxPhraseIds      = [];   // phrase IDs the active phrase context menu acts on
let _infoToastTimer    = null;
let g_autosave = (() => { try { return localStorage.getItem('expanto_autosave') !== '0'; } catch { return true; } })();
let _autosaveTimer = null;
let _autosaveDirty = false;

// ── Field-navigation accesskeys (Alt+letter) ─────────────────────────────────
const FIELD_AK_DEFAULTS = {
  fTrigger: 't', fApps: 'a', fPhrase: 'f', fCat: 'k',
  fTags: 'g', fLang: 's', fComment: 'o', fNewFile: 'v',
  bCat: 'k', bTagInput: 'g', bLang: 's', bComment: 'o', bFile: 'v',
};
// detail-panel fields vs bulk-panel fields (mutually exclusive, so keys may overlap)
const DETAIL_AK_FIELDS = new Set(['fTrigger','fApps','fPhrase','fCat','fTags','fLang','fComment','fNewFile']);
const BULK_AK_FIELDS   = new Set(['bCat','bTagInput','bLang','bComment','bFile']);
let g_fieldKeys = { ...FIELD_AK_DEFAULTS };
let g_wordlistDlFolder    = '';
let g_wordlistIndexLoaded = false;
let g_packIndexLoaded = false;
try {
  const saved = JSON.parse(localStorage.getItem('expanto_field_keys') || '{}');
  Object.assign(g_fieldKeys, saved);
} catch(_) {}
let g_checkboxMode = false;       // show checkbox column in phrase list
let g_collapsedGroups = new Set(); // collapsed phrase-group values (Phase 2 list grouping)
let g_groupByCol = (() => { try { return localStorage.getItem('expanto_group_col') || null; } catch { return null; } })();
let g_bulkTagMap    = new Map();  // tag → count of selected phrases that have it
let g_bulkTagRemove = new Set();  // tags to remove from all selected
let g_bulkTagAdd    = new Set();  // tags to add to all selected
let g_lastClickIdx = -1;          // phrase list index of last click (for shift-range)
let g_showHiddenFiles = false;
// Include hidden files in the new-phrase file picker. Hidden files are often
// exactly where quick additions go, so they are shown by default (tagged
// "· dold"); the toggle state persists across sessions.
let g_showHiddenInNewFile = (localStorage.getItem('expShowHiddenInPicker') ?? '1') === '1';
let g_newFileSelected     = '';      // last real file chosen in #fNewFile (survives the show/hide toggle)
let g_collapsedFolders = new Set(
  (() => { try { return JSON.parse(localStorage.getItem('collapsedFolders') || '[]'); } catch(_){ return []; } })()
);
let g_newFileFolder = '';
let g_configuredFolders = [];  // [{id, path, enabled}] from receiveSettings
let g_hiddenFolderIds   = new Set();  // folder IDs hidden from file list
let g_usageTimes   = {};      // phraseId → ISO timestamp of last use
let g_recentMode   = 'off';   // 'off' | 'used' | 'edited'
let g_aiSearchMode = false;
let g_aiSearchIds  = new Set();
let g_searchHistory  = [];    // most-recent-last list of submitted search strings
let g_searchHistIdx  = -1;    // -1 = current input; ≥0 = browsing history
let g_searchHistSaved = '';   // saved input when history browsing started

// ── Boot ──────────────────────────────────────────────────────────────────────
window.addEventListener('DOMContentLoaded', () => {
  bindUI();
  applyTheme(g_theme);
  applyFontSize(g_fontSize);
  applyCompactMode(g_compactMode);
  applyPreviewLines(g_previewLines);
  applySidebarCollapsed(g_sidebarCollapsed);
  applySidebarMode(g_sidebarMode);
  _applySectionVisibility();
  applyTranslations();
  postToAhk({ action: 'ready', lang: g_lang });
});

// ── AHK → JS entry points ────────────────────────────────────────────────────
window.initData = function(data, autoSelectId) {
  g_phrases    = data.phrases    || [];
  g_usageTimes = data.usageTimes || {};
  populateSidebar();
  applyFilter();
  if (autoSelectId) selectPhrase(autoSelectId);
  postToAhk({ action: 'getFiles' });
  postToAhk({ action: 'getSettings' });
  postToAhk({ action: 'getGeneralSettings' });
  if (g_showUndoToast && g_undoDeletePhrase) {
    g_showUndoToast = false;
    showUndoDeleteToast(g_undoDeletePhrase);
  }
};

function _isFileHidden(f) {
  return f.hidden !== undefined ? !!f.hidden : !!g_fileSettingsCache[f.path]?.hidden;
}

// ── New-phrase file picker ───────────────────────────────────────────────────
// A custom dropdown that mirrors the left-hand file list: files grouped by folder
// (folder order, then alphabetical), folders expand/collapse in sync with that list
// (shared g_collapsedFolders), and hidden files are excluded until revealed. The real
// value lives in the hidden <input id="fNewFile"> so the rest of the code keeps reading
// `#fNewFile`.value as the chosen path.
let g_fpHighlight = -1;   // keyboard-nav highlight: index into the rendered file rows

function _fileCountMap() {
  const m = {};
  for (const p of g_phrases) m[p.file] = (m[p.file] || 0) + 1;
  return m;
}

function _fileLabel(path) {
  if (!path) return '';
  return g_fileSettingsCache[path]?.label
    || g_files.find(f => f.path === path)?.name
    || path.split(/[\\/]/).pop() || path;
}

function _defaultNewFilePath() {
  const sorted = _sortTargetFiles(g_files);
  return (sorted.find(f => !_isFileHidden(f)) || sorted[0])?.path || '';
}

// Set the picker's selected file: updates the hidden input (#fNewFile, the source of
// truth read elsewhere) and the visible button label. Unless `silent`, also runs the
// per-file side effects (defaults + suggestions) the old <select> change handler did.
function setNewFile(path, silent) {
  const input = document.getElementById('fNewFile');
  if (!input) return;
  input.value = path || '';
  if (path) g_newFileSelected = path;
  if (path && !silent) localStorage.setItem('expLastNewFile', path);
  const disp = document.getElementById('fNewFileBtn');
  if (disp)
    disp.value = path
      ? (_fileLabel(path) + (_isFileHidden({ path }) ? ' · ' + T('newfile.hiddenTag') : ''))
      : '';
  _updateAiAutoRow(path);
  if (!silent && g_newPhraseMode) {
    _applyFileDefaults(path);
    updateNewPhraseSuggestions(path);
  }
}

// Encrypted files are never sent to the AI — reflect that in the quick-add
// AI checkbox whenever the target file changes.
function _updateAiAutoRow(path) {
  const row = document.getElementById('aiAutoRow');
  const cb  = document.getElementById('fAiAuto');
  if (!row || !cb) return;
  const enc = (path || '').toLowerCase().endsWith('.enc');
  cb.disabled = enc;
  row.classList.toggle('ai-auto-disabled', enc);
  row.title = enc ? T('newfile.aiAuto.enc') : T('newfile.aiAuto.tip');
}

function renderFilePickerMenu() {
  const menu = document.getElementById('fNewFileMenu');
  if (!menu) return;
  menu.innerHTML = '';
  g_fpHighlight = -1;
  const counts   = _fileCountMap();
  const selected = document.getElementById('fNewFile')?.value || '';
  const hiddenTotal = g_files.reduce((n, f) => n + (_isFileHidden(f) ? 1 : 0), 0);

  // Visible files: non-hidden, or all when revealing, plus the current selection.
  const shown = _sortTargetFiles(g_files).filter(f =>
    !_isFileHidden(f) || g_showHiddenInNewFile || f.path === selected);

  // Group by folder, preserving the folder-then-alpha order from _sortTargetFiles.
  const groups = [], byId = {};
  for (const f of shown) {
    const fid = f.folder || '';
    if (!byId[fid]) {
      byId[fid] = { fid, label: (f.folderPath || '').split(/[\\/]/).pop() || T('newfile.noFolder'), files: [] };
      groups.push(byId[fid]);
    }
    byId[fid].files.push(f);
  }
  const multiFolder = groups.length > 1;

  if (!shown.length) {
    const empty = document.createElement('div');
    empty.className = 'fp-empty';
    empty.textContent = T('newfile.empty');
    menu.appendChild(empty);
  }

  for (const grp of groups) {
    const collapsed = multiFolder && g_collapsedFolders.has(grp.fid);
    if (multiFolder) {
      const hdr = document.createElement('div');
      hdr.className = 'fp-folder';
      hdr.innerHTML =
        `<span class="fp-arrow">${collapsed ? '▸' : '▾'}</span>` +
        `<span class="fp-folder-name" title="${escHtml(grp.label)}">${escHtml(grp.label)}</span>`;
      hdr.addEventListener('click', () => {
        if (g_collapsedFolders.has(grp.fid)) g_collapsedFolders.delete(grp.fid);
        else                                 g_collapsedFolders.add(grp.fid);
        try { localStorage.setItem('collapsedFolders', JSON.stringify([...g_collapsedFolders])); } catch(_) {}
        renderFilePickerMenu();   // refresh the picker
        populateSidebar();        // keep the left-hand list in sync
      });
      menu.appendChild(hdr);
    }
    if (collapsed) continue;
    for (const f of grp.files) {
      const row = document.createElement('div');
      row.className = 'fp-file' + (multiFolder ? ' fp-child' : '')
        + (f.path === selected ? ' selected' : '')
        + (_isFileHidden(f) ? ' file-hidden' : '');
      row.dataset.path = f.path;
      row.innerHTML =
        `<span class="fp-file-name" title="${escHtml(f.path)}">${escHtml(_fileLabel(f.path))}</span>` +
        `<span class="fp-file-count">${counts[f.path] || 0}</span>`;
      row.addEventListener('click', () => {
        setNewFile(f.path, false); closeFilePickerMenu();
        document.getElementById('fTrigger')?.focus();   // reset button focus so Alt+V reopens
      });
      menu.appendChild(row);
    }
  }

  if (hiddenTotal > 0) {
    const tog = document.createElement('div');
    tog.className = 'fp-toggle-hidden';
    tog.textContent = g_showHiddenInNewFile ? T('newfile.hideHidden') : T('newfile.showHidden', hiddenTotal);
    tog.addEventListener('click', () => {
      g_showHiddenInNewFile = !g_showHiddenInNewFile;
      localStorage.setItem('expShowHiddenInPicker', g_showHiddenInNewFile ? '1' : '0');
      renderFilePickerMenu();
    });
    menu.appendChild(tog);
  }
}

function openFilePickerMenu() {
  const menu = document.getElementById('fNewFileMenu');
  const btn  = document.getElementById('fNewFileBtn');
  if (!menu || !btn) return;
  renderFilePickerMenu();
  menu.classList.remove('hidden');
  btn.setAttribute('aria-expanded', 'true');
  _positionDropdown(menu, btn.getBoundingClientRect());
  const rows = [...menu.querySelectorAll('.fp-file')];
  const selPath = document.getElementById('fNewFile')?.value;
  g_fpHighlight = Math.max(0, rows.findIndex(r => r.dataset.path === selPath));
  _fpApplyHighlight();
}

function closeFilePickerMenu() {
  const menu = document.getElementById('fNewFileMenu');
  const btn  = document.getElementById('fNewFileBtn');
  if (menu) menu.classList.add('hidden');
  if (btn)  btn.setAttribute('aria-expanded', 'false');
  g_fpHighlight = -1;
}

// Re-sync the button label with the current value; re-render the menu if it's open.
function refreshFilePicker() {
  const input = document.getElementById('fNewFile');
  if (input) setNewFile(input.value, true);
  const menu = document.getElementById('fNewFileMenu');
  if (menu && !menu.classList.contains('hidden')) renderFilePickerMenu();
}

function _fpApplyHighlight() {
  const rows = [...document.querySelectorAll('#fNewFileMenu .fp-file')];
  rows.forEach((r, i) => r.classList.toggle('fp-active', i === g_fpHighlight));
  if (rows[g_fpHighlight]) rows[g_fpHighlight].scrollIntoView({ block: 'nearest' });
}

function _fpMoveHighlight(dir) {
  const rows = [...document.querySelectorAll('#fNewFileMenu .fp-file')];
  if (!rows.length) return;
  g_fpHighlight = (g_fpHighlight + dir + rows.length) % rows.length;
  _fpApplyHighlight();
}

function _fpChooseHighlight() {
  const row = [...document.querySelectorAll('#fNewFileMenu .fp-file')][g_fpHighlight];
  if (row) {
    setNewFile(row.dataset.path, false); closeFilePickerMenu();
    document.getElementById('fTrigger')?.focus();
  }
}

window.receiveFiles = function(files) {
  g_files = files || [];
  g_fileSettingsMap = {};
  g_files.forEach(f => {
    g_fileSettingsMap[f.path] = { hsOn: f.hsOn !== 0, hintTOn: f.hintTOn !== 0, hintPOn: f.hintPOn !== 0 };
    // Cache per-file settings that came bundled in the files array
    if (f.label !== undefined || f.metaFields !== undefined || f.defaultCat !== undefined || f.hidden !== undefined) {
      g_fileSettingsCache[f.path] = {
        label:      f.label      || '',
        metaFields: f.metaFields || '',
        defaultCat: f.defaultCat || '',
        groupField:    f.groupField    || '',
        titleFields:   f.titleFields   || '',
        titlePattern:  f.titlePattern  || '',
        sharedFields:  f.sharedFields  || '',
        hidden:     !!f.hidden,
      };
    }
  });
  refreshFilePicker();
  rebuildDynamicCols();
  renderListHeader();
  renderListFilters();
  applyColWidthsCSS();
  populateSidebar();
  applyFilter();
};

window.receiveSettings = function(data) {
  g_configuredFolders = data.folders || [];
  g_hiddenFolderIds   = new Set(data.hiddenFolders || []);
  renderFolderList(g_configuredFolders);
  populateSidebar();
};

window.receiveAiSettings = function(data) {
  g_aiEnabled  = !!data.enabled;
  g_llmEnabled = !!data.llm_enabled;
  const el = id => document.getElementById(id);
  el('aiEnabled').checked   = g_aiEnabled;
  el('aiApiKey').value      = data.api_key  || '';
  el('aiAutoTag').checked   = !!data.auto_tag;
  // the quick-add panel mirror of the auto_tag setting
  const aa = el('fAiAuto');
  if (aa) aa.checked = !!data.auto_tag;
  el('aiAutoRow')?.classList.toggle('hidden', !g_aiEnabled);
  el('aiExclude').value     = data.exclude  || '';
  el('aiUsage').textContent = data.usage    || '';
  const modelSel = el('aiModel');
  if (data.model) {
    for (const opt of modelSel.options)
      if (opt.value === data.model) { opt.selected = true; break; }
  }
  // Local LLM fields
  el('llmEnabled').checked  = g_llmEnabled;
  el('llmEndpoint').value   = data.llm_endpoint || 'http://localhost:11434/v1';
  el('llmModel').value      = data.llm_model    || '';
  el('llmApiKey').value     = data.llm_api_key  || '';
  _updateLlmModelList(data.llm_models || [], data.llm_model || '');
  _updateLlmStatus(data.llm_online ? (data.llm_models || []).length : -1);
  const aiSearchBtn = document.getElementById('btnAiSearch');
  if (aiSearchBtn) aiSearchBtn.classList.toggle('hidden', !g_aiEnabled && !g_llmEnabled);
};

function _updateLlmModelList(models, selected) {
  const list = document.getElementById('llmModelList');
  if (!list) return;
  list.innerHTML = '';
  if (!models.length) { list.classList.add('hidden'); return; }
  models.forEach(m => {
    const div = document.createElement('div');
    div.className = 'llm-model-item' + (m === selected ? ' active' : '');
    div.textContent = m;
    div.addEventListener('click', () => {
      document.getElementById('llmModel').value = m;
      list.querySelectorAll('.llm-model-item').forEach(x => x.classList.remove('active'));
      div.classList.add('active');
    });
    list.appendChild(div);
  });
  list.classList.remove('hidden');
}

function _updateLlmStatus(modelCount) {
  const el = document.getElementById('llmStatus');
  if (!el) return;
  if (modelCount < 0) {
    el.textContent = T('ai.llm.offline');
    el.className = 'sp-status llm-status-offline';
  } else {
    el.textContent = T('ai.llm.online', modelCount);
    el.className = 'sp-status llm-status-online';
  }
  el.classList.remove('hidden');
}

window.receiveAiSuggestion = function(s) {
  const btn = document.getElementById('btnAiSuggest');
  if (btn) { btn.disabled = false; btn.textContent = '✨ AI'; }
  const live = !!s.live;
  if (live) {
    _setAiAutoBusy(false);
    // Stale or out-of-context: user kept typing, closed the panel or left new mode
    if (s.error || !g_newPhraseMode || (s.seq && s.seq !== _aiLiveSeq)) return;
  } else if (s.error) { alert('AI: ' + s.error); return; }
  // live mode never overwrites what the user typed by hand (aiSrc === 'user');
  // file defaults and earlier AI fills are fair game
  const put = (id, val) => {
    const el = document.getElementById(id);
    if (!el || !val) return;
    if (live && el.value.trim() && el.dataset.aiSrc === 'user') return;
    el.value = val;
    el.dataset.aiSrc = 'ai';
  };
  put('fCat', s.cat); put('fTags', s.tags); put('fComment', s.comment); put('fLang', s.lang);
};

window.receiveAiSearchResult = function(data) {
  const btn = document.getElementById('btnAiSearch');
  if (btn) { btn.disabled = false; }
  if (data.error) { alert('AI: ' + data.error); if (btn) btn.textContent = T('aiSearch.btn'); return; }
  const ids = data.ids || [];
  g_aiSearchIds = new Set(ids);
  g_aiSearchMode = ids.length > 0;
  if (btn) {
    btn.textContent = g_aiSearchMode ? T('aiSearch.clear') : T('aiSearch.btn');
    btn.classList.toggle('active', g_aiSearchMode);
    if (g_aiSearchMode) btn.removeAttribute('data-i18n');
    else btn.dataset.i18n = 'aiSearch.btn';
  }
  if (!g_aiSearchMode) alert(T('aiSearch.noMatch'));
  applyFilter();
};

function applySpellCheck(on) {
  const spellFields = ['fPhrase', 'fComment', 'fsLabel'];
  spellFields.forEach(id => {
    const el = document.getElementById(id);
    if (el) el.spellcheck = on;
  });
  document.querySelectorAll('.alt-phrase-input').forEach(el => { el.spellcheck = on; });
}

window.receiveDictSettings = function(data) {
  const on = data.spellEnabled !== 0;
  const cb = document.getElementById('spellEnabled');
  if (cb) cb.checked = on;
  applySpellCheck(on);
  renderDictFolderList(data.paths || []);
  const st = document.getElementById('dictStatus');
  if (st) st.textContent = data.status || '';
  const cbComp = document.getElementById('compoundEnabled');
  if (cbComp) cbComp.checked = !!data.compoundEnabled;
  const ml = document.getElementById('compoundMinLen');
  if (ml) ml.value = data.compoundMinLen || 12;
};

window.receiveHotkeySettings = function(data) {
  const set = (id, val) => { const el = document.getElementById(id); if (el) el.value = val || ''; };
  const chk = (id, val) => { const el = document.getElementById(id); if (el) el.checked = (val == 1); };
  set('hkOpenGui',    data.OpenGui);
  set('hkMarkWord',   data.MarkWord);
  set('hkStepNext',   data.StepNext);
  set('hkUndo',       data.Undo);
  set('hkLastFired',  data.LastFired);
  chk('hkCapsCap',    data.CapsCapture);
  set('hkNew',        data.New);
  set('hkUpdate',     data.Update);
  set('hkDelete',     data.Delete);
  set('hkFiltFile',   data.FilterFile);
  set('hkFiltCat',    data.FilterCat);
  set('hkFiltTag',    data.FilterTag);
  set('hkAssignCat',  data.AssignCat);
  set('hkAssignTag',  data.AssignTag);
  set('hkSwitchField',data.SwitchField);
  set('hkAiSuggest',  data.AiSuggest);
  set('hkLayout',     data.Layout);
  set('hkOnTop',      data.OnTop);
  set('hkMoveFile',   data.MoveFile);
  set('hkSettings',   data.Settings);
  set('hkEditFile',   data.EditFile);
  set('hkLastEdited', data.LastEdited);
  set('hkDupes',      data.Dupes);
  set('hkPanel',      data.Panel);
  set('hkInsert',     data.Insert);
  set('hkInsertStep', data.InsertStep);
  set('qkFiltFile',   data.QkFilterFile);
  set('qkFiltCat',    data.QkFilterCat);
  set('qkFiltTag',    data.QkFilterTag);
  set('qkMoveFile',   data.QkMoveFile);
  set('qkAssignCat',  data.QkAssignCat);
  set('qkAssignTag',  data.QkAssignTag);
  // Populate field-nav key inputs from localStorage
  const akMap = { fTrigger:'akFTrigger', fApps:'akFApps', fPhrase:'akFPhrase', fCat:'akFCat',
                  fTags:'akFTags', fLang:'akFLang', fComment:'akFComment', bFile:'akBFile' };
  Object.entries(akMap).forEach(([fid, inpId]) => set(inpId, g_fieldKeys[fid] || FIELD_AK_DEFAULTS[fid]));
};

window.receivePopupSettings = function(data) {
  const set = (id, val) => { const el = document.getElementById(id); if (el) el.value = val ?? ''; };
  const chk = (id, val) => { const el = document.getElementById(id); if (el) el.checked = (val == 1); };
  chk('popupEnabled',  data.enabled);
  chk('popupFuzzy',    data.fuzzy);
  set('popupChars',    data.chars    ?? 2);
  set('popupTimeout',  data.timeout  ?? 5);
  set('popupInsert',   data.insertKey ?? 'Tab');
  set('popupUp',       data.upKey    ?? 'Up');
  set('popupDown',     data.downKey  ?? 'Down');
  set('popupNumKey',   data.numKey   ?? '');
};

window.receiveFileSettings = function(data) {
  const path = data.path || '';
  const prev = g_fileSettingsCache[path] || {};
  g_fileSettingsCache[path] = {
    label:      data.label      || '',
    defaultCat: data.defaultCat || '',
    metaFields: data.metaFields || '',
    groupField:    data.groupField    || '',
    titleFields:   data.titleFields   || '',
    titlePattern:  data.titlePattern  || '',
    sharedFields:  data.sharedFields  || '',
    hidden:     data.hidden !== undefined ? !!data.hidden : (prev.hidden || false),
  };
  // Rebuild dynamic columns in case metaFields changed
  rebuildDynamicCols();
  renderListHeader();
  renderListFilters();
  applyColWidthsCSS();
  // Update sidebar label if it changed
  populateSidebar();
  // Refresh the new-phrase file picker (label and/or hidden state may have changed)
  refreshFilePicker();
  // Only populate form fields if this panel is open for that file
  if (g_fileSettingsFile !== path) return;
  document.getElementById('fsLabel').value       = data.label      || '';
  document.getElementById('fsDefaultCat').value  = data.defaultCat || '';
  document.getElementById('fsMetaFields').value  = data.metaFields || '';
  _fsSetCouplingFields(data);
  updateFsMetaPreview();
};

let _fsSharedVals = {};   // groupFieldName → comma-sep. shared-fields string

function _fsSetCouplingFields(d) {
  document.getElementById('fsGroupField').value   = d.groupField   || '';
  document.getElementById('fsTitleFields').value  = d.titleFields  || '';
  document.getElementById('fsTitlePattern').value = d.titlePattern || '';
  _fsSharedVals = {};
  (d.sharedFields || '').split(';').forEach(part => {
    const eq = part.indexOf('=');
    if (eq < 0) return;
    const g = part.slice(0, eq).trim();
    if (g) _fsSharedVals[g] = part.slice(eq + 1).trim();
  });
  _fsRenderSharedInputs();
}

// One "Delade fält för <group>" input per entry typed in "Gruppera på".
function _fsRenderSharedInputs() {
  const cont = document.getElementById('fsSharedContainer');
  if (!cont) return;
  cont.querySelectorAll('.fs-shared-input').forEach(inp => { _fsSharedVals[inp.dataset.group] = inp.value; });
  const groups = document.getElementById('fsGroupField').value.split(',').map(s => s.trim()).filter(Boolean);
  cont.innerHTML = '';
  groups.forEach(g => {
    const div = document.createElement('div');
    div.className = 'field-group';
    const label = document.createElement('label');
    label.innerHTML = `Delade fält för <b>${escHtml(g)}</b> <span style="font-weight:400;text-transform:none">(komma-sep.)</span>`;
    const inp = document.createElement('input');
    inp.type = 'text';
    inp.className = 'field-input fs-shared-input';
    inp.spellcheck = false;
    inp.dataset.group = g;
    inp.value = _fsSharedVals[g] || '';
    inp.placeholder = `fält gemensamma för alla med samma ${g}`;
    div.appendChild(label);
    div.appendChild(inp);
    cont.appendChild(div);
  });
}

// Collect the per-group inputs back into the "group=f1,f2;group2=f3" storage form.
function _fsCollectSharedFields() {
  const cont = document.getElementById('fsSharedContainer');
  if (cont) cont.querySelectorAll('.fs-shared-input').forEach(inp => { _fsSharedVals[inp.dataset.group] = inp.value; });
  const groups = document.getElementById('fsGroupField').value.split(',').map(s => s.trim()).filter(Boolean);
  return groups
    .map(g => [g, (_fsSharedVals[g] || '').split(',').map(s => s.trim()).filter(Boolean).join(',')])
    .filter(([, fields]) => fields)
    .map(([g, fields]) => `${g}=${fields}`)
    .join(';');
}

window.receiveDynamicSettings = function(data) {
  const mode = document.getElementById('dynDefaultMode');
  if (mode) mode.value = data.defaultMode || 'auto';
  const labels = document.getElementById('dynStepLabels');
  if (labels) labels.value = data.stepLabels || '';
  const pm = document.getElementById('pasteMode');
  if (pm) { pm.value = data.pasteMode || 'auto'; _updatePasteMinLenVis(); }
  const pml = document.getElementById('pasteMinLen');
  if (pml) pml.value = data.pasteMinLen ?? 30;
  g_dynAppModes = data.appModes || [];
  renderDynAppGrid();
};

function _updatePasteMinLenVis() {
  const row = document.getElementById('pasteMinLenRow');
  if (row) row.style.display = (document.getElementById('pasteMode')?.value === 'auto') ? '' : 'none';
}

window.receiveEncStatus = function(data) {
  g_encUnlocked = !!data.unlocked;
  const lockedCnt = data.encLocked || 0;
  const status = document.getElementById('encStatus');
  if (status) {
    if (data.unlocked)      status.textContent = T('enc.unlocked');
    else if (lockedCnt > 0) status.textContent = T('enc.locked', lockedCnt);
    else                    status.textContent = T('enc.none');
  }
  const toggle = document.getElementById('btnEncToggle');
  if (toggle) toggle.textContent = data.unlocked ? T('btn.lockSession') : T('btn.unlock');
  const lockBtn = document.getElementById('btnEncLock');
  if (lockBtn) {
    lockBtn.classList.toggle('hidden', lockedCnt === 0);
    lockBtn.title = T('enc.lockBtn', lockedCnt);
  }
  populateSidebar();
};

window.showFirstRun = function(data) {
  const bundles = data.bundles || [];
  const defaultFolder = data.defaultFolder || '';
  const box = document.getElementById('frBundles');
  box.innerHTML = bundles.map(b =>
    `<label class="fr-bundle-row">
      <input type="checkbox" class="fr-bundle-chk" data-files="${escHtml(b.files)}" ${b.isDefault ? 'checked' : ''}>
      <span>${escHtml(b.label)}</span>
    </label>`
  ).join('');
  document.getElementById('frFolderPath').value = defaultFolder;
  document.getElementById('firstRunModal').classList.remove('hidden');
  // The ini bundles are just the curated defaults — list every other .txt in
  // the wordlists repo too, fetched live (silently skipped when offline)
  const covered = new Set(bundles.flatMap(b => String(b.files || '').split('|').map(s => s.trim()).filter(Boolean)));
  fetch('https://api.github.com/repos/ibst1/wordlists/git/trees/HEAD?recursive=1')
    .then(r => r.json())
    .then(j => {
      const extra = (j.tree || []).map(t => t.path)
        .filter(p => p.endsWith('.txt') && !covered.has(p)).sort();
      if (!extra.length) return;
      const hdr = document.createElement('div');
      hdr.className = 'fr-section-label';
      hdr.style.marginTop = '8px';
      hdr.textContent = T('fr.more');
      box.appendChild(hdr);
      extra.forEach(p => {
        const row = document.createElement('label');
        row.className = 'fr-bundle-row';
        row.innerHTML = `<input type="checkbox" class="fr-bundle-chk" data-files="${escHtml(p)}"> <span>${escHtml(p.replace(/\.txt$/, ''))}</span>`;
        box.appendChild(row);
      });
    })
    .catch(() => {});
  // Starter phrase packs from the ahk-phrases repo (also skipped when offline)
  fetch('https://api.github.com/repos/ibst1/ahk-phrases/git/trees/HEAD?recursive=1')
    .then(r => r.json())
    .then(j => {
      const packs = _groupPhrasePacks(j.tree || []);
      if (!packs.length) return;
      const hdr = document.createElement('div');
      hdr.className = 'fr-section-label';
      hdr.style.marginTop = '8px';
      hdr.textContent = T('fr.packs');
      box.appendChild(hdr);
      packs.forEach(p => {
        const row = document.createElement('label');
        row.className = 'fr-bundle-row';
        row.innerHTML = `<input type="checkbox" class="fr-pack-chk" data-pack="${escHtml(p.name)}"`
          + ` data-files="${escHtml(p.files.join('|'))}"> <span>${escHtml(p.name)} (${escHtml(T('packs.files', p.files.length))})</span>`;
        box.appendChild(row);
      });
    })
    .catch(() => {});
};

window.receiveFirstRunFolder = function(path) {
  document.getElementById('frFolderPath').value = path;
};

window.closeFirstRun = function() {
  document.getElementById('firstRunModal').classList.add('hidden');
};

window.receiveWordlistFolder = function(path) {
  g_wordlistDlFolder = path;
  const lbl = document.getElementById('wordlistDlFolderLabel');
  if (lbl) lbl.textContent = path || T('spell.noFolder');
  _updateDownloadBtn();
};

window.wordlistDownloadProgress = function(done, total, file) {
  const st = document.getElementById('wordlistDlStatus');
  if (st) st.textContent = T('spell.dlProgress', done, total, file);
};

window.wordlistDownloadDone = function(folder) {
  const st = document.getElementById('wordlistDlStatus');
  if (st) st.textContent = `Klart! Ordlistemapp tillagd: ${folder}`;
  const btn = document.getElementById('btnDownloadWordlists');
  if (btn) btn.disabled = false;
  postToAhk({ action: 'getDictSettings' });
};

function activateSidebarTab(panelId) {
  const btn = document.querySelector(`.sidebar-tabs button[data-panel="${panelId}"]`);
  if (btn) btn.click();
}

function ensureDetailOpen() {
  if (!g_selId && !g_newPhraseMode) openNewPhrase();
}

// ── Field-key helpers ─────────────────────────────────────────────────────────
function _injectUnderscore(text, key) {
  // Wrap the first occurrence of `key` (case-insensitive) in <u>; append badge if absent
  if (!key) return escHtml(text);
  const idx = text.toLowerCase().indexOf(key.toLowerCase());
  if (idx >= 0)
    return escHtml(text.slice(0, idx)) + `<u>${escHtml(text[idx])}</u>` + escHtml(text.slice(idx + 1));
  return escHtml(text) + ` <span class="ak-ext">Alt+${escHtml(key.toUpperCase())}</span>`;
}

function applyFieldKeys() {
  document.querySelectorAll('[data-ak-for]').forEach(label => {
    const fieldId = label.dataset.akFor;
    const key     = g_fieldKeys[fieldId] || '';
    // The file picker's accesskey must live on its visible button — a browser accesskey
    // can only activate a focusable, on-screen element, not the hidden #fNewFile input.
    // Native Alt+<key> then clicks the button, which opens the tree.
    const input   = document.getElementById(fieldId === 'fNewFile' ? 'fNewFileBtn' : fieldId);
    if (input) {
      if (key) input.setAttribute('accesskey', key);
      else     input.removeAttribute('accesskey');
    }
    // Find the text target: a [data-ak-text] child, or the label itself if it has simple text
    const textEl = label.querySelector('[data-ak-text]') || (label.querySelector('input,select') ? null : label);
    if (!textEl) return;
    // Use current textContent (already translated by applyTranslations)
    const plain = textEl.textContent.trim();
    textEl.innerHTML = _injectUnderscore(plain, key);
  });
}

// ── Word list-marker cleanup on paste ────────────────────────────────────────
// Word copies bulleted/numbered list items as "<marker><TAB><text>" (e.g. "•\ttext",
// "1.\ttext", "a)\ttext"). Strip that leading marker + tab per line. The tab (or a run
// of ≥2 spaces) is required, which keeps ordinary text like "1. Intro" (single space) safe.
const _LIST_MARKER_RE =
  /^[ \t]*(?:[•◦▪‣·∙o*‒–—⁃-]|\(?\d{1,3}[.)]|\(?[ivxlcdm]{1,7}[.)]|\(?[a-z][.)])(?:\t+| {2,})/i;

function _stripListMarkers(text) {
  if (!text || (text.indexOf('\t') === -1 && !/ {2,}/.test(text))) return text;
  return text.split('\n').map(line => line.replace(_LIST_MARKER_RE, '')).join('\n');
}

function _onListPaste(e) {
  const cd = e.clipboardData || window.clipboardData;
  if (!cd) return;
  const raw = cd.getData('text/plain');
  if (!raw) return;
  const cleaned = _stripListMarkers(raw);
  if (cleaned === raw) return;   // nothing to strip → let the browser paste normally
  e.preventDefault();
  const el = e.target;
  let ok = false;
  try { ok = document.execCommand('insertText', false, cleaned); } catch (_) {}
  if (!ok) {
    const s = el.selectionStart ?? el.value.length, en = el.selectionEnd ?? el.value.length;
    el.value = el.value.slice(0, s) + cleaned + el.value.slice(en);
    el.selectionStart = el.selectionEnd = s + cleaned.length;
    el.dispatchEvent(new Event('input', { bubbles: true }));
  }
}

function swapTriggerPhrase() {
  if (!g_selId && !g_newPhraseMode) return;
  const trigEl = document.getElementById('fTrigger');
  const phraEl = document.getElementById('fPhrase');
  if (!trigEl || !phraEl) return;
  const tmp = trigEl.value;
  trigEl.value = phraEl.value;
  phraEl.value = tmp;
  trigEl.dispatchEvent(new Event('input', { bubbles: true }));
  phraEl.dispatchEvent(new Event('input', { bubbles: true }));
  _scheduleAutosave();   // the non-bubbling events above never reached the detailBody autosave listener
}

window.handleGuiHotkey = function(name) {
  switch (name) {
    case 'New':        openNewPhrase(); break;
    case 'Update':     saveEdited(); break;
    case 'Delete':     deleteSelected(); break;
    case 'FilterFile': activateSidebarTab('panelFiles'); break;
    case 'FilterCat':  activateSidebarTab('panelCats'); break;
    case 'FilterTag':  activateSidebarTab('panelTags'); break;
    case 'AssignCat':  ensureDetailOpen(); setTimeout(() => document.getElementById('fCat')?.focus(), 50); break;
    case 'AssignTag':  ensureDetailOpen(); setTimeout(() => document.getElementById('fTags')?.focus(), 50); break;
    case 'FilePicker':
      // Alt+V, driven from AHK (WebView accesskey can't open this custom control reliably)
      if (g_newPhraseMode) {
        document.getElementById('fNewFileBtn')?.focus();
        openFilePickerMenu();
      } else if (!document.getElementById('bulkPanel').classList.contains('hidden')) {
        const bf = document.getElementById('bFile');
        if (bf) { bf.focus(); try { bf.showPicker(); } catch (_) {} }
      }
      break;
    case 'SwitchField':  swapTriggerPhrase(); break;
    case 'Insert':       if (g_selId) postToAhk({ action: 'directInsert',     id: g_selId }); break;
    case 'InsertStep':   if (g_selId) postToAhk({ action: 'directInsertStep', id: g_selId }); break;
    case 'AiSuggest':    aiSuggestForSelected(); break;
    case 'OnTop':      postToAhk({ action: 'toggleOnTop' }); break;
    case 'MoveFile':   document.getElementById('btnDuplicateMore')?.click(); break;
    case 'Settings':   g_settingsMode ? leaveSettings() : enterSettings(g_settingsPage); break;
    case 'EditFile': {
      const p = g_phrases.find(x => x.id === g_selId);
      const file = p?.file || [...g_selFiles][0] || '';
      if (file) postToAhk({ action: 'editFile', path: file });
      break;
    }
    case 'Panel':
      if (!document.getElementById('detailPanel').classList.contains('hidden')) closeDetail();
      else if (g_selId) selectPhrase(g_selId);
      break;
  }
};

window.receiveOnTop = function(on) {
  // Visual feedback: show a brief indicator on the window title or a toast
  const el = document.getElementById('toolbar');
  if (!el) return;
  el.title = on ? T('onTop.on') : '';
};

window.receiveMarkedWord = function(word) {
  if (!g_newPhraseMode) openNewPhrase();
  const trigger = document.getElementById('fTrigger');
  const phrase  = document.getElementById('fPhrase');
  const trim    = document.getElementById('phraseTrim');
  if (trigger) trigger.value = word;
  if (phrase)  phrase.value  = word;
  if (trim)    trim.checked  = true;
  if (phrase)  phrase.focus();
};

window.openForSearch = function() {
  const el = document.getElementById('searchBox');
  if (el) { el.focus(); el.select(); }
};

window.newFileCreated = function(_path) {
  closeNewFileDialog();
};

window.newFileError = function(msg) {
  const err = document.getElementById('nfError');
  err.textContent = msg;
  err.classList.remove('hidden');
};

window.updateAiUsage = function(text) {
  document.getElementById('aiUsage').textContent = text;
};

window.setAiBatchStatus = function(done, total) {
  const btn = document.getElementById('btnAiBatchAll');
  if (!btn) return;
  btn.textContent = (done && total) ? T('ai.batch.progress', done, total) : T('ai.batch.idle');
  btn.disabled = done > 0 && done < total;
};

window.updatePhrase = function(hs) {
  const idx = g_phrases.findIndex(p => p.id === hs.id);
  if (idx >= 0) g_phrases[idx] = hs; else g_phrases.push(hs);
  populateSidebar();
  applyFilter();
  selectPhrase(hs.id);
};

window.removePhrase = function(id) {
  g_phrases = g_phrases.filter(p => p.id !== id);
  if (g_selId === id) closeDetail();
  populateSidebar();
  applyFilter();
};

// ── JS → AHK ─────────────────────────────────────────────────────────────────
function postToAhk(msg) {
  if (window.chrome && window.chrome.webview)
    window.chrome.webview.postMessage(msg);
}

// ── UI binding ───────────────────────────────────────────────────────────────
function bindUI() {
  document.getElementById('searchBox').addEventListener('input', () => {
    g_searchHistIdx = -1;   // typing always breaks history navigation
    applyFilter();
  });
  document.getElementById('clearSearch').addEventListener('click', () => {
    document.getElementById('searchBox').value = '';
    applyFilter();
  });
  document.getElementById('chkFuzzy').addEventListener('change', e => {
    g_fuzzy = e.target.checked;
    applyFilter();
  });

  document.querySelectorAll('input[name="genTheme"]').forEach(radio => {
    radio.addEventListener('change', e => { if (e.target.checked) applyTheme(e.target.value); });
  });
  document.querySelectorAll('input[name="genLang"]').forEach(radio => {
    radio.addEventListener('change', e => { if (e.target.checked) setLang(e.target.value); });
  });
  const chkStartMin = document.getElementById('genStartMinimized');
  if (chkStartMin) chkStartMin.addEventListener('change', saveGeneralSettings);
  document.querySelectorAll('input[name="genSidebar"]').forEach(r => {
    r.addEventListener('change', e => { if (e.target.checked) applySidebarMode(e.target.value); });
  });
  ['files','cats','tags','lang'].forEach(sec => {
    const chk = document.getElementById('navSec_' + sec);
    if (!chk) return;
    chk.checked = !!g_navSections[sec];
    chk.addEventListener('change', () => {
      const anyOtherChecked = ['files','cats','tags','lang'].some(s => s !== sec && g_navSections[s]);
      if (!chk.checked && !anyOtherChecked) { chk.checked = true; return; }
      g_navSections[sec] = chk.checked;
      _applySectionVisibility();
    });
  });
  document.querySelectorAll('input[name="genFontSize"]').forEach(r => {
    r.addEventListener('change', e => { if (e.target.checked) applyFontSize(parseInt(e.target.value)); });
  });
  document.getElementById('btnCompact').addEventListener('click', () => applyCompactMode(!g_compactMode));
  document.getElementById('previewLinesSlider')?.addEventListener('input', e => applyPreviewLines(e.target.value));
  document.getElementById('btnToggleSidebar').addEventListener('click', () => applySidebarCollapsed(!g_sidebarCollapsed));
  // Clicking the narrow expand-strip when sidebar is collapsed also expands it
  document.getElementById('sidebarResizeHandle').addEventListener('click', e => {
    if (g_sidebarCollapsed) { e.stopPropagation(); applySidebarCollapsed(false); }
  });
  document.getElementById('sidebarResizeHandle').addEventListener('dblclick', e => {
    e.stopPropagation();
    e.preventDefault();
    applySidebarCollapsed(!g_sidebarCollapsed);
  });

  document.getElementById('btnRecentToggle').addEventListener('click', () => {
    g_recentMode = g_recentMode === 'off' ? 'used' : g_recentMode === 'used' ? 'edited' : 'off';
    const btn = document.getElementById('btnRecentToggle');
    btn.textContent = T('recent.' + g_recentMode);
    btn.classList.toggle('active', g_recentMode !== 'off');
    applyFilter();
  });
  document.getElementById('btnAiSearch').addEventListener('click', () => {
    if (g_aiSearchMode) {
      g_aiSearchMode = false;
      g_aiSearchIds.clear();
      const btn = document.getElementById('btnAiSearch');
      btn.textContent = T('aiSearch.btn');
      btn.classList.remove('active');
      btn.dataset.i18n = 'aiSearch.btn';
      applyFilter();
      return;
    }
    if (!g_aiEnabled) { alert(T('aiSearch.noAi')); return; }
    const q = document.getElementById('searchBox').value.trim();
    if (!q) { alert(T('aiSearch.noQuery')); return; }
    const phrases = g_filtered.slice(0, 150).map(p => ({ id: p.id, trigger: p.trigger, phrase: p.phrase }));
    if (!phrases.length) return;
    const btn = document.getElementById('btnAiSearch');
    btn.textContent = T('aiSearch.searching');
    btn.disabled = true;
    postToAhk({ action: 'aiSemanticSearch', query: q, phrases });
  });

  // ＋ Ny fras → open detail panel as new phrase
  document.getElementById('btnAddNew').addEventListener('click', openNewPhrase);

  // Detail panel actions
  document.getElementById('closeDetail').addEventListener('click', closeDetail);
  document.getElementById('btnSave').addEventListener('click', saveAndInsert);
  // quick-add AI checkbox persists as the auto_tag setting
  document.getElementById('fAiAuto')?.addEventListener('change', e => {
    postToAhk({ action: 'saveAutoTag', on: e.target.checked ? 1 : 0 });
    const st = document.getElementById('aiAutoTag');
    if (st) st.checked = e.target.checked;
  });
  document.getElementById('btnSaveOnly').addEventListener('click', () => saveEdited());
  document.getElementById('btnDelete').addEventListener('click', deleteSelected);
  document.getElementById('btnCancel').addEventListener('click', closeDetail);
  document.getElementById('btnDuplicate').addEventListener('click', duplicatePhrase);
  document.getElementById('btnDuplicateMore').addEventListener('click', openDuplicateToMenu);
  document.addEventListener('click', e => {
    if (!e.target.closest('#dupToMenu') && !e.target.closest('#btnDuplicateMore')) closeDupToMenu();
  });
  document.getElementById('btnAiSuggest').addEventListener('click', aiSuggestForSelected);
  // Live AI suggestions while typing a new phrase (debounced)
  ['fTrigger', 'fPhrase'].forEach(id =>
    document.getElementById(id)?.addEventListener('input', () => _aiLiveArm()));
  // Hand-edited metadata fields are off limits for live AI fills
  ['fCat', 'fTags', 'fComment', 'fLang'].forEach(id =>
    document.getElementById(id)?.addEventListener('input', e => { e.target.dataset.aiSrc = 'user'; }));
  document.getElementById('fAiAuto')?.addEventListener('change', e => {
    if (e.target.checked) _aiLiveArm(); else _aiLiveReset();
  });
  document.getElementById('btnAiDrop').addEventListener('click', e => {
    e.stopPropagation();
    const menu = document.getElementById('aiDropMenu');
    if (!menu.classList.contains('hidden')) { menu.classList.add('hidden'); return; }
    const btn  = document.getElementById('btnAiDrop');
    const rect = btn.getBoundingClientRect();
    _positionDropdown(menu, rect);
    menu.classList.remove('hidden');
  });
  document.getElementById('aiDropMenu').addEventListener('click', e => {
    const item = e.target.closest('[data-aiaction]');
    if (!item) return;
    document.getElementById('aiDropMenu').classList.add('hidden');
    const act = item.dataset.aiaction;
    if (act === 'single') aiSuggestForSelected();
    else if (act === 'bulk')  aiSuggestBulk();
    else if (act === 'batch') aiBatchVisible();
  });
  document.getElementById('btnBulkAi').addEventListener('click', aiSuggestBulk);
  document.addEventListener('click', () => document.getElementById('aiDropMenu')?.classList.add('hidden'));

  // File settings panel
  document.getElementById('btnFileSettings').addEventListener('click', () => {
    const path = g_selFiles.size === 1 ? [...g_selFiles][0] : (g_files[0]?.path || '');
    openFileSettings(path);
  });
  document.getElementById('closeFileSettings').addEventListener('click', closeFileSettings);
  document.getElementById('btnCancelFileSettings').addEventListener('click', closeFileSettings);
  document.getElementById('btnSaveFileSettings').addEventListener('click', saveFileSettingsNow);
  document.getElementById('fsFilePicker').addEventListener('change', e => {
    g_fileSettingsFile = e.target.value;
    fetchAndShowFileSettings(g_fileSettingsFile);
  });
  document.getElementById('btnRenameFile').addEventListener('click', renameFileNow);
  document.getElementById('fsRenameInput').addEventListener('keydown', e => {
    if (e.key === 'Enter') { e.preventDefault(); renameFileNow(); }
  });
  document.getElementById('fsMetaFields').addEventListener('input', updateFsMetaPreview);
  document.getElementById('fsGroupField').addEventListener('input', _fsRenderSharedInputs);

  // New-phrase file picker: a folder tree mirroring the left list (open via the button
  // or Alt+V; folders expand/collapse in sync with the sidebar).
  const fpBtn = document.getElementById('fNewFileBtn');
  if (fpBtn) {
    // Open on focus AND click, never toggle. A native Alt+V accesskey in WebView2 focuses
    // the button (that's why Alt+T on the visible inputs works) but does not click it — so
    // "open on focus" is what makes Alt+V work. Making both focus and click always OPEN
    // (rather than toggle) keeps it robust whether the browser focuses, clicks, or both.
    fpBtn.addEventListener('focus', openFilePickerMenu);
    fpBtn.addEventListener('blur',  closeFilePickerMenu);   // Tab/click away closes it
    fpBtn.addEventListener('click', e => { e.stopPropagation(); openFilePickerMenu(); });
    fpBtn.addEventListener('keydown', e => {
      const menu = document.getElementById('fNewFileMenu');
      const open = menu && !menu.classList.contains('hidden');
      if (!open) {
        if (e.key === 'ArrowDown' || e.key === 'Enter' || e.key === ' ') { e.preventDefault(); openFilePickerMenu(); }
        return;
      }
      if      (e.key === 'Escape')                  { e.preventDefault(); closeFilePickerMenu(); document.getElementById('fTrigger')?.focus(); }
      else if (e.key === 'ArrowDown')               { e.preventDefault(); _fpMoveHighlight(1); }
      else if (e.key === 'ArrowUp')                 { e.preventDefault(); _fpMoveHighlight(-1); }
      else if (e.key === 'Enter' || e.key === ' ')  { e.preventDefault(); _fpChooseHighlight(); }
    });
  }
  // Keep mousedown inside the menu from moving focus off the input — otherwise the input's
  // blur handler closes the menu before the row's click can register, making files unclickable.
  document.getElementById('fNewFileMenu')?.addEventListener('mousedown', e => e.preventDefault());
  document.addEventListener('click', e => {
    if (!e.target.closest('#fNewFilePicker')) closeFilePickerMenu();
  });

  // Strip Word list markers (bullets/numbers + tab) when pasting into trigger/phrase
  document.getElementById('fTrigger').addEventListener('paste', _onListPaste);
  document.getElementById('fPhrase').addEventListener('paste', _onListPaste);


  document.getElementById('btnSwapFields').addEventListener('click', swapTriggerPhrase);
  document.getElementById('btnAddAlt')?.addEventListener('click', () => _addAltBox('', true));
  document.getElementById('fUrl').addEventListener('input', _updateUrlIcon);
  document.getElementById('btnUrlBrowse').addEventListener('click', () => postToAhk({ action: 'browseLinkFile' }));
  document.getElementById('btnUrlOpen').addEventListener('click', () => {
    const u = document.getElementById('fUrl').value.trim();
    if (!u) { alert(T('alert.noUrl')); return; }
    postToAhk({ action: 'openUrl', url: u });
  });
  // Auto-save: any edit in the detail body schedules a debounced save
  const _db = document.getElementById('detailBody');
  if (_db) {
    _db.addEventListener('input',  _scheduleAutosave);
    _db.addEventListener('change', _scheduleAutosave);
  }
  const _ga = document.getElementById('genAutosave');
  if (_ga) {
    _ga.checked = g_autosave;
    _ga.addEventListener('change', () => applyAutosave(_ga.checked));
  }
  window.addEventListener('blur', _flushAutosave);
  document.getElementById('fTrigger').addEventListener('input', checkTriggerDuplicate);
  document.getElementById('fTrigger').addEventListener('input', _onTriggerEdited);
  document.getElementById('fPhrase').addEventListener('input', _syncFieldsFromText);
  document.getElementById('fTags').addEventListener('input', () => {
    const chipsEl = document.getElementById('tagSuggestChips');
    if (chipsEl && !chipsEl.classList.contains('hidden')) _refreshTagChipActive(chipsEl);
  });

  // Column filters (event delegation — filters are re-rendered dynamically)
  document.getElementById('listFilters').addEventListener('input', e => {
    const inp = e.target.closest('.col-filter');
    if (!inp) return;
    const col = inp.dataset.col;
    if (col in g_colFilters) { g_colFilters[col] = inp.value.trim().toLowerCase(); applyFilter(); }
  });

  // Column sort (event delegation)
  document.getElementById('listHeader').addEventListener('click', e => {
    const head = e.target.closest('.col-head[data-sort]');
    if (!head || e.target.classList.contains('col-resize')) return;
    const col = head.dataset.sort;
    if (g_sortCol === col) g_sortDir = g_sortDir === 'asc' ? 'desc' : 'asc';
    else { g_sortCol = col; g_sortDir = 'asc'; }
    renderSortIndicators();
    applyFilter();
  });

  // Column visibility right-click menu
  document.getElementById('listHeader').addEventListener('contextmenu', openColVisMenu);
  document.addEventListener('click', e => {
    if (!e.target.closest('#colVisMenu')) closeColVisMenu();
  });

  // Column state init (renders header + filters, applies CSS)
  initColState();

  // Settings mode
  document.getElementById('btnSettings').addEventListener('click', () => enterSettings(g_settingsPage));
  document.getElementById('btnCloseSettings').addEventListener('click', leaveSettings);
  document.querySelectorAll('.settings-cat-list li').forEach(li => {
    li.addEventListener('click', () => showSettingsPage(li.dataset.settings));
  });

  // Settings pages — folders
  document.getElementById('btnAddFolder').addEventListener('click', () => postToAhk({ action: 'addFolder' }));

  // Settings pages — General
  document.getElementById('btnSaveGeneral').addEventListener('click', saveGeneralSettings);

  // Settings pages — AI
  document.getElementById('btnSaveAiSettings').addEventListener('click', saveAiSettings);
  document.getElementById('btnResetAiUsage').addEventListener('click', () => postToAhk({ action: 'aiResetUsage' }));
  document.getElementById('btnAiBatchAll').addEventListener('click', aiBatchVisible);
  document.getElementById('btnLlmProbe').addEventListener('click', () => {
    const btn = document.getElementById('btnLlmProbe');
    btn.disabled = true;
    // Save current endpoint + key so AHK probes with the values typed in the UI
    postToAhk({
      action:       'saveAiSettings',
      api_key:      document.getElementById('aiApiKey').value,
      model:        document.getElementById('aiModel').value,
      enabled:      document.getElementById('aiEnabled').checked,
      auto_tag:     document.getElementById('aiAutoTag').checked,
      exclude:      document.getElementById('aiExclude').value,
      llm_enabled:  document.getElementById('llmEnabled').checked,
      llm_endpoint: document.getElementById('llmEndpoint').value,
      llm_model:    document.getElementById('llmModel').value,
      llm_api_key:  document.getElementById('llmApiKey').value,
    });
    // AHK will call receiveAiSettings with updated llm_models after saving
    setTimeout(() => { btn.disabled = false; }, 5000);
  });
  document.getElementById('btnMaintUndo').addEventListener('click', () => postToAhk({ action: 'aiMaintenance', task: 'undo' }));
  document.querySelectorAll('.ai-maint-btn').forEach(btn => {
    btn.addEventListener('click', () => postToAhk({ action: 'aiMaintenance', task: btn.dataset.task }));
  });

  // Settings pages — maintenance
  document.getElementById('btnRunDupeCheck').addEventListener('click', runDuplicateCheck);
  document.getElementById('btnRunSemDupes').addEventListener('click', () => {
    if (!g_aiEnabled && !g_llmEnabled) { alert(T('maint.semdupes.noAi')); return; }
    postToAhk({ action: 'aiMaintenance', task: 'dupes' });
  });
  document.getElementById('btnRunStats').addEventListener('click', runStatAnalysis);

  // Settings pages — hotkeys
  document.getElementById('btnSaveHotkeys').addEventListener('click', saveHotkeySettings);
  document.getElementById('btnCaptureKey').addEventListener('click', startKeyCapture);
  document.querySelectorAll('.hk-input').forEach(inp => {
    inp.addEventListener('focus', () => { g_captureTarget = inp; });
  });

  // Settings pages — popup
  document.getElementById('btnSavePopup').addEventListener('click', savePopupSettings);

  // Settings pages — dynamic fields
  document.getElementById('btnSaveDynamic').addEventListener('click', saveDynamicSettings);
  document.getElementById('pasteMode').addEventListener('change', _updatePasteMinLenVis);
  document.getElementById('btnAddDynApp').addEventListener('click', () => {
    g_dynAppModes.push({ app: '', mode: 'auto' });
    renderDynAppGrid();
    const rows = document.querySelectorAll('.dyn-app-row input');
    if (rows.length) rows[rows.length - 1].focus();
  });

  // Settings pages — spell check enabled toggle
  document.getElementById('btnSaveSpellEnabled').addEventListener('click', () => {
    const on = document.getElementById('spellEnabled').checked;
    applySpellCheck(on);
    postToAhk({ action: 'saveSpellEnabled', enabled: on ? 1 : 0 });
  });

  // Settings pages — dictionary
  document.getElementById('btnAddDictFolder').addEventListener('click', () => {
    postToAhk({ action: 'addDictFolder' });
  });
  document.getElementById('btnSaveCompound').addEventListener('click', () => {
    postToAhk({
      action:      'saveCompoundSettings',
      enabled:     document.getElementById('compoundEnabled').checked,
      minLen:      parseInt(document.getElementById('compoundMinLen').value, 10) || 12,
    });
    const st = document.getElementById('compoundStatus');
    if (st) { st.textContent = T('compound.saved'); setTimeout(() => { if (st) st.textContent = ''; }, 2000); }
  });

  // Toolbar enc lock button
  document.getElementById('btnEncLock').addEventListener('click', () => {
    postToAhk({ action: 'enc', task: 'unlock' });
  });

  // Settings pages — encryption
  document.getElementById('btnEncToggle').addEventListener('click', () => {
    postToAhk({ action: 'enc', task: g_encUnlocked ? 'lock' : 'unlock' });
  });
  document.querySelectorAll('[data-enc]').forEach(btn => {
    btn.addEventListener('click', () => postToAhk({ action: 'enc', task: btn.dataset.enc }));
  });

  // New-file dialog
  document.getElementById('btnNfCreate').addEventListener('click', submitNewFile);
  document.getElementById('btnNfCancel').addEventListener('click', closeNewFileDialog);
  document.getElementById('nfName').addEventListener('keydown', e => {
    if (e.key === 'Enter') submitNewFile();
    if (e.key === 'Escape') closeNewFileDialog();
  });
  document.getElementById('newFileDialog').addEventListener('click', e => {
    if (e.target === e.currentTarget) closeNewFileDialog();
  });
  document.getElementById('btnCloseBackup').addEventListener('click', closeBackupModal);
  document.getElementById('backupModal').addEventListener('click', e => {
    if (e.target === e.currentTarget) closeBackupModal();
  });
  // Help popups for the file-settings ⓘ icons (content is too long for a native tooltip)
  document.querySelectorAll('.fs-help[data-help]').forEach(el => {
    el.style.cursor = 'pointer';
    el.addEventListener('click', () => openHelpModal(el.dataset.help));
  });
  document.getElementById('btnCloseHelp').addEventListener('click', closeHelpModal);
  document.getElementById('helpModal').addEventListener('click', e => {
    if (e.target === e.currentTarget) closeHelpModal();
  });
  document.addEventListener('keydown', e => {
    if (e.key === 'Escape' && !document.getElementById('helpModal').classList.contains('hidden'))
      closeHelpModal();
  });
  document.getElementById('btnChooseWordlistFolder').addEventListener('click', () => {
    postToAhk({ action: 'chooseDictDownloadFolder' });
  });
  document.getElementById('btnDownloadWordlists').addEventListener('click', () => {
    const files = [...document.querySelectorAll('.wl-chk:checked')].map(c => c.dataset.path);
    if (!files.length || !g_wordlistDlFolder) return;
    document.getElementById('wordlistDlStatus').textContent = 'Startar nedladdning…';
    document.getElementById('btnDownloadWordlists').disabled = true;
    postToAhk({ action: 'downloadWordlists', folder: g_wordlistDlFolder, files });
  });
  document.getElementById('btnRefreshWordlistIndex').addEventListener('click', () => {
    g_wordlistIndexLoaded = false;
    loadWordlistIndex(true);
  });
  document.getElementById('btnDownloadPhrasePacks')?.addEventListener('click', () => {
    const packs = [...document.querySelectorAll('#phrasePackIndex .pk-chk:checked')].map(c => ({
      name: c.dataset.pack, files: c.dataset.files.split('|').filter(Boolean),
    }));
    if (!packs.length) return;
    document.getElementById('phrasePackStatus').textContent = T('packs.downloading');
    postToAhk({ action: 'downloadPhrasePacks', packs });
  });
  document.getElementById('btnRefreshPhrasePacks')?.addEventListener('click', () => loadPhrasePackIndex(true));
  document.getElementById('btnFirstRunStart').addEventListener('click', () => {
    const allFiles = [];
    document.querySelectorAll('.fr-bundle-chk:checked').forEach(chk => {
      chk.dataset.files.split('|').filter(Boolean).forEach(f => allFiles.push(f));
    });
    const phrasePacks = [...document.querySelectorAll('.fr-pack-chk:checked')].map(c => ({
      name: c.dataset.pack, files: c.dataset.files.split('|').filter(Boolean),
    }));
    const folder = document.getElementById('frFolderPath').value.trim();
    postToAhk({ action: 'firstRunSetup', wordlistFiles: allFiles, phrasePacks, phraseFolder: folder });
  });
  document.getElementById('btnFirstRunSkip').addEventListener('click', () => {
    postToAhk({ action: 'firstRunSetup', wordlistFiles: [], phrasePacks: [], phraseFolder: '' });
  });
  document.getElementById('btnFirstRunBrowse').addEventListener('click', () => {
    postToAhk({ action: 'browsePhraseFolder' });
  });

  // File context menu
  const ctxMenu = document.getElementById('ctxMenu');
  ctxMenu.addEventListener('click', e => {
    e.stopPropagation();
    const item = e.target.closest('.ctx-item');
    if (!item || item.classList.contains('ctx-submenu-trigger')) return;
    const action = item.dataset.action;
    const phraseAction = item.dataset.phraseaction;
    if (phraseAction === 'selectall') {
      selectAll(); closeContextMenu();
    } else if (phraseAction === 'togglechk') {
      toggleCheckboxMode(); closeContextMenu();
    } else if (phraseAction === 'duplicate') {
      _ctxDuplicate(_ctxPhraseIds); closeContextMenu();
    } else if (action === 'dupToFile') {
      closeContextMenu(); _ctxDupToFile(_ctxPhraseIds, item.dataset.path);
    } else if (action === 'moveToFile') {
      closeContextMenu(); _ctxMoveToFile(_ctxPhraseIds, item.dataset.path);
    } else if (item.classList.contains('ctx-new-file')) {
      closeContextMenu();
      openNewFileDialog(item.dataset.folder);
    } else if (action === 'hideFile') {
      postToAhk({ action: 'setFileHidden', path: item.dataset.path, hidden: true });
      closeContextMenu();
    } else if (action === 'showFile') {
      postToAhk({ action: 'setFileHidden', path: item.dataset.path, hidden: false });
      closeContextMenu();
    } else if (action === 'hideFolder') {
      postToAhk({ action: 'setFolderHidden', id: item.dataset.folderid, hidden: true });
      closeContextMenu();
    } else if (action === 'showFolder') {
      postToAhk({ action: 'setFolderHidden', id: item.dataset.folderid, hidden: false });
      closeContextMenu();
    } else if (action === 'openEditor') {
      postToAhk({ action: 'openEditor', path: item.dataset.path });
      closeContextMenu();
    } else if (action === 'openFolder') {
      postToAhk({ action: 'openFolder', path: item.dataset.path });
      closeContextMenu();
    } else if (action === 'applyPreset') {
      const preset = item.dataset.preset;
      postToAhk({ action: 'applyPreset', preset, paths: _ctxPresetPaths });
      showInfoToast(T('toast.preset', T('ctx.preset.' + preset)));
      closeContextMenu();
    } else if (action === 'backups') {
      postToAhk({ action: 'getBackups', path: item.dataset.path });
      closeContextMenu();
    } else if (action === 'batchFileSet') {
      postToAhk({ action: 'fileBatchSet', type: item.dataset.type, enable: item.dataset.enable === 'true', paths: _ctxPresetPaths });
      closeContextMenu();
    } else if (action === 'encryptPath') {
      postToAhk({ action: 'enc', task: 'lockPath', path: item.dataset.path });
      closeContextMenu();
    } else if (action === 'decryptPath') {
      postToAhk({ action: 'enc', task: 'unlockPath', path: item.dataset.path });
      closeContextMenu();
    } else {
      postToAhk({ action: 'fileToggle', path: item.dataset.path, type: action });
      closeContextMenu();
    }
  });
  document.addEventListener('click', closeContextMenu);
  // Right-click on empty space in the file panel → "Ny fil…"
  document.getElementById('panelFiles').addEventListener('contextmenu', e => {
    if (e.target.closest('.file-item') || e.target.closest('.folder-group-hdr')) return;
    e.preventDefault();
    showFolderContextMenu(e, '');
  });

  document.addEventListener('contextmenu', e => {
    if (!e.target.closest('#panelFiles') && !e.target.closest('#ctxMenu')) closeContextMenu();
  });

  // Show hidden files toggle
  document.getElementById('chkShowHidden').addEventListener('change', e => {
    g_showHiddenFiles = e.target.checked;
    populateSidebar();
    applyFilter();
  });


  // Bulk edit panel
  document.getElementById('closeBulk').addEventListener('click', closeBulkPanel);
  document.getElementById('btnBulkSave').addEventListener('click', saveBulkEdit);
  document.getElementById('btnBulkDelete').addEventListener('click', bulkDelete);
  document.getElementById('btnBulkCancel').addEventListener('click', closeBulkPanel);
  document.getElementById('bTagAddBtn').addEventListener('click', _bulkAddTag);
  document.getElementById('bTagInput').addEventListener('keydown', e => {
    if (e.key === 'Enter') { e.preventDefault(); _bulkAddTag(); }
  });

  // Keyboard navigation
  document.addEventListener('keydown', onGlobalKey);

  // Sidebar filter tabs
  document.querySelectorAll('.sidebar-tabs button').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.sidebar-tabs button').forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.sidebar-panel').forEach(p => p.classList.remove('active'));
      btn.classList.add('active');
      document.getElementById(btn.dataset.panel).classList.add('active');
    });
  });

  // Panel resize handles
  _bindPanelResize('sidebarResizeHandle', 'sidebar', 'sidebarWidth', 120, 500, false);
  _bindPanelResize('detailResizeHandle',  null,      'detailWidth',  220, 600, true);

  // Vertical resize handles for stacked sidebar sections
  _bindVResize('sidebarVResizeFC', 'panelFiles');
  _bindVResize('sidebarVResizeCT', 'panelCats');
  _bindVResize('sidebarVResizeTL', 'panelTags');

  // Collapsible section headers (stacked mode)
  _initSectionCollapseHandlers();
}

function _bindPanelResize(handleId, panelId, storageKey, minW, maxW, rightPanel) {
  const handle = document.getElementById(handleId);
  if (!handle) return;
  const getPanel = () => panelId
    ? document.getElementById(panelId)
    : (document.getElementById('detailPanel').classList.contains('hidden')
        ? (document.getElementById('bulkPanel').classList.contains('hidden')
            ? document.getElementById('fileSettingsPanel')
            : document.getElementById('bulkPanel'))
        : document.getElementById('detailPanel'));
  // Restore saved width
  const saved = localStorage.getItem(storageKey);
  if (saved) {
    const w = saved + 'px';
    if (rightPanel) {
      ['detailPanel','bulkPanel','fileSettingsPanel'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.style.width = w;
      });
    } else {
      const p = document.getElementById(panelId);
      if (p) p.style.width = w;
    }
  }
  handle.addEventListener('mousedown', e => {
    e.preventDefault();
    const panel = getPanel();
    if (!panel) return;
    const startX   = e.clientX;
    const startW   = panel.getBoundingClientRect().width;
    handle.classList.add('dragging');
    const applyW = newW => {
      if (rightPanel) {
        // Keep all right panels in sync
        ['detailPanel','bulkPanel','fileSettingsPanel'].forEach(id => {
          const el = document.getElementById(id);
          if (el) el.style.width = newW + 'px';
        });
      } else {
        panel.style.width = newW + 'px';
      }
    };
    const onMove = ev => {
      const delta = rightPanel ? startX - ev.clientX : ev.clientX - startX;
      applyW(Math.max(minW, Math.min(maxW, startW + delta)));
    };
    const onUp = () => {
      handle.classList.remove('dragging');
      const w = parseInt(panel.style.width);
      if (!isNaN(w)) try { localStorage.setItem(storageKey, w); } catch(_){}
      document.removeEventListener('mousemove', onMove);
      document.removeEventListener('mouseup',   onUp);
    };
    document.addEventListener('mousemove', onMove);
    document.addEventListener('mouseup',   onUp);
  });
}

// ── Settings mode ─────────────────────────────────────────────────────────────
function enterSettings(page) {
  g_settingsMode = true;
  document.getElementById('filterNav').classList.add('hidden');
  document.getElementById('settingsNav').classList.remove('hidden');
  document.getElementById('listArea').classList.add('hidden');
  document.getElementById('settingsMain').classList.remove('hidden');
  document.getElementById('detailPanel').classList.add('hidden');
  showSettingsPage(page || g_settingsPage);
}

function leaveSettings() {
  g_settingsMode = false;
  document.getElementById('filterNav').classList.remove('hidden');
  document.getElementById('settingsNav').classList.add('hidden');
  document.getElementById('listArea').classList.remove('hidden');
  document.getElementById('settingsMain').classList.add('hidden');
}

function showSettingsPage(page) {
  g_settingsPage = page;
  document.querySelectorAll('.settings-cat-list li').forEach(li => {
    li.classList.toggle('selected', li.dataset.settings === page);
  });
  const pageIds = {
    general: 'spGeneral', folders: 'spFolders', hotkeys: 'spHotkeys', popup: 'spPopup', dynamic: 'spDynamic',
    ai: 'spAi', maint: 'spMaint', spell: 'spSpell', enc: 'spEnc',
  };
  document.querySelectorAll('.settings-page').forEach(p => p.classList.add('hidden'));
  const targetId = pageIds[page];
  if (targetId) document.getElementById(targetId).classList.remove('hidden');
  if (page === 'spell') loadWordlistIndex();
  if (page === 'folders') loadPhrasePackIndex();
}

// ── Sidebar ───────────────────────────────────────────────────────────────────
function populateSidebar() {
  const fileCounts = {};
  for (const p of g_phrases) fileCounts[p.file] = (fileCounts[p.file] || 0) + 1;
  // Include all known files (especially locked .enc files with 0 loaded phrases)
  for (const f of g_files)
    if (!(f.path in fileCounts)) fileCounts[f.path] = 0;
  // Phrases from hidden files are excluded from cat/tag counts when not showing hidden
  const visiblePhrases = g_showHiddenFiles
    ? g_phrases
    : g_phrases.filter(p => !g_fileSettingsCache[p.file]?.hidden);
  renderFileFilterList(fileCounts);

  // Category counts scoped to selected files
  const catCounts = {};
  const catFiltered = g_selFiles.size > 0;
  for (const p of visiblePhrases) {
    if (catFiltered && !g_selFiles.has(p.file)) continue;
    if (p.cat) catCounts[p.cat] = (catCounts[p.cat] || 0) + 1;
  }
  renderFilterList('catList', catCounts, g_selCats, v => {
    if (v === null) g_selCats.clear();
    else g_selCats.has(v) ? g_selCats.delete(v) : g_selCats.add(v);
    populateSidebar(); applyFilter();
  }, catFiltered);
  renderTagCloud();

  // Tab filter indicator: ● only on the tab where the active selection lives
  document.querySelector('[data-panel="panelFiles"]').classList.toggle('filtered', g_selFiles.size > 0);
  document.querySelector('[data-panel="panelCats"]').classList.toggle('filtered', g_selCats.size > 0);
  document.querySelector('[data-panel="panelTags"]').classList.toggle('filtered', g_selTags.size > 0 || g_selLangs.size > 0);
}

function renderFilterList(elId, counts, selSet, onClick, isFiltered) {
  const ul = document.getElementById(elId);
  ul.innerHTML = '';
  if (isFiltered) {
    const note = document.createElement('li');
    note.className = 'filter-scope-note';
    note.textContent = T('scope.file');
    ul.appendChild(note);
  }
  const all = document.createElement('li');
  all.className = selSet.size === 0 ? 'selected' : '';
  all.innerHTML = `<span class="li-name">${T('allFilter')}</span><span class="li-count">${Object.values(counts).reduce((a,b)=>a+b,0)}</span>`;
  all.addEventListener('click', () => onClick(null));
  ul.appendChild(all);
  Object.entries(counts).sort((a,b) => b[1]-a[1]).forEach(([name, cnt]) => {
    const li = document.createElement('li');
    li.className = selSet.has(name) ? 'selected' : '';
    const display = name.split(/[\\/]/).pop() || name;
    li.innerHTML = `<span class="li-name" title="${escHtml(name)}">${escHtml(display)}</span><span class="li-count">${cnt}</span>`;
    li.addEventListener('click', () => onClick(name));
    ul.appendChild(li);
  });
}

function _flhState(paths, type) {
  if (!paths.length) return true;
  return paths.every(p => {
    const s = g_fileSettingsMap[p];
    if (type === 'hs')    return s?.hsOn    !== false;
    if (type === 'hintT') return s?.hintTOn !== false;
    if (type === 'hintP') return s?.hintPOn !== false;
    return true;
  });
}

function renderFileFilterList(counts) {
  const ul = document.getElementById('fileList');
  ul.innerHTML = '';
  // Determine which folder each file belongs to (needed for folder-hidden check)
  const fileFolder = {};
  for (const f of g_files) fileFolder[f.path] = f.folder || '';

  const hasHiddenFiles    = Object.keys(counts).some(p => g_fileSettingsCache[p]?.hidden);
  const hasHiddenFolders  = Object.keys(counts).some(p => g_hiddenFolderIds.has(fileFolder[p]));
  const toggleRow = document.getElementById('hiddenToggleRow');
  if (toggleRow) toggleRow.classList.toggle('hidden', !hasHiddenFiles && !hasHiddenFolders);

  const visibleCounts = {};
  for (const [path, cnt] of Object.entries(counts)) {
    const hidden       = g_fileSettingsCache[path]?.hidden;
    const folderHidden = g_hiddenFolderIds.has(fileFolder[path]);
    if ((!hidden && !folderHidden) || g_showHiddenFiles) visibleCounts[path] = cnt;
  }
  const total = Object.values(visibleCounts).reduce((a,b)=>a+b,0);
  const globalPaths = Object.keys(visibleCounts);
  const allHs = _flhState(globalPaths, 'hs');
  const allHt = _flhState(globalPaths, 'hintT');
  const allHp = _flhState(globalPaths, 'hintP');
  const all = document.createElement('li');
  all.className = 'all-files-row' + (g_selFiles.size === 0 ? ' selected' : '');
  all.innerHTML =
    `<span class="li-name">${T('allFilter')}</span>` +
    `<span class="flh-badges" id="flhGlobal">` +
    `<span class="flh-btn${allHs?' on':''}" data-type="hs"    title="Slå av/på HS för alla filer">H</span>` +
    `<span class="flh-btn${allHt?' on':''}" data-type="hintT" title="Slå av/på trigger-popup för alla filer">T</span>` +
    `<span class="flh-btn${allHp?' on':''}" data-type="hintP" title="Slå av/på fras-popup för alla filer">P</span>` +
    `</span>` +
    `<span class="li-count">${total}</span>`;
  all.addEventListener('click', e => {
    const btn = e.target.closest('[data-type]');
    if (btn && btn.closest('.flh-badges')) {
      const type = btn.dataset.type;
      const paths = globalPaths
        .filter(f => !(f.toLowerCase().endsWith('.enc') && !g_encUnlocked));
      postToAhk({ action: 'fileBatchSet', type, enable: !btn.classList.contains('on'), paths });
      return;
    }
    if (!e.target.closest('.flh-badges')) {
      g_selFiles.clear(); populateSidebar(); applyFilter();
    }
  });
  ul.appendChild(all);

  // Build folder groups from g_files (preserves INI order)
  const folderOrder = [];   // folder IDs in order of first appearance
  const folderFiles = {};   // folderId → [path, ...]
  const folderLabel = {};   // folderId → display name
  const folderPaths = {};   // folderId → full folder path
  for (const f of g_files) {
    if (!(f.path in visibleCounts)) continue;
    const fid = f.folder || '';
    if (!folderFiles[fid]) {
      folderFiles[fid] = [];
      folderPaths[fid] = f.folderPath || '';
      folderLabel[fid] = (f.folderPath || fid).split(/[\\/]/).pop() || fid;
      folderOrder.push(fid);
    }
    folderFiles[fid].push(f.path);
  }

  const multiFolder = folderOrder.length > 1;

  for (const fid of folderOrder) {
    const isFolderHidden = g_hiddenFolderIds.has(fid);
    if (isFolderHidden && !g_showHiddenFiles) continue;

    const paths = folderFiles[fid];
    const folderTotal = paths.reduce((s, p) => s + (visibleCounts[p] || 0), 0);
    const isCollapsed = g_collapsedFolders.has(fid);

    if (multiFolder) {
      const hdr = document.createElement('li');
      const folderAllSel = paths.length > 0 && paths.every(p => g_selFiles.has(p));
      hdr.className = 'folder-group-hdr'
        + (isCollapsed    ? ' collapsed'     : '')
        + (isFolderHidden ? ' folder-hidden' : '')
        + (folderAllSel   ? ' folder-selected' : '');
      const fHs = _flhState(paths, 'hs'), fT = _flhState(paths, 'hintT'), fP = _flhState(paths, 'hintP');
      hdr.innerHTML =
        `<span class="fgh-arrow">${isCollapsed ? '▸' : '▾'}</span>` +
        `<span class="fgh-name" title="${escHtml(folderLabel[fid])}">${escHtml(folderLabel[fid])}</span>` +
        `<span class="fgh-badges">` +
        `<span class="fb${fHs ? ' on':''}" data-type="hs">H</span>` +
        `<span class="fb${fT  ? ' on':''}" data-type="hintT">T</span>` +
        `<span class="fb${fP  ? ' on':''}" data-type="hintP">P</span>` +
        `</span>` +
        `<span class="li-count">${folderTotal}</span>`;
      hdr.addEventListener('click', e => {
        if (e.target.closest('.fgh-badges')) {
          e.stopPropagation();
          const badge = e.target.closest('[data-type]');
          if (!badge) return;
          const type = badge.dataset.type;
          postToAhk({ action: 'fileBatchSet', type, enable: !badge.classList.contains('on'), paths });
          return;
        }
        if (e.target.closest('.fgh-arrow')) {
          // Expand/collapse is limited to the arrow on the left.
          if (g_collapsedFolders.has(fid)) g_collapsedFolders.delete(fid);
          else g_collapsedFolders.add(fid);
          try { localStorage.setItem('collapsedFolders', JSON.stringify([...g_collapsedFolders])); } catch(_){}
          populateSidebar();
          return;
        }
        // Clicking the folder name selects all its files (toggles the whole group).
        const allSel = paths.length > 0 && paths.every(p => g_selFiles.has(p));
        if (allSel) paths.forEach(p => g_selFiles.delete(p));
        else        paths.forEach(p => g_selFiles.add(p));
        populateSidebar();
        applyFilter();
      });
      hdr.addEventListener('contextmenu', e => {
        e.preventDefault();
        showFolderContextMenu(e, folderPaths[fid], fid);
      });
      ul.appendChild(hdr);
    }

    if (isCollapsed) continue;

    paths.slice().sort((a,b) => (visibleCounts[b]||0) - (visibleCounts[a]||0)).forEach(path => {
      const cnt = visibleCounts[path] || 0;
      const li = document.createElement('li');
      const cached = g_fileSettingsCache[path];
      const isHidden = !!cached?.hidden;
      const isLocked = path.toLowerCase().endsWith('.enc') && !g_encUnlocked;
      li.className = 'file-item'
        + (multiFolder ? ' folder-child' : '')
        + (g_selFiles.has(path) ? ' selected' : '')
        + (isHidden ? ' file-hidden' : '')
        + (isLocked ? ' file-enc-locked' : '');
      const display = (cached?.label) || path.split(/[\\/]/).pop() || path;
      const isEnc = path.toLowerCase().endsWith('.enc');
      const s = g_fileSettingsMap[path] || {};
      const hsOn    = s.hsOn    !== false;
      const hintTOn = s.hintTOn !== false;
      const hintPOn = s.hintPOn !== false;
      if (isLocked) {
        li.innerHTML =
          `<span class="li-name" title="${escHtml(path)}">🔒 ${escHtml(display)}</span>` +
          `<span class="li-count enc-locked-label">${T('badge.locked')}</span>`;
        li.addEventListener('click', () => postToAhk({ action: 'enc', task: 'unlock' }));
      } else {
        li.innerHTML =
          `<span class="li-name" title="${escHtml(path)}">${isEnc ? '🔓 ' : ''}${escHtml(display)}</span>` +
          `<span class="li-count">${cnt}</span>` +
          `<span class="file-badges">` +
          `<span class="fb${hsOn    ? ' on':''}" data-type="hs"    title="${T(hsOn    ?'badge.hsActive':'badge.hsInactive')}">H</span>` +
          `<span class="fb${hintTOn ? ' on':''}" data-type="hintT" title="${T(hintTOn?'badge.hintTActive':'badge.hintTInactive')}">T</span>` +
          `<span class="fb${hintPOn ? ' on':''}" data-type="hintP" title="${T(hintPOn?'badge.hintPActive':'badge.hintPInactive')}">P</span>` +
          `</span>`;
        li.addEventListener('click', e => {
          const badge = e.target.closest('[data-type]');
          if (badge) {
            const type   = badge.dataset.type;
            const enable = !badge.classList.contains('on');
            // Optimistic UX: flip badge immediately so click feels instant
            const s = g_fileSettingsMap[path] || {};
            if (type === 'hs')    s.hsOn    = enable;
            if (type === 'hintT') s.hintTOn = enable;
            if (type === 'hintP') s.hintPOn = enable;
            g_fileSettingsMap[path] = s;
            badge.classList.toggle('on', enable);
            const titleKey = type === 'hs'    ? (enable ? 'badge.hsActive'    : 'badge.hsInactive')
                           : type === 'hintT' ? (enable ? 'badge.hintTActive' : 'badge.hintTInactive')
                                              : (enable ? 'badge.hintPActive' : 'badge.hintPInactive');
            badge.title = T(titleKey);
            postToAhk({ action: 'fileBatchSet', type, enable, paths: [path] });
          } else {
            g_selFiles.has(path) ? g_selFiles.delete(path) : g_selFiles.add(path);
            populateSidebar(); applyFilter();
          }
        });
        li.addEventListener('contextmenu', e => {
          e.preventDefault();
          showFileContextMenu(e, path, { hsOn, hintTOn, hintPOn, isHidden });
        });
        li.addEventListener('dragover', e => {
          if (!e.dataTransfer.types.includes('application/expanto-phrase-id')) return;
          e.preventDefault();
          e.dataTransfer.dropEffect = 'move';
          li.classList.add('drag-over');
        });
        li.addEventListener('dragleave', e => {
          if (!li.contains(e.relatedTarget)) li.classList.remove('drag-over');
        });
        li.addEventListener('drop', e => {
          e.preventDefault();
          li.classList.remove('drag-over');
          const phraseId = e.dataTransfer.getData('application/expanto-phrase-id');
          if (!phraseId) return;
          const phrase = g_phrases.find(x => x.id === phraseId);
          if (!phrase || phrase.file === path) return;
          postToAhk({ action: 'movePhrase', id: phraseId, targetFile: path });
        });
      }
      ul.appendChild(li);
    });
  }

}

// ── Settings panel — folder list ─────────────────────────────────────────────
function renderFolderList(folders) {
  const ul = document.getElementById('folderList');
  ul.innerHTML = '';
  if (!folders.length) {
    ul.innerHTML = `<li class="folder-empty">${T('folders.empty')}</li>`;
    return;
  }
  folders.forEach(f => {
    const li = document.createElement('li');
    li.className = 'folder-item' + (f.enabled ? '' : ' folder-disabled');
    const name = (f.path || f.id).split(/[\\/]/).pop() || f.id;
    li.innerHTML =
      `<label class="folder-toggle" title="${escHtml(f.path || '')}">` +
      `<input type="checkbox" ${f.enabled ? 'checked' : ''} data-id="${escHtml(f.id)}"> ` +
      `<span class="folder-name">${escHtml(name)}</span></label>` +
      `<button class="folder-del" data-id="${escHtml(f.id)}" title="${escHtml(T('folders.delTip'))}">✕</button>`;
    li.querySelector('input').addEventListener('change', e => {
      postToAhk({ action: 'toggleFolder', id: e.target.dataset.id, enabled: e.target.checked });
    });
    li.querySelector('.folder-del').addEventListener('click', e => {
      const id = e.currentTarget.dataset.id;
      const nm = (f.path || id).split(/[\\/]/).pop() || id;
      if (confirm(T('folders.del.confirm', nm)))
        postToAhk({ action: 'removeFolder', id });
    });
    ul.appendChild(li);
  });
}

// ── Wordlist downloader ───────────────────────────────────────────────────────
async function loadWordlistIndex(force) {
  if (g_wordlistIndexLoaded && !force) return;
  const el = document.getElementById('wordlistIndex');
  if (!el) return;
  el.innerHTML = `<div class="wl-msg">${escHtml(T('wl.fetching'))}</div>`;
  try {
    const r = await fetch('https://api.github.com/repos/ibst1/wordlists/git/trees/HEAD?recursive=1');
    if (!r.ok) throw new Error('HTTP ' + r.status);
    const data = await r.json();
    const files = (data.tree || []).filter(f => f.type === 'blob' && f.path.endsWith('.txt'));
    if (!files.length) { el.innerHTML = `<div class="wl-msg">${escHtml(T('wl.none'))}</div>`; return; }
    renderWordlistIndex(files);
    g_wordlistIndexLoaded = true;
  } catch(e) {
    el.innerHTML = `<div class="wl-msg wl-err">${escHtml(T('wl.fetchErr', e.message))}</div>`;
  }
}

// ── Phrase-pack downloader (Settings → Phrase folders) ────────────────────────
// Packs = top-level folders of .ahk files in the ahk-phrases repo.
function _groupPhrasePacks(tree) {
  const groups = {};
  for (const f of tree) {
    if (f.type !== 'blob' || !f.path.endsWith('.ahk') || !f.path.includes('/')) continue;
    const name = f.path.split('/')[0];
    (groups[name] = groups[name] || { name, files: [], size: 0 }).files.push(f.path);
    groups[name].size += f.size || 0;
  }
  return Object.values(groups).sort((a, b) => a.name.localeCompare(b.name));
}

function _updatePackBtn() {
  const btn = document.getElementById('btnDownloadPhrasePacks');
  if (btn) btn.disabled = !document.querySelector('#phrasePackIndex .pk-chk:checked');
}

async function loadPhrasePackIndex(force) {
  if (g_packIndexLoaded && !force) return;
  const el = document.getElementById('phrasePackIndex');
  if (!el) return;
  el.innerHTML = `<div class="wl-msg">${escHtml(T('wl.fetching'))}</div>`;
  try {
    const r = await fetch('https://api.github.com/repos/ibst1/ahk-phrases/git/trees/HEAD?recursive=1');
    if (!r.ok) throw new Error('HTTP ' + r.status);
    const data = await r.json();
    const packs = _groupPhrasePacks(data.tree || []);
    if (!packs.length) { el.innerHTML = `<div class="wl-msg">${escHtml(T('packs.none'))}</div>`; return; }
    el.innerHTML = packs.map(p => {
      const kb = Math.round(p.size / 1024);
      return `<div class="wl-file-row"><label><input type="checkbox" class="pk-chk"`
        + ` data-pack="${escHtml(p.name)}" data-files="${escHtml(p.files.join('|'))}">`
        + ` <strong>${escHtml(p.name)}</strong> <span class="wl-size">(${escHtml(T('packs.files', p.files.length))}, ${kb} KB)</span></label></div>`;
    }).join('');
    el.querySelectorAll('.pk-chk').forEach(c => c.addEventListener('change', _updatePackBtn));
    _updatePackBtn();
    g_packIndexLoaded = true;
  } catch(e) {
    el.innerHTML = `<div class="wl-msg wl-err">${escHtml(T('wl.fetchErr', e.message))}</div>`;
  }
}

window.phrasePackDone = function(d) {
  const st = document.getElementById('phrasePackStatus');
  if (st) st.textContent = d && d.failed ? T('packs.someFailed', d.failed) : T('packs.done');
};

function renderWordlistIndex(files) {
  const el = document.getElementById('wordlistIndex');
  if (!el) return;
  const groups = {};
  for (const f of files) {
    const parts = f.path.split('/');
    const cat   = parts.length > 1 ? parts[0] : '';
    const name  = parts[parts.length - 1];
    if (!groups[cat]) groups[cat] = [];
    groups[cat].push({ path: f.path, name, size: f.size || 0 });
  }
  let html = '';
  for (const [cat, items] of Object.entries(groups)) {
    if (cat) {
      html += `<div class="wl-cat-hdr"><label><input type="checkbox" class="wl-cat-chk" data-cat="${escHtml(cat)}" checked>`
            + ` <strong>${escHtml(cat)}/</strong></label></div>`;
    }
    for (const it of items) {
      const kb = it.size ? ` <span class="wl-size">(${Math.round(it.size / 1024)} KB)</span>` : '';
      html += `<div class="wl-file-row"><label><input type="checkbox" class="wl-chk"`
            + ` data-path="${escHtml(it.path)}" data-cat="${escHtml(cat)}" checked>`
            + ` ${escHtml(it.name)}${kb}</label></div>`;
    }
  }
  el.innerHTML = html;
  _updateDownloadBtn();
  el.querySelectorAll('.wl-cat-chk').forEach(chk => {
    chk.addEventListener('change', () => {
      el.querySelectorAll(`.wl-chk[data-cat="${CSS.escape(chk.dataset.cat)}"]`).forEach(c => { c.checked = chk.checked; });
      _updateDownloadBtn();
    });
  });
  el.querySelectorAll('.wl-chk').forEach(chk => chk.addEventListener('change', _updateDownloadBtn));
}

function _updateDownloadBtn() {
  const btn = document.getElementById('btnDownloadWordlists');
  if (btn) btn.disabled = !g_wordlistDlFolder || !document.querySelector('.wl-chk:checked');
}

// ── Settings panel — dict folder list ────────────────────────────────────────
function renderDictFolderList(paths) {
  const ul = document.getElementById('dictFolderList');
  if (!ul) return;
  ul.innerHTML = '';
  if (!paths.length) {
    ul.innerHTML = `<li class="folder-empty">${T('dictFolders.empty')}</li>`;
    return;
  }
  paths.forEach(p => {
    const li = document.createElement('li');
    li.className = 'folder-item';
    const name = p.split(/[\\/]/).pop() || p;
    li.innerHTML =
      `<label class="folder-toggle" title="${escHtml(p)}"><span class="folder-name">${escHtml(name)}</span></label>` +
      `<button class="folder-del" title="Ta bort mapp">✕</button>`;
    li.querySelector('.folder-del').addEventListener('click', () => {
      if (confirm(T('dictFolders.del.confirm', name)))
        postToAhk({ action: 'removeDictFolder', path: p });
    });
    ul.appendChild(li);
  });
}

function pushSearchHistory(q) {
  q = (q || '').trim();
  if (!q) return;
  const i = g_searchHistory.indexOf(q);
  if (i >= 0) g_searchHistory.splice(i, 1);
  g_searchHistory.push(q);
  if (g_searchHistory.length > 30) g_searchHistory.shift();
  g_searchHistIdx = -1;
}

// ── Filter & render list ──────────────────────────────────────────────────────
function applyFilter() {
  const q  = document.getElementById('searchBox').value.trim().toLowerCase();
  const cf = g_colFilters;
  g_filtered = g_phrases.filter(p => {
    if (!g_showHiddenFiles && g_fileSettingsCache[p.file]?.hidden) return false;
    if (g_selFiles.size && !g_selFiles.has(p.file)) return false;
    if (g_selCats.size  && !g_selCats.has(p.cat))   return false;
    if (g_selTags.size) {
      const pTags = new Set((p.tags || '').split(',').map(t => t.trim()).filter(Boolean));
      for (const t of g_selTags) if (!pTags.has(t)) return false;
    }
    if (g_selLangs.size && !g_selLangs.has(p.lang || '')) return false;
    if (cf.trigger && !(p.trigger || '').toLowerCase().includes(cf.trigger)) return false;
    if (cf.phrase  && !((p.phrase || '') + ' ' + (p.alts || []).join(' ')).toLowerCase().includes(cf.phrase)) return false;
    if (cf.cat     && !(p.cat     || '').toLowerCase().includes(cf.cat))     return false;
    if (cf.tags    && !(p.tags    || '').toLowerCase().includes(cf.tags))    return false;
    if (cf.lang    && !(p.lang    || '').toLowerCase().includes(cf.lang))    return false;
    if (cf.file    && !(p.file    || '').toLowerCase().includes(cf.file))    return false;
    for (const dc of g_dynamicCols) {
      const fv = cf[dc.key];
      if (fv) {
        const val = ((p.customFields || {})[dc.key.slice(3)] || '').toLowerCase();
        if (!val.includes(fv)) return false;
      }
    }
    if (!q) return true;
    const altText = (p.alts || []).join(' ') + ' ' + (p.altNames || []).join(' ');
    if (g_fuzzy) return fuzzyMatch(q, (p.trigger + ' ' + p.phrase + ' ' + altText + ' ' + p.cat).toLowerCase());
    return (p.trigger + p.phrase + altText + p.cat + p.comment + p.tags + (p.aliases||'')).toLowerCase().includes(q);
  });
  if (g_recentMode === 'used') {
    g_filtered = g_filtered.filter(p => g_usageTimes[p.id]);
    g_filtered.sort((a, b) => (g_usageTimes[b.id] || '') > (g_usageTimes[a.id] || '') ? 1 : -1);
  } else if (g_recentMode === 'edited') {
    g_filtered = g_filtered.filter(p => p.lastupdated);
    g_filtered.sort((a, b) => (b.lastupdated || '') > (a.lastupdated || '') ? 1 : -1);
  } else if (g_sortCol) {
    const dir = g_sortDir === 'asc' ? 1 : -1;
    g_filtered.sort((a, b) => {
      const av = (a[g_sortCol] || '').toLowerCase();
      const bv = (b[g_sortCol] || '').toLowerCase();
      return av < bv ? -dir : av > bv ? dir : 0;
    });
  }
  if (g_aiSearchMode && g_aiSearchIds.size) {
    const byId = new Map(g_filtered.map(p => [p.id, p]));
    g_filtered = [...g_aiSearchIds].map(id => byId.get(id)).filter(Boolean);
  }
  _applyPhraseGrouping();
  renderPhraseList();
  document.getElementById('phraseCount').textContent = T('count', g_filtered.length, g_phrases.length !== g_filtered.length ? g_phrases.length : null);
}

// ── Column config, widths, visibility, sort, filters ─────────────────────────
function rebuildDynamicCols() {
  const seen = new Set(COL_ORDER.map(c => c.key));
  const newCols = [];
  for (const [path, cfg] of Object.entries(g_fileSettingsCache)) {
    if (!cfg.metaFields) continue;
    for (const f of cfg.metaFields.split(',').map(s => s.trim()).filter(Boolean)) {
      const key = 'cf_' + f;
      if (seen.has(key)) continue;
      seen.add(key);
      newCols.push({ key, label: f, sortKey: key, defaultWidth: 100, defaultHidden: true, isDynamic: true });
    }
  }
  const prevDynKeys = new Set(g_dynamicCols.map(c => c.key));
  g_dynamicCols = newCols;
  syncColOrder();
  // Add new keys to g_colWidths / g_colFilters; remove gone ones
  for (const c of newCols) {
    if (!g_colWidths.has(c.key)) g_colWidths.set(c.key, c.defaultWidth);
    if (!(c.key in g_colFilters)) g_colFilters[c.key] = '';
  }
  for (const key of prevDynKeys) {
    if (!newCols.find(c => c.key === key)) {
      g_colWidths.delete(key);
      g_colVisible.delete(key);
      delete g_colFilters[key];
    }
  }
}

function initColState() {
  try {
    g_colOrder = JSON.parse(localStorage.getItem('expanto_col_order') || 'null') || [];
  } catch { g_colOrder = []; }
  syncColOrder();
  try {
    const sw = localStorage.getItem('expanto_col_widths2');
    const wo = sw ? JSON.parse(sw) : null;
    g_colWidths = new Map(allCols().map(c => [c.key, wo?.[c.key] ?? c.defaultWidth]));
  } catch { g_colWidths = new Map(allCols().map(c => [c.key, c.defaultWidth])); }
  try {
    const sv = localStorage.getItem('expanto_col_visible');
    g_colVisible = sv
      ? new Set(JSON.parse(sv))
      : new Set(allCols().filter(c => !c.defaultHidden).map(c => c.key));
  } catch {
    g_colVisible = new Set(allCols().filter(c => !c.defaultHidden).map(c => c.key));
  }
  renderListHeader();
  renderListFilters();
  applyColWidthsCSS();
}

function saveColState() {
  try {
    localStorage.setItem('expanto_col_widths2', JSON.stringify(Object.fromEntries(g_colWidths)));
    localStorage.setItem('expanto_col_visible', JSON.stringify([...g_colVisible]));
    localStorage.setItem('expanto_col_order',   JSON.stringify(g_colOrder));
  } catch {}
}

function applyColWidthsCSS() {
  // nr auto-fits the largest row number until the user drags it to an
  // explicit width (any value other than the 26px default)
  const nrAuto = Math.max(26, String(Math.max(g_phrases.length, 1)).length * 8 + 14);
  const val = allCols().map(c => {
    if (!g_colVisible.has(c.key)) return '0px';
    const w = g_colWidths.get(c.key) ?? c.defaultWidth;
    if (c.key === 'nr') return ((w == null || w === c.defaultWidth) ? nrAuto : w) + 'px';
    return w === null ? '1fr' : w + 'px';
  }).join(' ');
  let minW = g_checkboxMode ? 24 : 0;
  for (const c of allCols()) {
    if (!g_colVisible.has(c.key)) continue;
    const w = g_colWidths.get(c.key) ?? c.defaultWidth;
    minW += w === null ? 200 : w; // treat 1fr as 200px minimum
  }
  const area = document.getElementById('listArea');
  area.style.setProperty('--col-widths', val);
  area.style.setProperty('--pre-col', g_checkboxMode ? '24px' : '0px');
  area.style.setProperty('--list-min-width', minW + 'px');
}

function renderListHeader() {
  const chkHead = g_checkboxMode
    ? `<span class="col-head cell-chk" title="Välj/avmarkera alla"><input type="checkbox" id="chkSelectAll" title="Välj/avmarkera alla"></span>`
    : '<span class="col-head cell-chk" style="pointer-events:none"></span>';
  document.getElementById('listHeader').innerHTML = chkHead + allCols().map(c => {
    const hidden = !g_colVisible.has(c.key);
    const sort   = c.sortKey ? ` data-sort="${c.sortKey}"` : '';
    const resize = `<span class="col-resize" data-col="${c.key}"></span>`;
    return `<span class="col-head${hidden ? ' col-hidden-head' : ''}"${sort} data-col-key="${c.key}">`
      + escHtml(c.isDynamic ? c.label : T('col.' + c.key))
      + `<span class="sort-ind" id="si-${c.key}"></span>`
      + `<span class="group-ind" id="gi-${c.key}"${g_groupByCol === c.key ? ` title="${escHtml(T('group.ind'))}"` : ''}>`
      + (g_groupByCol === c.key ? '▤' : '') + `</span>`
      + resize
      + `</span>`;
  }).join('');
  bindColResize();
  bindColDrag();
}

function bindColDrag() {
  let dragKey = null;
  document.querySelectorAll('#listHeader .col-head[data-col-key]').forEach(head => {
    const key = head.dataset.colKey;
    head.draggable = true;
    head.addEventListener('dragstart', e => {
      if (e.target.closest('.col-resize')) { e.preventDefault(); return; }
      dragKey = key;
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/plain', key);
      setTimeout(() => head.classList.add('col-dragging'), 0);
    });
    head.addEventListener('dragend', () => {
      head.classList.remove('col-dragging');
      document.querySelectorAll('#listHeader .col-drag-over').forEach(el => el.classList.remove('col-drag-over'));
      dragKey = null;
    });
    head.addEventListener('dragover', e => {
      if (!dragKey || dragKey === key) return;
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
      document.querySelectorAll('#listHeader .col-drag-over').forEach(el => el.classList.remove('col-drag-over'));
      head.classList.add('col-drag-over');
    });
    head.addEventListener('dragleave', e => {
      if (!head.contains(e.relatedTarget)) head.classList.remove('col-drag-over');
    });
    head.addEventListener('drop', e => {
      e.preventDefault();
      head.classList.remove('col-drag-over');
      const fromKey = dragKey || e.dataTransfer.getData('text/plain');
      if (!fromKey || fromKey === key) return;
      const fromIdx = g_colOrder.indexOf(fromKey);
      const toIdx   = g_colOrder.indexOf(key);
      if (fromIdx < 0 || toIdx < 0) return;
      g_colOrder.splice(fromIdx, 1);
      g_colOrder.splice(toIdx, 0, fromKey);
      renderListHeader();
      renderListFilters();
      renderPhraseList();
      applyColWidthsCSS();
      saveColState();
    });
  });
}

function renderListFilters() {
  const blankCell = '<span class="cell-chk"></span>';
  document.getElementById('listFilters').innerHTML = blankCell + allCols().map(c => {
    const hidden = !g_colVisible.has(c.key);
    if (c.fixed) return `<span${hidden ? ' class="col-hidden-head"' : ''}></span>`;
    const val = escHtml(g_colFilters[c.key] || '');
    return `<input class="col-filter${hidden ? ' col-hidden-head' : ''}" data-col="${c.key}" `
      + `value="${val}" placeholder="…" spellcheck="false">`;
  }).join('');
}

function bindColResize() {
  document.querySelectorAll('.col-resize').forEach(handle => {
    handle.addEventListener('mousedown', e => {
      e.preventDefault();
      const key = handle.dataset.col;
      const startX = e.clientX;
      const startW = g_colWidths.get(key) ?? 130;
      handle.classList.add('dragging');
      const onMove = ev => {
        g_colWidths.set(key, Math.max(key === 'nr' ? 18 : 40, startW + ev.clientX - startX));
        applyColWidthsCSS();
      };
      const onUp = () => {
        handle.classList.remove('dragging');
        document.removeEventListener('mousemove', onMove);
        document.removeEventListener('mouseup', onUp);
        saveColState();
      };
      document.addEventListener('mousemove', onMove);
      document.addEventListener('mouseup', onUp);
    });
  });
}

function renderSortIndicators() {
  allCols().forEach(c => {
    const el = document.getElementById('si-' + c.key);
    if (el) el.textContent = g_sortCol === c.key ? (g_sortDir === 'asc' ? '▲' : '▼') : '';
    const gi = document.getElementById('gi-' + c.key);
    if (gi) {
      const on = g_groupByCol === c.key;
      gi.textContent = on ? '▤' : '';
      gi.title = on ? T('group.ind') : '';
    }
  });
}

// ── Column visibility menu (right-click on header) ────────────────────────────
function openColVisMenu(e) {
  e.preventDefault();
  e.stopPropagation();
  const menu = document.getElementById('colVisMenu');
  menu.innerHTML = '';
  // Group / ungroup by the right-clicked column
  const colHead = e.target.closest('[data-col-key]');
  const colKey = colHead?.dataset.colKey;
  const gcol = colKey ? allCols().find(c => c.key === colKey) : null;
  const setGroup = (key) => {
    g_groupByCol = key;
    g_collapsedGroups = key ? new Set(g_filtered.map(_phraseGroupValue).filter(Boolean)) : new Set();
    try { localStorage.setItem('expanto_group_col', g_groupByCol || ''); } catch (_) {}
    closeColVisMenu();
    renderSortIndicators();   // updates the ▤ group badge in the header
    applyFilter();
  };
  const addGroupItem = (text, onClick) => {
    const it = document.createElement('div');
    it.className = 'col-vis-item col-vis-action';
    const lbl = document.createElement('label');
    lbl.style.cursor = 'pointer';
    lbl.textContent = text;
    it.appendChild(lbl);
    it.addEventListener('click', onClick);
    menu.appendChild(it);
  };
  if (gcol && !gcol.fixed) {
    if (g_groupByCol === colKey) addGroupItem(T('group.off'), () => setGroup(null));
    else addGroupItem(T('group.by', gcol.isDynamic ? gcol.label : T('col.' + colKey)), () => setGroup(colKey));
  } else if (g_groupByCol) {
    addGroupItem(T('group.off'), () => setGroup(null));
  }
  if (menu.children.length) {
    const sep = document.createElement('div');
    sep.className = 'col-vis-sep';
    menu.appendChild(sep);
  }
  allCols().filter(c => !c.fixed).forEach(c => {
    const item = document.createElement('div');
    item.className = 'col-vis-item';
    const cb = document.createElement('input');
    cb.type = 'checkbox';
    cb.checked = g_colVisible.has(c.key);
    cb.addEventListener('change', () => {
      if (cb.checked) g_colVisible.add(c.key);
      else g_colVisible.delete(c.key);
      saveColState();
      renderListHeader();
      renderListFilters();
      applyColWidthsCSS();
      renderPhraseList();
    });
    const lbl = document.createElement('label');
    lbl.textContent = c.isDynamic ? c.label : T('col.' + c.key);
    lbl.style.cursor = 'pointer';
    lbl.prepend(cb);
    item.appendChild(lbl);
    menu.appendChild(item);
  });
  menu.style.top  = e.clientY + 'px';
  menu.style.left = e.clientX + 'px';
  menu.classList.remove('hidden');
}

function closeColVisMenu() {
  document.getElementById('colVisMenu')?.classList.add('hidden');
}

function fuzzyMatch(pattern, text) {
  let pi = 0;
  for (let i = 0; i < text.length && pi < pattern.length; i++)
    if (text[i] === pattern[pi]) pi++;
  return pi === pattern.length;
}

// ── Phase 2: group the phrase list by a column (toggled via the header menu) ──
function _colValue(p, key) {
  if (!key) return '';
  if (key.startsWith('cf_')) return String((p.customFields || {})[key.slice(3)] || '').trim();
  switch (key) {
    case 'trigger': return (p.trigger || '').trim();
    case 'phrase':  return (p.phrase || '').trim();
    case 'cat':     return (p.cat || '').trim();
    case 'tags':    return (p.tags || '').trim();
    case 'lang':    return (p.lang || '').trim();
    case 'file':    return (p.file || '').split(/[\\/]/).pop();
    default:        return '';
  }
}
function _phraseGroupValue(p) {
  return g_groupByCol ? _colValue(p, g_groupByCol) : '';
}

// Stable-cluster g_filtered by group value (ungrouped phrases keep their order, last).
function _applyPhraseGrouping() {
  let any = false;
  const tagged = g_filtered.map((p, idx) => { const gv = _phraseGroupValue(p); if (gv) any = true; return { p, gv, idx }; });
  if (!any) return;
  const order = [], seen = new Set();
  tagged.forEach(w => { if (w.gv && !seen.has(w.gv)) { seen.add(w.gv); order.push(w.gv); } });
  order.push('');
  const rank = new Map(order.map((g, i) => [g, i]));
  tagged.sort((a, b) => {
    const ra = rank.has(a.gv) ? rank.get(a.gv) : order.length;
    const rb = rank.has(b.gv) ? rank.get(b.gv) : order.length;
    return ra !== rb ? ra - rb : a.idx - b.idx;
  });
  g_filtered = tagged.map(w => w.p);
}

// The group row is a column-aligned summary of its member phrases (same grid as
// a phrase row): each column shows the aggregated value across the group.
function _buildPhraseGroupHeader(gv, radNr) {
  const members = g_filtered.filter(p => _phraseGroupValue(p) === gv);
  // A single-phrase group is not expandable — its header acts as the phrase's row.
  const single = members.length === 1;
  const collapsed = !single && g_collapsedGroups.has(gv);
  const hdr = document.createElement('div');
  hdr.className = 'phrase-group-hdr' + (collapsed ? ' collapsed' : '') + (single ? ' single' : '');
  if (single) {
    hdr.dataset.id = members[0].id;
    if (members[0].id === g_selId) hdr.classList.add('selected');
  }
  const cv = k => g_colVisible.has(k);
  const distinct = arr => [...new Set(arr.map(s => String(s == null ? '' : s).trim()).filter(Boolean))];
  const triggers = members.map(p => p.trigger).filter(Boolean);
  const joinedPhrases = members.map(p => p.phrase || '').join(' | ');
  const phraseCell = single ? (members[0].phrase || '')
                   : joinedPhrases.length > 60 ? `[${members.length} fraser]` : joinedPhrases;
  const cats  = distinct(members.flatMap(p => (p.cat  || '').split(',')));
  const tags  = distinct(members.flatMap(p => (p.tags || '').split(',')));
  const langs = distinct(members.map(p => p.lang));
  // same file-name logic as normal rows: per-file label, else basename
  // without the .ahk/.enc extension
  const files = distinct(members.map(p =>
    (g_fileSettingsCache[p.file]?.label) || (p.file || '').split(/[\\/]/).pop().replace(/\.(ahk|enc)$/i, '')));
  const arrow = `<span class="pgh-arrow">${collapsed ? '▸' : '▾'}</span>`;
  const stdCls = { nr: 'cell-nr', trigger: 'cell-trigger', phrase: 'cell-phrase', cat: 'cell-cat', tags: 'cell-tags', lang: 'cell-lang', file: 'cell-file' };
  const cells = allCols().map(c => {
    const vis = cv(c.key);
    const cls = ('cell ' + (stdCls[c.key] || '')).trim() + (vis ? '' : ' cell-hidden');
    if (!vis) return `<div class="${cls}"></div>`;
    let content = '', title = '';
    switch (c.key) {
      case 'nr':      content = single ? String(radNr || '') : arrow; break;
      case 'trigger': content = escHtml(triggers.join(', ')); title = triggers.join(', '); break;
      case 'phrase':  content = escHtml(phraseCell); title = joinedPhrases; break;
      case 'cat':     content = escHtml(cats.join(', ')); break;
      case 'tags':    content = tags.map(t => `<span class="tag-chip">${escHtml(t)}</span>`).join(''); break;
      case 'lang':    content = escHtml(langs.join(', ')); break;
      case 'file':    content = escHtml(files.join(', ')); break;
      default:        content = escHtml(distinct(members.map(p => (p.customFields || {})[c.key.slice(3)])).join(', ')); break;
    }
    return `<div class="${cls}"${title ? ` title="${escHtml(title)}"` : ''}>${content}</div>`;
  }).join('');
  hdr.innerHTML = `<div class="cell cell-chk"></div>` + cells;
  hdr.addEventListener('click', () => {
    if (single) {
      g_multiSel.clear();
      closeBulkPanel();
      selectPhrase(members[0].id);
      return;
    }
    if (g_collapsedGroups.has(gv)) g_collapsedGroups.delete(gv); else g_collapsedGroups.add(gv);
    renderPhraseList();
  });
  if (single) {
    hdr.addEventListener('dblclick', () => postToAhk({ action: 'insertPhrase', id: members[0].id }));
    hdr.addEventListener('contextmenu', e => {
      e.preventDefault();
      e.stopPropagation();
      showPhraseContextMenu(e, members[0].id, g_filtered.indexOf(members[0]));
    });
  }
  return hdr;
}

function renderPhraseList() {
  const container = document.getElementById('phraseList');
  container.innerHTML = '';
  if (g_filtered.length === 0) {
    const msg = g_recentMode === 'used' ? T('list.recentUsed')
              : g_recentMode === 'edited' ? T('list.recentEdited')
              : T('list.noMatch');
    container.innerHTML = `<div id="emptyState"><div class="empty-icon">🔍</div><p>${msg}</p></div>`;
    return;
  }
  const frag = document.createDocumentFragment();
  const grouping = g_filtered.some(p => _phraseGroupValue(p));
  const groupCounts = {};
  if (grouping) g_filtered.forEach(p => { const gv = _phraseGroupValue(p); if (gv) groupCounts[gv] = (groupCounts[gv] || 0) + 1; });
  let _curGroup = null;
  g_filtered.forEach((p, i) => {
    if (grouping) {
      const gv = _phraseGroupValue(p);
      // No header for the ungrouped bucket ('') — those phrases render as normal rows.
      if (gv !== _curGroup) { _curGroup = gv; if (gv) frag.appendChild(_buildPhraseGroupHeader(gv, i + 1)); }
      // Collapsed group → skip its rows. Single-phrase groups render only as their header.
      if (gv && (groupCounts[gv] === 1 || g_collapsedGroups.has(gv))) return;
    }
    const disabled = p.disabled == 1;
    const isMulti  = g_multiSel.has(p.id);
    let cls = 'phrase-row';
    if (p.id === g_selId) cls += ' selected';
    if (isMulti)          cls += ' multi-selected';
    if (disabled)         cls += ' disabled';
    const row = document.createElement('div');
    row.className = cls;
    row.dataset.id = p.id;
    row.dataset.idx = i;
    const tagHtml = (p.tags || '').split(',').filter(Boolean)
      .map(t => `<span class="tag-chip">${escHtml(t.trim())}</span>`).join('');
    const disabledBadge = disabled ? `<span class="tag-chip off">av</span>` : '';
    const cv = k => g_colVisible.has(k);
    const chkCell = g_checkboxMode
      ? `<div class="cell cell-chk"><input type="checkbox"${isMulti ? ' checked' : ''}></div>`
      : '<div class="cell cell-chk"></div>';
    const cells = allCols().map(c => {
      const vis = cv(c.key);
      switch (c.key) {
        case 'nr':      return vis ? `<div class="cell cell-nr">${i+1}</div>` : `<div class="cell cell-nr cell-hidden"></div>`;
        case 'trigger': return vis ? `<div class="cell cell-trigger" title="${escHtml(p.trigger)}">${escHtml(p.trigger)}</div>` : `<div class="cell cell-trigger cell-hidden"></div>`;
        case 'phrase':  return vis ? `<div class="cell cell-phrase" title="${escHtml(p.phrase)}">${escHtml(p.phrase)}</div>` : `<div class="cell cell-phrase cell-hidden"></div>`;
        case 'cat':     return vis ? `<div class="cell cell-cat">${escHtml(p.cat || '')}</div>` : `<div class="cell cell-cat cell-hidden"></div>`;
        case 'tags':    return vis ? `<div class="cell cell-tags">${disabledBadge}${tagHtml}</div>` : `<div class="cell cell-tags cell-hidden"></div>`;
        case 'lang':    return vis ? `<div class="cell cell-lang">${escHtml(p.lang || '')}</div>` : `<div class="cell cell-lang cell-hidden"></div>`;
        case 'file': {
          if (!vis) return `<div class="cell cell-file cell-hidden"></div>`;
          const fn = (g_fileSettingsCache[p.file]?.label) || (p.file || '').split(/[\\/]/).pop().replace(/\.(ahk|enc)$/i, '');
          return `<div class="cell cell-file" title="${escHtml(p.file || '')}">${escHtml(fn)}</div>`;
        }
        default: {
          const val = escHtml((p.customFields || {})[c.key.slice(3)] || '');
          return vis ? `<div class="cell" title="${val}">${val}</div>` : `<div class="cell cell-hidden"></div>`;
        }
      }
    }).join('');
    row.innerHTML = chkCell + cells;
    row.addEventListener('click', e => {
      if (e.target.type === 'checkbox') return; // handled by change event below
      if (g_checkboxMode) {
        _toggleMultiSel(p.id, i, e.shiftKey);
        return;
      }
      if (e.ctrlKey) {
        _toggleMultiSel(p.id, i, false);
        return;
      }
      if (e.shiftKey && g_lastClickIdx >= 0) {
        const lo = Math.min(g_lastClickIdx, i), hi = Math.max(g_lastClickIdx, i);
        g_multiSel.clear();
        for (let j = lo; j <= hi; j++) g_multiSel.add(g_filtered[j].id);
        g_selId = null;
        closeDetail();
        openBulkPanel();
        renderPhraseList();
        return;
      }
      g_lastClickIdx = i;
      g_multiSel.clear();
      closeBulkPanel();
      selectPhrase(p.id);
    });
    const chkInput = row.querySelector('input[type=checkbox]');
    if (chkInput) {
      chkInput.addEventListener('change', () => {
        _toggleMultiSel(p.id, i, false);
      });
    }
    row.addEventListener('contextmenu', e => {
      e.preventDefault();
      e.stopPropagation();
      showPhraseContextMenu(e, p.id, i);
    });
    row.addEventListener('dblclick', () => postToAhk({ action: 'insertPhrase', id: p.id }));

    row.draggable = true;
    row.addEventListener('dragstart', e => {
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('application/expanto-phrase-id', p.id);
      e.dataTransfer.setData('text/plain', p.id);
      setTimeout(() => row.classList.add('dragging'), 0);
    });
    row.addEventListener('dragend', () => {
      row.classList.remove('dragging');
      document.querySelectorAll('.file-item.drag-over').forEach(el => el.classList.remove('drag-over'));
    });

    frag.appendChild(row);
  });
  // "Select all" checkbox in header
  const chkAll = document.getElementById('chkSelectAll');
  if (chkAll) {
    chkAll.checked  = g_filtered.length > 0 && g_filtered.every(p => g_multiSel.has(p.id));
    chkAll.indeterminate = !chkAll.checked && g_multiSel.size > 0;
    chkAll.addEventListener('change', () => {
      if (chkAll.checked) g_filtered.forEach(p => g_multiSel.add(p.id));
      else g_multiSel.clear();
      if (g_multiSel.size >= 2) { g_selId = null; closeDetail(); openBulkPanel(); }
      else closeBulkPanel();
      renderPhraseList();
    });
  }
  container.appendChild(frag);
}

function _bulkAddTag() {
  const inp = document.getElementById('bTagInput');
  const tag = inp.value.trim();
  if (!tag) return;
  inp.value = '';
  if (g_bulkTagRemove.has(tag)) {
    g_bulkTagRemove.delete(tag); // un-remove existing tag
  } else if (!g_bulkTagAdd.has(tag)) {
    g_bulkTagAdd.add(tag);
  }
  renderBulkTagCloud();
}

function _parseTriggerAlias(val) {
  const parts = val.split(',').map(s => s.trim()).filter(Boolean);
  return { trigger: parts[0] || '', aliases: parts.slice(1).join(', ') };
}

// ── Alternative phrase texts (extra textareas under FRAS; pick one on insert) ──
// Each variant can carry an optional name ("Formell", "Kort", …) shown in the
// insert-time picker. Names travel as p.altNames: [mainName, alt1Name, …].
function _altInputs() {
  return [...document.querySelectorAll('#fAltList .alt-phrase-input')];
}
// Empty texts are dropped together with their name so the arrays stay aligned.
// altNames is [] when every name (incl. the main one) is empty.
function _collectAltData(trim) {
  const texts = [], names = [];
  document.querySelectorAll('#fAltList .alt-phrase-row').forEach(row => {
    const t  = row.querySelector('.alt-phrase-input');
    const tv = trim ? t.value.trim() : t.value;
    if (tv === '') return;
    texts.push(tv);
    names.push((row.querySelector('.alt-name-input')?.value || '').trim());
  });
  const mainName = (document.getElementById('fMainName')?.value || '').trim();
  let altNames = [mainName, ...names];
  if (!texts.length || altNames.every(n => !n)) altNames = [];
  return { alts: texts, altNames };
}
function _renderAlts(alts, names) {
  const list = document.getElementById('fAltList');
  if (!list) return;
  list.innerHTML = '';
  names = names || [];
  (alts || []).forEach((v, i) => _addAltBox(v, names[i + 1] || ''));
  const mn = document.getElementById('fMainName');
  if (mn) mn.value = names[0] || '';
  _syncMainNameVisibility();
}
// The main phrase's name field only appears once there are alternatives —
// a lone phrase has nothing to be named against.
function _syncMainNameVisibility() {
  const has = document.querySelectorAll('#fAltList .alt-phrase-input').length > 0;
  document.getElementById('fMainName')?.classList.toggle('hidden', !has);
}
function _addAltBox(val = '', name = '', focus = false) {
  const list = document.getElementById('fAltList');
  if (!list) return;
  const row = document.createElement('div');
  row.className = 'alt-phrase-row';
  const hdr = document.createElement('div');
  hdr.className = 'alt-row-hdr';
  const nameInp = document.createElement('input');
  nameInp.type = 'text';
  nameInp.className = 'field-input alt-name-input';
  nameInp.value = name;
  nameInp.placeholder = T('alt.name.ph');
  nameInp.spellcheck = false;
  const rm = document.createElement('button');
  rm.type = 'button';
  rm.className = 'alt-remove-btn';
  rm.title = T('alt.remove.tip');
  rm.tabIndex = -1;
  rm.textContent = '✕';
  rm.addEventListener('click', () => { row.remove(); _syncMainNameVisibility(); _scheduleAutosave(); });
  const ta = document.createElement('textarea');
  ta.className = 'field-input alt-phrase-input';
  ta.rows = 3;
  ta.value = val;
  ta.placeholder = T('alt.ph');
  ta.spellcheck = document.getElementById('spellEnabled')?.checked ?? true;
  ta.addEventListener('paste', _onListPaste);
  hdr.appendChild(nameInp);
  hdr.appendChild(rm);
  row.appendChild(hdr);
  row.appendChild(ta);
  list.appendChild(row);
  _syncMainNameVisibility();
  if (focus) ta.focus();
}

// ── Detail panel ──────────────────────────────────────────────────────────────
function selectPhrase(id) {
  _flushAutosave();
  if (g_settingsMode) leaveSettings();
  g_selId = id;
  g_newPhraseMode = false;
  postToAhk({ action: 'setSelected', id });
  document.querySelectorAll('.phrase-row, .phrase-group-hdr[data-id]').forEach(r =>
    r.classList.toggle('selected', r.dataset.id == id));
  const p = g_phrases.find(x => x.id === id);
  if (!p) return;
  const opts = p.options || '';
  document.getElementById('detailPanel').classList.remove('hidden');
  document.getElementById('detailTitle').textContent = p.trigger;
  document.getElementById('fFileGroup').style.display = 'none';
  document.getElementById('fStatusGroup').style.display = '';
  document.getElementById('fMetaGroup').style.display = '';
  document.getElementById('btnDelete').style.display = '';
  document.getElementById('btnDuplicate').style.display = '';
  document.getElementById('aiSplit').style.display  = '';
  document.getElementById('dupSplit').style.display = '';
  document.getElementById('fTrigger').value  = p.trigger + (p.aliases ? ', ' + p.aliases : '');
  document.getElementById('fApps').value     = p.apps    || '';
  document.getElementById('fPhrase').value   = p.phrase;
  _renderAlts(p.alts || [], p.altNames || []);
  document.getElementById('fCat').value      = p.cat || '';
  document.getElementById('fLang').value     = p.lang || '';
  document.getElementById('fComment').value  = p.comment || '';
  document.getElementById('fTags').value     = p.tags || '';
  document.getElementById('fOptStar').checked = opts.includes('*');
  document.getElementById('fOptQ').checked    = opts.includes('?');
  document.getElementById('fOptO').checked    = opts.includes('O') || opts.includes('o');
  document.getElementById('fOptC').checked    = opts.includes('C') && !opts.includes('C0') && !opts.includes('C1');
  document.getElementById('fDisabled').checked = p.disabled == 1;
  document.getElementById('fUrl').value = p.url || '';
  _updateUrlIcon();
  const file = (p.file || '').split(/[\\/]/).pop();
  document.getElementById('fMeta').innerHTML =
    `<span class="meta-badge" title="${escHtml(p.file || '')}">${escHtml(file)}</span>` +
    (p.lang ? `<span class="meta-badge">${escHtml(p.lang)}</span>` : '');
  document.getElementById('triggerDupWarn')?.classList.add('hidden'); document.getElementById('triggerDictWarn')?.classList.add('hidden');
  updateNewPhraseSuggestions(p.file);
  renderCustomFieldInputs(p.file, p.customFields || {});
  _applyAutosaveUI();
}

function closeDetail() {
  _flushAutosave();
  g_selId = null;
  g_newPhraseMode = false;
  document.getElementById('detailPanel').classList.add('hidden');
  document.querySelectorAll('.phrase-row').forEach(r => r.classList.remove('selected'));
  document.getElementById('fFileGroup').style.display = 'none';
  document.getElementById('fStatusGroup').style.display = '';
  document.getElementById('fMetaGroup').style.display = '';
  document.getElementById('btnDelete').style.display = '';
  document.getElementById('btnDuplicate').style.display = '';
  document.getElementById('triggerDupWarn')?.classList.add('hidden'); document.getElementById('triggerDictWarn')?.classList.add('hidden');
  document.getElementById('tagSuggestChips')?.classList.add('hidden');
  document.getElementById('customFieldsGroup')?.classList.add('hidden');
  g_moveSourceId = null;
  closeDupToMenu();
}

function saveEdited(insertAfterSave = false) {
  if (g_newPhraseMode) { saveNewPhrase(insertAfterSave); return; }
  const p = g_phrases.find(x => x.id === g_selId);
  if (!p) return;
  let opts = p.options || '';
  opts = setOpt(opts, '*', document.getElementById('fOptStar').checked);
  opts = setOpt(opts, '?', document.getElementById('fOptQ').checked);
  opts = setOpt(opts, 'O', document.getElementById('fOptO').checked);
  opts = setOpt(opts, 'C', document.getElementById('fOptC').checked);
  const { trigger: newTrigger, aliases: newAliases } = _parseTriggerAlias(document.getElementById('fTrigger').value);
  const rawPhrase    = document.getElementById('fPhrase').value;
  const shouldTrim   = document.getElementById('phraseTrim')?.checked;
  const savedPhrase  = shouldTrim ? rawPhrase.trim() : rawPhrase;
  const { alts, altNames } = _collectAltData(shouldTrim);
  const updated = {
    ...p,
    trigger:      newTrigger,
    aliases:      newAliases,
    apps:         document.getElementById('fApps').value.trim(),
    phrase:       savedPhrase,
    alts,
    altNames,
    cat:          document.getElementById('fCat').value.trim(),
    lang:         document.getElementById('fLang').value.trim(),
    comment:      document.getElementById('fComment').value.trim(),
    tags:         document.getElementById('fTags').value.trim(),
    options:      opts,
    disabled:     document.getElementById('fDisabled').checked ? 1 : 0,
    url:          document.getElementById('fUrl').value.trim(),
    customFields: getCustomFieldValues(p.file),
  };
  // With alternatives, always insert via the id path so the variant picker runs.
  const insertText = (insertAfterSave && shouldTrim && rawPhrase !== savedPhrase && !alts.length) ? rawPhrase : '';
  const propagate = _computePropagations(p, updated);
  postToAhk({ action: 'save', phrase: updated, insertAfterSave: !!insertAfterSave, insertText, propagate });
  if (propagate.length) showInfoToast(T('toast.propagated'));
}

function saveAndInsert() { saveEdited(true); }

function setOpt(opts, flag, on) {
  const has = opts.toUpperCase().includes(flag.toUpperCase());
  if (on && !has) return opts + flag;
  if (!on && has) return opts.split('').filter(c => c.toUpperCase() !== flag.toUpperCase()).join('');
  return opts;
}

function deleteSelected() {
  if (!g_selId) return;
  const p = g_phrases.find(x => x.id === g_selId);
  if (!p) return;
  if (!confirm(T('confirm.deletePhrase', p.trigger))) return;
  g_undoDeletePhrase = { ...p };
  g_showUndoToast    = true;
  postToAhk({ action: 'delete', id: g_selId });
}

function showUndoDeleteToast(p) {
  let el = document.getElementById('undoToast');
  if (!el) {
    el = document.createElement('div');
    el.id = 'undoToast';
    el.className = 'undo-toast hidden';
    document.body.appendChild(el);
  }
  clearTimeout(g_undoToastTimer);
  el.innerHTML = `${escHtml(T('toast.deleted', p.trigger))} <button onclick="undoDelete()">${escHtml(T('toast.undo'))}</button>`;
  el.classList.remove('hidden');
  g_undoToastTimer = setTimeout(() => {
    el.classList.add('hidden');
    g_undoDeletePhrase = null;
  }, 8000);
}

window.receiveBackups = function(path, slots) {
  const fileName = path.split(/[\\/]/).pop();
  document.getElementById('backupModalTitle').textContent = T('backup.title', fileName);
  const list = document.getElementById('backupList');
  if (!slots.length) {
    list.innerHTML = `<p class="backup-empty">${escHtml(T('backup.none'))}</p>`;
  } else {
    list.innerHTML = slots.map(s =>
      `<div class="backup-row">
        <span class="backup-info">${escHtml(T('backup.slot', s.slot, s.mtime))}</span>
        <button class="action-btn" data-path="${escHtml(path)}" data-slot="${s.slot}">${escHtml(T('backup.restore'))}</button>
      </div>`
    ).join('');
    list.querySelectorAll('button[data-slot]').forEach(btn => {
      btn.addEventListener('click', () => {
        postToAhk({ action: 'restoreBackup', path: btn.dataset.path, slot: parseInt(btn.dataset.slot) });
        showInfoToast(T('toast.backupRestored'));
        closeBackupModal();
      });
    });
  }
  document.getElementById('backupModal').classList.remove('hidden');
};

function closeBackupModal() {
  document.getElementById('backupModal').classList.add('hidden');
}

const HELP_TITLE_KEYS = {
  sharedFields:  'fs.sharedTitle',
  titleAutofill: 'fs.titleTitle',
};
function openHelpModal(key) {
  const src = document.getElementById('helpSrc_' + key);
  if (!src) return;
  document.getElementById('helpModalTitle').textContent = T(HELP_TITLE_KEYS[key] || 'help.title');
  document.getElementById('helpModalBody').innerHTML = src.innerHTML;
  document.getElementById('helpModal').classList.remove('hidden');
}
function closeHelpModal() {
  document.getElementById('helpModal').classList.add('hidden');
}

function showInfoToast(msg) {
  let el = document.getElementById('infoToast');
  if (!el) {
    el = document.createElement('div');
    el.id = 'infoToast';
    el.className = 'undo-toast hidden';
    document.body.appendChild(el);
  }
  clearTimeout(_infoToastTimer);
  el.textContent = msg;
  el.classList.remove('hidden');
  _infoToastTimer = setTimeout(() => el.classList.add('hidden'), 2000);
}

function undoDelete() {
  if (!g_undoDeletePhrase) return;
  postToAhk({ action: 'restorePhrase', data: g_undoDeletePhrase });
  g_undoDeletePhrase = null;
  clearTimeout(g_undoToastTimer);
  const el = document.getElementById('undoToast');
  if (el) el.classList.add('hidden');
}

function bulkDelete() {
  const n = g_multiSel.size;
  if (!n) return;
  if (!confirm(T('confirm.bulkDelete', n))) return;
  postToAhk({ action: 'bulkDelete', ids: [...g_multiSel] });
}

// ── New phrase in detail panel ────────────────────────────────────────────────
function openNewPhrase() {
  _flushAutosave();
  if (g_settingsMode) leaveSettings();
  document.getElementById('fileSettingsPanel').classList.add('hidden');
  g_newPhraseMode = true;
  g_selId = null;
  document.querySelectorAll('.phrase-row').forEach(r => r.classList.remove('selected'));
  document.getElementById('detailTitle').textContent = T('detail.new');
  document.getElementById('fFileGroup').style.display = '';
  document.getElementById('fStatusGroup').style.display = 'none';
  document.getElementById('fMetaGroup').style.display = 'none';
  document.getElementById('btnDelete').style.display = 'none';
  document.getElementById('btnDuplicate').style.display = 'none';
  // The AI and "duplicate ▾" actions need an existing, selected phrase — hide them
  // in new/copy mode so they don't sit there inert (that lone dead ▾ was the bug).
  document.getElementById('aiSplit').style.display  = 'none';
  document.getElementById('dupSplit').style.display = 'none';
  document.getElementById('fTrigger').value  = '';
  document.getElementById('fApps').value     = '';
  document.getElementById('fPhrase').value   = '';
  _renderAlts([], []);
  document.getElementById('fCat').value      = '';
  document.getElementById('fLang').value     = '';
  document.getElementById('fComment').value  = '';
  document.getElementById('fTags').value     = '';
  document.getElementById('fUrl').value      = '';
  ['fCat', 'fTags', 'fComment', 'fLang'].forEach(id => {
    const el = document.getElementById(id);
    if (el) delete el.dataset.aiSrc;
  });
  _aiLiveReset();
  _updateUrlIcon();
  document.getElementById('phraseTrim').checked = false;
  document.getElementById('fOptStar').checked = false;
  document.getElementById('fOptQ').checked    = false;
  document.getElementById('fOptO').checked    = false;
  document.getElementById('fOptC').checked    = false;

  // Pre-select file: last explicitly chosen file first, then the single
  // filtered file, then the default (first visible)
  const last = localStorage.getItem('expLastNewFile');
  const lastOk = last && g_files.some(f => f.path === last) ? last : null;
  const preselect = lastOk || (g_selFiles.size === 1 ? [...g_selFiles][0] : null);
  setNewFile(preselect || _defaultNewFilePath(), true);   // sets #fNewFile value + button label
  const chosen = document.getElementById('fNewFile').value;

  // Apply file-specific defaults
  _applyFileDefaults(chosen);

  document.getElementById('triggerDupWarn')?.classList.add('hidden'); document.getElementById('triggerDictWarn')?.classList.add('hidden');
  document.getElementById('detailPanel').classList.remove('hidden');
  document.getElementById('fTrigger').focus();
  updateNewPhraseSuggestions(chosen);
  _applyAutosaveUI();
}

function _applyFileDefaults(path) {
  if (!path) return;
  const cached = g_fileSettingsCache[path];
  if (!cached) {
    // Fetch asynchronously; AHK will call receiveFileSettings which caches, but not re-apply here
    // (User can change the file in the dropdown to trigger a re-apply via _onNewFilePick)
    postToAhk({ action: 'getFileSettings', path });
    return;
  }
  if (cached.defaultCat) document.getElementById('fCat').value = cached.defaultCat;
  renderCustomFieldInputs(path, {});
  updateNewPhraseSuggestions(path);
}

function _renderNewPhraseMetaHint(path, metaFields) {
  // Show meta-field hints inside the fMeta area (currently hidden in new mode → reuse for hint)
  if (!metaFields) return;
  const fields = metaFields.split(',').map(s => s.trim()).filter(Boolean);
  if (!fields.length) return;
  const group = document.getElementById('fMetaGroup');
  const meta  = document.getElementById('fMeta');
  group.style.display = '';
  const fname = _fileLabel(document.getElementById('fNewFile')?.value || '');
  meta.innerHTML =
    `<span style="font-size:11px;color:var(--text-dim);width:100%;margin-bottom:4px">Efterfrågas vid infogning i <em>${escHtml(fname)}</em>:</span>` +
    fields.map(f => `<span class="meta-badge">{${escHtml(f)}}</span>`).join('');
}

function saveNewPhrase(insertAfterSave = false) {
  const { trigger, aliases } = _parseTriggerAlias(document.getElementById('fTrigger').value);
  const rawPhrase  = document.getElementById('fPhrase').value;
  const shouldTrim = document.getElementById('phraseTrim')?.checked;
  const phrase     = shouldTrim ? rawPhrase.trim() : rawPhrase;
  const { alts, altNames } = _collectAltData(shouldTrim);
  const file       = document.getElementById('fNewFile').value;
  if (!trigger || !phrase) { alert(T('alert.triggerPhraseRequired')); return; }
  let opts = '';
  opts = setOpt(opts, '*', document.getElementById('fOptStar').checked);
  opts = setOpt(opts, '?', document.getElementById('fOptQ').checked);
  opts = setOpt(opts, 'O', document.getElementById('fOptO').checked);
  opts = setOpt(opts, 'C', document.getElementById('fOptC').checked);
  const moveSource = g_moveSourceId;
  g_moveSourceId = null;
  postToAhk({
    action:  'new',
    trigger, phrase, file, alts, altNames,
    cat:          document.getElementById('fCat').value.trim(),
    lang:         document.getElementById('fLang').value.trim(),
    tags:         document.getElementById('fTags').value.trim(),
    comment:      document.getElementById('fComment').value.trim(),
    aliases,
    apps:         document.getElementById('fApps').value.trim(),
    options:      opts,
    url:          document.getElementById('fUrl').value.trim(),
    customFields: getCustomFieldValues(file),
    _moveSourceId: moveSource || '',
    insertAfterSave: !!insertAfterSave,
    insertText: (insertAfterSave && shouldTrim && rawPhrase !== phrase && !alts.length) ? rawPhrase : '',
    // Post-save AI fill is only the safety net for saves that beat the live
    // suggestion — skip it when the panel already has category + language
    aiAuto: !!(g_aiEnabled && !file.toLowerCase().endsWith('.enc')
               && document.getElementById('fAiAuto')?.checked
               && !(document.getElementById('fCat').value.trim()
                    && document.getElementById('fLang').value.trim())),
  });
  localStorage.setItem('expLastNewFile', file);
  _aiLiveReset();
  closeDetail();
}

// ── AI actions ───────────────────────────────────────────────────────────────
// Live AI metadata suggestions while typing a new phrase: debounced on
// trigger/phrase input; fills only fields the user hasn't typed in themselves.
let _aiLiveTimer = null;
let _aiLiveSeq = 0;
let _aiLiveLastSent = '';

function _setAiAutoBusy(on) {
  document.getElementById('aiAutoRow')?.classList.toggle('ai-busy', !!on);
}

function _aiLiveReset() {
  clearTimeout(_aiLiveTimer);
  _aiLiveTimer = null;
  _aiLiveLastSent = '';
  _aiLiveSeq++;            // invalidates any in-flight response
  _setAiAutoBusy(false);
}

function _aiLiveArm() {
  if (!g_newPhraseMode) return;
  clearTimeout(_aiLiveTimer);
  _aiLiveTimer = setTimeout(_aiLiveFire, 1500);
}

function _aiLiveFire() {
  if (!g_newPhraseMode || !g_aiEnabled) return;
  const cb = document.getElementById('fAiAuto');
  if (!cb || !cb.checked || cb.disabled) return;
  const file = document.getElementById('fNewFile')?.value || '';
  if (!file || file.toLowerCase().endsWith('.enc')) return;
  const trigger = document.getElementById('fTrigger')?.value.trim() || '';
  const phrase  = document.getElementById('fPhrase')?.value.trim() || '';
  if (phrase.length < 3) return;
  const key = trigger + '\u0001' + phrase;
  if (key === _aiLiveLastSent) return;   // nothing new since last call
  _aiLiveLastSent = key;
  _aiLiveSeq++;
  _setAiAutoBusy(true);
  postToAhk({ action: 'aiSuggest', id: '', trigger, phrase, file, live: 1, seq: _aiLiveSeq });
}

function aiSuggestForSelected() {
  if (!g_selId) return;
  const p = g_phrases.find(x => x.id === g_selId);
  if (!p) return;
  const btn = document.getElementById('btnAiSuggest');
  btn.disabled = true;
  btn.textContent = '✨…';
  postToAhk({
    action:  'aiSuggest',
    id:      p.id,
    trigger: p.trigger,
    phrase:  p.phrase,
    file:    p.file,
  });
}

window.receiveGeneralSettings = function(data) {
  const el = document.getElementById('genEditorCmd');
  if (el) el.value = data.editorCmd || '';
  const chk = document.getElementById('genStartMinimized');
  if (chk) chk.checked = !!data.startMinimized;
  const auto = document.getElementById('genAutostart');
  if (auto) auto.checked = !!data.autostart;
};

function saveGeneralSettings() {
  postToAhk({
    action:         'saveGeneralSettings',
    editorCmd:      document.getElementById('genEditorCmd').value.trim(),
    startMinimized: !!(document.getElementById('genStartMinimized')?.checked),
    autostart:      !!(document.getElementById('genAutostart')?.checked),
  });
}

function saveAiSettings() {
  postToAhk({
    action:       'saveAiSettings',
    api_key:      document.getElementById('aiApiKey').value,
    model:        document.getElementById('aiModel').value,
    enabled:      document.getElementById('aiEnabled').checked,
    auto_tag:     document.getElementById('aiAutoTag').checked,
    exclude:      document.getElementById('aiExclude').value,
    llm_enabled:  document.getElementById('llmEnabled').checked,
    llm_endpoint: document.getElementById('llmEndpoint').value,
    llm_model:    document.getElementById('llmModel').value,
    llm_api_key:  document.getElementById('llmApiKey').value,
  });
}

function aiBatchVisible() {
  if (!g_aiEnabled && !g_llmEnabled) { alert(T('confirm.aiEnableFirst')); return; }
  if (!g_filtered.length) return;
  if (!confirm(T('confirm.aiBatch', g_filtered.length))) return;
  postToAhk({ action: 'aiBatch', ids: g_filtered.map(p => p.id) });
}

// ── Duplicate ─────────────────────────────────────────────────────────────────
function duplicatePhrase() {
  if (!g_selId) return;
  postToAhk({ action: 'duplicate', id: g_selId });
}

function _positionDropdown(menu, btnRect) {
  const estH = 120; // generous estimate before menu is visible
  const spaceBelow = window.innerHeight - btnRect.bottom;
  menu.style.left  = 'auto';
  menu.style.right = Math.max(0, window.innerWidth - btnRect.right) + 'px';
  menu.style.top   = spaceBelow >= estH + 6
    ? (btnRect.bottom + 4) + 'px'
    : (btnRect.top - estH - 4) + 'px';
  // After rendering, adjust vertically if still out of bounds
  requestAnimationFrame(() => {
    const mRect = menu.getBoundingClientRect();
    if (mRect.bottom > window.innerHeight - 4) {
      menu.style.top = Math.max(4, btnRect.top - mRect.height - 4) + 'px';
    }
    if (mRect.top < 4) menu.style.top = '4px';
  });
}

// Target files for the move/duplicate menus: grouped by folder (in the same
// config/INI order the sidebar uses), then alphabetical by display label within
// each folder.
function _sortTargetFiles(files) {
  const order = new Map();   // folderId → first-appearance index in g_files (= sidebar order)
  for (const f of g_files) {
    const fid = f.folder || '';
    if (!order.has(fid)) order.set(fid, order.size);
  }
  const label = f => (g_fileSettingsCache[f.path]?.label) || f.name || '';
  return [...files].sort((a, b) =>
    ((order.get(a.folder || '') ?? 0) - (order.get(b.folder || '') ?? 0))
    || label(a).localeCompare(label(b), undefined, { sensitivity: 'base' }));
}

function openDuplicateToMenu(e) {
  e.stopPropagation();
  const p = g_phrases.find(x => x.id === g_selId);
  if (!p) return;
  const menu = document.getElementById('dupToMenu');
  const files = _sortTargetFiles(g_files.filter(f => f.path !== p.file));
  const makeItems = (containerId, isMove) => {
    const container = document.getElementById(containerId);
    container.innerHTML = '';
    if (!files.length) {
      const el = document.createElement('div');
      el.className = 'dtm-item';
      el.style.color = 'var(--text-dim)';
      el.textContent = T('btn.noOtherFiles');
      container.appendChild(el);
      return;
    }
    files.forEach(f => {
      const cached = g_fileSettingsCache[f.path];
      const label = (cached?.label) || f.path.split(/[\\/]/).pop();
      const mf = cached?.metaFields;
      const el = document.createElement('div');
      el.className = 'dtm-item';
      el.innerHTML = `<span class="dtm-filename">${escHtml(label)}</span>` +
        (mf ? `<span class="dtm-hint">[${escHtml(mf)}]</span>` : '');
      el.addEventListener('click', () => {
        closeDupToMenu();
        // Duplicate to another file goes through the same prompt as same-file duplicate
        // (offer keep-dynamic vs fill-in for dynamic fields). Move still opens the form.
        if (isMove) openCopyToForm(p.id, f.path, true);
        else postToAhk({ action: 'duplicate', id: p.id, targetFile: f.path });
      });
      container.appendChild(el);
    });
  };
  makeItems('dupToFiles', false);
  makeItems('moveToFiles', true);
  const btn = document.getElementById('btnDuplicateMore');
  const rect = btn.getBoundingClientRect();
  _positionDropdown(menu, rect);
  menu.classList.remove('hidden');
}

function closeDupToMenu() {
  document.getElementById('dupToMenu')?.classList.add('hidden');
}

function openCopyToForm(sourceId, targetFile, isMove) {
  const p = g_phrases.find(x => x.id === sourceId);
  if (!p) return;
  openNewPhrase();
  // Override target file
  if (targetFile) {
    setNewFile(targetFile, true);   // target may be a hidden file — picker keeps it selectable
    _applyFileDefaults(targetFile);
    updateNewPhraseSuggestions(targetFile);
    renderCustomFieldInputs(targetFile, p.customFields || {});
  }
  // Pre-fill from source phrase
  document.getElementById('fApps').value     = p.apps    || '';
  document.getElementById('fPhrase').value   = p.phrase;
  _renderAlts(p.alts || [], p.altNames || []);
  document.getElementById('fCat').value      = p.cat    || '';
  document.getElementById('fLang').value     = p.lang   || '';
  document.getElementById('fComment').value  = p.comment || '';
  document.getElementById('fTags').value     = p.tags    || '';
  const opts = p.options || '';
  document.getElementById('fOptStar').checked = opts.includes('*');
  document.getElementById('fOptQ').checked    = opts.includes('?');
  document.getElementById('fOptO').checked    = opts.includes('O') || opts.includes('o');
  document.getElementById('fOptC').checked    = opts.includes('C') && !opts.includes('C0') && !opts.includes('C1');
  document.getElementById('fTrigger').value  = p.trigger + (p.aliases ? ', ' + p.aliases : '');
  document.getElementById('fUrl').value      = p.url || '';
  _updateUrlIcon();
  document.getElementById('detailTitle').textContent = isMove ? T('detail.moveTo') : T('detail.dupTo');
  if (isMove) g_moveSourceId = sourceId;
  document.getElementById('triggerDupWarn')?.classList.add('hidden'); document.getElementById('triggerDictWarn')?.classList.add('hidden');
  document.getElementById('fTrigger').focus();
}

// ── Phrase link (url metadata) ────────────────────────────────────────────────
function _updateUrlIcon() {
  const has = !!(document.getElementById('fUrl')?.value || '').trim();
  document.getElementById('detailUrlIcon')?.classList.toggle('hidden', !has);
  const openBtn = document.getElementById('btnUrlOpen');
  if (openBtn) openBtn.disabled = !has;
}

// AHK returns the file chosen via the 📂 browse button.
window.receiveLinkFile = function(path) {
  const el = document.getElementById('fUrl');
  if (!el || !path) return;
  el.value = path;
  _updateUrlIcon();
};

// ── Auto-save (on by default; toggle in General settings) ─────────────────────
function applyAutosave(on) {
  if (!on) _flushAutosave();           // commit any pending edit while autosave is still on
  g_autosave = !!on;
  try { localStorage.setItem('expanto_autosave', on ? '1' : '0'); } catch (_) {}
  const ga = document.getElementById('genAutosave');
  if (ga) ga.checked = g_autosave;
  _applyAutosaveUI();
}

// Show/hide the Save buttons for the current panel mode. With autosave on while
// editing an existing phrase: hide plain "Spara", turn "Spara & infoga" into "Infoga".
function _applyAutosaveUI() {
  const editMode = !g_newPhraseMode && !!g_selId;
  const auto = g_autosave && editMode;
  const btnSave = document.getElementById('btnSave');
  const btnSaveOnly = document.getElementById('btnSaveOnly');
  const btnCancel = document.getElementById('btnCancel');
  if (btnSaveOnly) btnSaveOnly.style.display = auto ? 'none' : '';
  if (btnSave) btnSave.textContent = auto ? T('btn.insert') : T('btn.save');
  if (btnCancel) btnCancel.textContent = auto ? T('btn.close') : T('btn.cancel');
}

function _scheduleAutosave() {
  if (!g_autosave || g_newPhraseMode || !g_selId) return;
  _autosaveDirty = true;
  clearTimeout(_autosaveTimer);
  _autosaveTimer = setTimeout(_flushAutosave, 700);
}

function _flushAutosave() {
  clearTimeout(_autosaveTimer);
  if (!_autosaveDirty || !g_autosave || g_newPhraseMode || !g_selId) { _autosaveDirty = false; return; }
  const p = g_phrases.find(x => x.id === g_selId);
  if (!p) { _autosaveDirty = false; return; }
  const { trigger } = _parseTriggerAlias(document.getElementById('fTrigger').value);
  const phrase = document.getElementById('fPhrase').value;
  if (!trigger || !phrase.trim()) { _autosaveDirty = false; return; }   // never save an incomplete phrase
  _autosaveDirty = false;
  saveEdited(false);
  // Editing the trigger changes the phrase id (path|trigger); re-point so later edits still save.
  g_selId = p.file + '|' + trigger;
}

// ── File settings panel ───────────────────────────────────────────────────────
function openFileSettings(path) {
  if (g_settingsMode) leaveSettings();

  const sel = document.getElementById('fsFilePicker');
  sel.innerHTML = '';
  g_files.forEach(f => {
    const opt = document.createElement('option');
    opt.value = f.path;
    const cached = g_fileSettingsCache[f.path];
    opt.textContent = (cached?.label || f.name);
    sel.appendChild(opt);
  });
  if (path && g_files.some(f => f.path === path)) sel.value = path;
  else if (g_files.length) sel.value = g_files[0].path;

  g_fileSettingsFile = sel.value;
  document.getElementById('fsTitle').textContent = T('fs.title');
  document.getElementById('detailPanel').classList.add('hidden');
  document.getElementById('fileSettingsPanel').classList.remove('hidden');
  fetchAndShowFileSettings(g_fileSettingsFile);
}

function fetchAndShowFileSettings(path) {
  if (!path) return;
  _fsUpdateRenameField(path);
  const cached = g_fileSettingsCache[path];
  if (cached) {
    document.getElementById('fsLabel').value      = cached.label      || '';
    document.getElementById('fsDefaultCat').value = cached.defaultCat || '';
    document.getElementById('fsMetaFields').value = cached.metaFields || '';
    _fsSetCouplingFields(cached);
    updateFsMetaPreview();
  } else {
    document.getElementById('fsLabel').value      = '';
    document.getElementById('fsDefaultCat').value = '';
    document.getElementById('fsMetaFields').value = '';
    _fsSetCouplingFields({});
    updateFsMetaPreview();
    postToAhk({ action: 'getFileSettings', path });
  }
}

function closeFileSettings() {
  g_fileSettingsFile = null;
  document.getElementById('fileSettingsPanel').classList.add('hidden');
}

// Show the current base filename in the rename input; keep the extension as a hint.
function _fsUpdateRenameField(path) {
  const inp  = document.getElementById('fsRenameInput');
  const hint = document.getElementById('fsRenameHint');
  const err  = document.getElementById('fsRenameError');
  if (!inp) return;
  const file = (path || '').split(/[\\/]/).pop() || '';
  const dot  = file.lastIndexOf('.');
  const base = dot > 0 ? file.slice(0, dot) : file;
  const ext  = dot > 0 ? file.slice(dot)    : '';
  inp.value = base;
  if (hint) hint.textContent = ext ? `Tillägget ${ext} behålls. Filen ligger kvar i samma mapp; fraser, inställningar och statistik följer med.` : '';
  if (err) err.classList.add('hidden');
}

function renameFileNow() {
  const path = g_fileSettingsFile || document.getElementById('fsFilePicker').value;
  if (!path) return;
  const newName = document.getElementById('fsRenameInput').value.trim();
  if (!newName) return;
  document.getElementById('fsRenameError').classList.add('hidden');
  postToAhk({ action: 'renameFile', path, newName });
}

window.renameFileError = function(msg) {
  const err = document.getElementById('fsRenameError');
  if (!err) return;
  err.textContent = msg;
  err.classList.remove('hidden');
};

window.renameFileDone = function(newPath) {
  g_fileSettingsFile = newPath;
  // g_files was already refreshed by receiveFiles — rebuild the picker and reselect.
  const sel = document.getElementById('fsFilePicker');
  if (sel) {
    sel.innerHTML = '';
    g_files.forEach(f => {
      const opt = document.createElement('option');
      opt.value = f.path;
      const cached = g_fileSettingsCache[f.path];
      opt.textContent = (cached?.label || f.name);
      sel.appendChild(opt);
    });
    sel.value = newPath;
  }
  _fsUpdateRenameField(newPath);
  fetchAndShowFileSettings(newPath);
  showInfoToast(T('toast.fileRenamed'));
};

function saveFileSettingsNow() {
  const path = g_fileSettingsFile || document.getElementById('fsFilePicker').value;
  if (!path) return;
  const data = {
    action:     'saveFileSettings',
    path,
    label:      document.getElementById('fsLabel').value.trim(),
    defaultCat: document.getElementById('fsDefaultCat').value.trim(),
    metaFields: document.getElementById('fsMetaFields').value.trim(),
    groupField:   document.getElementById('fsGroupField').value.trim(),
    titleFields:  document.getElementById('fsTitleFields').value.trim(),
    titlePattern: document.getElementById('fsTitlePattern').value.trim(),
    sharedFields: _fsCollectSharedFields(),
  };
  g_fileSettingsCache[path] = {
    label:      data.label,
    defaultCat: data.defaultCat,
    metaFields: data.metaFields,
    groupField:   data.groupField,
    titleFields:  data.titleFields,
    titlePattern: data.titlePattern,
    sharedFields: data.sharedFields,
    hidden:     g_fileSettingsCache[path]?.hidden || false,
  };
  // Refresh the file picker label
  const sel = document.getElementById('fsFilePicker');
  for (const opt of sel.options)
    if (opt.value === path) { opt.textContent = data.label || path.split(/[\\/]/).pop(); break; }
  postToAhk(data);
}

function updateFsMetaPreview() {
  const raw = document.getElementById('fsMetaFields').value;
  const fields = raw.split(',').map(s => s.trim()).filter(Boolean);
  const preview = document.getElementById('fsMetaPreview');
  const content = document.getElementById('fsMetaPreviewContent');
  if (!fields.length) { preview.style.display = 'none'; return; }
  preview.style.display = '';
  content.innerHTML = fields.map(f => `<span class="fs-meta-chip">{${escHtml(f)}}</span>`).join('');
}

// ── Key capture ("Fånga tangent") ────────────────────────────────────────────
// Keys that can act as the left-hand side of a custom AHK combination (held + another key).
// Standard modifiers (Ctrl/Shift/Alt/Win) are handled via e.ctrlKey etc.; these are extras.
const COMBO_TRIGGER_KEYS = new Set(['CapsLock', 'F1','F2','F3','F4','F5','F6','F7','F8','F9','F10','F11','F12']);
let g_captureComboMod = null; // held combo-trigger key waiting for a second key

function startKeyCapture() {
  if (!g_captureTarget) {
    document.getElementById('captureStatus').textContent = T('capture.focusFirst');
    return;
  }
  g_capturingKey = true;
  g_captureComboMod = null;
  document.getElementById('captureStatus').textContent = T('capture.waiting');
  document.getElementById('btnCaptureKey').textContent = T('capture.btn.working');
  document.addEventListener('keydown', onCaptureKey, { capture: true });
  document.addEventListener('keyup',   onCaptureKeyUp, { capture: true });
}

function _endCapture() {
  g_capturingKey = false;
  g_captureComboMod = null;
  document.removeEventListener('keydown', onCaptureKey, { capture: true });
  document.removeEventListener('keyup',   onCaptureKeyUp, { capture: true });
  document.getElementById('btnCaptureKey').textContent = T('capture.btn.ready');
}

function onCaptureKeyUp(e) {
  // Combo-trigger released without a second key — cancel combo mode
  if (g_captureComboMod && e.key === g_captureComboMod) {
    g_captureComboMod = null;
    _endCapture();
    document.getElementById('captureStatus').textContent = T('capture.aborted');
  }
}

function onCaptureKey(e) {
  e.preventDefault();
  e.stopPropagation();

  const keyMap = {
    ' ': 'Space', 'ArrowUp': 'Up', 'ArrowDown': 'Down', 'ArrowLeft': 'Left', 'ArrowRight': 'Right',
    'Enter': 'Enter', 'Tab': 'Tab', 'Escape': 'Escape', 'Backspace': 'Backspace',
    'Delete': 'Delete', 'Insert': 'Insert', 'Home': 'Home', 'End': 'End',
    'PageUp': 'PgUp', 'PageDown': 'PgDn', 'PrintScreen': 'PrintScreen', 'ScrollLock': 'ScrollLock',
    'Pause': 'Pause', 'CapsLock': 'CapsLock', 'NumLock': 'NumLock',
  };
  const toAhkKey = k => keyMap[k] || (/^F\d+$/.test(k) ? k : (k.length === 1 ? k.toLowerCase() : k));

  const pureModifiers = ['Shift','Control','Alt','Meta','AltGraph'];

  // First key is a combo-trigger (e.g. CapsLock) — wait for the second key
  if (!g_captureComboMod && COMBO_TRIGGER_KEYS.has(e.key)) {
    g_captureComboMod = e.key;
    document.getElementById('captureStatus').textContent = T('capture.holdKey', toAhkKey(e.key));
    return; // keep listeners active
  }

  // Ignore lone standard modifiers
  if (pureModifiers.includes(e.key)) return;

  let combo;
  if (g_captureComboMod) {
    // Custom combination: CapsLock & Space  (AHK syntax)
    combo = toAhkKey(g_captureComboMod) + ' & ' + toAhkKey(e.key);
  } else {
    let prefix = '';
    if (e.ctrlKey && e.altKey) prefix = '<^>!';
    else {
      if (e.shiftKey) prefix += '+';
      if (e.ctrlKey)  prefix += '^';
      if (e.altKey)   prefix += '!';
      if (e.metaKey)  prefix += '#';
    }
    combo = prefix + toAhkKey(e.key);
  }

  _endCapture();
  if (g_captureTarget) g_captureTarget.value = combo;
  document.getElementById('captureStatus').textContent = T('capture.captured', combo);
}

// ── Hotkey settings save ──────────────────────────────────────────────────────
function saveHotkeySettings() {
  const get = id => document.getElementById(id)?.value || '';
  const chk = id => document.getElementById(id)?.checked || false;
  postToAhk({
    action: 'saveHotkeySettings',
    OpenGui:      get('hkOpenGui'),   MarkWord:    get('hkMarkWord'),
    StepNext:     get('hkStepNext'),  Undo:        get('hkUndo'),
    LastFired:    get('hkLastFired'), CapsCapture: chk('hkCapsCap') ? 1 : 0,
    New:          get('hkNew'),       Update:      get('hkUpdate'),
    Delete:       get('hkDelete'),    FilterFile:  get('hkFiltFile'),
    FilterCat:    get('hkFiltCat'),   FilterTag:   get('hkFiltTag'),
    AssignCat:    get('hkAssignCat'), AssignTag:   get('hkAssignTag'),
    SwitchField:  get('hkSwitchField'), AiSuggest: get('hkAiSuggest'),
    Layout:       get('hkLayout'),    OnTop:       get('hkOnTop'),
    MoveFile:     get('hkMoveFile'),  Settings:    get('hkSettings'),
    EditFile:     get('hkEditFile'),  LastEdited:  get('hkLastEdited'),
    Dupes:        get('hkDupes'),     Panel:       get('hkPanel'),
    Insert:       get('hkInsert'),    InsertStep:  get('hkInsertStep'),
    QkFilterFile: get('qkFiltFile'),  QkFilterCat: get('qkFiltCat'),
    QkFilterTag:  get('qkFiltTag'),   QkMoveFile:  get('qkMoveFile'),
    QkAssignCat:  get('qkAssignCat'), QkAssignTag: get('qkAssignTag'),
  });
  // Save field-nav keys to localStorage
  const akIds = { fTrigger:'akFTrigger', fApps:'akFApps', fPhrase:'akFPhrase', fCat:'akFCat',
                  fTags:'akFTags', fLang:'akFLang', fComment:'akFComment', bFile:'akBFile' };
  Object.entries(akIds).forEach(([fid, inpId]) => {
    const v = (document.getElementById(inpId)?.value || '').toLowerCase().trim().slice(0, 1);
    if (v) g_fieldKeys[fid] = v;
    else   g_fieldKeys[fid] = FIELD_AK_DEFAULTS[fid];
  });
  // bTagInput mirrors fTags key (same letter, different panel)
  g_fieldKeys.bTagInput = g_fieldKeys.fTags;
  g_fieldKeys.bCat      = g_fieldKeys.fCat;
  g_fieldKeys.bLang     = g_fieldKeys.fLang;
  g_fieldKeys.bComment  = g_fieldKeys.fComment;
  try { localStorage.setItem('expanto_field_keys', JSON.stringify(g_fieldKeys)); } catch(_) {}
  applyFieldKeys();
}

// ── Popup settings save ───────────────────────────────────────────────────────
function savePopupSettings() {
  const get = id => document.getElementById(id)?.value ?? '';
  const chk = id => document.getElementById(id)?.checked || false;
  postToAhk({
    action:    'savePopupSettings',
    enabled:   chk('popupEnabled') ? 1 : 0,
    fuzzy:     chk('popupFuzzy')   ? 1 : 0,
    chars:     parseInt(get('popupChars'), 10)   || 2,
    timeout:   parseInt(get('popupTimeout'), 10) || 0,
    insertKey: get('popupInsert'),
    upKey:     get('popupUp'),
    downKey:   get('popupDown'),
    numKey:    get('popupNumKey'),
  });
}

// ── Dynamic fields grid + save ────────────────────────────────────────────────
function renderDynAppGrid() {
  const container = document.getElementById('dynAppRows');
  container.innerHTML = '';
  if (!g_dynAppModes.length) {
    container.innerHTML = `<div class="dyn-app-empty">${T('dynApp.empty')}</div>`;
    return;
  }
  g_dynAppModes.forEach((row, i) => {
    const div = document.createElement('div');
    div.className = 'dyn-app-row';
    div.innerHTML =
      `<input class="field-input" value="${escHtml(row.app)}" placeholder="${escHtml(T('dynApp.appPh'))}" spellcheck="false">` +
      `<select>` +
        `<option value="auto"${row.mode==='auto'?' selected':''}>${T('dynApp.mode.auto')}</option>` +
        `<option value="inline"${row.mode==='inline'?' selected':''}>${T('dynApp.mode.inline')}</option>` +
        `<option value="dialog"${row.mode==='dialog'?' selected':''}>${T('dynApp.mode.dialog')}</option>` +
        `<option value="off"${row.mode==='off'?' selected':''}>${T('dynApp.mode.off')}</option>` +
      `</select>` +
      `<button class="dyn-app-del" title="${escHtml(T('btn.delete'))}">✕</button>`;
    div.querySelector('input').addEventListener('input', e => { g_dynAppModes[i].app = e.target.value; });
    div.querySelector('select').addEventListener('change', e => { g_dynAppModes[i].mode = e.target.value; });
    div.querySelector('.dyn-app-del').addEventListener('click', () => {
      g_dynAppModes.splice(i, 1);
      renderDynAppGrid();
    });
    container.appendChild(div);
  });
}

function saveDynamicSettings() {
  postToAhk({
    action:      'saveDynamicSettings',
    defaultMode: document.getElementById('dynDefaultMode').value,
    stepLabels:  document.getElementById('dynStepLabels').value,
    appModes:    g_dynAppModes.filter(r => r.app.trim()),
    pasteMode:   document.getElementById('pasteMode').value,
    pasteMinLen: parseInt(document.getElementById('pasteMinLen').value, 10) || 30,
  });
}

// ── Keyboard navigation ───────────────────────────────────────────────────────
function onGlobalKey(e) {
  const tag = document.activeElement.tagName;
  const inInput = tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT';

  const isSearch = document.activeElement?.id === 'searchBox';

  // Enter NEVER inserts a phrase. In the search box it commits the search by
  // selecting the top result; inside an edit field it falls through to the default
  // (newline in the phrase textarea). Insert = Ctrl+Enter, save-only = Alt+Enter.
  if (e.key === 'Enter' && !e.ctrlKey && !e.altKey && isSearch) {
    e.preventDefault();
    pushSearchHistory(document.getElementById('searchBox').value);
    if (g_filtered.length) {
      const id = g_filtered.some(p => p.id === g_selId) ? g_selId : g_filtered[0].id;
      selectPhrase(id);
      const row = document.querySelector(`.phrase-row[data-id="${id}"]`);
      if (row) row.scrollIntoView({ block: 'nearest' });
    }
    return;
  }

  if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
    if (inInput && !isSearch) return;
    const sb = document.getElementById('searchBox');
    const dir = e.key === 'ArrowDown' ? 1 : -1;

    // ArrowUp in empty searchBox → browse backwards through search history
    if (isSearch && dir < 0 && !sb.value) {
      e.preventDefault();
      if (!g_searchHistory.length) return;
      if (g_searchHistIdx === -1) {
        g_searchHistSaved = '';
        g_searchHistIdx = g_searchHistory.length - 1;
      } else if (g_searchHistIdx > 0) {
        g_searchHistIdx--;
      } else {
        return;
      }
      sb.value = g_searchHistory[g_searchHistIdx];
      applyFilter();
      return;
    }

    // ArrowDown while in history mode → step forward / back to current
    if (isSearch && dir > 0 && g_searchHistIdx >= 0) {
      e.preventDefault();
      if (g_searchHistIdx < g_searchHistory.length - 1) {
        g_searchHistIdx++;
        sb.value = g_searchHistory[g_searchHistIdx];
      } else {
        g_searchHistIdx = -1;
        sb.value = g_searchHistSaved;
      }
      applyFilter();
      return;
    }

    // Navigate phrase list (works both from searchBox and from no-input context)
    e.preventDefault();
    const cur = g_filtered.findIndex(p => p.id === g_selId);
    let next;
    if (cur < 0) {
      next = dir > 0 ? 0 : g_filtered.length - 1;
    } else {
      next = Math.max(0, Math.min(g_filtered.length - 1, cur + dir));
    }
    const p = g_filtered[next];
    if (!p) return;
    selectPhrase(p.id);
    const row = document.querySelector(`.phrase-row[data-id="${p.id}"]`);
    if (row) row.scrollIntoView({ block: 'nearest' });

  } else if (e.key === 'Escape') {
    if (document.activeElement?.id === 'searchBox') {
      const sb = document.getElementById('searchBox');
      if (sb.value) { sb.value = ''; applyFilter(); }
      sb.blur();  // always blur so second Escape reaches closeDetail
      return;
    }
    if (inInput) document.activeElement.blur();
    if (g_settingsMode) { leaveSettings(); return; }
    if (!document.getElementById('detailPanel').classList.contains('hidden')) {
      closeDetail();
    } else {
      postToAhk({ action: 'closeGui' });
    }

  } else if (e.ctrlKey && e.key === 'Enter') {
    e.preventDefault();
    if (g_selId || g_newPhraseMode) saveAndInsert();
  } else if (e.altKey && !e.ctrlKey && e.key === 'Enter') {
    // Alt+Enter → save/update only (no insert)
    e.preventDefault();
    if (g_selId || g_newPhraseMode) saveEdited();
  } else if (e.ctrlKey && e.key === 's') {
    e.preventDefault();
    if (g_selId || g_newPhraseMode) saveEdited();
  } else if (e.ctrlKey && e.key === 'a') {
    // Allow Ctrl+A in any input/textarea (select all text in field); intercept only on the list
    if (inInput) return;
    if (g_settingsMode || g_newPhraseMode) return;
    e.preventDefault();
    selectAll();
  } else if (e.altKey && !e.ctrlKey && !e.shiftKey && e.key.length === 1) {
    // Alt+letter → jump to specific field in the active panel
    const key    = e.key.toLowerCase();
    const inDet  = !document.getElementById('detailPanel').classList.contains('hidden');
    const inBulk = !document.getElementById('bulkPanel').classList.contains('hidden');
    if (!inDet && !inBulk) return;
    // Find matching field
    const match = Object.entries(g_fieldKeys).find(([fid, k]) => {
      if (k !== key) return false;
      if (DETAIL_AK_FIELDS.has(fid) && !inDet)  return false;
      if (BULK_AK_FIELDS.has(fid)   && !inBulk) return false;
      return true;
    });
    if (!match) return;
    e.preventDefault();
    // The new-phrase file picker is a custom control — focus its button and open the tree.
    if (match[0] === 'fNewFile') {
      const btn = document.getElementById('fNewFileBtn');
      if (btn) btn.focus();
      openFilePickerMenu();
      return;
    }
    const el = document.getElementById(match[0]);
    if (!el) return;
    el.focus();
    if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') el.select();
    // For native dropdowns, actually open the picker (focus alone wouldn't reveal the list)
    else if (el.tagName === 'SELECT') { try { el.showPicker(); } catch (_) {} }
  }
}

// ── Tag cloud ─────────────────────────────────────────────────────────────────
function renderTagCloud() {
  const tagCounts = {}, langCounts = {};
  const scopeFiles = g_selFiles.size > 0;
  const scopeCats  = g_selCats.size  > 0;
  for (const p of (g_showHiddenFiles ? g_phrases : g_phrases.filter(p2 => !g_fileSettingsCache[p2.file]?.hidden))) {
    if (scopeFiles && !g_selFiles.has(p.file)) continue;
    if (scopeCats  && !g_selCats.has(p.cat))  continue;
    (p.tags || '').split(',').forEach(t => {
      const tt = t.trim();
      if (tt) tagCounts[tt] = (tagCounts[tt] || 0) + 1;
    });
    const lang = (p.lang || '').trim();
    if (lang) langCounts[lang] = (langCounts[lang] || 0) + 1;
  }
  const cloud = document.getElementById('tagCloud');
  if (!cloud) return;
  cloud.innerHTML = '';
  if (scopeFiles || scopeCats) {
    const scopeKey = (scopeFiles && scopeCats) ? 'scope.fileCat' : scopeFiles ? 'scope.file' : 'scope.cat';
    cloud.insertAdjacentHTML('beforeend',
      `<span class="filter-scope-note" style="display:block;margin-bottom:4px;cursor:default;font-style:italic">${T(scopeKey)}</span>`);
  }
  if (g_selTags.size) {
    const clear = document.createElement('span');
    clear.className = 'tc-clear';
    clear.textContent = T('tags.clearSelection');
    clear.addEventListener('click', () => { g_selTags.clear(); renderTagCloud(); applyFilter(); });
    cloud.appendChild(clear);
  }
  if (!Object.keys(tagCounts).length) {
    cloud.insertAdjacentHTML('beforeend', `<span style="font-size:11px;color:var(--text-dim);padding:2px">${T('tags.none')}</span>`);
  }
  const _selPhrase = g_selId ? g_phrases.find(p => p.id === g_selId) : null;
  const _selPhrTags = new Set(_selPhrase ? (_selPhrase.tags || '').split(',').map(t => t.trim()).filter(Boolean) : []);
  Object.entries(tagCounts).sort((a, b) => {
    const ai = _selPhrTags.has(a[0]), bi = _selPhrTags.has(b[0]);
    return ai !== bi ? (ai ? -1 : 1) : b[1] - a[1];
  }).forEach(([tag, cnt]) => {
    const chip = document.createElement('span');
    chip.className = 'tc-chip' + (g_selTags.has(tag) ? ' active' : '');
    chip.textContent = tag;
    chip.title = T('tags.chip.count', cnt);
    chip.addEventListener('click', () => {
      g_selTags.has(tag) ? g_selTags.delete(tag) : g_selTags.add(tag);
      renderTagCloud(); applyFilter();
    });
    cloud.appendChild(chip);
  });
  const langList = document.getElementById('langList');
  if (!langList) return;
  langList.innerHTML = '';
  if (!Object.keys(langCounts).length) return;
  const allLi = document.createElement('li');
  allLi.className = g_selLangs.size === 0 ? 'selected' : '';
  allLi.innerHTML = `<span class="li-name">${T('allFilter')}</span><span class="li-count">${g_phrases.length}</span>`;
  allLi.addEventListener('click', () => { g_selLangs.clear(); renderTagCloud(); applyFilter(); });
  langList.appendChild(allLi);
  Object.entries(langCounts).sort((a,b) => b[1]-a[1]).forEach(([lang, cnt]) => {
    const li = document.createElement('li');
    li.className = g_selLangs.has(lang) ? 'selected' : '';
    li.innerHTML = `<span class="li-name">${escHtml(lang)}</span><span class="li-count">${cnt}</span>`;
    li.addEventListener('click', () => {
      g_selLangs.has(lang) ? g_selLangs.delete(lang) : g_selLangs.add(lang);
      renderTagCloud(); applyFilter();
    });
    langList.appendChild(li);
  });
}

// ── Trigger duplicate / dict check ───────────────────────────────────────────
let _dictCheckTimer = null;
function checkTriggerDuplicate() {
  const raw = document.getElementById('fTrigger').value;
  const val = raw.split(',')[0].trim().toLowerCase();
  const warn = document.getElementById('triggerDupWarn');
  const dictWarn = document.getElementById('triggerDictWarn');
  if (!warn) return;
  if (!val) {
    warn.classList.add('hidden');
    if (dictWarn) dictWarn.classList.add('hidden');
    return;
  }
  const isSelf = p => !g_newPhraseMode && p.id === g_selId;
  const exact = g_phrases.find(p => {
    if (isSelf(p)) return false;
    if (p.trigger.toLowerCase() === val) return true;
    return (p.aliases || '').split(',').some(a => a.trim().toLowerCase() === val);
  });
  const collide = !exact && g_phrases.find(p => {
    if (isSelf(p)) return false;
    const t = p.trigger.toLowerCase();
    return t !== val && (val.startsWith(t) || t.startsWith(val));
  });
  if (exact) {
    warn.textContent = T('trigDup', val, exact.file.split(/[\\/]/).pop());
    warn.classList.remove('hidden', 'warn-collide');
  } else if (collide) {
    warn.textContent = T('trigCollide', val, collide.trigger, collide.file.split(/[\\/]/).pop());
    warn.classList.remove('hidden');
    warn.classList.add('warn-collide');
  } else {
    warn.classList.add('hidden');
    warn.classList.remove('warn-collide');
  }
  if (dictWarn) {
    clearTimeout(_dictCheckTimer);
    _dictCheckTimer = setTimeout(() => {
      postToAhk({ action: 'checkTriggerInDict', word: val });
    }, 300);
  }
}

window.receiveTriggerDictMatch = function(word, matched) {
  const dictWarn = document.getElementById('triggerDictWarn');
  if (!dictWarn) return;
  const current = document.getElementById('fTrigger').value.trim().toLowerCase();
  if (current !== word) return; // stale response
  if (matched) {
    dictWarn.textContent = T('trigDict', word);
    dictWarn.classList.remove('hidden');
  } else {
    dictWarn.classList.add('hidden');
  }
};

// ── Cat/tag suggestions in detail panel ──────────────────────────────────────
function updateNewPhraseSuggestions(filePath) {
  const cats = new Set(), tags = new Set();
  for (const p of g_phrases) {
    if (filePath && p.file !== filePath) continue;
    if (p.cat) cats.add(p.cat);
    (p.tags || '').split(',').forEach(t => { const tt = t.trim(); if (tt) tags.add(tt); });
  }
  const catDl = document.getElementById('catSuggestions');
  if (catDl) catDl.innerHTML = [...cats].sort().map(c => `<option value="${escHtml(c)}">`).join('');
  const chipsEl = document.getElementById('tagSuggestChips');
  if (!chipsEl) return;
  if (!tags.size) { chipsEl.classList.add('hidden'); return; }
  chipsEl.classList.remove('hidden');
  chipsEl._allTags = [...tags].sort();
  _refreshTagChipActive(chipsEl);
}

function _refreshTagChipActive(chipsEl) {
  const allTags = chipsEl._allTags;
  if (!allTags) return;
  const cur = new Set(
    document.getElementById('fTags').value.split(',').map(t => t.trim()).filter(Boolean)
  );
  chipsEl.innerHTML = allTags.map(t =>
    `<span class="suggest-chip${cur.has(t) ? ' active' : ''}" data-tag="${escHtml(t)}">${escHtml(t)}</span>`
  ).join('');
  chipsEl.querySelectorAll('.suggest-chip').forEach(chip => {
    chip.addEventListener('click', () => {
      const tag = chip.dataset.tag;
      const fTags = document.getElementById('fTags');
      const parts = fTags.value.split(',').map(t => t.trim()).filter(Boolean);
      const idx = parts.indexOf(tag);
      if (idx >= 0) parts.splice(idx, 1); else parts.push(tag);
      fTags.value = parts.join(', ');
      _scheduleAutosave();   // programmatic .value change fires no 'input' event, so autosave must be told
      _refreshTagChipActive(chipsEl);
    });
  });
}

// ── Custom meta fields in detail panel ───────────────────────────────────────
// depField → keyField, parsed from the file's "group=f1,f2;…" shared-fields config.
function _parseFileCouplings(filePath) {
  const cfg = g_fileSettingsCache[filePath || ''] || {};
  const couplings = {};
  (cfg.sharedFields || '').split(';').forEach(part => {
    const eq = part.indexOf('=');
    if (eq < 0) return;
    const key = part.slice(0, eq).trim();
    if (!key) return;
    part.slice(eq + 1).split(',').map(s => s.trim()).filter(Boolean).forEach(dep => { couplings[dep] = key; });
  });
  return couplings;
}

// Phase 3: shared-field edits to propagate to group-mates (phrases sharing the key value).
function _computePropagations(p, updated) {
  const couplings = _parseFileCouplings(p.file);   // dep → key
  const oldCf = p.customFields || {}, newCf = updated.customFields || {};
  const props = [];
  for (const [dep, key] of Object.entries(couplings)) {
    const nv = String(newCf[dep] ?? '').trim();
    if (!nv || nv === String(oldCf[dep] ?? '').trim()) continue;   // only a changed, non-empty shared value
    const kv = String(newCf[key] ?? '').trim();
    if (!kv) continue;
    const mates = g_phrases.filter(q => q.file === p.file && q.id !== p.id
      && String((q.customFields || {})[key] ?? '').trim() === kv
      && String((q.customFields || {})[dep] ?? '').trim() !== nv);
    if (mates.length) props.push({ keyField: key, keyValue: kv, field: dep, value: nv });
  }
  return props;
}

// Editor metadata fields = the file's metaFields ∪ every field used in a coupling,
// so shared keys/dependents always have an input (and get saved). The reserved
// "trigger" pseudo-key is NOT a metadata field — it IS the hotstring abbreviation
// (the fTrigger input), so it must never get its own custom-field box.
function _fileEditorFields(filePath) {
  const cfg = g_fileSettingsCache[filePath || ''] || {};
  const fields = (cfg.metaFields || '').split(',').map(s => s.trim()).filter(Boolean);
  const couplings = _parseFileCouplings(filePath);
  for (const dep of Object.keys(couplings)) {
    if (!fields.includes(dep)) fields.push(dep);
    const key = couplings[dep];
    if (key !== 'trigger' && !fields.includes(key)) fields.push(key);
  }
  return fields;
}

// When a key metadata field is filled in the editor, copy the shared (dependent)
// fields from an existing phrase that has the same key value — cascading nested keys.
function _wireSharedFieldAutofill(filePath, fields) {
  const couplings = _parseFileCouplings(filePath);
  if (!Object.keys(couplings).length) return;
  const fieldSet = new Set(fields);
  const keyDeps = {};
  for (const [dep, key] of Object.entries(couplings))
    if (fieldSet.has(dep) && fieldSet.has(key)) (keyDeps[key] = keyDeps[key] || []).push(dep);

  const findMatch = (kf, kv) =>
    g_phrases.find(p => p.file === filePath && p.id !== g_selId && String((p.customFields || {})[kf] || '').trim() === kv)
    || g_phrases.find(p => p.id !== g_selId && String((p.customFields || {})[kf] || '').trim() === kv);

  const fillFromKey = (keyField, seen) => {
    seen = seen || new Set();
    if (seen.has(keyField) || !keyDeps[keyField]) return;
    seen.add(keyField);
    const keyInput = document.getElementById(`fCustom_${keyField}`);
    const kv = keyInput ? keyInput.value.trim() : '';
    if (!kv) return;
    const match = findMatch(keyField, kv);
    if (!match) return;
    keyDeps[keyField].forEach(dep => {
      const depInput = document.getElementById(`fCustom_${dep}`);
      if (!depInput || depInput.value.trim()) return;   // don't overwrite a typed value
      const v = String((match.customFields || {})[dep] || '').trim();
      if (v) {
        depInput.value = v;
        if (keyDeps[dep]) fillFromKey(dep, seen);        // cascade nested levels
      }
    });
  };
  for (const key of Object.keys(keyDeps)) {
    const keyInput = document.getElementById(`fCustom_${key}`);
    if (keyInput) keyInput.addEventListener('input', () => fillFromKey(key));
  }
}

// ── Live metadata sync (editor) ──────────────────────────────────────────────
// A single value is shared by three representations: the custom-field input, the
// {field=value} placeholder in the phrase body, and — for fields coupled to the
// reserved "trigger" key — the hotstring abbreviation. Editing any one updates the
// others live. _metaSync guards against the directions re-triggering each other;
// the body is only rewritten when the user is NOT the one editing it (so the caret
// never jumps while typing in the textarea).
let _metaSync = false;

function _currentEditorFile() {
  return g_newPhraseMode
    ? (document.getElementById('fNewFile')?.value || '')
    : (g_phrases.find(p => p.id === g_selId)?.file || '');
}
function _trigPrimary() { return _parseTriggerAlias(document.getElementById('fTrigger').value).trigger; }
function _setTrigPrimary(v) {
  const fTrig = document.getElementById('fTrigger');
  const { aliases } = _parseTriggerAlias(fTrig.value);   // keep any aliases, replace the primary trigger
  if (_trigPrimary() === v) return;
  fTrig.value = v + (aliases ? ', ' + aliases : '');
}
// Update an existing {field} / {field=…} placeholder in the body to {field=val}
// (or back to {field} when val is empty). Never appends — only touches the text
// where the user already placed a placeholder.
function _writeFieldIntoText(field, val) {
  const ta = document.getElementById('fPhrase');
  if (!ta) return;
  const re = new RegExp(`\\{${_reEsc(field)}(?:=[^{}]*)?\\}`, 'g');
  const next = ta.value.replace(re, val ? `{${field}=${val}}` : `{${field}}`);
  if (next !== ta.value) ta.value = next;
}
const _trigDeps = (couplings) => Object.keys(couplings).filter(d => couplings[d] === 'trigger');

// Mirrors ParseChoiceField in Expanto.ahk: a {field=…} value that is a list of
// options ([a/b] or a/b) is a pick-on-insert choice, NOT a stored field value — so
// the editor must not mirror it into the custom-field inputs or the trigger.
function _isChoiceValue(val) {
  const v = (val || '').trim();
  if (v.startsWith('[') && v.endsWith(']')) return true;
  return v.split('/').map(s => s.trim()).filter(Boolean).length >= 2;
}

// Source = the phrase body: mirror {field=value} into the field inputs (+ trigger
// for coupled fields). Does NOT rewrite the body — the user is typing in it.
function _syncFieldsFromText() {
  if (_metaSync) return;
  _metaSync = true;
  try {
    const couplings = _parseFileCouplings(_currentEditorFile());
    const ta = document.getElementById('fPhrase');
    const re = /\{([^{}=]+)=([^{}]*)\}/g;
    let m;
    while ((m = re.exec(ta.value)) !== null) {
      const field = m[1].trim(), val = m[2];
      if (_isChoiceValue(val)) continue;   // {kön=manlig/kvinnlig} is a choice, not a value
      const input = document.getElementById('fCustom_' + field);
      if (input && input.value !== val) input.value = val;
      if (couplings[field] === 'trigger') {
        _setTrigPrimary(val);
        _trigDeps(couplings).forEach(dep => {
          if (dep === field) return;
          const di = document.getElementById('fCustom_' + dep);
          if (di && di.value !== val) di.value = val;
        });
      }
    }
  } finally { _metaSync = false; }
  _scheduleAutosave();
}

// Source = a custom-field input: write {field=value} into the body and, for a
// trigger-coupled field, mirror to the abbreviation and sibling coupled fields.
function _onFieldEdited(field) {
  if (_metaSync) return;
  _metaSync = true;
  try {
    const couplings = _parseFileCouplings(_currentEditorFile());
    const val = (document.getElementById('fCustom_' + field) || {}).value || '';
    _writeFieldIntoText(field, val);
    if (couplings[field] === 'trigger') {
      _setTrigPrimary(val);
      checkTriggerDuplicate();
      _trigDeps(couplings).forEach(dep => {
        if (dep === field) return;
        const di = document.getElementById('fCustom_' + dep);
        if (di && di.value !== val) di.value = val;
        _writeFieldIntoText(dep, val);
      });
    }
  } finally { _metaSync = false; }
  _scheduleAutosave();
}

// Source = the trigger/abbreviation: push its value to coupled fields and their
// {field=value} placeholders.
function _onTriggerEdited() {
  if (_metaSync) return;
  const couplings = _parseFileCouplings(_currentEditorFile());
  const deps = _trigDeps(couplings);
  if (!deps.length) return;
  _metaSync = true;
  try {
    const val = _trigPrimary();
    deps.forEach(dep => {
      const di = document.getElementById('fCustom_' + dep);
      if (di && di.value !== val) di.value = val;
      _writeFieldIntoText(dep, val);
    });
  } finally { _metaSync = false; }
  _scheduleAutosave();
}

function renderCustomFieldInputs(filePath, currentValues) {
  const group = document.getElementById('customFieldsGroup');
  if (!group) return;
  group.innerHTML = '';
  const fields = _fileEditorFields(filePath);
  if (!fields.length) { group.classList.add('hidden'); return; }
  group.classList.remove('hidden');
  const cur = (currentValues && typeof currentValues === 'object') ? currentValues : {};
  const hdr = document.createElement('div');
  hdr.className = 'sp-section-title';
  hdr.style.cssText = 'margin:6px 12px 2px;font-size:10px';
  hdr.textContent = T('customFields.title');
  group.appendChild(hdr);
  fields.forEach(f => {
    const div = document.createElement('div');
    div.className = 'field-group';
    const label = document.createElement('label');
    label.textContent = f;
    label.title = T('customFields.title.tip', f);
    const input = document.createElement('input');
    input.type = 'text';
    input.className = 'field-input';
    input.id = `fCustom_${f}`;
    input.placeholder = T('customFields.ph');
    input.spellcheck = false;
    input.value = cur[f] || '';
    input.addEventListener('input', () => _onFieldEdited(f));   // field → body {f=value} (+ trigger)
    div.appendChild(label);
    div.appendChild(input);
    group.appendChild(div);
  });
  const applyBtn = document.createElement('button');
  applyBtn.id = 'btnApplyMeta';
  applyBtn.className = 'tb-btn ghost apply-meta-btn';
  applyBtn.textContent = T('customFields.applyMeta');
  applyBtn.title = T('customFields.applyMeta.title');
  applyBtn.addEventListener('click', applyMetadata);
  group.appendChild(applyBtn);
  _wireSharedFieldAutofill(filePath, fields);
}

function getCustomFieldValues(filePath) {
  const fields = _fileEditorFields(filePath);
  const result = {};
  fields.forEach(f => {
    const el = document.getElementById(`fCustom_${f}`);
    if (el) result[f] = el.value.trim();
  });
  return result;
}

// ── Bulk edit panel ───────────────────────────────────────────────────────────
function openBulkPanel() {
  document.getElementById('detailPanel').classList.add('hidden');
  document.getElementById('fileSettingsPanel').classList.add('hidden');
  const panel = document.getElementById('bulkPanel');
  panel.classList.remove('hidden');
  document.getElementById('bulkTitle').textContent = T('bulk.title', g_multiSel.size);
  const wasHidden = panel.dataset.wasHidden !== 'false';
  if (wasHidden) {
    document.getElementById('bSetCat').checked     = false;
    document.getElementById('bSetLang').checked    = false;
    document.getElementById('bSetComment').checked = false;
    document.getElementById('bSetFile').checked    = false;
    document.getElementById('bCat').value     = '';
    document.getElementById('bLang').value    = '';
    document.getElementById('bComment').value = '';
  }
  // Always rebuild tag map from current selection
  g_bulkTagMap.clear(); g_bulkTagRemove.clear(); g_bulkTagAdd.clear();
  for (const id of g_multiSel) {
    const p = g_phrases.find(x => x.id === id);
    if (!p) continue;
    (p.tags || '').split(',').forEach(t => {
      const tt = t.trim(); if (!tt) return;
      g_bulkTagMap.set(tt, (g_bulkTagMap.get(tt) || 0) + 1);
    });
  }
  renderBulkTagCloud();
  panel.dataset.wasHidden = 'false';
  // Populate file dropdown
  const bFile = document.getElementById('bFile');
  bFile.innerHTML = '';
  g_files.forEach(f => {
    const cached = g_fileSettingsCache[f.path];
    const label  = cached?.label || f.path.split(/[\\/]/).pop();
    const opt    = document.createElement('option');
    opt.value    = f.path;
    opt.textContent = label;
    bFile.appendChild(opt);
  });
}

function renderBulkTagCloud() {
  const cloud = document.getElementById('bTagCloud');
  if (!cloud) return;
  cloud.innerHTML = '';
  const n = g_multiSel.size;
  // Existing tags from selected phrases (sorted by frequency desc)
  for (const [tag, cnt] of [...g_bulkTagMap.entries()].sort((a,b) => b[1]-a[1])) {
    if (g_bulkTagAdd.has(tag)) continue; // shown as add-chip below
    const chip = document.createElement('span');
    const isRemove = g_bulkTagRemove.has(tag);
    const isAll    = cnt === n;
    chip.className = 'btc-chip ' + (isRemove ? 'btc-remove' : isAll ? 'btc-all' : 'btc-some');
    chip.innerHTML = escHtml(tag) + `<span class="btc-x"> ✕</span>`;
    chip.title = isRemove
      ? `Tas bort från alla — klicka för att återställa`
      : (isAll ? `Finns i alla ${n} fraser` : `Finns i ${cnt} av ${n} fraser`) + ` — klicka för att ta bort`;
    chip.addEventListener('click', () => {
      if (g_bulkTagRemove.has(tag)) g_bulkTagRemove.delete(tag);
      else                          g_bulkTagRemove.add(tag);
      renderBulkTagCloud();
    });
    cloud.appendChild(chip);
  }
  // Tags queued for adding (not in any selected phrase yet, or being force-added)
  for (const tag of g_bulkTagAdd) {
    const chip = document.createElement('span');
    chip.className = 'btc-chip btc-add';
    chip.innerHTML = escHtml(tag) + `<span class="btc-x"> ✕</span>`;
    chip.title = 'Läggs till i alla markerade — klicka för att ta bort';
    chip.addEventListener('click', () => {
      g_bulkTagAdd.delete(tag);
      renderBulkTagCloud();
    });
    cloud.appendChild(chip);
  }
}

function closeBulkPanel() {
  g_multiSel.clear();
  if (g_checkboxMode) {
    g_checkboxMode = false;
    applyColWidthsCSS();
    renderListHeader();
    renderListFilters();
  }
  const bp = document.getElementById('bulkPanel');
  bp.classList.add('hidden');
  bp.dataset.wasHidden = 'true';
  document.querySelectorAll('.phrase-row.multi-selected').forEach(r => r.classList.remove('multi-selected'));
}

function _toggleMultiSel(id, idx, _shiftKey) {
  // Pull the normally-selected phrase into the multi-selection set first
  if (g_selId && g_selId !== id) {
    g_multiSel.add(g_selId);
    g_selId = null;
    closeDetail();
  }
  if (g_multiSel.has(id)) g_multiSel.delete(id);
  else                     g_multiSel.add(id);
  g_lastClickIdx = idx;
  if (g_multiSel.size >= 2) {
    g_selId = null;
    closeDetail();
    openBulkPanel();
  } else if (g_multiSel.size === 0) {
    closeBulkPanel();
  } else if (!document.getElementById('bulkPanel').classList.contains('hidden')) {
    // Was in bulk panel, deselected to 1 item → leave bulk, select that item normally
    const remainId = [...g_multiSel][0];
    g_multiSel.clear();
    closeBulkPanel();
    selectPhrase(remainId);
    return;
  }
  // size === 1 and bulk panel was hidden: row shows as multi-selected, user can keep Ctrl+clicking
  renderPhraseList();
}

function selectAll() {
  g_filtered.forEach(p => g_multiSel.add(p.id));
  if (g_multiSel.size >= 2) { g_selId = null; closeDetail(); openBulkPanel(); }
  renderPhraseList();
}

function toggleCheckboxMode() {
  g_checkboxMode = !g_checkboxMode;
  applyColWidthsCSS();
  renderListHeader();
  renderListFilters();
  renderPhraseList();
}

function showPhraseContextMenu(e, id, _idx) {
  // If the right-clicked row is part of a multi-selection, act on the whole
  // selection; otherwise act on just this one row (mirrors the file context menu).
  const ids = (g_multiSel.size > 1 && g_multiSel.has(id)) ? [...g_multiSel] : [id];
  _ctxPhraseIds = ids;
  const single = ids.length === 1;
  const countLabel = single ? '' : ` (${ids.length})`;
  const srcFile = single ? (g_phrases.find(x => x.id === ids[0])?.file || null) : null;

  const fileItems = (action) => {
    // For a single phrase, hide its own file as a target; for a mixed selection list all.
    const targets = _sortTargetFiles(g_files.filter(f => !single || f.path !== srcFile));
    if (!targets.length)
      return `<div class="ctx-item" style="color:var(--text-dim);cursor:default">${escHtml(T('btn.noOtherFiles'))}</div>`;
    return targets.map(f => {
      const label = (g_fileSettingsCache[f.path]?.label) || f.name;
      return `<div class="ctx-item" data-action="${action}" data-path="${escHtml(f.path)}">${escHtml(label)}</div>`;
    }).join('');
  };
  const submenu = (labelKey, action) =>
    `<div class="ctx-submenu">` +
    `<div class="ctx-item ctx-submenu-trigger">${escHtml(T(labelKey))}${countLabel}</div>` +
    `<div class="ctx-submenu-panel">${fileItems(action)}</div></div>`;

  const menu = document.getElementById('ctxMenu');
  menu.innerHTML =
    `<div class="ctx-item" data-phraseaction="duplicate">${escHtml(T('ctx.duplicate'))}${countLabel}</div>` +
    submenu('ctx.dupToFile',  'dupToFile') +
    submenu('ctx.moveToFile', 'moveToFile') +
    `<div class="ctx-sep"></div>` +
    `<div class="ctx-item" data-phraseaction="selectall">${T('ctx.selectAll')}</div>` +
    `<div class="ctx-item" data-phraseaction="togglechk">${T(g_checkboxMode ? 'ctx.exitCheckbox' : 'ctx.startCheckbox')}</div>`;
  menu.style.left = '-9999px';
  menu.style.top  = '-9999px';
  menu.classList.remove('hidden');
  const mw = menu.offsetWidth, mh = menu.offsetHeight;
  menu.style.left = Math.max(0, Math.min(e.clientX, window.innerWidth  - mw - 4)) + 'px';
  menu.style.top  = Math.max(0, Math.min(e.clientY, window.innerHeight - mh - 4)) + 'px';
}

// Right-click phrase actions. For a single phrase, "to another file" opens the
// pre-filled edit form (so you can confirm/tweak before saving). For several at
// once a form makes no sense, so the copy/move happens directly after a confirm.
function _ctxFileLabel(path) {
  return (g_fileSettingsCache[path]?.label) || path.split(/[\\/]/).pop();
}
function _ctxDuplicate(ids) {
  if (!ids.length) return;
  if (ids.length === 1) postToAhk({ action: 'duplicate', id: ids[0] });
  else { postToAhk({ action: 'bulkDuplicate', ids }); showInfoToast(T('toast.dupedToFile', ids.length, '')); }
}
function _ctxDupToFile(ids, path) {
  if (!ids.length || !path) return;
  // Single phrase: route through the duplicate handler so dynamic fields get the
  // same keep-or-fill prompt as a same-file duplicate.
  if (ids.length === 1) { postToAhk({ action: 'duplicate', id: ids[0], targetFile: path }); return; }
  if (!confirm(T('confirm.dupToFile', ids.length, _ctxFileLabel(path)))) return;
  postToAhk({ action: 'duplicateToFile', ids, targetFile: path });
  showInfoToast(T('toast.dupedToFile', ids.length, _ctxFileLabel(path)));
}
function _ctxMoveToFile(ids, path) {
  if (!ids.length || !path) return;
  if (ids.length === 1) { openCopyToForm(ids[0], path, true); return; }
  if (!confirm(T('confirm.moveToFile', ids.length, _ctxFileLabel(path)))) return;
  postToAhk({ action: 'moveToFile', ids, targetFile: path });
  showInfoToast(T('toast.movedToFile', ids.length, _ctxFileLabel(path)));
}

function saveBulkEdit() {
  if (!g_multiSel.size) { closeBulkPanel(); return; }
  const updates = {
    cat:      document.getElementById('bCat').value.trim(),
    lang:     document.getElementById('bLang').value.trim(),
    comment:  document.getElementById('bComment').value.trim(),
    file:     document.getElementById('bFile').value,
    _setCat:     document.getElementById('bSetCat').checked,
    _setLang:    document.getElementById('bSetLang').checked,
    _setComment: document.getElementById('bSetComment').checked,
    _setFile:    document.getElementById('bSetFile').checked,
    tagAdd:    [...g_bulkTagAdd],
    tagRemove: [...g_bulkTagRemove],
  };
  const hasTagChange = updates.tagAdd.length > 0 || updates.tagRemove.length > 0;
  if (!updates._setCat && !updates._setLang && !updates._setComment && !updates._setFile && !hasTagChange) {
    alert(T('bulk.noField'));
    return;
  }
  postToAhk({ action: 'bulkSave', ids: [...g_multiSel], updates });
  closeBulkPanel();
}

function aiSuggestBulk() {
  if (!g_aiEnabled) { alert(T('confirm.aiEnableFirst')); return; }
  if (!g_multiSel.size) return;
  if (!confirm(T('confirm.aiBulk', g_multiSel.size))) return;
  postToAhk({ action: 'aiBatch', ids: [...g_multiSel] });
}

// ── New-file dialog ───────────────────────────────────────────────────────────
function openNewFileDialog(preselectedFolder) {
  // Populate folder picker from all configured enabled folders
  const sel = document.getElementById('nfFolderSel');
  sel.innerHTML = '';
  const enabledFolders = g_configuredFolders.filter(f => f.enabled && f.path);
  if (!enabledFolders.length) {
    // Fallback: add the preselected folder if provided
    if (preselectedFolder) {
      const opt = document.createElement('option');
      opt.value = preselectedFolder;
      opt.textContent = preselectedFolder.split(/[\\/]/).pop() || preselectedFolder;
      sel.appendChild(opt);
    }
  } else {
    enabledFolders.forEach(f => {
      const opt = document.createElement('option');
      opt.value = f.path;
      opt.textContent = f.path.split(/[\\/]/).pop() || f.path;
      sel.appendChild(opt);
    });
    if (preselectedFolder) sel.value = preselectedFolder;
  }
  document.getElementById('nfName').value = '';
  document.getElementById('nfError').classList.add('hidden');
  document.querySelector('[name="nfType"][value="ahk"]').checked = true;
  const encLabel = document.getElementById('nfEncLabel');
  if (encLabel) encLabel.style.opacity = g_encUnlocked ? '' : '0.5';
  document.getElementById('newFileDialog').classList.remove('hidden');
  setTimeout(() => document.getElementById('nfName').focus(), 50);
}

function closeNewFileDialog() {
  document.getElementById('newFileDialog').classList.add('hidden');
}

function submitNewFile() {
  const name = document.getElementById('nfName').value.trim();
  const folder = document.getElementById('nfFolderSel').value;
  if (!name) {
    const err = document.getElementById('nfError');
    err.textContent = T('nf.err.name');
    err.classList.remove('hidden');
    return;
  }
  if (!folder) {
    const err = document.getElementById('nfError');
    err.textContent = T('nf.err.folder');
    err.classList.remove('hidden');
    return;
  }
  const enc = document.querySelector('[name="nfType"]:checked').value === 'enc';
  postToAhk({ action: 'newFile', folder, name, enc });
}

// ── File context menu ─────────────────────────────────────────────────────────
function showFileContextMenu(e, path, s) {
  // If the right-clicked file is part of a multi-file selection, apply to all selected files
  _ctxPresetPaths = g_selFiles.size > 1 && g_selFiles.has(path) ? [...g_selFiles] : [path];
  const menu = document.getElementById('ctxMenu');
  const hideAction = s.isHidden
    ? `<div class="ctx-item" data-action="showFile" data-path="${escHtml(path)}">${T('ctx.showFile')}</div>`
    : `<div class="ctx-item" data-action="hideFile" data-path="${escHtml(path)}">${T('ctx.hideFile')}</div>`;
  const folderPath = (g_files.find(f => f.path === path)?.folderPath) || '';
  const isEnc = path.toLowerCase().endsWith('.enc');
  const openInEditor = !isEnc
    ? `<div class="ctx-item" data-action="openEditor" data-path="${escHtml(path)}">${T('ctx.openEditor')}</div>`
    : '';
  const backupsItem = !isEnc
    ? `<div class="ctx-item" data-action="backups" data-path="${escHtml(path)}">${T('ctx.backups')}</div>`
    : '';
  const encItem = isEnc
    ? `<div class="ctx-item" data-action="decryptPath" data-path="${escHtml(path)}">${T('ctx.decryptFile')}</div>`
    : `<div class="ctx-item" data-action="encryptPath" data-path="${escHtml(path)}">${T('ctx.encryptFile')}</div>`;
  const presetsSubmenu =
    `<div class="ctx-submenu">` +
    `<div class="ctx-item ctx-submenu-trigger">${T('ctx.presets')}</div>` +
    `<div class="ctx-submenu-panel">` +
    `<div class="ctx-item" data-action="applyPreset" data-preset="spellcheck">${T('ctx.preset.spellcheck')}</div>` +
    `<div class="ctx-item" data-action="applyPreset" data-preset="abbrev">${T('ctx.preset.abbrev')}</div>` +
    `<div class="ctx-item" data-action="applyPreset" data-preset="phrases">${T('ctx.preset.phrases')}</div>` +
    `</div></div>`;
  const detailsSubmenu =
    `<div class="ctx-submenu">` +
    `<div class="ctx-item ctx-submenu-trigger">${T('ctx.details')}</div>` +
    `<div class="ctx-submenu-panel">` +
    `<div class="ctx-item" data-action="batchFileSet" data-type="hs"    data-enable="${!s.hsOn}">${T(s.hsOn ? 'ctx.disableHs' : 'ctx.enableHs')}</div>` +
    `<div class="ctx-item" data-action="batchFileSet" data-type="hintT" data-enable="${!s.hintTOn}">${T(s.hintTOn ? 'ctx.disableHintT' : 'ctx.enableHintT')}</div>` +
    `<div class="ctx-item" data-action="batchFileSet" data-type="hintP" data-enable="${!s.hintPOn}">${T(s.hintPOn ? 'ctx.disableHintP' : 'ctx.enableHintP')}</div>` +
    `</div></div>`;
  menu.innerHTML =
    presetsSubmenu + detailsSubmenu +
    `<div class="ctx-sep"></div>` +
    `<div class="ctx-item ctx-file-settings" data-path="${escHtml(path)}">${T('ctx.fileSettings')}</div>` +
    openInEditor + backupsItem + encItem +
    `<div class="ctx-sep"></div>` +
    hideAction;
  menu.querySelector('.ctx-file-settings').addEventListener('click', e2 => {
    e2.stopPropagation();
    closeContextMenu();
    openFileSettings(path);
  });
  menu.style.left = '-9999px';
  menu.style.top  = '-9999px';
  menu.classList.remove('hidden');
  const mw = menu.offsetWidth, mh = menu.offsetHeight;
  menu.style.left = Math.max(0, Math.min(e.clientX, window.innerWidth  - mw - 4)) + 'px';
  menu.style.top  = Math.max(0, Math.min(e.clientY, window.innerHeight - mh - 4)) + 'px';
}

function showFolderContextMenu(e, folderPath, folderId) {
  _ctxPresetPaths = folderId
    ? g_files.filter(f => f.folder === folderId).map(f => f.path)
    : g_files.map(f => f.path);
  const menu = document.getElementById('ctxMenu');
  const isFolderHidden = folderId && g_hiddenFolderIds.has(folderId);
  const toggleItem = folderId
    ? `<div class="ctx-item" data-action="${isFolderHidden ? 'showFolder' : 'hideFolder'}" data-folderid="${escHtml(folderId)}">${T(isFolderHidden ? 'ctx.showFolder' : 'ctx.hideFolder')}</div>`
    : '';
  const openFolderItem = folderPath
    ? `<div class="ctx-item" data-action="openFolder" data-path="${escHtml(folderPath)}">${T('ctx.openFolder')}</div>`
    : '';
  const presetItems =
    `<div class="ctx-sep"></div>` +
    `<div class="ctx-item" data-action="applyPreset" data-preset="spellcheck">${T('ctx.preset.spellcheck')}</div>` +
    `<div class="ctx-item" data-action="applyPreset" data-preset="abbrev">${T('ctx.preset.abbrev')}</div>` +
    `<div class="ctx-item" data-action="applyPreset" data-preset="phrases">${T('ctx.preset.phrases')}</div>`;
  menu.innerHTML = openFolderItem + toggleItem +
    (openFolderItem || toggleItem ? `<div class="ctx-sep"></div>` : '') +
    `<div class="ctx-item ctx-new-file" data-folder="${escHtml(folderPath)}">${T('ctx.newFile')}</div>` +
    presetItems;
  menu.style.left = '-9999px';
  menu.style.top  = '-9999px';
  menu.classList.remove('hidden');
  const mw = menu.offsetWidth, mh = menu.offsetHeight;
  menu.style.left = Math.max(0, Math.min(e.clientX, window.innerWidth  - mw - 4)) + 'px';
  menu.style.top  = Math.max(0, Math.min(e.clientY, window.innerHeight - mh - 4)) + 'px';
}

function closeContextMenu() {
  document.getElementById('ctxMenu').classList.add('hidden');
}

// ── Maintenance ───────────────────────────────────────────────────────────────
function runDuplicateCheck() {
  const trigMap   = new Map();
  const phraseMap = new Map();
  g_phrases.forEach(p => {
    const t = p.trigger.toLowerCase();
    if (!trigMap.has(t)) trigMap.set(t, []);
    trigMap.get(t).push(p);
    const ph = (p.phrase || '').trim().toLowerCase().replace(/\s+/g, ' ');
    if (ph.length > 5) {
      if (!phraseMap.has(ph)) phraseMap.set(ph, []);
      phraseMap.get(ph).push(p);
    }
  });
  const trigDupes   = [...trigMap.entries()].filter(([, ps]) => ps.length > 1);
  const phraseDupes = [...phraseMap.entries()].filter(([, ps]) => ps.length > 1);
  const out = document.getElementById('maintDupesResult');
  if (!out) return;
  out.classList.remove('hidden');
  if (!trigDupes.length && !phraseDupes.length) {
    out.innerHTML = `<p class="maint-ok">${escHtml(T('maint.dupes.none'))}</p>`;
    return;
  }
  let html = '';
  if (trigDupes.length) {
    html += `<div class="maint-group-title">${escHtml(T('maint.dupes.triggers', trigDupes.length))}</div>`;
    trigDupes.forEach(([trig, ps]) => {
      html += `<div class="maint-dup-row"><b class="maint-trigger">${escHtml(trig)}</b>`
            + ps.map(p => ` <span class="maint-file">${escHtml(p.file.split(/[\\/]/).pop())}</span>`).join('')
            + '</div>';
    });
  }
  if (phraseDupes.length) {
    html += `<div class="maint-group-title" style="margin-top:10px">${escHtml(T('maint.dupes.phrases', phraseDupes.length))}</div>`;
    phraseDupes.forEach(([ph, ps]) => {
      const preview = ph.length > 50 ? ph.slice(0, 50) + '…' : ph;
      html += `<div class="maint-dup-row"><span class="maint-phrase-text">${escHtml(preview)}</span>`
            + ps.map(p => ` <span class="maint-trigger">${escHtml(p.trigger)}</span>`).join('')
            + '</div>';
    });
  }
  out.innerHTML = html;
}

function runStatAnalysis() {
  const out = document.getElementById('maintStatsResult');
  if (!out) return;
  out.classList.remove('hidden');
  const now   = Date.now();
  const ms    = n => n * 86400000;
  const total = g_phrases.length;
  if (!total) { out.innerHTML = '<p class="maint-ok">Inga fraser.</p>'; return; }
  const used      = g_phrases.filter(p => g_usageTimes[p.id]).length;
  const neverUsed = total - used;
  const dead30    = g_phrases.filter(p => !g_usageTimes[p.id] || now - new Date(g_usageTimes[p.id]) > ms(30)).length;
  const dead90    = g_phrases.filter(p => !g_usageTimes[p.id] || now - new Date(g_usageTimes[p.id]) > ms(90)).length;
  const fileCount = new Map();
  g_phrases.forEach(p => { const f = p.file.split(/[\\/]/).pop(); fileCount.set(f, (fileCount.get(f) || 0) + 1); });
  const topFiles  = [...fileCount.entries()].sort((a, b) => b[1] - a[1]).slice(0, 8);
  const pct = n => Math.round(n / total * 100);
  const row = (label, val) => `<tr><td>${escHtml(label)}</td><td>${val}</td></tr>`;
  let html = `<table class="maint-stats-table">
    ${row(T('maint.stats.total'), total)}
    ${row(T('maint.stats.used'), `${used} (${pct(used)}%)`)}
    ${row(T('maint.stats.neverUsed'), neverUsed)}
    ${row(T('maint.stats.dead30'), dead30)}
    ${row(T('maint.stats.dead90'), dead90)}
  </table>`;
  if (topFiles.length) {
    html += `<div class="maint-group-title" style="margin-top:10px">${escHtml(T('maint.stats.topFiles'))}</div>
    <table class="maint-stats-table">`;
    topFiles.forEach(([f, n]) => { html += row(escHtml(f), n); });
    html += '</table>';
  }
  out.innerHTML = html;
}

// ── Metadata apply (bidirectional {key=value} sync) ──────────────────────────
function applyMetadata() {
  const phraseEl = document.getElementById('fPhrase');
  if (!phraseEl) return;

  const filePath = g_newPhraseMode
    ? (document.getElementById('fNewFile')?.value || '')
    : (g_phrases.find(p => p.id === g_selId)?.file || '');
  const cached = g_fileSettingsCache[filePath] || {};
  const fields = (cached.metaFields || '').split(',').map(s => s.trim()).filter(Boolean);
  if (!fields.length) return;

  // Step 1: extract {key=value} already in phrase text → pre-fill empty fields
  let text = phraseEl.value;
  fields.forEach(f => {
    const re = new RegExp(`\\{${_reEsc(f)}=([^}]*)\\}`, 'g');
    let m;
    while ((m = re.exec(text)) !== null) {
      const el = document.getElementById(`fCustom_${f}`);
      if (el && !el.value.trim()) el.value = m[1];
    }
  });

  // Step 2: embed all field values into phrase text placeholders
  fields.forEach(f => {
    const el = document.getElementById(`fCustom_${f}`);
    if (!el) return;
    const val = el.value.trim();
    // Replace {f} or {f=anything} with {f=val} (if val non-empty) or {f} (if empty)
    const re = new RegExp(`\\{${_reEsc(f)}(?:=[^}]*)?\\}`, 'g');
    text = text.replace(re, val ? `{${f}=${val}}` : `{${f}}`);
  });

  phraseEl.value = text;
  _scheduleAutosave();   // programmatic .value change fires no 'input' event
}

function _reEsc(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

// ── Helpers ───────────────────────────────────────────────────────────────────
function escHtml(s) {
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
