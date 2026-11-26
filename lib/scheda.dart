// Un esercizio della scheda: es. Squat, 4 × 8 con 60 kg.
class Esercizio {
  final String nome;
  final int serie;
  final int ripetizioni;
  final double carico; // in kg; 0 = corpo libero

  const Esercizio({
    required this.nome,
    required this.serie,
    required this.ripetizioni,
    this.carico = 0,
  });

  // Volume = kg totali sollevati: serie × ripetizioni × carico.
  // Servirà nella sezione Progressi per il carico settimanale.
  double volume() {
    return serie * ripetizioni * carico;
  }
}

// Un giorno della scheda: es. giorno "A" con i suoi esercizi.
// È il contenuto mostrato quando scegli A / B / C nella sezione Scheda.
class GiornoAllenamento {
  final String nome; // es. "A" oppure "Petto e tricipiti"
  final String tipo;
  final List<Esercizio> esercizi; // nell'ordine in cui si eseguono

  // Nessun valore predefinito: un giorno ha sempre un nome e una lista
  // di esercizi (al limite vuota: const [] mentre lo stai compilando).
  const GiornoAllenamento({
    required this.nome,
    required this.tipo,
    required this.esercizi,
  });
}

// La scheda completa: i giorni (A, B, C...) e la durata della programmazione.
class Scheda {
  final List<GiornoAllenamento> giorni;
  final DateTime dataInizio; // primo giorno della programmazione
  final int durataSettimane; // es. 8 → "Settimana X di 8"

  const Scheda({
    required this.giorni,
    required this.dataInizio,
    required this.durataSettimane,
  });

  // Settimana in cui siamo, contando da 1 (non da 0).
  // È un getter: si legge come un campo (scheda.settimanaCorrente),
  // ma il valore viene ricalcolato ogni volta, quindi è sempre aggiornato.
  int get settimanaCorrente {
    final now = DateTime.now();
    // Tempo trascorso dall'inizio (un oggetto Duration).
    final differenza = now.difference(dataInizio);
    // Solo i giorni interi passati: il primo giorno vale 0.
    final giorniPassati = differenza.inDays;
    // ~/ è la divisione intera: 0-6 giorni → 0, 7-13 → 1, ...
    final settimane = giorniPassati ~/ 7;
    // +1 perché per noi la prima settimana è la "settimana 1".
    return settimane + 1;
  }

  // REGOLA: la programmazione è finita quando abbiamo superato l'ultima
  // settimana (es. settimana 9 di una scheda da 8).
  // Servirà per proporre la settimana di scarico, caso (a) del CLAUDE.md.
  bool get programmazioneFinita {
    return settimanaCorrente > durataSettimane;
  }
}
