import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Primary Brand Colors ---
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color darkGreen = Color(0xFF009624);
  static const Color lightGreen = Color(0xFF5EFC82);
  static const Color accentGreen = Color(0xFF00E676);

  // --- Dark Theme Colors ---
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkCardLight = Color(0xFF2C2C2C);
  static const Color darkDivider = Color(0xFF333333);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB3B3B3);
  static const Color darkTextHint = Color(0xFF757575);

  // --- Light Theme Colors ---
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardLight = Color(0xFFF1F3F4);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF5F6368);
  static const Color lightTextHint = Color(0xFF9AA0A6);

  // --- Status Colors ---
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFFF1744);
  static const Color warning = Color(0xFFFFAB00);
  static const Color info = Color(0xFF2979FF);

  // --- Gradient Presets ---
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00C853),
      Color(0xFF00E676),
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E1E1E),
      Color(0xFF000000),
    ],
  );

  static const LinearGradient shimmerGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E1E1E),
      Color(0xFF2C2C2C),
      Color(0xFF1E1E1E),
    ],
  );

  static const LinearGradient shimmerGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE0E0E0),
      Color(0xFFF5F5F5),
      Color(0xFFE0E0E0),
    ],
  );

  // --- Avatar Gradient Presets ---
  static const List<LinearGradient> avatarGradients = [
    LinearGradient(
      colors: [Color(0xFF00C853), Color(0xFF00E676)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF2979FF), Color(0xFF00B0FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFAA00FF), Color(0xFFE040FB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFFF6D00), Color(0xFFFFAB00)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFFF1744), Color(0xFFFF5252)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];
}
