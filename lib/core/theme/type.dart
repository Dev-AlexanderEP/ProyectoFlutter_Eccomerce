// lib/theme/type.dart
import 'package:flutter/material.dart';

class AppTypography {

  static TextStyle poppins({
    double size = 16,
  }) {
    return TextStyle(
      fontFamily: 'Poppins',
      fontSize: size,
      fontWeight: FontWeight.normal,
    );
  }
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle fancy = TextStyle(
    fontFamily: 'KiwiFruit',
    fontSize: 20,
    fontWeight: FontWeight.normal,
  );
}
