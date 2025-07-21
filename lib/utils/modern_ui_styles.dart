import 'package:flutter/material.dart';

/// Modern UI styles from new architecture
/// 新架构的现代UI样式配置
class ModernUIStyles {
  // Private constructor to prevent instantiation
  ModernUIStyles._();

  // ===== Colors =====
  static const Color cardBackgroundColor = Color(0xFF1A3D2E);
  static const Color accentColor = Color(0xFFDC143C);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color darkGreenBackground = Color(0xFF0D2818);
  
  // ===== Card Decoration =====
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackgroundColor.withOpacity(0.9),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: accentColor.withOpacity(0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ===== Elevated Card Decoration =====
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    color: cardBackgroundColor.withOpacity(0.95),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: accentColor.withOpacity(0.5),
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 6),
      ),
      BoxShadow(
        color: accentColor.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  // ===== Glass Effect Decoration =====
  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ===== Button Styles =====
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: accentColor,
    foregroundColor: Colors.white,
    elevation: 4,
    shadowColor: accentColor.withOpacity(0.4),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: cardBackgroundColor,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: accentColor.withOpacity(0.5),
        width: 1,
      ),
    ),
  );

  // ===== Text Styles =====
  static TextStyle get headingStyle => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle get subheadingStyle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white.withOpacity(0.9),
  );

  static TextStyle get bodyStyle => TextStyle(
    fontSize: 14,
    color: Colors.white.withOpacity(0.8),
  );

  static TextStyle get captionStyle => TextStyle(
    fontSize: 12,
    color: Colors.white.withOpacity(0.6),
  );

  // ===== Input Decoration =====
  static InputDecoration inputDecoration(String label, {IconData? icon}) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
    prefixIcon: icon != null ? Icon(icon, color: accentColor) : null,
    filled: true,
    fillColor: cardBackgroundColor.withOpacity(0.5),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: accentColor.withOpacity(0.3),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: Colors.white.withOpacity(0.2),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: accentColor,
        width: 2,
      ),
    ),
  );

  // ===== Animations =====
  static Duration get shortAnimationDuration => const Duration(milliseconds: 200);
  static Duration get mediumAnimationDuration => const Duration(milliseconds: 300);
  static Duration get longAnimationDuration => const Duration(milliseconds: 500);
  
  static Curve get defaultCurve => Curves.easeInOut;
  static Curve get bounceCurve => Curves.elasticOut;
  static Curve get smoothCurve => Curves.easeOutCubic;
}