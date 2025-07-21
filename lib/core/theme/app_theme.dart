import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 应用主题配置
class AppTheme {
  static const Color primaryColor = Color(0xFFDC143C);
  static const Color backgroundColor = Color(0xFF0D2818);
  static const Color cardColor = Color(0xFF1A3D2E);
  static const Color accentColor = Color(0xFFFFD700);
  
  /// 亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      cardColor: cardColor,
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
      
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cardColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
  
  /// 暗色主题
  static ThemeData get darkTheme {
    return lightTheme; // 目前使用同一套主题
  }
}