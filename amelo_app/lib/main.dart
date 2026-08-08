import 'package:flutter/material.dart';
import 'theme.dart';
import 'app_routes.dart';

void main() {
  runApp(AmeloApp());
}

class AmeloApp extends StatelessWidget {
  const AmeloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Amelo App',
          debugShowCheckedModeBanner: false,

          theme: AmeloTheme.lightTheme, // Modo Claro
          darkTheme: AmeloTheme.darkTheme, // Modo Escuro
          //Seletor de Tema
          themeMode: currentMode,
          initialRoute: AppRoutes.login,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
