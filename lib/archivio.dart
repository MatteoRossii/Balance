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
import 'check_in.dart';

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

// ---- CHECK-IN ----
// Etichetta sotto cui salviamo l'elenco dei check-in (uno per giorno).
const _chiaveCheckIn = 'checkin';

// Legge l'elenco dei check-in. Lista vuota se non c'è niente
// (prima apertura) o se i dati salvati sono rovinati.
Future<List<CheckIn>> caricaCheckIn() async {
  final archivio = await SharedPreferences.getInstance();
  final testo = archivio.getString(_chiaveCheckIn);
  if (testo == null) {
    return []; // niente di salvato
  }
  try {
    // Dal testo a una lista di mappe...
    final listaMappe = jsonDecode(testo) as List;
    // ...e da ogni mappa a un CheckIn.
    return [
      for (final mappa in listaMappe)
        CheckIn.fromJson(mappa as Map<String, dynamic>),
    ];
  } catch (errore) {
    return []; // testo illeggibile: si riparte da un elenco vuoto
  }
}

// Salva tutto l'elenco: ogni CheckIn → mappa, poi la lista → testo JSON.
Future<void> salvaCheckIn(List<CheckIn> elenco) async {
  final archivio = await SharedPreferences.getInstance();
  final listaMappe = [for (final checkIn in elenco) checkIn.toJson()];
  await archivio.setString(_chiaveCheckIn, jsonEncode(listaMappe));
}
