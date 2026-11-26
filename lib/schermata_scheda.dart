// ============================================================
// schermata_scheda.dart – sezione "Scheda" della barra in basso
//
// Il file ha 2 parti:
//   1. schedaEsempio     -> dati finti, finché non potremo inserirli
//   2. SchermataScheda   -> cosa si vede sullo schermo
// ============================================================

import 'package:flutter/material.dart';

import 'scheda.dart';
import 'tema.dart';

// --- 1. DATI DI ESEMPIO ---------------------------------------
// È `final` e non `const` perché DateTime(...) non può essere const.
// DOVE OPERARE: cambia data e durata per provare la barra
// (es. durataSettimane: 3 → programmazione finita).
final schedaEsempio = Scheda(
  dataInizio: DateTime(2026, 11, 3),
  durataSettimane: 8,
  giorni: [
    GiornoAllenamento(nome: 'Giorno A', tipo: 'Upper', esercizi: [
      Esercizio(nome: 'Squat', serie: 4, ripetizioni: 8, carico: 60),
      Esercizio(nome: 'Panca piana', serie: 4, ripetizioni: 8, carico: 50),
    ]),
    GiornoAllenamento(nome: 'Giorno B', tipo: 'Lower', esercizi: [
      Esercizio(nome: 'Stacco da terra', serie: 3, ripetizioni: 5, carico: 80),
      // Niente `carico:` → vale 0 grazie a `this.carico = 0` (corpo libero).
      Esercizio(nome: 'Trazioni', serie: 4, ripetizioni: 6),
      Esercizio(nome: 'Rematore', serie: 3, ripetizioni: 10, carico: 40),
    ]),
    GiornoAllenamento(nome: 'Giorno C', tipo: 'Full-Body', esercizi: [
      Esercizio(nome: 'Lento avanti', serie: 4, ripetizioni: 8, carico: 30),
      Esercizio(nome: 'Affondi', serie: 3, ripetizioni: 10, carico: 20),
      Esercizio(nome: 'Plank', serie: 3, ripetizioni: 1),
    ]),
  ],
);

// --- 2. SCHERMATA ---------------------------------------------
// StatefulWidget: la schermata deve ricordare quale giorno (A/B/C)
// è selezionato, e quel valore cambia quando tocchi i pulsanti.
// Come in main.dart (Navigazione), si scrive in due classi:
//   - SchermataScheda       -> la "configurazione" (non cambia)
//   - _SchermataSchedaState -> i dati che cambiano + il metodo build
class SchermataScheda extends StatefulWidget {
  const SchermataScheda({super.key});

  @override
  State<SchermataScheda> createState() => _SchermataSchedaState();
}

class _SchermataSchedaState extends State<SchermataScheda> {
  // Posizione del giorno scelto nella lista scheda.giorni:
  // 0 = A, 1 = B, 2 = C. All'apertura è selezionato il primo.
  // NON è final: deve poter cambiare quando tocchi un altro giorno.
  int _giornoSelezionato = 0;

  @override
  Widget build(BuildContext context) {
    // Gli stili di testo del tema: così le dimensioni restano coerenti
    // in tutta l'app invece di scrivere numeri sparsi.
    final testi = Theme.of(context).textTheme;
    final scheda = schedaEsempio;
    final giorno = scheda.giorni[_giornoSelezionato];

    // ListView invece di Column: se i contenuti superano l'altezza
    // dello schermo (iPhone SE) si può scorrere invece di andare in errore.
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Titolo pagina: 28 grassetto (CLAUDE.md, "Grafica").
        Text(
          'Scheda',
          style: testi.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16), // spazio tra blocchi: 16

        _CardAvanzamento(scheda: scheda),
        const SizedBox(height: 16),

        // Selettore dei giorni A / B / C.
        // <int>: il valore di ogni pulsante è la posizione del giorno
        // nella lista (0, 1, 2), come _giornoSelezionato.
        SegmentedButton<int>(
          // Un pulsante per ogni giorno della scheda ("collection for"):
          // se la scheda avesse 4 giorni, i pulsanti diventerebbero 4 da soli.
          segments: [
            for (var i = 0; i < scheda.giorni.length; i++)
              ButtonSegment(value: i, label: Text(scheda.giorni[i].nome)),
          ],
          // Vuole un Set (insieme) perché permetterebbe anche più selezioni;
          // {x} è un Set con un solo elemento.
          selected: {_giornoSelezionato},
          // Chiamata quando tocchi un pulsante: `nuovi` è il Set con la
          // nuova selezione (es. {2} se tocchi C). .first prende l'unico valore.
          // setState ridisegna lo schermo con il nuovo giorno.
          onSelectionChanged: (nuovi) {
            setState(() => _giornoSelezionato = nuovi.first);
          },
          // Toglie la ✓ accanto alla lettera selezionata.
          showSelectedIcon: false,
        ),
        const SizedBox(height: 16), //lascia spazio tra i pulsanti e l'esercizio
        Text(
          giorno.tipo,
          style: testi.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        for (final esercizio in giorno.esercizi)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // SINISTRA: nome + serie × ripetizioni.
                  // Expanded prende tutto lo spazio libero e spinge il peso a destra.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          esercizio.nome,
                          style: testi.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${esercizio.serie} × ${esercizio.ripetizioni}',
                          style: testi.bodyMedium?.copyWith(
                            color: coloreTestoSecondario,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // DESTRA: il peso, con lo stesso stile del nome.
                  Text(
                    '${esercizio.carico} kg',
                    style: testi.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // PROVA: aggiunge sempre lo stesso esercizio al giorno selezionato.
        // Nel prossimo passo lo sostituiremo con un modulo da compilare.
        FilledButton.icon(
          onPressed: () {
            setState(() {
              giorno.esercizi.add(
                const Esercizio(
                    nome: 'Curl', serie: 3, ripetizioni: 10, carico: 12),
              );
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Aggiungi esercizio'),
        ),
      ],
    );
  }
}

// Card "Settimana X di N" con la barra di avanzamento.
// Il trattino basso iniziale (_CardAvanzamento) la rende privata:
// si può usare solo dentro questo file.
class _CardAvanzamento extends StatelessWidget {
  const _CardAvanzamento({required this.scheda});

  final Scheda scheda;

  @override
  Widget build(BuildContext context) {
    final testi = Theme.of(context).textTheme;

    // La barra vuole un numero tra 0.0 (vuota) e 1.0 (piena).
    // clamp evita di andare oltre 1.0 quando la programmazione è finita
    // (es. settimana 9 di 8 → 1.125 → diventa 1.0).
    final avanzamento =
        (scheda.settimanaCorrente / scheda.durataSettimane).clamp(0.0, 1.0);

    // Qui usiamo la regola scritta in scheda.dart: la UI non fa calcoli,
    // chiede soltanto "è finita?" e sceglie il testo.
    final titolo = scheda.programmazioneFinita
        ? 'Programmazione finita'
        : 'Settimana ${scheda.settimanaCorrente} di ${scheda.durataSettimane}';

    // Card: angoli, bordo e colore arrivano già dal tema (tema.dart).
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          // Allinea i figli a sinistra (di default sarebbero centrati).
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo card: 17 semibold.
            Text(
              titolo,
              style: testi.titleMedium?.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: avanzamento,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: coloreVerdeChiaro,
            ),
          ],
        ),
      ),
    );
  }
}
