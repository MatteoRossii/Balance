// ============================================================
// main.dart – punto di ingresso dell'app Balance
//
// Il file ha 3 parti, dall'alto verso il basso:
//   1. main()            -> avvia l'app
//   2. MyApp             -> impostazioni generali (titolo, tema)
//   3. Navigazione       -> barra in basso + schermata mostrata
// ============================================================

import 'package:flutter/material.dart';

// Importa i colori e lo stile (card, pulsanti, barra) da lib/tema.dart.
import 'tema.dart';
import 'schermata_scheda.dart';

// --- 1. AVVIO -------------------------------------------------
// Flutter parte sempre da main(). runApp() mette MyApp sullo schermo.
void main() {
  runApp(const MyApp());
}

// --- 2. IMPOSTAZIONI GENERALI ---------------------------------
// Qui NON si disegnano schermate: si configurano solo le cose
// che valgono per tutta l'app.
// DOVE OPERARE: titolo della scheda del browser, tema, prima schermata.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Toglie il nastro "DEBUG" in alto a destra durante lo sviluppo.
      debugShowCheckedModeBanner: false,
      // Nome che compare nella scheda del browser.
      title: 'BALANCE',
      // Colori e stile: sono definiti in lib/tema.dart.
      theme: temaBalance,
      // Prima schermata mostrata all'avvio: la nostra barra di navigazione.
      home: const Navigazione(),
    );
  }
}

// --- 3. NAVIGAZIONE -------------------------------------------
// È uno StatefulWidget perché deve ricordare quale sezione è
// selezionata, e quel valore cambia quando tocchi la barra.
// Un StatefulWidget si scrive sempre in due classi:
//   - Navigazione       -> la "configurazione" (sotto)
//   - _NavigazioneState -> i dati che cambiano + il metodo build
class Navigazione extends StatefulWidget {
  const Navigazione({super.key});

  @override
  State<Navigazione> createState() => _NavigazioneState();
}

class _NavigazioneState extends State<Navigazione> {
  // Sezione selezionata: 0 = Oggi, 1 = Scheda, 2 = Calendario, 3 = Progressi.
  // L'ordine deve coincidere con quello delle voci in `destinations`.
  int _indiceSelezionato = 0;

  // Per ora ogni sezione è solo un testo segnaposto.
  // DOVE OPERARE: quando crei le schermate vere (es. SchermataScheda),
  // questa lista di testi diventerà una lista di widget, nello stesso ordine.
  final List<String> _titoli = ['Oggi', 'Scheda', 'Calendario', 'Progressi'];

  @override
  Widget build(BuildContext context) {
    // Scaffold = scheletro di una schermata: un corpo (body)
    // e, in basso, la barra di navigazione.
    return Scaffold(
      // ---- CORPO: la schermata della sezione selezionata ----
      // SafeArea tiene il contenuto lontano da notch e barra di sistema dell'iPhone.
      body: SafeArea(
        // Su schermi larghi il contenuto non supera 500 e resta centrato.
        // Il Center esterno mette la colonna da 500 al centro dello schermo;
        // ConstrainedBox pone il limite di larghezza.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            // DOVE OPERARE: qui dentro va il contenuto della sezione scelta.
            // Il Center interno serve solo per il testo segnaposto: con una
            // ListView di card si toglie.
            // Se è selezionata "Scheda" (indice 1) mostra la schermata vera,
            // altrimenti ancora il testo segnaposto.
            // `? :` è un if/else in forma breve: condizione ? se vero : se falso
            child: _indiceSelezionato == 1
                ? const SchermataScheda()
                : Center(child: Text(_titoli[_indiceSelezionato])),
          ),
        ),
      ),

      // ---- BARRA IN BASSO ----
      // Sta fuori dal body, quindi resta larga quanto lo schermo.
      bottomNavigationBar: NavigationBar(
        // Quale voce è evidenziata.
        selectedIndex: _indiceSelezionato,
        // Chiamata quando tocchi una voce; `indice` è la posizione toccata.
        // setState dice a Flutter di ridisegnare con il nuovo valore:
        // senza setState il numero cambierebbe ma lo schermo no.
        onDestinationSelected: (indice) {
          setState(() => _indiceSelezionato = indice);
        },
        // Le 4 voci. DOVE OPERARE: per cambiare icone o nomi delle sezioni.
        // Se ne aggiungi o togli una, aggiorna anche `_titoli` sopra.
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Oggi'),
          NavigationDestination(
              icon: Icon(Icons.fitness_center), label: 'Scheda'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month), label: 'Calendario'),
          NavigationDestination(
              icon: Icon(Icons.show_chart), label: 'Progressi'),
        ],
      ),
    );
  }
}
