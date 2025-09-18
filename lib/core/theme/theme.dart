// lib/theme/theme.dart
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  fontFamily: 'Poppins',
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32),
    headlineMedium: TextStyle(fontSize: 24),
    titleLarge: TextStyle(fontSize: 20),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
    labelLarge: TextStyle(fontFamily: 'KiwiFruit', fontSize: 16),
  ),
);
