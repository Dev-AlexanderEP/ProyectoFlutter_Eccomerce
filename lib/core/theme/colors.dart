// lib/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Paleta roja (Tailwind-style)
  static const red50 = Color(0xFFFef2f2);
  static const red100 = Color(0xFFFee2e2);
  static const red200 = Color(0xFFFecaca);
  static const red300 = Color(0xFFfca5a5);
  static const red400 = Color(0xFFf87171);
  static const red500 = Color(0xFFef4444); // 👈 rojo principal
  static const red600 = Color(0xFFdc2626);
  static const red700 = Color(0xFFb91c1c);
  static const red800 = Color(0xFF991b1b);
  static const red900 = Color(0xFF7f1d1d);
  static const red950 = Color(0xFF450a0a);

  // Otros colores si quieres
  static const neutral = Color(0xFFf5f5f5);
  static const dark = Color(0xFF111827);
}

class AppThemeColors {
  static const primary = AppColors.red500;
  static const primaryLight = AppColors.red100;
  static const primaryDark = AppColors.red700;

  static const secondary = Color(0xFF3b82f6); // azul ejemplo
  static const secondaryLight = Color(0xFFdbeafe);
  static const secondaryDark = Color(0xFF1e40af);

  static const background = Colors.white;
  static const surface = AppColors.neutral;
  static const error = AppColors.red600;
}
