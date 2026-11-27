// ============================================================
// archivio.dart – salvataggio della scheda sul dispositivo
//
// La scheda viene trasformata in un testo JSON e salvata con
// shared_preferences (sul web: il localStorage del browser),
// sotto l'etichetta 'scheda'. All'avvio si rilegge da qui.
// Niente grafica in questo file: solo dati.
// ============================================================

import 'dart:convert'; // jsonEncode / jsonDecode: mappa ⇄ testo JSON

import 'package:shared_preferences/shared_preferences.dart';

import 'scheda.dart';

// L'etichetta sotto cui salviamo la scheda nell'"armadietto".
const _chiaveScheda = 'scheda';

// Scheda di partenza per chi apre l'app la prima volta:
// un solo giorno, vuoto, da rinominare e riempire.
Scheda schedaVuota() {
  final adesso = DateTime.now();
  return Scheda(
    // Solo giorno/mese/anno di oggi (senza ore e minuti).
    dataInizio: DateTime(adesso.year, adesso.month, adesso.day),
    durataSettimane: 8,
    giorni: [
      GiornoAllenamento(nome: 'Giorno A', tipo: 'Allenamento', esercizi: []),
    ],
  );
}

// Legge la scheda salvata. Restituisce null se non c'è niente
// (prima apertura) o se i dati salvati sono rovinati.
// Future<...> + async: la lettura richiede un attimo, va "aspettata".
Future<Scheda?> caricaScheda() async {
  final archivio = await SharedPreferences.getInstance();
  final testo = archivio.getString(_chiaveScheda);
  if (testo == null) {
    return null; // niente di salvato
  }
  // try / catch: "prova a fare questo; se qualcosa va storto,
  // invece di bloccare l'app esegui il blocco catch".
  try {
    final mappa = jsonDecode(testo) as Map<String, dynamic>;
    return Scheda.fromJson(mappa);
  } catch (errore) {
    return null; // testo illeggibile: si riparte da una scheda vuota
  }
}

// Salva la scheda: la trasforma in testo JSON e la scrive nell'archivio.
Future<void> salvaScheda(Scheda scheda) async {
  final archivio = await SharedPreferences.getInstance();
  await archivio.setString(_chiaveScheda, jsonEncode(scheda.toJson()));
}
