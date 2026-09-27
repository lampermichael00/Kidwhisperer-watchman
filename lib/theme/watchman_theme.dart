import 'package:flutter/material.dart';

class WatchmanTheme {
  static const Color pine = Color(0xFF1B4332);
  static const Color moss = Color(0xFF2D6A4F);
  static const Color sage = Color(0xFF95D5B2);
  static const Color cream = Color(0xFFF8F4EC);
  static const Color alert = Color(0xFF9B2226);
  static const Color amber = Color(0xFFE9C46A);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: pine,
        brightness: Brightness.light,
        primary: pine,
        secondary: moss,
        error: alert,
        surface: cream,
      ),
      scaffoldBackgroundColor: cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: pine,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: sage,
        brightness: Brightness.dark,
        primary: sage,
        secondary: moss,
        error: alert,
      ),
    );
  }
}
