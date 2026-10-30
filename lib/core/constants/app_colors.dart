import 'package:flutter/material.dart';

class AppColors {
  // FinPulse Primary Lime Green Brand Palette
  static const Color primary = Color(0xFF8CE827); // FinPulse Lime Green
  static const Color primaryDark = Color(0xFF75C71D);
  static const Color primaryLight = Color(0xFFA6F74D);
  static const Color secondary = Color(0xFF06B6D4);
  static const Color accent = Color(0xFF8CE827);

  // FinPulse Dark Theme (Official Figma Spec)
  static const Color darkBg = Color(0xFF0C0F14); // Deepest slate/black
  static const Color darkSurface = Color(0xFF161922); // Card surface
  static const Color darkCard = Color(0xFF161922);
  static const Color darkInput = Color(0xFF1B1E26); // Input fields
  static const Color darkInputFilled = Color(0xFF1B1E26);
  static const Color darkBorder = Color(0xFF262B36); // Subtle borders
  static const Color darkButton = Color(0xFF1C1F26); // Top icons & social buttons

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E95A3); // Muted grey
  static const Color textMuted = Color(0xFF646B79);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E95A3);

  // Light Theme fallbacks
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Status & Feedback Colors
  static const Color success = Color(0xFF8CE827);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Button text
  static const Color onPrimary = Color(0xFF0C0F14);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8CE827), Color(0xFF66B513)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
