import 'package:flutter/material.dart';

class AppColors {
  // FinPulse / ECORP Design Palette
  static const Color primary = Color(0xFF98E836); // Default 98E836 Lime Green
  static const Color primaryDark = Color(0xFF82CA2B);
  static const Color primaryLight = Color(0xFFAEF05A);
  static const Color secondary = Color(0xFF38BDF8); // 38BDF8 Sky Blue
  static const Color accent = Color(0xFF98E836);
  static const Color expense = Color(0xFFF43F5E); // F43F5E Rose / Red
  static const Color savings = Color(0xFF38BDF8); // 38BDF8 Sky Blue
  static const Color purple = Color(0xFF9353D3); // 9353D3 Purple
  static const Color amber = Color(0xFFF59E0B); // F59E0B Amber

  // Dark Theme Surfaces (Default Authoritative Design)
  static const Color darkBg = Color(0xFF0C0F14); // Main dark background
  static const Color darkSurface = Color(0xFF161922); // Card surface
  static const Color darkCard = Color(0xFF161922);
  static const Color darkSubContainer = Color(0xFF10141D); // Inner container / pill container
  static const Color darkBorder = Color(0xFF262B36); // Dark borders
  static const Color darkInput = Color(0xFF10141D);
  static const Color darkInputFilled = Color(0xFF10141D);
  static const Color darkButton = Color(0xFF1E2638);
  static const Color darkTextPrimary = Colors.white; // High-contrast white text
  static const Color darkTextSecondary = Color(0xFF8E95A3); // Muted grey text
  static const Color darkTextMuted = Color(0xFF646B79);

  // Light Theme Surfaces (Optional Theme)
  static const Color lightBg = Color(0xFFF8FAFC); // Main light background
  static const Color lightSurface = Color(0xFFFFFFFF); // Clean white card surface
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSubContainer = Color(0xFFF1F5F9); // Inner container / pill container
  static const Color lightBorder = Color(0xFFE2E8F0); // Subtle slate borders
  static const Color lightTextPrimary = Color(0xFF0F172A); // High-contrast dark text
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate muted text
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Common Tokens (Defaulting to Dark Theme)
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textMuted = darkTextMuted;

  // Dynamic Theme Helpers
  static Color getBg(bool isDark) => isDark ? darkBg : lightBg;
  static Color getCard(bool isDark) => isDark ? darkCard : lightCard;
  static Color getBorder(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color getSubContainer(bool isDark) => isDark ? darkSubContainer : lightSubContainer;
  static Color getTextPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;

  // Status & Feedback Colors
  static const Color success = Color(0xFF98E836);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFF43F5E);
  static const Color info = Color(0xFF38BDF8);

  // Button text
  static const Color onPrimary = Color(0xFF0C0F14);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF98E836), Color(0xFF7CB82B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
