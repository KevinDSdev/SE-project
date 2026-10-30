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

  // Light Theme Surfaces (Light Theme Only)
  static const Color lightBg = Color(0xFFF8FAFC); // Main light background
  static const Color lightSurface = Color(0xFFFFFFFF); // Clean white card surface
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSubContainer = Color(0xFFF1F5F9); // Inner container / pill container
  static const Color lightBorder = Color(0xFFE2E8F0); // Subtle slate borders
  static const Color lightTextPrimary = Color(0xFF0F172A); // High-contrast dark text
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate muted text
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Backward compatibility tokens mapped to Light Theme
  static const Color darkBg = lightBg;
  static const Color darkSurface = lightSurface;
  static const Color darkCard = lightCard;
  static const Color darkInput = lightSubContainer;
  static const Color darkInputFilled = lightSubContainer;
  static const Color darkBorder = lightBorder;
  static const Color darkButton = lightSubContainer;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextMuted;
  static const Color darkTextPrimary = lightTextPrimary;
  static const Color darkTextSecondary = lightTextSecondary;

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
