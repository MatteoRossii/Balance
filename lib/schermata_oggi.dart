// ============================================================
// schermata_oggi.dart – sezione "Oggi" della barra in basso
// ============================================================

import 'package:flutter/material.dart';

import 'tema.dart';
import 'check_in.dart';
import 'archivio.dart';

// Nomi in italiano. DateTime.weekday va da 1 (lunedì) a 7 (domenica),
// DateTime.month da 1 (gennaio) a 12: le liste partono da 0, quindi -1.
const _nomiGiorni = [
  'lunedì',
  'martedì',
  'mercoledì',
  'giovedì',
  'venerdì',
  'sabato',
  'domenica',
];
const _nomiMesi = [
  'gennaio',
  'febbraio',
  'marzo',
  'aprile',
  'maggio',
  'giugno',
  'luglio',
  'agosto',
  'settembre',
  'ottobre',
  'novembre',
  'dicembre',
];

// Scrive una data come "sabato 28 novembre".
String _dataEstesa(DateTime data) {
  final giorno = _nomiGiorni[data.weekday - 1];
  final mese = _nomiMesi[data.month - 1];
  return '$giorno ${data.day} $mese';
}

// Nomi della scala del check-in: posizione 0 = voto 1 ... posizione 4 = voto 5.
const _nomiSensazioni = [
  'Molto stanco',
  'Stanco',
  'Normale',
  'Bene',
  'Al top',
];
// I muscoli che si possono segnare come doloranti (CLAUDE.md, "Grafica").
const _muscoli = [
  'Petto',
  'Schiena',
  'Spalle',
  'Bicipiti',
  'Tricipiti',
  'Addome',
  'Quadricipiti',
  'Femorali',
  'Glutei',
  'Polpacci',
];

// Tutti i check-in salvati (uno per giorno). All'avvio main() la riempie
// con quelli dell'archivio. Non si mostra mai come elenco: serve alle regole.
List<CheckIn> elencoCheckIn = [];

// StatefulWidget: la schermata deve ricordare le scelte del check-in.
class SchermataOggi extends StatefulWidget {
  const SchermataOggi({super.key});

  @override
  State<SchermataOggi> createState() => _SchermataOggiState();
}

class _SchermataOggiState extends State<SchermataOggi> {
  // Come ti senti oggi, da 1 a 5. null = non hai ancora scelto.
  int? _sensazione;
// Hai dolori muscolari? false = No (valore di partenza), true = Sì.
  bool _dolori = false;
  // Muscoli doloranti scelti. Set = insieme: ogni muscolo al massimo una volta.
  // final: il Set resta lo stesso, cambiamo solo cosa contiene.
  final Set<String> _muscoliDoloranti = {};
  // true se oggi il check-in è già stato salvato (cambia il testo del pulsante).
  bool _salvatoOggi = false;

  // initState: eseguito UNA volta, quando la schermata viene creata
  // (prima del primo build). Qui ricompiliamo la card se oggi
  // il check-in c'è già.
  @override
  void initState() {
    super.initState();
    for (final checkIn in elencoCheckIn) {
      if (stessoGiorno(checkIn.data, DateTime.now())) {
        _sensazione = checkIn.sensazione;
        _dolori = checkIn.haDolori;
        // addAll: aggiunge al Set tutti i muscoli della lista.
        _muscoliDoloranti.addAll(checkIn.muscoliDoloranti);
        _salvatoOggi = true;
      }
    }
  }

  // Getter: si può salvare solo se hai scelto un voto e, se hai detto
  // di avere dolori, almeno un muscolo ("Sì" senza muscoli non ha senso).
  bool get _puoiSalvare {
    if (_sensazione == null) {
      return false;
    }
    if (_dolori && _muscoliDoloranti.isEmpty) {
      return false;
    }
    return true;
  }

  // Salva il check-in di oggi (o sostituisce quello già salvato oggi).
  void _salvaCheckIn() {
    final adesso = DateTime.now();
    final nuovo = CheckIn(
      // Solo giorno/mese/anno, senza ore.
      data: DateTime(adesso.year, adesso.month, adesso.day),
      // `!`: il pulsante funziona solo se hai scelto un voto (_puoiSalvare).
      sensazione: _sensazione!,
      // Il Set diventa una lista (il JSON non conosce i Set).
      muscoliDoloranti: _muscoliDoloranti.toList(),
    );
    setState(() {
      // Togliamo l'eventuale check-in di oggi già salvato...
      elencoCheckIn.removeWhere(
        (vecchio) => stessoGiorno(vecchio.data, adesso),
      );
      // ...e mettiamo quello nuovo: sempre una sola riga per giorno.
      elencoCheckIn.add(nuovo);
      _salvatoOggi = true;
    });
    salvaCheckIn(elencoCheckIn);
    // Messaggio di conferma in basso, sparisce da solo.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in salvato')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final testi = Theme.of(context).textTheme;

    // ListView come nella Scheda: si può scorrere su schermi piccoli.
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Data di oggi, piccola e grigia, sopra il titolo.
        Text(
          _dataEstesa(DateTime.now()),
          style: testi.bodyLarge?.copyWith(color: coloreTestoSecondario),
        ),
        const SizedBox(height: 4),
        // Titolo pagina: 28 grassetto (CLAUDE.md, "Grafica").
        Text(
          'Bentornato in Balance',
          style: testi.headlineMedium?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // ---- CHECK-IN ----
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Come ti senti oggi?',
                  style: testi.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // SizedBox largo quanto la card: i 5 pulsanti si dividono
                // tutto lo spazio invece di stare stretti a sinistra.
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    // Pulsanti più alti e con poco margine ai lati,
                    // così il nome dello stato ci sta anche su iPhone SE.
                    style: SegmentedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 12,
                      ),
                    ),
                    // Un pulsante per ogni voto da 1 a 5:
                    // sopra il numero, sotto il nome dello stato.
                    segments: [
                      for (var voto = 1; voto <= 5; voto++)
                        ButtonSegment(
                          value: voto,
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$voto',
                                style: testi.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _nomiSensazioni[voto - 1],
                                // Al centro, al massimo su 2 righe
                                // ("Molto stanco" va a capo).
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: testi.labelSmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                    // Set con il voto scelto, oppure vuoto se non hai scelto.
                    selected: {if (_sensazione != null) _sensazione!},
                    // Permette di non avere nulla selezionato (all'inizio,
                    // o se ritocchi il voto già scelto).
                    emptySelectionAllowed: true,
                    onSelectionChanged: (nuovi) {
                      setState(() {
                        _sensazione = nuovi.isEmpty ? null : nuovi.first;
                      });
                    },
                    showSelectedIcon: false,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Hai dolori muscolari?',
                  style: testi.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // <bool>: il valore di ogni pulsante è vero o falso.
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('No')),
                    ButtonSegment(value: true, label: Text('Sì')),
                  ],
                  selected: {_dolori},
                  onSelectionChanged: (nuovi) {
                    setState(() {
                      _dolori = nuovi.first;
                      // Tornando su "No" togliamo i muscoli scelti.
                      if (!_dolori) {
                        _muscoliDoloranti.clear();
                      }
                    });
                  },
                  showSelectedIcon: false,
                ),
                // I muscoli compaiono solo se hai risposto Sì.
                if (_dolori)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    // Wrap: mette i figli in fila e va a capo da solo.
                    child: Wrap(
                      spacing: 8, // spazio orizzontale tra le pastiglie
                      runSpacing: 8, // spazio tra una riga e l'altra
                      children: [
                        for (final muscolo in _muscoli)
                          FilterChip(
                            label: Text(muscolo),
                            // Accesa se il muscolo è nel Set.
                            selected: _muscoliDoloranti.contains(muscolo),
                            // `scelto`: true se l'hai appena acceso,
                            // false se l'hai appena spento.
                            onSelected: (scelto) {
                              setState(() {
                                if (scelto) {
                                  _muscoliDoloranti.add(muscolo);
                                } else {
                                  _muscoliDoloranti.remove(muscolo);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                // Avviso se hai detto "Sì" ma non hai scelto nessun muscolo.
                if (_dolori && _muscoliDoloranti.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Scegli almeno un muscolo',
                      style: testi.bodyMedium?.copyWith(
                        color: coloreTestoSecondario,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  // onPressed null = pulsante disattivato (grigio).
                  onPressed: _puoiSalvare ? _salvaCheckIn : null,
                  child: Text(
                    _salvatoOggi ? 'Aggiorna check-in' : 'Salva check-in',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
