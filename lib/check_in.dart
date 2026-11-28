// ============================================================
// check_in.dart – il check-in giornaliero (solo dati, niente grafica)
//
// Ogni giorno ha al massimo un CheckIn. Lo storico NON si mostra
// all'utente: serve alle regole (scarico per indolenzimento,
// consiglio di oggi).
// ============================================================

class CheckIn {
  // Solo giorno/mese/anno (senza ore): così "oggi alle 8" e
  // "oggi alle 21" sono lo stesso giorno.
  final DateTime data;
  // Come ti senti: 1 (Distrutto) ... 5 (Al top).
  final int sensazione;
  // Muscoli indolenziti. Lista vuota = nessun dolore.
  // Lista e non Set: il JSON conosce le liste ma non i Set.
  final List<String> muscoliDoloranti;

  const CheckIn({
    required this.data,
    required this.sensazione,
    required this.muscoliDoloranti,
  });

  // Getter: "c'era indolenzimento quel giorno?"
  // isNotEmpty = la lista ha almeno un elemento.
  bool get haDolori => muscoliDoloranti.isNotEmpty;

  // --- SALVATAGGIO (JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'data': data.toIso8601String(),
      'sensazione': sensazione,
      'muscoliDoloranti': muscoliDoloranti,
    };
  }

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      data: DateTime.parse(json['data'] as String),
      sensazione: json['sensazione'] as int,
      // Ricostruiamo una lista di testi, uno per ogni elemento salvato.
      muscoliDoloranti: [
        for (final muscolo in json['muscoliDoloranti'] as List)
          muscolo as String,
      ],
    );
  }
}

// true se due date cadono nello stesso giorno (le ore non contano).
bool stessoGiorno(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
