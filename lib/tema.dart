// ============================================================
// tema.dart – colori e stile dell'app (da CLAUDE.md, "Grafica")
//
// Il file ha 2 parti:
//   1. Costanti dei colori   -> i codici esadecimali approvati
//   2. temaBalance           -> lo stile di card, pulsanti e barra
//
// DOVE OPERARE: per cambiare un colore modifica la costante qui sotto,
// e cambia in tutta l'app. Per cambiare lo stile di tutte le card
// o di tutti i pulsanti, modifica la voce corrispondente in temaBalance.
// ============================================================

import 'package:flutter/material.dart';

// --- 1. COLORI ------------------------------------------------
// In Flutter #0E7C66 si scrive Color(0xFF0E7C66): "0xFF" + il codice.
// (FF significa colore pieno, non trasparente.)
const coloreAccento = Color(0xFF0E7C66); // verde principale
const coloreAccentoScuro = Color(0xFF0A5E4D); // verde scuro
const coloreSfondo = Color(0xFFF6F7F5); // sfondo delle schermate
const coloreCard = Color(0xFFFFFFFF); // sfondo delle card
const coloreBordo = Color(0xFFE4E8E6); // bordo sottile delle card
const coloreTesto = Color(0xFF17201D); // testo principale
const coloreTestoSecondario = Color(0xFF5B6661); // testo meno importante
const coloreVerdeChiaro = Color(0xFFE3F2EE); // voce selezionata, evidenziazioni
// Promemoria esami: non sono nel tema, si usano direttamente nel widget.
const colorePromemoriaSfondo = Color(0xFFFDF3E1);
const colorePromemoriaTesto = Color(0xFF8A5300);

// --- 2. TEMA --------------------------------------------------
// Passato a MaterialApp in main.dart (theme: temaBalance).
// Ogni Card, FilledButton e NavigationBar dell'app prende lo stile da qui,
// quindi non va ripetuto widget per widget.
final ThemeData temaBalance = ThemeData(
  useMaterial3: true,

  // Palette. Imposto i colori uno per uno invece di usare fromSeed,
  // che li genera da un colore e li altera un po': qui servono quelli esatti.
  // Nomi: primary = verde principale, onPrimary = testo sopra il verde,
  // surface = card, onSurface = testo, outline = bordi.
  colorScheme: const ColorScheme.light(
    primary: coloreAccento,
    onPrimary: Colors.white,
    primaryContainer: coloreVerdeChiaro,
    onPrimaryContainer: coloreAccentoScuro,
    surface: coloreCard,
    onSurface: coloreTesto,
    onSurfaceVariant: coloreTestoSecondario,
    outline: coloreBordo,
  ),

  // Sfondo di tutte le schermate.
  scaffoldBackgroundColor: coloreSfondo,

  // Card: angoli arrotondati a 20, bordo sottile, niente ombra.
  // margin zero: la distanza tra le card la decidiamo noi (16) nelle schermate.
  cardTheme: CardThemeData(
    color: coloreCard,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: coloreBordo),
    ),
  ),

  // Pulsanti pieni (FilledButton): larghi quanto il contenitore,
  // alti almeno 48, angoli 14.
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),

  // Barra in basso: sfondo bianco, voce selezionata evidenziata in verde chiaro.
  // surfaceTintColor trasparente evita una sfumatura colorata di Material 3.
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: coloreCard,
    indicatorColor: coloreVerdeChiaro,
    surfaceTintColor: Colors.transparent,
  ),
);
