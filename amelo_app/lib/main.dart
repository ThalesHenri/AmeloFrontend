import 'package:flutter/material.dart';
import 'theme.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/detalhes_demandas_screen.dart';
import 'ui/screens/login_screen.dart';

void main() {
  runApp(AmeloApp());
}

class AmeloApp extends StatelessWidget {
  const AmeloApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 👁️ O MaterialApp inteiro agora observa o themeNotifier!
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Amelo App',
          debugShowCheckedModeBanner: false,

          // Os dois grimórios de cores:
          theme: AmeloTheme.lightTheme, // Modo Claro
          darkTheme: AmeloTheme.darkTheme, // Modo Escuro
          // A runa que faz a troca acontecer:
          themeMode: currentMode,

          home: const DetalhesDemandaScreen(),
        );
      },
    );
  }
}
