// ============================================================
// schermata_scheda.dart – sezione "Scheda" della barra in basso
//
// Il file ha 2 parti:
//   1. schedaAttuale     -> la scheda mostrata (caricata dal telefono)
//   2. SchermataScheda   -> cosa si vede sullo schermo
// ============================================================

import 'package:flutter/material.dart';

import 'archivio.dart';
import 'scheda.dart';
import 'tema.dart';

// Scrive una data come "3/11/2026". Una sola funzione usata sia nella
// card sia nella finestra: per cambiare formato basta cambiarla qui.
String _testoData(DateTime data) {
  return '${data.day}/${data.month}/${data.year}';
}

// --- 1. LA SCHEDA -------------------------------------------
// La scheda attuale, quella mostrata e modificata sullo schermo.
// Parte vuota; all'avvio main() la sostituisce con quella salvata
// sul telefono (se c'è). È `var` perché quando cambi data o durata
// la sostituiamo con una scheda nuova (i campi di Scheda sono final).
var schedaAttuale = schedaVuota();

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

  // Da usare al posto di setState quando cambiano i DATI della scheda:
  // ridisegna la schermata (setState) e poi salva sul telefono.
  // `modifica` è la funzione con i cambiamenti, la stessa che daresti a setState.
  void _aggiornaESalva(VoidCallback modifica) {
    setState(modifica);
    salvaScheda(schedaAttuale);
  }

  // Apre la finestra per aggiungere un esercizio,
  // o per modificarlo/eliminarlo se passi quello esistente.
  void _apriModuloEsercizio([Esercizio? esistente]) {
    // Il giorno a cui aggiungere l'esercizio (quello scelto con A/B/C).
    final giorno = schedaAttuale.giorni[_giornoSelezionato];

    // Qui ricordiamo cosa scrive l'utente nel campo "Nome".
    // `var` e non `final`: il valore cambia a ogni lettera.
    var nome = '';
    var serieTesto = '';
    var ripetizioniTesto = '';
    var caricoTesto = '';

    if (esistente != null) {
      nome = esistente.nome;
      serieTesto = '${esistente.serie}';
      ripetizioniTesto = '${esistente.ripetizioni}';
      caricoTesto = esistente.carico == 0 ? '' : '${esistente.carico}';
    }

    // "Telecomando" del modulo: con questa chiave, quando premi Salva,
    // possiamo dire al Form "controlla tutti i campi".
    final chiaveModulo = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // In alto invece che al centro: così i campi restano sopra
          // la tastiera dell'iPhone e Safari non fa scorrere la pagina.
          alignment: Alignment.topCenter,
          // Titolo diverso se stiamo aggiungendo o modificando.
          title: Text(
            esistente == null ? 'Nuovo esercizio' : 'Modifica esercizio',
          ),
          content: Form(
            key: chiaveModulo, // attacchiamo il "telecomando" al modulo
            child: Column(
              // La colonna occupa solo l'altezza che le serve,
              // invece di allungarsi per tutto lo schermo.
              mainAxisSize: MainAxisSize.min,
              children: [
                // TextFormField = TextField che sa farsi controllare dal Form.
                TextFormField(
                  initialValue: nome,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  onChanged: (testo) => nome = testo,
                  // Il controllo: restituisce il messaggio d'errore,
                  // oppure null se va tutto bene.
                  validator: (testo) {
                    if (testo == null || testo.trim().isEmpty) {
                      return 'Scrivi il nome';
                    }
                    return null;
                  },
                ),
                // Serie e Ripetizioni affiancate, metà spazio ciascuna.
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: serieTesto,
                        // Su iPhone apre il tastierino numerico.
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Serie'),
                        onChanged: (testo) => serieTesto = testo,
                        validator: (testo) {
                          // Proviamo a leggere un numero intero:
                          // null se il campo è vuoto o non è un numero.
                          final numero = int.tryParse(testo ?? '');
                          if (numero == null || numero < 1) {
                            return 'Almeno 1';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: ripetizioniTesto,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Ripetizioni'),
                        onChanged: (testo) => ripetizioniTesto = testo,
                        // Stesso controllo delle serie.
                        validator: (testo) {
                          final numero = int.tryParse(testo ?? '');
                          if (numero == null || numero < 1) {
                            return 'Almeno 1';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  initialValue: caricoTesto,
                  // Tastierino numerico con la virgola (per 62,5 kg).
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Kg (0 = corpo libero)',
                  ),
                  onChanged: (testo) => caricoTesto = testo,
                  validator: (testo) {
                    // Campo vuoto = va bene: in Salva diventa 0 kg.
                    if (testo == null || testo.trim().isEmpty) {
                      return null;
                    }
                    // Come in Salva: virgola → punto, poi numero decimale.
                    final numero = double.tryParse(testo.replaceAll(',', '.'));
                    if (numero == null || numero < 0) {
                      return 'Scrivi un numero da 0 in su (es. 62,5)';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            // Elimina c'è solo quando modifichi un esercizio esistente.
            if (esistente != null)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => _confermaEliminazione(giorno, esistente),
                child: const Text('Elimina'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                final tuttoOk = chiaveModulo.currentState!.validate();
                if (!tuttoOk) {
                  return; // esce subito: niente salvataggio, finestra aperta
                }
                // Dal testo ai numeri. tryParse dà null se il testo
                // non è un numero valido (es. vuoto o "abc");
                // ?? 0 vuol dire "se è null, usa 0".
                final serie = int.tryParse(serieTesto) ?? 0;
                final ripetizioni = int.tryParse(ripetizioniTesto) ?? 0;
                // In Italia si scrive 62,5 ma Dart vuole 62.5:
                // sostituiamo la virgola col punto prima di convertire.
                final carico =
                    double.tryParse(caricoTesto.replaceAll(',', '.')) ?? 0;

                // L'esercizio con i dati scritti nei campi.
                final nuovo = Esercizio(
                  nome: nome,
                  serie: serie,
                  ripetizioni: ripetizioni,
                  carico: carico,
                );

                _aggiornaESalva(() {
                  if (esistente == null) {
                    // Esercizio nuovo: lo aggiungiamo in fondo.
                    giorno.esercizi.add(nuovo);
                  } else {
                    // Modifica: troviamo la posizione di quello vecchio
                    // (0, 1, 2...) e mettiamo il nuovo al suo posto.
                    final posizione = giorno.esercizi.indexOf(esistente);
                    giorno.esercizi[posizione] = nuovo;
                  }
                });
                Navigator.pop(context); // chiude la finestra
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  void _confermaEliminazione(GiornoAllenamento giorno, Esercizio esercizio) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminare ${esercizio.nome}?'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context), // chiude solo la conferma
              child: const Text('Annulla'),
            ),
            TextButton(
              // Rosso: lo stesso colore dei messaggi d'errore del Form.
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                _aggiornaESalva(() {
                  giorno.esercizi.remove(esercizio);
                });
                Navigator.pop(context); // chiude la conferma
                Navigator.pop(context); // chiude la finestra di modifica
              },
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
  }

  // Apre la finestra per aggiungere un nuovo giorno alla scheda.
  void _apriModuloGiorno([GiornoAllenamento? esistente]) {
    // Cosa scrive l'utente nei due campi.
    var nome = '';
    var tipo = '';

    // Se stiamo modificando, partiamo dai valori del giorno.
    if (esistente != null) {
      nome = esistente.nome;
      tipo = esistente.tipo;
    }

    // "Telecomando" del modulo, come nella finestra degli esercizi.
    final chiaveModulo = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // In alto, per la tastiera dell'iPhone (come per gli esercizi).
          alignment: Alignment.topCenter,
          title: Text(esistente == null ? 'Nuovo giorno' : 'Modifica giorno'),
          content: Form(
            key: chiaveModulo,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: nome,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nome (es. Giorno D)',
                  ),
                  onChanged: (testo) => nome = testo,
                  validator: (testo) {
                    if (testo == null || testo.trim().isEmpty) {
                      return 'Scrivi il nome';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: tipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo (es. Upper, Lower, Full-Body)',
                  ),
                  onChanged: (testo) => tipo = testo,
                  validator: (testo) {
                    if (testo == null || testo.trim().isEmpty) {
                      return 'Scrivi il tipo';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            // Elimina c'è solo quando modifichi un giorno
            // E non è l'ultimo rimasto (la scheda deve avere almeno un giorno).
            if (esistente != null && schedaAttuale.giorni.length > 1)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => _confermaEliminazioneGiorno(esistente),
                child: const Text('Elimina'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () {
                final tuttoOk = chiaveModulo.currentState!.validate();
                if (!tuttoOk) {
                  return; // errori: la finestra resta aperta
                }
                _aggiornaESalva(() {
                  if (esistente == null) {
                    schedaAttuale.giorni.add(
                      GiornoAllenamento(
                        nome: nome.trim(),
                        tipo: tipo.trim(),
                        // Lista vuota MODIFICABILE (senza const):
                        // dopo ci aggiungeremo gli esercizi.
                        esercizi: [],
                      ),
                    );
                    // Seleziona subito il giorno appena creato,
                    // che è l'ultimo della lista.
                    _giornoSelezionato = schedaAttuale.giorni.length - 1;
                  } else {
                    // Modifica: stesso posto, nuovo nome e tipo,
                    // ma GLI STESSI esercizi del giorno vecchio.
                    final posizione = schedaAttuale.giorni.indexOf(esistente);
                    schedaAttuale.giorni[posizione] = GiornoAllenamento(
                      nome: nome.trim(),
                      tipo: tipo.trim(),
                      esercizi: esistente.esercizi,
                    );
                  }
                });
                Navigator.pop(context); // chiude la finestra
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

// Apre la finestra per cambiare durata e data di inizio della programmazione.
  void _apriModuloProgrammazione() {
    // Partiamo dai valori attuali.
    var durataTesto = '${schedaAttuale.durataSettimane}';
    var dataInizio = schedaAttuale.dataInizio;

    final chiaveModulo = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder: dà alla finestra un suo setState
        // (setStateFinestra) per ridisegnarla quando cambi la data.
        return StatefulBuilder(
          builder: (context, setStateFinestra) {
            return AlertDialog(
              alignment: Alignment.topCenter,
              title: const Text('Programmazione'),
              content: Form(
                key: chiaveModulo,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: durataTesto,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Durata (settimane)',
                      ),
                      onChanged: (testo) => durataTesto = testo,
                      validator: (testo) {
                        final numero = int.tryParse(testo ?? '');
                        if (numero == null || numero < 1) {
                          return 'Almeno 1';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Data di inizio a sinistra, pulsante "Cambia" a destra.
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Inizio: ${_testoData(dataInizio)}',
                          ),
                        ),
                        TextButton(
                          // async: questa funzione sa "aspettare" (await).
                          onPressed: () async {
                            // Apre il calendario e ASPETTA la scelta.
                            // Se premi Annulla, `scelta` è null.
                            final scelta = await showDatePicker(
                              context: context,
                              initialDate: dataInizio,
                              firstDate: DateTime(2020),
                              // Niente date future: la scheda si inserisce
                              // quando la si inizia.
                              lastDate: DateTime.now(),
                              helpText: 'Data di inizio',
                            );
                            if (scelta != null) {
                              // Ridisegna la finestra con la nuova data.
                              setStateFinestra(() => dataInizio = scelta);
                            }
                          },
                          child: const Text('Cambia'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annulla'),
                ),
                TextButton(
                  onPressed: () {
                    final tuttoOk = chiaveModulo.currentState!.validate();
                    if (!tuttoOk) {
                      return;
                    }
                    final durata = int.tryParse(durataTesto) ?? 1;
                    _aggiornaESalva(() {
                      // Scheda nuova al posto della vecchia: STESSI giorni,
                      // nuova data e nuova durata.
                      schedaAttuale = Scheda(
                        giorni: schedaAttuale.giorni,
                        dataInizio: dataInizio,
                        durataSettimane: durata,
                      );
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Salva'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Chiede conferma e, se confermi, elimina il giorno con i suoi esercizi.
  void _confermaEliminazioneGiorno(GiornoAllenamento giorno) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminare ${giorno.nome}?'),
          // Avviso: insieme al giorno spariscono anche i suoi esercizi.
          content: const Text('Verranno eliminati anche i suoi esercizi.'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context), // chiude solo la conferma
              child: const Text('Annulla'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                _aggiornaESalva(() {
                  schedaAttuale.giorni.remove(giorno);
                  // Il giorno selezionato potrebbe non esistere più
                  // (es. eri sul 4° e ora ce ne sono 3): torniamo al primo.
                  _giornoSelezionato = 0;
                });
                Navigator.pop(context); // chiude la conferma
                Navigator.pop(context); // chiude la finestra del giorno
              },
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gli stili di testo del tema: così le dimensioni restano coerenti
    // in tutta l'app invece di scrivere numeri sparsi.
    final testi = Theme.of(context).textTheme;
    final scheda = schedaAttuale;
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

        _CardAvanzamento(
          scheda: scheda,
          onModifica: _apriModuloProgrammazione,
        ),
        const SizedBox(height: 16),

        // Selettore dei giorni A / B / C.
        // <int>: il valore di ogni pulsante è la posizione del giorno
        // nella lista (0, 1, 2), come _giornoSelezionato.
        // A sinistra i giorni, a destra il pulsante per aggiungerne uno.
        Row(
          children: [
            Expanded(
              child: SegmentedButton<int>(
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
            ),
            const SizedBox(width: 8),
            // Pulsante tondo con il +, sfondo verde chiaro.
            IconButton.filledTonal(
              onPressed: _apriModuloGiorno,
              icon: const Icon(Icons.add),
              tooltip: 'Aggiungi giorno',
            ),
          ],
        ),
        const SizedBox(height: 16), //lascia spazio tra i pulsanti e l'esercizio
        // Tipo del giorno a sinistra, matita per modificarlo a destra.
        Row(
          children: [
            Expanded(
              child: Text(
                giorno.tipo,
                style: testi.titleMedium?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _apriModuloGiorno(giorno),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Modifica giorno',
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final esercizio in giorno.esercizi)
          Card(
            // Taglia l'effetto del tocco lungo gli angoli arrotondati.
            clipBehavior: Clip.antiAlias,
            // InkWell: rende toccabile ciò che contiene, con l'effetto "onda".
            child: InkWell(
              onTap: () => _apriModuloEsercizio(esercizio),
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
          ),
        const SizedBox(height: 16),

        // PROVA: aggiunge sempre lo stesso esercizio al giorno selezionato.
        // Nel prossimo passo lo sostituiremo con un modulo da compilare.
        FilledButton.icon(
          onPressed: _apriModuloEsercizio,
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
  const _CardAvanzamento({required this.scheda, required this.onModifica});

  final Scheda scheda;
  // La funzione da chiamare quando tocchi la matita
  // (la decide chi usa la card, cioè la schermata).
  final VoidCallback onModifica;

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    titolo,
                    style: testi.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Data di inizio, piccola e grigia, accanto alla matita.
                Text(
                  'dal ${_testoData(scheda.dataInizio)}',
                  style: testi.bodyMedium?.copyWith(
                    color: coloreTestoSecondario,
                  ),
                ),
                IconButton(
                  onPressed: onModifica,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Modifica programmazione',
                ),
              ],
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
