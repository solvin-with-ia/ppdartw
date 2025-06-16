import 'package:flutter/material.dart';

/// Paleta principal:
/// Fondo Base 1: #330072 (centro gradiente)
/// Fondo Base 2: #1F0D3F (periferia gradiente)
/// Resaltado Neon: #8B00FF
/// Texto Claro: #FFFFFF
/// Emoji guía: #FFD700

final ThemeData planningPokerTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF330072),
  scaffoldBackgroundColor: const Color(0xFF1F0D3F),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF8B00FF),
    brightness: Brightness.dark,
    primary: const Color(0xFF330072),
    secondary: const Color(0xFF8B00FF),
    // background: const Color(0xFF1F0D3F), // Deprecated, use surface instead
    surface: const Color(0xFF1F0D3F),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    // onBackground: Colors.white, // Deprecated, replaced with onSurface
    onSurface: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
    labelLarge: TextStyle(color: Color(0xFF8B00FF)), // Neon highlight
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF330072),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF8B00FF), width: 2),
      ),
      shadowColor: const Color(0xFF8B00FF),
      elevation: 8,
    ),
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF1F0D3F),
    shadowColor: Color(0xFF8B00FF),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      side: BorderSide(color: Color(0xFF8B00FF), width: 2),
    ),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFFFD700)), // Emoji guía
);
