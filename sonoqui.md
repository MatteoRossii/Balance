# sonoqui.md – Dove siamo arrivati

> **Per Claude:** leggi questo file all'inizio di ogni sessione, insieme a `CLAUDE.md`.
> Aggiornalo alla fine di ogni sessione (o quando Matteo lo chiede).
> Ultimo aggiornamento: **27/11/2026**, passi 5 e 6 completati (da committare se `git status` mostra modifiche).

---

## 1. Come lavorare con Matteo (IMPORTANTE)

Matteo **non conosce Dart/Flutter**: lo sta imparando costruendo Balance.
Il metodo usato finora gli è piaciuto e va mantenuto **identico**:

1. **Un sotto-passo alla volta**, piccolo e provabile subito nell'app. Un solo concetto nuovo per volta (al massimo due, legati tra loro). I passi grandi si dividono (es. 5a, 5b, 5c).
2. Per ogni sotto-passo:
   - spiega **l'idea** prima del codice (cosa vogliamo ottenere, perché si fa così), con disegni ASCII della schermata quando aiutano;
   - indica il **punto esatto** del file dove scrivere ("tra la riga X e la riga Y", mostrando le righe vicine);
   - dai il **codice completo** da incollare (niente `...` da completare: un suggerimento con i puntini non basta);
   - spiega **riga per riga** le parti nuove, partendo da zero (cos'è, a cosa serve, analogia semplice), e collega ai concetti che ha già visto ("come in `_CardAvanzamento`...");
   - di' **come provarlo**: `r` (hot reload, cambi di aspetto) oppure `R` (hot restart, quando cambiano i dati iniziali) e cosa deve vedere, inclusi i difetti "previsti" che sistemeremo dopo.
3. Chiudi con: **"Dimmi 'fatto' e ricontrollo, oppure 'fai tu'"**.
   - **"fatto" / "controlla" / "correggi errori"** → leggi il file (`git diff`, `sed -n`), lancia `flutter analyze`, conferma cosa va bene, segnala errori traducendo i messaggi in italiano semplice. Spesso **dimentica di salvare** (Cmd+S) o applica solo **una parte** del passo: se mancano pezzi, dillo. "Correggi errori" a volte significa "sistema i difetti previsti": se `analyze` è pulito, chiedi cosa vede.
   - **"fai tu"** → fai tu la modifica con lo stesso codice spiegato, lancia `flutter analyze`, ricorda `r` o `R`.
   - Se chiede di **rispiegare**, rifallo partendo dall'idea, senza codice, con un'analogia.
4. Dopo ogni passo funzionante, suggerisci un **commit** (con il comando pronto). Non committare senza che lo chieda. Spesso si dimentica: ricordaglielo prima di iniziare un passo nuovo.
5. Rispetta le sue **scelte di design** anche se diverse dalla tua proposta, e spiega se semplificano.
6. Se sbagli una spiegazione o una previsione, **ammettilo** chiaramente e spiega il motivo vero.
7. Piccoli ritocchi di stile (commenti vecchi, righe vuote) segnalali come **facoltativi**, in breve.
8. Rispondi sempre in **italiano**.
9. Matteo prova l'app anche **sull'iPhone** (Safari): considera i limiti di Safari iOS.

---

## 2. Stato del codice

### File
- `lib/main.dart` – app, tema, barra di navigazione in basso. `Scaffold` con `resizeToAvoidBottomInset: false` (la pagina non si accorcia con la tastiera).
- `lib/tema.dart` – colori e tema (card con `margin: EdgeInsets.zero`; `FilledButton` largo quanto il contenitore, alto 48).
- `lib/scheda.dart` – modello dati (logica separata dalla UI), campi tutti `final`:
  - `Esercizio` (nome, serie, ripetizioni, carico `double`; 0 = corpo libero) + `volume()`.
  - `GiornoAllenamento` (nome es. "Giorno A", **tipo** es. "Upper", esercizi).
  - `Scheda` (giorni, dataInizio, durataSettimane) + getter `settimanaCorrente`, `programmazioneFinita`.
- `lib/schermata_scheda.dart` – sezione Scheda:
  - `schedaEsempio`: dati finti, liste modificabili (non `const`).
  - Card "Settimana X di N" (`_CardAvanzamento`), selettore giorni (`SegmentedButton`, stato `_giornoSelezionato`), titolo con il **tipo** del giorno.
  - Card esercizi attaccate tra loro, **toccabili** (`Card` con `clipBehavior: Clip.antiAlias` + `InkWell`) → aprono il modulo in modifica.
  - `_apriModuloEsercizio([Esercizio? esistente])`: `AlertDialog` **in alto** (`alignment: Alignment.topCenter`, evita lo scorrimento della pagina con la tastiera iPhone), `Form` + `GlobalKey<FormState>`, 4 `TextFormField` con `initialValue` e `validator`:
    - Nome obbligatorio; Serie e Ripetizioni interi ≥ 1 ("Almeno 1"); Kg vuoto = 0, altrimenti numero ≥ 0 con virgola o punto.
    - Titolo "Nuovo esercizio" / "Modifica esercizio". In modifica, Kg a 0 → campo vuoto (scelta di Matteo).
    - Salva: `validate()`, conversione con `tryParse ?? 0`, poi `.add` (nuovo) oppure `indexOf` + `lista[posizione] = nuovo` (modifica).
    - Pulsante rosso **Elimina** (solo in modifica, collection `if`) → `_confermaEliminazione(giorno, esercizio)`: finestra "Eliminare X?", `remove` + due `Navigator.pop`.

### Decisioni prese
- Il peso si mostra come numero anche quando è 0 ("0 kg" = corpo libero).
- Sul web `60.0` viene mostrato come `60`: nessuna formattazione del peso necessaria.
- `nome` del giorno resta corto (va nei pulsanti); `tipo` è libero e lo inserisce l'utente.
- Finestre = `AlertDialog` con pulsanti `TextButton`. Controlli con `Form` + `validator` (scelto anche per `initialValue`).
- `autofocus` resta: su iPhone Safari non apre la tastiera (limite di iOS: la tastiera si apre solo con un tocco diretto), sul computer sì.

### Concetti Dart/Flutter già spiegati
`ListView`/`children`, widget e `child`, `const` (e il suo "contagio"), `final` vs `var`, collection `for` e collection `if`, `Card`, `Padding`, `EdgeInsets`, `Column`, `Row`, `Expanded`, `crossAxisAlignment`, `mainAxisSize`, `SizedBox`, interpolazione, `style` + `copyWith` + `?.`, getter, `if`/`else`/`==`/`!=`/`||`/`!`/`return`, `? :`, `%`, `setState`, liste: `.add`, `.remove`, `indexOf`, `lista[i] = x`, `required`, parametri facoltativi `[ ]`, tipi con `?` (`String?`, `Esercizio?`), `null`, `??`, `!` dopo un valore, metodi e `void`, passare una funzione senza `()` vs `() => f(x)`, `showDialog`/`builder`, `AlertDialog` (+ `alignment`), `Navigator.pop` (pila di fogli), `TextField`/`TextFormField`, `onChanged`, `initialValue`, `keyboardType`, `Form`, `GlobalKey`, `validator`, `validate()`, `tryParse`, `replaceAll`, `trim`, `isEmpty`, `InkWell`/`onTap`, `clipBehavior`, `TextButton.styleFrom`, `colorScheme.error`, ambito delle variabili.

---

## 3. Prossimi passi

1. ~~Campi Serie/Ripetizioni/Kg~~ ✓ · ~~Controlli~~ ✓ · ~~Modificare ed eliminare esercizi~~ ✓
2. ~~Gestire i giorni~~ ✓ (passo 6): pulsante **+** (`IconButton.filledTonal`) accanto ai giorni → `_apriModuloGiorno([GiornoAllenamento? esistente])`; matita accanto al tipo → stessa finestra in modifica (tiene `esercizi: esistente.esercizi`); Elimina solo se `giorni.length > 1` (`&&`), `_confermaEliminazioneGiorno` → `remove` e `_giornoSelezionato = 0`. Attenzione: con molti giorni il `SegmentedButton` può non entrare su iPhone SE.
3. ~~Data di inizio e durata~~ ✓ (passo 7): matita sulla card avanzamento (`onModifica`, `VoidCallback`) → `_apriModuloProgrammazione` con `StatefulBuilder` + `await showDatePicker` (niente date future: `lastDate: DateTime.now()`); `schedaEsempio` è `var` e viene sostituita. Card mostra "dal 3/11/2026" (`_testoData`). App in italiano con `flutter_localizations` (sdk) in `main.dart`.
4. ~~Salvataggio sul dispositivo~~ ✓ (passo 8, fatto da Claude su richiesta di Matteo): `shared_preferences` (sul web = localStorage). `toJson`/`fromJson` (factory) in `scheda.dart`; nuovo file `lib/archivio.dart` con `schedaVuota()`, `caricaScheda()` (try/catch → null se rotta), `salvaScheda()`. `main()` è `async`: `WidgetsFlutterBinding.ensureInitialized()` + carica prima di `runApp`. In `schermata_scheda.dart` la variabile globale è `schedaAttuale` (prima `schedaEsempio`, dati di esempio rimossi); i `setState` che cambiano dati sono diventati `_aggiornaESalva(...)`. Prima apertura: un giorno vuoto "Giorno A"/"Allenamento", inizio oggi, 8 settimane. Concetti da spiegare/ripassare se chiede: Map, JSON, `factory`, `as`, `num`, `Future`, `try/catch`.
   - `test/widget_test.dart` è ancora il test di esempio del contatore (non funziona, va riscritto o tolto).
   - Da fare più avanti: **export/import JSON** (backup), utile perché iOS può cancellare i dati del sito.
5. **Allegato** foto/PDF della scheda originale: consigliato **rimandarlo** dopo la sezione Oggi (spazio limitato sul web).

Poi, secondo `CLAUDE.md`: Oggi → Calendario → Progressi e scarico.
