# sonoqui.md – Dove siamo arrivati

> **Per Claude:** leggi questo file all'inizio di ogni sessione, insieme a `CLAUDE.md`.
> Aggiornalo alla fine di ogni sessione (o quando Matteo lo chiede).
> Ultimo aggiornamento: **26/11/2026**, ultimo commit `28234b7 aggiunta esercizio`.

---

## 1. Come lavorare con Matteo (IMPORTANTE)

Matteo **non conosce Dart/Flutter**: lo sta imparando costruendo Balance.
Il metodo usato finora gli è piaciuto e va mantenuto **identico**:

1. **Un sotto-passo alla volta**, piccolo e provabile subito nell'app. Un solo concetto nuovo per volta (al massimo due, legati tra loro).
2. Per ogni sotto-passo:
   - spiega **l'idea** prima del codice (cosa vogliamo ottenere, perché si fa così), con disegni ASCII della schermata quando aiutano;
   - indica il **punto esatto** del file dove scrivere ("tra la riga X e la riga Y", mostrando le righe vicine);
   - dai il **codice completo** da incollare (niente `...` da completare: un suggerimento con i puntini non basta);
   - spiega **riga per riga** le parti nuove, partendo da zero (cos'è, a cosa serve, analogia semplice), e collega ai concetti che ha già visto ("come in `_CardAvanzamento`...");
   - di' **come provarlo**: `r` (hot reload, cambi di aspetto) oppure `R` (hot restart, quando cambiano i dati iniziali) e cosa deve vedere, inclusi i difetti "previsti" che sistemeremo dopo.
3. Chiudi con: **"Dimmi 'fatto' e ricontrollo, oppure 'fai tu'"**.
   - **"fatto" / "controlla"** → leggi il file (`git diff`, `sed -n`), lancia `flutter analyze`, conferma cosa va bene, segnala errori traducendo i messaggi in italiano semplice. Spesso **dimentica di salvare** (Cmd+S): se il file su disco non ha le modifiche, suggeriscilo.
   - **"fai tu"** → fai tu la modifica con lo stesso codice spiegato, lancia `flutter analyze`, ricorda `r` o `R`.
4. Dopo ogni passo funzionante, suggerisci un **commit** (con il comando pronto). Non committare senza che lo chieda.
5. Rispetta le sue **scelte di design** anche se diverse dalla tua proposta, e spiega se semplificano (es. "0 kg" invece di "Corpo libero" → più semplice, gestisce anche la zavorra).
6. Se sbagli una spiegazione, **ammettilo** chiaramente e spiega il motivo vero.
7. Piccoli ritocchi di stile (commenti vecchi, righe vuote, `// ` con lo spazio) segnalali come **facoltativi**, in breve.
8. Rispondi sempre in **italiano**.

---

## 2. Stato del codice

### File
- `lib/main.dart` – app, tema, barra di navigazione in basso.
- `lib/tema.dart` – colori e tema (card con `margin: EdgeInsets.zero`: gli spazi si decidono nelle schermate; `FilledButton` largo quanto il contenitore, alto 48).
- `lib/scheda.dart` – modello dati (logica separata dalla UI):
  - `Esercizio` (nome, serie, ripetizioni, carico `double`; 0 = corpo libero) + `volume()`.
  - `GiornoAllenamento` (nome es. "Giorno A", **tipo** es. "Upper"/"Lower"/"Full-Body", esercizi).
  - `Scheda` (giorni, dataInizio, durataSettimane) + getter `settimanaCorrente`, `programmazioneFinita`.
- `lib/schermata_scheda.dart` – sezione Scheda:
  - `schedaEsempio`: dati finti, **non più `const`** (liste modificabili).
  - Card "Settimana X di N" con barra (`_CardAvanzamento`).
  - Selettore giorni A/B/C (`SegmentedButton`, stato `_giornoSelezionato`).
  - Titolo con il **tipo** del giorno (17 semibold) sopra le card.
  - Card esercizi **attaccate tra loro** (scelta di Matteo: niente spazio tra le card): a sinistra nome + "serie × ripetizioni" grigio, a destra il peso "60 kg" con lo stesso stile del nome.
  - Pulsante "Aggiungi esercizio" (`FilledButton.icon`) → `_apriModuloEsercizio()`.
  - `_apriModuloEsercizio()`: `AlertDialog` con campo **Nome** (`TextField` + `onChanged` → variabile `nome`), pulsanti Annulla / Salva. Salva aggiunge `Esercizio(nome: nome, serie: 3, ripetizioni: 10)` (**serie e ripetizioni ancora fisse, provvisorie**).

### Decisioni prese
- Il peso si mostra come numero anche quando è 0 ("0 kg" = corpo libero; i kg positivi possono essere zavorra). Niente "Corpo libero".
- Sul web `60.0` viene mostrato come `60` (Dart → JavaScript), quindi nessuna formattazione del peso necessaria.
- `nome` del giorno resta corto (va nei pulsanti A/B/C); `tipo` è libero e lo inserirà l'utente.
- Finestra di inserimento = `AlertDialog` (gestisce da sola la tastiera); pulsanti nella finestra = `TextButton` (un `FilledButton` col tema attuale sarebbe largo infinito).

### Concetti Dart/Flutter già spiegati
`ListView`/`children`, widget e `child`, `const` (e il suo "contagio"), `final` vs `var`, collection `for`, `Card`, `Padding`, `EdgeInsets.all/only`, `Column`, `Row`, `Expanded`, `crossAxisAlignment`, `SizedBox`, interpolazione `'${...}'` / `'$x'`, `style` + `copyWith` + `?.`, getter, `if` / `==` / `return`, `%`, `setState` (con `=>` e con `{ }`), `.add`, `required` nel costruttore, errori dell'analizzatore, metodi e `void`, passare una funzione senza `()`, `showDialog` / `builder`, `AlertDialog`, `Navigator.pop` (pila di fogli), `TextField`, `onChanged`, variabili "condivise" dalle funzioni interne, ambito (scope) delle variabili.

---

## 3. Prossimi passi

### ▶ Sotto-passo 3 (spiegato ma NON ancora applicato): campi Serie, Ripetizioni, Kg
Nella finestra di `_apriModuloEsercizio()`:
- variabili `serieTesto`, `ripetizioniTesto`, `caricoTesto` (sotto `var nome = '';`);
- `content` diventa `Column(mainAxisSize: MainAxisSize.min, ...)`: Nome; `Row` con Serie | Ripetizioni (`Expanded`, `keyboardType: TextInputType.number`); Kg (`TextInputType.numberWithOptions(decimal: true)`, label "Kg (0 = corpo libero)");
- in Salva: `int.tryParse(...) ?? 0`, `double.tryParse(caricoTesto.replaceAll(',', '.')) ?? 0` (verificato: `?? 0` dà un `double`), poi `Esercizio(nome:, serie:, ripetizioni:, carico:)`.
- Concetti nuovi: testo ≠ numero, `tryParse`, `null`, `??`, `replaceAll`, `mainAxisSize`, `keyboardType`.
- Prove: normale, "62,5", kg vuoto/0, serie vuota (→ 0, difetto previsto).
- Matteo deve ancora decidere se scriverlo lui ("fatto") o farlo fare a Claude ("fai tu"): ripresentagli il sotto-passo.

### Poi, in ordine
4. **Controlli** nel modulo: nome vuoto, serie/ripetizioni vuote o 0, testo non numerico → non salvare e mostrare l'errore sotto il campo (probabile uso di `errorText` o `Form` + `validator`: scegliere la via più semplice e spiegarla).
5. **Modificare ed eliminare** un esercizio (es. tocco sulla card → stessa finestra precompilata; eliminazione con conferma).
6. **Gestire i giorni**: aggiungere/rinominare/eliminare un giorno, con **nome** e **tipo** (cosa allena) inseriti dall'utente.
7. **Data di inizio e durata** della programmazione modificabili.
8. **Salvataggio sul dispositivo** (ora i dati si perdono ricaricando la pagina). Prima di aggiungere un pacchetto (probabilmente `shared_preferences`) spiegare a cosa serve e le alternative. Probabilmente spostare la scheda nello stato / in un punto unico.
9. **Allegato** foto/PDF della scheda originale (ultimo, è solo un riferimento).

Poi, secondo `CLAUDE.md`: Oggi → Calendario → Progressi e scarico.
