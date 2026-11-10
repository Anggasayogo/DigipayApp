import 'package:flutter/material.dart';

class AppColors {
  // Primary Red Palette (Modern Red / Scarlet / Crimson)
  static const Color primary = Color(0xFFD32F2F); // Material Red 700
  static const Color primaryDark = Color(0xFFB71C1C); // Material Red 900
  static const Color primaryLight = Color(0xFFFFCDD2); // Material Red 100
  static const Color accent = Color(0xFFFF5252); // Red Accent
  static const Color primaryGradientStart = Color(0xFFE53935);
  static const Color primaryGradientEnd = Color(0xFFB71C1C);

  // Backgrounds & Neutrals
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  // Typography & Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textLight = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEEF2F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGradientStart, primaryGradientEnd],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC62828), Color(0xFF8E0000)],
  );
}
