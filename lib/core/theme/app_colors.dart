import 'package:flutter/material.dart';

/// ────────────────────────────────────────────────────────────────
/// AppColors — Structured Rebellion Design System
///
/// High-contrast, pitch-black backgrounds with neon accent colors.
/// Inspired by Swiss-style minimalist design with bold, heavy
/// typography and sharp visual hierarchy.
/// ────────────────────────────────────────────────────────────────
abstract class AppColors {
  // ── Backgrounds ─────────────────────────────────────────────
  /// Primary solid pitch-black background
  static const Color background = Color(0xFF000000);

  /// Slightly elevated surface (cards, panels)
  static const Color surface = Color(0xFF0D0D0D);

  /// Elevated surface (dialogs, modals)
  static const Color surfaceElevated = Color(0xFF1A1A1A);

  /// Subtle divider / border
  static const Color border = Color(0xFF2A2A2A);

  // ── Neon Accents ────────────────────────────────────────────
  /// Primary neon orange — main accent for highlights, CTAs
  static const Color neonOrange = Color(0xFFFF6B00);

  /// Neon orange with reduced opacity for subtle highlights
  static const Color neonOrangeDim = Color(0x80FF6B00);

  /// Secondary neon green — for success states, alive indicators
  static const Color neonGreen = Color(0xFF00FF88);

  /// Neon green with reduced opacity
  static const Color neonGreenDim = Color(0x8000FF88);

  /// Danger / elimination color
  static const Color neonRed = Color(0xFFFF2244);

  /// Warning color for suspect states
  static const Color neonYellow = Color(0xFFFFD600);

  /// Ghost / eliminated state color — muted cyan
  static const Color ghostCyan = Color(0xFF00BCD4);

  /// Mafioso reveal color — deep crimson
  static const Color mafiosoRed = Color(0xFFB71C1C);

  // ── Text ────────────────────────────────────────────────────
  /// Primary text — pure white
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text — medium gray
  static const Color textSecondary = Color(0xFFB0B0B0);

  /// Disabled / hint text
  static const Color textDisabled = Color(0xFF666666);

  /// Inverted text (for accent backgrounds)
  static const Color textOnAccent = Color(0xFF000000);
}
