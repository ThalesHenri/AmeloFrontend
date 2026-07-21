import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class AmeloTheme {
  // Cores basicas da Identidade Visual do App
  static const Color backgroundColor = Color(0xFF091322); // Azul Escuro
  static const Color surfaceCard = Color(0xFF132238); // Azul cards e inputs

  // 🛡️ CORES DE IDENTIDADE E TEXTO
  static const Color primaryNavy = Color(0xFF0B1E36); // Azul Marinho Amelo
  static const Color primaryGold = Color(0xFFEAB308); // Dourado/Amber
  static const Color textDark = Color(0xFF0F172A); // Texto para Modo Claro
  static const Color textLight = Color(0xFFFFFFFF); // Texto para Modo Escuro
  static const Color textSecondary = Color(0xFF64748B); // Subtítulos/Dicas

  //Cores do tema claro
  static const Color lightBackground = Color(0xFFF1F5F9); // Cinza Claro Suave
  static const Color lightSurface = Color(0xFFFFFFFF);

  //Status das Demandas
  static const Color statusAbertas = Color(0xFF3B82F6); // Azul
  static const Color statusUrgente = Color(0xFFEF4444); // Vermelho
  static const Color statusAndamento = Color(0xFFF59E0B); // Amarelo
  static const Color statusConcluido = Color(0xFF22C55E); // Verde

  // Tema Escuro do App
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryGold,
        onPrimary: textLight,
        surface: surfaceCard,
        background: backgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceCard,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        foregroundColor: textDark,
      ),
      cardTheme: const CardThemeData(
        color: surfaceCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        onPrimary: textLight,
        surface: lightSurface,
        onSurface: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy, // Mesma cor do scaffoldBackgroundColor
        elevation: 0,
        iconTheme: IconThemeData(color: textLight),
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: const CardThemeData(
        color: lightSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
