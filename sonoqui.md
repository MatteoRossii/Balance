# sonoqui.md – Dove siamo arrivati

> **Per Claude:** leggi questo file all'inizio di ogni sessione, insieme a `CLAUDE.md`.
> Aggiornalo alla fine di ogni sessione (o quando Matteo lo chiede).
> Ultimo aggiornamento: **28/11/2026**, ultimo commit `5a63cea fine sezione scheda`
> (⚠️ schermata Oggi + check-in completo ancora **da committare**: controlla `git status`).
> **Sezione Scheda completata.** Sezione **Oggi**: check-in completo (con salvataggio).
> **Pausa per ritocchi grafici** alle pagine già fatte (Oggi, Scheda), chiesta da Matteo il 28/11.
> Dopo i ritocchi si riprende dal **punto 3 di Oggi** ("Allenamento di oggi": già spiegato, NON applicato; vedi §3).
> Dal 28/11 Matteo ha attivato lo stile **caveman** (risposte asciutte): stesso metodo, meno parole di contorno.

---

## 1. Come lavorare con Matteo (IMPORTANTE)

Matteo **non conosce Dart/Flutter**: lo sta imparando costruendo Balance.
Il metodo usato finora gli è piaciuto e va mantenuto **identico**:

1. **Un sotto-passo alla volta**, piccolo e provabile subito nell'app. Un solo concetto nuovo per volta (al massimo due, legati tra loro). I passi grandi si dividono (es. 5a, 5b, 5c).
2. Per ogni sotto-passo:
   - spiega **l'idea** prima del codice (cosa vogliamo ottenere, perché si fa così), con disegni ASCII della schermata quando aiutano;
   - indica il **punto esatto** del file dove scrivere ("tra la riga X e la riga Y", mostrando le righe vicine): **ricontrolla i numeri di riga** prima, cambiano spesso;
   - dai il **codice completo** da incollare (niente `...` da completare);
   - spiega **riga per riga** le parti nuove, partendo da zero (cos'è, a cosa serve, analogia semplice), e collega ai concetti che ha già visto ("come nel 5b...");
   - di' **come provarlo**: `r` (hot reload), `R` (hot restart), oppure **fermare e riavviare** `flutter run` (quando cambiano `main()` o i pacchetti), e cosa deve vedere, inclusi i difetti "previsti".
3. Chiudi con: **"Dimmi 'fatto' e ricontrollo, oppure 'fai tu'"**.
   - **"fatto" / "controlla" / "correggi errori"** → `git diff`, `flutter analyze`, conferma cosa va bene, traduci gli errori in italiano semplice. Spesso **dimentica di salvare** (Cmd+S) o applica solo **una parte** del passo (es. mancano i pezzi che "collegano", e l'analizzatore dà "isn't referenced"): dillo e, se chiede, completa tu. "Correggi errori" a volte significa "sistema i difetti previsti": se `analyze` è pulito, chiedi cosa vede.
   - **"fai tu"** (molto frequente) → fai tu la modifica con lo stesso codice spiegato, `dart format` + `flutter analyze`, ricorda come provarlo.
   - Se chiede di **rispiegare**, rifallo partendo dall'idea, senza codice, con un'analogia.
   - Se chiede "fammi direttamente tu X", fai il lavoro intero, poi spiega cosa hai fatto e perché (riassunto per file).
4. Dopo ogni passo funzionante, suggerisci un **commit** (con il comando pronto). Non committare senza che lo chieda. Spesso si dimentica: ricordaglielo prima di iniziare un passo nuovo.
5. Rispetta le sue **scelte di design** anche se diverse dalla tua proposta, e spiega se semplificano.
6. Se sbagli una spiegazione o una previsione, **ammettilo** chiaramente e spiega il motivo vero.
7. Piccoli ritocchi di stile (commenti vecchi, righe vuote, commenti non rientrati) segnalali come **facoltativi**, in breve.
8. Rispondi sempre in **italiano**.
9. Matteo prova l'app anche **sull'iPhone** (Safari / app sulla Home): considera i limiti di Safari iOS (tastiera, scorrimento pagina, spazio di archiviazione).
10. Per le decisioni di progetto proponi **una raccomandazione chiara** (con un'alternativa scartata e il perché), poi chiedi conferma.

---

## 2. Stato del codice

### File
- `lib/main.dart`
  - `main()` è **`async`**: `WidgetsFlutterBinding.ensureInitialized()`, poi `await caricaScheda()` → se non è `null` diventa `schedaAttuale`, poi `elencoCheckIn = await caricaCheckIn()`, poi `runApp`.
  - `MaterialApp`: tema, **italiano** (`flutter_localizations`: `localizationsDelegates`, `supportedLocales`, `locale: Locale('it')`).
  - `Navigazione`: `Scaffold` (`resizeToAvoidBottomInset: false`), `NavigationBar` con 4 voci; `switch (_indiceSelezionato)`: 0 → `SchermataOggi`, 1 → `SchermataScheda`, `_` → testo segnaposto (`_titoli`). (Commenti sopra lo `switch` ancora vecchi, parlano del `? :`: ritocco facoltativo.)
- `lib/tema.dart` – colori e tema (card con `margin: EdgeInsets.zero`; `FilledButton` largo quanto il contenitore, alto 48). Contiene `coloreTestoSecondario`, `coloreVerdeChiaro`.
- `lib/scheda.dart` – modello dati, campi tutti `final`, ognuno con `toJson()` e `factory ...fromJson(...)`:
  - `Esercizio` (nome, serie, ripetizioni, carico `double`; 0 = corpo libero) + `volume()`. In `fromJson` il carico passa da `num` → `toDouble()`.
  - `GiornoAllenamento` (nome es. "Giorno A", **tipo** es. "Upper", esercizi: lista **modificabile**, mai `const []`).
  - `Scheda` (giorni, dataInizio, durataSettimane) + getter `settimanaCorrente`, `programmazioneFinita`. Data in JSON con `toIso8601String()` / `DateTime.parse`.
- `lib/archivio.dart` – salvataggio (niente UI): `shared_preferences`, etichette `'scheda'` e `'checkin'`.
  - `caricaCheckIn()` → `Future<List<CheckIn>>` (lista vuota se niente o rotto), `salvaCheckIn(List<CheckIn>)`.
  - `schedaVuota()`: prima apertura → un giorno "Giorno A"/"Allenamento" senza esercizi, inizio oggi, 8 settimane.
  - `caricaScheda()` → `Future<Scheda?>` (`null` se non c'è o se il JSON è rotto, con `try/catch`).
  - `salvaScheda(scheda)` → `Future<void>`.
- `lib/schermata_scheda.dart` – sezione Scheda:
  - `_testoData(DateTime)` → "3/11/2026" (funzione top-level che restituisce `String`).
  - `var schedaAttuale = schedaVuota();` (variabile globale; `main()` la sostituisce con quella salvata).
  - `_aggiornaESalva(VoidCallback modifica)`: `setState(modifica)` + `salvaScheda(schedaAttuale)`. **Usarlo al posto di `setState` ogni volta che cambiano i dati** (il `setState` del giorno selezionato resta normale).
  - `_CardAvanzamento(scheda:, onModifica:)`: "Settimana X di N" / "Programmazione finita", "dal 3/11/2026" grigio, matita → `_apriModuloProgrammazione` (durata + data con `StatefulBuilder` / `setStateFinestra` e `await showDatePicker`, niente date future).
  - Riga giorni: `SegmentedButton` in `Expanded` + `IconButton.filledTonal` (+) → `_apriModuloGiorno()`.
  - Titolo tipo del giorno + matita → `_apriModuloGiorno(giorno)` (modifica; tiene gli esercizi). Elimina giorno solo se `giorni.length > 1` → `_confermaEliminazioneGiorno` (`_giornoSelezionato = 0`).
  - Card esercizi toccabili (`InkWell`) → `_apriModuloEsercizio(esercizio)`; pulsante "Aggiungi esercizio" → `_apriModuloEsercizio()`. Form con validator (nome obbligatorio, serie/ripetizioni ≥ 1, kg vuoto = 0 o ≥ 0 con virgola), Salva = `add` o `indexOf` + sostituzione, Elimina con conferma (`_confermaEliminazione`).
  - Tutte le finestre: `AlertDialog` con `alignment: Alignment.topCenter` (evita che la tastiera iPhone faccia scorrere la pagina).
- `lib/schermata_oggi.dart` – sezione Oggi (`StatefulWidget` `SchermataOggi` / `_SchermataOggiState`):
  - `_nomiGiorni`, `_nomiMesi`, `_dataEstesa(DateTime)` → "sabato 28 novembre" (`weekday - 1`, `month - 1`).
  - In alto: data (grigia) **sopra** "Bentornato in Balance" (scelta di Matteo).
  - Card check-in: "Come ti senti oggi?" → `SegmentedButton<int>` 1–5 (`int? _sensazione`, `emptySelectionAllowed`, `selected: {if (_sensazione != null) _sensazione!}`), sotto il nome del voto (`_nomiSensazioni`) o un suggerimento; "Hai dolori muscolari?" → `SegmentedButton<bool>` No/Sì (`bool _dolori = false`, su No `_muscoliDoloranti.clear()`); se Sì, `Wrap` di `FilterChip` per i 10 `_muscoli` (`final Set<String> _muscoliDoloranti`).
  - Variabile globale `List<CheckIn> elencoCheckIn = []` (riempita da `main()`).
  - `initState` ricompila la card col check-in di oggi; `_salvatoOggi`; getter `_puoiSalvare` (voto scelto e, se "Sì", almeno un muscolo; altrimenti avviso grigio "Scegli almeno un muscolo"); `_salvaCheckIn()` (`removeWhere` riga di oggi + `add`, `salvaCheckIn`, `SnackBar` "Check-in salvato"); `FilledButton` "Salva check-in" / "Aggiorna check-in" (grigio se non si può salvare).
  - Ordine nella `ListView`: data, titolo, card check-in. (Card "Allenamento di oggi" non ancora aggiunta.)
- `lib/check_in.dart` – classe `CheckIn` (solo dati): `data` (solo giorno/mese/anno), `sensazione` `int` 1–5, `muscoliDoloranti` `List<String>` (lista perché il JSON non conosce i Set), getter `haDolori`, `toJson` / `factory fromJson`. Funzione top-level `stessoGiorno(a, b)`.
- Prova dei dati sul web: restano con Cmd+R o `R`, si perdono fermando e rilanciando `flutter run -d chrome` (Chrome di prova pulito). Per dati persistenti: `flutter run -d web-server --web-port 8080` + `http://localhost:8080` nel Chrome normale.
- `test/widget_test.dart` – è ancora il test d'esempio del contatore: **non funziona**, va riscritto o tolto (da proporre).

### Decisioni prese
- Il peso si mostra come numero anche quando è 0 ("0 kg" = corpo libero). Sul web `60.0` appare `60`.
- `nome` del giorno corto (va nei pulsanti); `tipo` libero, obbligatorio nel form.
- Finestre = `AlertDialog` con `TextButton`; controlli con `Form` + `validator`.
- `autofocus` resta: su iPhone non apre la tastiera (limite iOS), sul computer sì.
- Data di inizio: **niente date future**.
- Salvataggio: `shared_preferences` + JSON (scelto contro localStorage diretto e database tipo Hive/sqflite, esagerati).
- Dati di esempio rimossi: si parte da una scheda vuota.
- **Check-in (grafica, 28/11, scelta di Matteo)**: la scala è **Molto stanco**, Stanco, Normale, Bene, Al top ("Distrutto" del `CLAUDE.md` sostituito). Pulsanti 1–5 più grandi (`SegmentedButton` largo quanto la card, `styleFrom(padding: …)`), dentro ogni pulsante numero grande + nome dello stato piccolo (max 2 righe); tolta la riga di testo sotto i pulsanti.
- **Progressione dei carichi (decisa il 27/11, confermata da Matteo):**
  - la **scheda** è il piano e contiene il **carico attuale** di ogni esercizio (non "quello della prima settimana");
  - nasce un **diario degli allenamenti** (storico): classe nuova `AllenamentoFatto` (data, nome del giorno, esercizi con i kg davvero usati, riusa `Esercizio`), salvata in `archivio.dart` con un'altra etichetta (es. `'diario'`), stesso metodo JSON;
  - in **Oggi**, "Segna come fatto" apre una finestra con i kg **precompilati** dalla scheda; l'utente cambia solo quelli aumentati → Salva = 1) aggiunge una riga al diario, 2) aggiorna i carichi nella scheda;
  - il diario serve anche a capire **quale giorno tocca oggi** (dopo l'ultimo fatto: A → B → C → A) e alla sezione **Progressi** (grafico squat, carico settimanale con `volume()`);
  - **scartato**: carichi pianificati settimana per settimana nella scheda; **rimandato**: progressione automatica (eventuale *consiglio* in "Il consiglio di oggi", con regole "se... allora...", ma decide sempre l'utente).
- **Check-in (deciso il 28/11, confermato da Matteo):**
  - si salva un **elenco** di check-in, **uno per giorno** (etichetta `'checkin'` in `archivio.dart`); salvare di nuovo nello stesso giorno **sostituisce** la riga di oggi;
  - "stesso giorno" = stessa data senza ore (si salva solo giorno/mese/anno, come in `schedaVuota()`);
  - in Oggi si vede **solo il check-in di oggi**: se esiste la card si ricompila ("Aggiorna check-in"), altrimenti parte vuota; il giorno dopo è di nuovo vuota da sola;
  - lo **storico NON si mostra mai all'utente** come elenco: serve solo alle regole. In Progressi al massimo un **numero** derivato nella card Scarico (es. "Indolenzimento: 3 giorni di fila"). Niente grafico delle sensazioni;
  - **sensazione** (stanchezza generale: sonno, studio, stress) e **dolori** (muscoli precisi) sono **due segnali separati**:
    - sensazione → solo il **consiglio di oggi** (es. Distrutto → allenamento più leggero o riposo);
    - dolori → **scarico** caso (b) "indolenzimento troppi giorni di fila" (conta solo `haDolori`) + consiglio sui muscoli allenati oggi;
    - **opzione A scelta**: la stanchezza ripetuta (es. ≤ 2 per 3 giorni) **NON** porta allo scarico, solo a consigli giornalieri. (Scartata B: scarico anche per stanchezza senza dolori.)
  - soglie (quanti giorni, quanto più leggero) da scrivere in `lib/regole.dart`, facili da cambiare; l'app suggerisce soltanto, decide l'utente (non sostituisce medico/professionista).

### Concetti Dart/Flutter già spiegati
`ListView`/`children`, widget e `child`, `const` (e il suo "contagio"), `final` vs `var`, collection `for` e collection `if`, `Card`, `Padding`, `EdgeInsets`, `Column`, `Row`, `Expanded`, `crossAxisAlignment`, `mainAxisSize`, `SizedBox`, interpolazione, `style` + `copyWith` + `?.`, getter, `if`/`else`/`==`/`!=`/`||`/`&&`/`!`/`return`, `? :`, `%`, `setState`, liste: `.add`, `.remove`, `indexOf`, `lista[i] = x`, `length - 1`, `required`, parametri facoltativi `[ ]`, tipi con `?`, `null`, `??`, `!` dopo un valore, metodi `void` e funzioni che restituiscono `String`, passare una funzione senza `()` vs `() => f(x)`, `VoidCallback` (passare funzioni ai propri widget), `showDialog`/`builder`, `AlertDialog` (+ `alignment`), `Navigator.pop` (pila di fogli, anche due volte), `TextField`/`TextFormField`, `onChanged`, `initialValue`, `keyboardType`, `Form`, `GlobalKey`, `validator`, `validate()`, `tryParse`, `replaceAll`, `trim`, `isEmpty`, `InkWell`/`onTap`, `clipBehavior`, `IconButton` (+ `.filledTonal`, `tooltip`), `TextButton.styleFrom`, `colorScheme.error`, `StatefulBuilder`, `async`/`await`, `showDatePicker`, `DateTime` (`.day`, `.month`, `.year`, `.weekday`), ambito delle variabili, `switch` con `=>` e `_`, `bool`, `SegmentedButton<bool>` ed `emptySelectionAllowed`, `Set` (`add`, `remove`, `contains`, `clear`), `Wrap` (`spacing`, `runSpacing`), `FilterChip`, `isNotEmpty`, getter corto con `=>`, `Map<String, dynamic>`, JSON, `toJson`/`fromJson`, `factory`, `as`, `Future`, `jsonEncode`/`jsonDecode`, `try/catch`, `initState` (+ `super.initState()`), `addAll`, `toList`, `removeWhere`, `SnackBar`/`ScaffoldMessenger`, pulsante disattivato con `onPressed: null`.

**Spiegati solo di sfuggita**: `num`/`toDouble()`, `WidgetsFlutterBinding.ensureInitialized()`.
**Già presentati nel punto 3 (non ancora applicato)**: `.first` su lista, spread `...[ ]` dentro un `for`, `Divider`, `EdgeInsets.symmetric`.

---

## 3. Prossimi passi

### Fatto
Sezione **Scheda**: campi e controlli, modifica/eliminazione esercizi, gestione giorni, data e durata, app in italiano, salvataggio sul dispositivo.

### ▶ In corso: sezione **Oggi** (da `CLAUDE.md` e grafica approvata)
Ordine **rivisto il 28/11** (su proposta di Matteo: il check-in viene prima, come nella grafica):
1. ~~**Schermata Oggi di base**~~ ✓ (`schermata_oggi.dart`, collegata in `main.dart` con `switch`).
2. **Check-in**:
   - ~~2a "Come ti senti oggi?" 1–5~~ ✓
   - ~~2b "Hai dolori muscolari?" No/Sì + muscoli~~ ✓
   - ~~2c-1 classe `CheckIn` in `lib/check_in.dart`~~ ✓ (scritta da Matteo, analyze pulito)
   - ~~2c-2~~ ✓ `archivio.dart`: `caricaCheckIn()` / `salvaCheckIn(List<CheckIn>)`, etichetta `'checkin'`; variabile globale `List<CheckIn> elencoCheckIn` in `schermata_oggi.dart`, caricata in `main()`.
   - ~~2c-3~~ ✓ (fatto da Claude): `stessoGiorno(a, b)` in `check_in.dart`; in `_SchermataOggiState`: `initState` ricompila la card dal check-in di oggi, getter `_puoiSalvare` (serve un voto; se "Sì" almeno un muscolo, altrimenti avviso "Scegli almeno un muscolo"), `_salvaCheckIn()` (`removeWhere` riga di oggi + `add`, `salvaCheckIn`, `SnackBar` "Check-in salvato"), `FilledButton` "Salva check-in" / "Aggiorna check-in". Nuovi concetti: `initState`, `addAll`, `toList`, `removeWhere`, `SnackBar`/`ScaffoldMessenger`, pulsante disattivato con `onPressed: null`.
   - ⏸ **Pausa ritocchi grafici** (28/11): Matteo vuole sistemare l'aspetto delle pagine già fatte (Oggi, Scheda) prima di andare avanti. Ogni ritocco = piccolo passo con prova, come sempre; rispettare la grafica approvata in `CLAUDE.md` salvo scelte diverse di Matteo (da annotare qui sotto in "Decisioni").
3. ▶ **Card "Allenamento di oggi"** (già **spiegata** a Matteo, **non applicata**): in `schermata_oggi.dart` import `scheda.dart` + `schermata_scheda.dart`; nella `ListView` dopo la card check-in `SizedBox(height: 16)` + `_CardAllenamento(giorno: schedaAttuale.giorni.first)`; nuovo `StatelessWidget _CardAllenamento` in fondo al file: titolo "Allenamento di oggi" (17 semibold), sotto "Giorno A · Upper" grigio, se nessun esercizio "Nessun esercizio: aggiungili nella sezione Scheda.", altrimenti righe nome + "serie × rip" a sinistra e "kg" a destra, separate da `Divider` (`for ... ...[ if (esercizio != giorno.esercizi.first) const Divider(), Padding(symmetric vertical 8, Row(...)) ]`). Per ora sempre il primo giorno. Ripresentarlo dopo i ritocchi (ricontrolla i numeri di riga).
4. **Diario**: classe `AllenamentoFatto` + `toJson`/`fromJson` + `caricaDiario`/`salvaDiario` in `archivio.dart`, caricato in `main()` come la scheda.
5. **"Segna come fatto"**: finestra con i kg precompilati → aggiunge al diario + aggiorna i carichi della scheda (vedi "Progressione dei carichi").
6. **Quale giorno tocca oggi**: il giorno dopo l'ultimo nel diario (con giro A → B → C → A); "già fatto oggi" se c'è una riga con la data di oggi.
7. **"Il consiglio di oggi"**: regole "se... allora..." in `lib/regole.dart` (usa check-in + allenamento di oggi; vedi decisioni "Check-in").
8. Il **promemoria esami** arriverà con la sezione Calendario (gli esami NON riducono mai l'allenamento, solo promemoria sullo studio).

### Più avanti
- **Export/import JSON** (backup di scheda, diario e check-in): utile perché iOS può cancellare i dati del sito.
- La cartella `.claude/` (impostazioni locali di Claude Code) non va committata: proporre di aggiungerla a `.gitignore`.
- Sistemare `test/widget_test.dart`.
- **Allegato** foto/PDF della scheda originale (rimandato: spazio limitato sul web).
- Possibile problema: con molti giorni il `SegmentedButton` può non entrare su iPhone SE.

Poi, secondo `CLAUDE.md`: Calendario → Progressi e scarico.
