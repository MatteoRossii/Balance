# sonoqui.md – Dove siamo arrivati

> **Per Claude:** leggi questo file all'inizio di ogni sessione, insieme a `CLAUDE.md`.
> Aggiornalo alla fine di ogni sessione (o quando Matteo lo chiede).
> Ultimo aggiornamento: **27/11/2026**, ultimo commit `698b0eb aggiunta salvataggio dati`.
> **Sezione Scheda completata.** Prossima: sezione **Oggi** (vedi §3).

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
  - `main()` è **`async`**: `WidgetsFlutterBinding.ensureInitialized()`, poi `await caricaScheda()` → se non è `null` diventa `schedaAttuale`, poi `runApp`.
  - `MaterialApp`: tema, **italiano** (`flutter_localizations`: `localizationsDelegates`, `supportedLocales`, `locale: Locale('it')`).
  - `Navigazione`: `Scaffold` (`resizeToAvoidBottomInset: false`), `NavigationBar` con 4 voci; solo l'indice 1 (Scheda) è una schermata vera, le altre sono testi segnaposto (`_titoli`).
- `lib/tema.dart` – colori e tema (card con `margin: EdgeInsets.zero`; `FilledButton` largo quanto il contenitore, alto 48). Contiene `coloreTestoSecondario`, `coloreVerdeChiaro`.
- `lib/scheda.dart` – modello dati, campi tutti `final`, ognuno con `toJson()` e `factory ...fromJson(...)`:
  - `Esercizio` (nome, serie, ripetizioni, carico `double`; 0 = corpo libero) + `volume()`. In `fromJson` il carico passa da `num` → `toDouble()`.
  - `GiornoAllenamento` (nome es. "Giorno A", **tipo** es. "Upper", esercizi: lista **modificabile**, mai `const []`).
  - `Scheda` (giorni, dataInizio, durataSettimane) + getter `settimanaCorrente`, `programmazioneFinita`. Data in JSON con `toIso8601String()` / `DateTime.parse`.
- `lib/archivio.dart` – salvataggio (niente UI): `shared_preferences`, etichetta `'scheda'`.
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
- `test/widget_test.dart` – è ancora il test d'esempio del contatore: **non funziona**, va riscritto o tolto (da proporre).

### Decisioni prese
- Il peso si mostra come numero anche quando è 0 ("0 kg" = corpo libero). Sul web `60.0` appare `60`.
- `nome` del giorno corto (va nei pulsanti); `tipo` libero, obbligatorio nel form.
- Finestre = `AlertDialog` con `TextButton`; controlli con `Form` + `validator`.
- `autofocus` resta: su iPhone non apre la tastiera (limite iOS), sul computer sì.
- Data di inizio: **niente date future**.
- Salvataggio: `shared_preferences` + JSON (scelto contro localStorage diretto e database tipo Hive/sqflite, esagerati).
- Dati di esempio rimossi: si parte da una scheda vuota.
- **Progressione dei carichi (decisa il 27/11, confermata da Matteo):**
  - la **scheda** è il piano e contiene il **carico attuale** di ogni esercizio (non "quello della prima settimana");
  - nasce un **diario degli allenamenti** (storico): classe nuova `AllenamentoFatto` (data, nome del giorno, esercizi con i kg davvero usati, riusa `Esercizio`), salvata in `archivio.dart` con un'altra etichetta (es. `'diario'`), stesso metodo JSON;
  - in **Oggi**, "Segna come fatto" apre una finestra con i kg **precompilati** dalla scheda; l'utente cambia solo quelli aumentati → Salva = 1) aggiunge una riga al diario, 2) aggiorna i carichi nella scheda;
  - il diario serve anche a capire **quale giorno tocca oggi** (dopo l'ultimo fatto: A → B → C → A) e alla sezione **Progressi** (grafico squat, carico settimanale con `volume()`);
  - **scartato**: carichi pianificati settimana per settimana nella scheda; **rimandato**: progressione automatica (eventuale *consiglio* in "Il consiglio di oggi", con regole "se... allora...", ma decide sempre l'utente).

### Concetti Dart/Flutter già spiegati
`ListView`/`children`, widget e `child`, `const` (e il suo "contagio"), `final` vs `var`, collection `for` e collection `if`, `Card`, `Padding`, `EdgeInsets`, `Column`, `Row`, `Expanded`, `crossAxisAlignment`, `mainAxisSize`, `SizedBox`, interpolazione, `style` + `copyWith` + `?.`, getter, `if`/`else`/`==`/`!=`/`||`/`&&`/`!`/`return`, `? :`, `%`, `setState`, liste: `.add`, `.remove`, `indexOf`, `lista[i] = x`, `length - 1`, `required`, parametri facoltativi `[ ]`, tipi con `?`, `null`, `??`, `!` dopo un valore, metodi `void` e funzioni che restituiscono `String`, passare una funzione senza `()` vs `() => f(x)`, `VoidCallback` (passare funzioni ai propri widget), `showDialog`/`builder`, `AlertDialog` (+ `alignment`), `Navigator.pop` (pila di fogli, anche due volte), `TextField`/`TextFormField`, `onChanged`, `initialValue`, `keyboardType`, `Form`, `GlobalKey`, `validator`, `validate()`, `tryParse`, `replaceAll`, `trim`, `isEmpty`, `InkWell`/`onTap`, `clipBehavior`, `IconButton` (+ `.filledTonal`, `tooltip`), `TextButton.styleFrom`, `colorScheme.error`, `StatefulBuilder`, `async`/`await`, `showDatePicker`, `DateTime` (`.day`, `.month`, `.year`), ambito delle variabili.

**Introdotti nel passo 8 ma spiegati solo in breve** (fatto da Claude): `Map<String, dynamic>`, JSON (`jsonEncode`/`jsonDecode`), `factory`, `as`, `num`/`toDouble()`, `Future`, `try/catch`, `WidgetsFlutterBinding.ensureInitialized()`. Se servono nella sezione Oggi (es. per il diario), **rispiegali con calma** quando li si riusa.

---

## 3. Prossimi passi

### Fatto
Sezione **Scheda**: campi e controlli, modifica/eliminazione esercizi, gestione giorni, data e durata, app in italiano, salvataggio sul dispositivo.

### ▶ Prossimo: sezione **Oggi** (da `CLAUDE.md` e grafica approvata)
Ordine proposto, sempre in sotto-passi piccoli (da presentare a Matteo, non ancora iniziati):
1. **Schermata Oggi di base**: nuovo file `lib/schermata_oggi.dart`, collegato in `main.dart` all'indice 0 (come `SchermataScheda` all'indice 1). Titolo "Bentornato in Balance" + data di oggi.
2. **Card "Allenamento di oggi"**: mostra un giorno della scheda con esercizi e carichi attuali (all'inizio il primo giorno; la scelta "quale giorno tocca" arriva col diario).
3. **Diario**: classe `AllenamentoFatto` + `toJson`/`fromJson` + `caricaDiario`/`salvaDiario` in `archivio.dart`, caricato in `main()` come la scheda.
4. **"Segna come fatto"**: finestra con i kg precompilati → aggiunge al diario + aggiorna i carichi della scheda (vedi "Progressione dei carichi").
5. **Quale giorno tocca oggi**: il giorno dopo l'ultimo nel diario (con giro A → B → C → A); "già fatto oggi" se c'è una riga con la data di oggi.
6. **Check-in** "Come ti senti oggi?" (scala 1-5: Distrutto, Stanco, Normale, Bene, Al top), "Hai dolori muscolari?" Sì/No + muscoli (Petto, Schiena, Spalle, Bicipiti, Tricipiti, Addome, Quadricipiti, Femorali, Glutei, Polpacci), "Salva check-in" (anche questo da salvare).
7. **"Il consiglio di oggi"**: regole "se... allora..." in un file separato dalla UI (es. `lib/regole.dart`).
8. Il **promemoria esami** arriverà con la sezione Calendario (gli esami NON riducono mai l'allenamento, solo promemoria sullo studio).

### Più avanti
- **Export/import JSON** (backup della scheda e del diario): utile perché iOS può cancellare i dati del sito.
- Sistemare `test/widget_test.dart`.
- **Allegato** foto/PDF della scheda originale (rimandato: spazio limitato sul web).
- Possibile problema: con molti giorni il `SegmentedButton` può non entrare su iPhone SE.

Poi, secondo `CLAUDE.md`: Calendario → Progressi e scarico.
