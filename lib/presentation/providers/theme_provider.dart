/*
 * 主题提供者 (theme_provider.dart)
 * 
 * 功能说明：
 * - 管理应用主题状态
 * - 支持深色/浅色模式切换
 * - 持久化主题设置
 */

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题提供者
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  bool _isDarkMode = true;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  /// 加载保存的主题设置
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? true;
    notifyListeners();
  }
  
  /// 切换主题
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    // 保存主题设置
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }
  
  /// 获取当前主题数据
  ThemeData get currentTheme {
    if (_isDarkMode) {
      return ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF1A3D2E),
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        cardColor: const Color(0xFF1A3D2E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1A3D2E),
          secondary: Color(0xFFDC143C),
        ),
      );
    } else {
      return ThemeData.light().copyWith(
        primaryColor: const Color(0xFF1A3D2E),
        scaffoldBackgroundColor: Colors.grey[50],
        cardColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A3D2E),
          secondary: Color(0xFFDC143C),
        ),
      );
    }
  }
}