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

  // --- SALVATAGGIO (JSON) ---
  // Trasforma l'esercizio in una "mappa" (etichetta → valore):
  // il formato che si può scrivere come testo JSON e salvare.
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'serie': serie,
      'ripetizioni': ripetizioni,
      'carico': carico,
    };
  }

  // Il viaggio inverso: ricostruisce un esercizio da una mappa letta dal JSON.
  // `factory` = un costruttore che prepara i valori e poi crea l'oggetto.
  // `as String`, `as int`: diciamo a Dart di che tipo è ogni valore.
  factory Esercizio.fromJson(Map<String, dynamic> json) {
    return Esercizio(
      nome: json['nome'] as String,
      serie: json['serie'] as int,
      ripetizioni: json['ripetizioni'] as int,
      // Nel JSON 60.0 diventa 60: `num` accetta sia interi sia decimali,
      // toDouble() lo riporta a double.
      carico: (json['carico'] as num).toDouble(),
    );
  }
}

// Un giorno della scheda: es. giorno "A" con i suoi esercizi.
// È il contenuto mostrato quando scegli A / B / C nella sezione Scheda.
class GiornoAllenamento {
  final String nome; // es. "A" oppure "Petto e tricipiti"
  final String tipo;
  final List<Esercizio> esercizi; // nell'ordine in cui si eseguono

  // Nessun valore predefinito: un giorno ha sempre un nome e una lista
  // di esercizi (al limite vuota, ma MODIFICABILE: [] e non const []).
  const GiornoAllenamento({
    required this.nome,
    required this.tipo,
    required this.esercizi,
  });

  // --- SALVATAGGIO (JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'tipo': tipo,
      // Ogni esercizio si trasforma da solo ("collection for").
      'esercizi': [for (final esercizio in esercizi) esercizio.toJson()],
    };
  }

  factory GiornoAllenamento.fromJson(Map<String, dynamic> json) {
    return GiornoAllenamento(
      nome: json['nome'] as String,
      tipo: json['tipo'] as String,
      // Lista nuova (quindi modificabile) con un Esercizio per ogni mappa.
      esercizi: [
        for (final mappa in json['esercizi'] as List)
          Esercizio.fromJson(mappa as Map<String, dynamic>),
      ],
    );
  }
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

  // --- SALVATAGGIO (JSON) ---
  Map<String, dynamic> toJson() {
    return {
      // Una data non è testo: la scriviamo nel formato standard
      // "2026-11-03T00:00:00.000", che poi DateTime.parse sa rileggere.
      'dataInizio': dataInizio.toIso8601String(),
      'durataSettimane': durataSettimane,
      'giorni': [for (final giorno in giorni) giorno.toJson()],
    };
  }

  factory Scheda.fromJson(Map<String, dynamic> json) {
    return Scheda(
      dataInizio: DateTime.parse(json['dataInizio'] as String),
      durataSettimane: json['durataSettimane'] as int,
      giorni: [
        for (final mappa in json['giorni'] as List)
          GiornoAllenamento.fromJson(mappa as Map<String, dynamic>),
      ],
    );
  }
}
