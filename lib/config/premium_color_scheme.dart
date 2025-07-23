/*
 * 高级配色方案 (premium_color_scheme.dart)
 * 
 * 设计理念：
 * - 深色奢华风格，营造高级感
 * - 深红与深绿为主色调，金色点缀
 * - 低饱和度高级色彩，避免廉价感
 * - 参考奢侈品牌配色理念
 */

import 'package:flutter/material.dart';

class PremiumColors {
  PremiumColors._();

  // ===== 主色调 =====
  // 深酒红色 - 收入（如勃艮第酒红）
  static const Color deepWineRed = Color(0xFF722F37);     // 主红色
  static const Color wineRedLight = Color(0xFF8B3A3A);    // 浅一级
  static const Color wineRedDark = Color(0xFF4A1C1E);     // 深一级
  
  // 深森林绿 - 支出（深邃优雅）
  static const Color deepForestGreen = Color(0xFF1B4332); // 主绿色
  static const Color forestGreenLight = Color(0xFF2D6A4F); // 浅一级
  static const Color forestGreenDark = Color(0xFF081C15);  // 深一级
  
  // 金色系 - 成就/盈余（奢华感）
  static const Color luxuryGold = Color(0xFFD4AF37);      // 主金色
  static const Color champagneGold = Color(0xFFE6D5AA);   // 香槟金
  static const Color antiqueGold = Color(0xFF986515);     // 古董金
  
  // ===== 背景色系 =====
  static const Color premiumBlack = Color(0xFF0A0E0F);    // 高级黑
  static const Color darkCharcoal = Color(0xFF1A1D1E);    // 深炭灰
  static const Color charcoal = Color(0xFF2C3133);        // 炭灰
  static const Color darkGrey = Color(0xFF3E4447);        // 深灰
  
  // ===== 中性色 =====
  static const Color platinum = Color(0xFFE5E4E2);        // 铂金色（文字）
  static const Color silverGrey = Color(0xFFB8B8B8);      // 银灰色（次要文字）
  static const Color smokeGrey = Color(0xFF6B7280);       // 烟灰色（禁用）
  
  // ===== 功能色 =====
  static const Color errorRed = Color(0xFF991B1B);        // 错误红（深沉）
  static const Color warningAmber = Color(0xFF92400E);    // 警告琥珀
  static const Color infoNavy = Color(0xFF1E3A5F);        // 信息深蓝
  static const Color successEmerald = Color(0xFF065F46);  // 成功翡翠绿
  
  // ===== 渐变配色 =====
  static const List<Color> incomeGradient = [
    deepWineRed,
    wineRedLight,
  ];
  
  static const List<Color> expenseGradient = [
    deepForestGreen,
    forestGreenLight,
  ];
  
  static const List<Color> goldGradient = [
    luxuryGold,
    champagneGold,
    antiqueGold,
  ];
  
  static const List<Color> backgroundGradient = [
    premiumBlack,
    darkCharcoal,
  ];
  
  // ===== 卡片配色 =====
  static const Color cardBackground = darkCharcoal;
  static const Color cardBorder = Color(0xFF2A2F31);
  static const Color cardShadow = Color(0x66000000);
  
  // ===== 分类配色（优雅色调） =====
  static const List<Color> premiumCategoryColors = [
    Color(0xFF8B3A3A), // 酒红
    Color(0xFF2D6A4F), // 森林绿
    Color(0xFFD4AF37), // 金色
    Color(0xFF4B5563), // 石板灰
    Color(0xFF7C2D12), // 赤褐色
    Color(0xFF1F2937), // 深蓝灰
    Color(0xFF713F12), // 深琥珀
    Color(0xFF4C1D95), // 深紫
    Color(0xFF064E3B), // 深青绿
    Color(0xFF7F1D1D), // 深红褐
    Color(0xFF78350F), // 深棕
    Color(0xFF312E81), // 深靛蓝
  ];
  
  // ===== 特效配色 =====
  static const Color shimmerLight = Color(0x33D4AF37);    // 微光金
  static const Color glowEffect = Color(0x66D4AF37);      // 发光金
  static const Color dividerSubtle = Color(0xFF2A2F31);   // 精致分割线
}

// ===== Material Theme 配置 =====
class PremiumTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    
    // 主色配置
    primaryColor: PremiumColors.luxuryGold,
    scaffoldBackgroundColor: PremiumColors.premiumBlack,
    
    // 颜色方案
    colorScheme: const ColorScheme.dark(
      primary: PremiumColors.luxuryGold,
      secondary: PremiumColors.deepWineRed,
      tertiary: PremiumColors.deepForestGreen,
      surface: PremiumColors.darkCharcoal,
      background: PremiumColors.premiumBlack,
      error: PremiumColors.errorRed,
      onPrimary: PremiumColors.premiumBlack,
      onSecondary: PremiumColors.platinum,
      onSurface: PremiumColors.platinum,
      onBackground: PremiumColors.platinum,
      onError: PremiumColors.platinum,
    ),
    
    // 卡片主题
    cardTheme: CardThemeData(
      color: PremiumColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(
          color: PremiumColors.cardBorder,
          width: 1,
        ),
      ),
    ),
    
    // 文字主题
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: PremiumColors.platinum,
        fontWeight: FontWeight.w300,
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        color: PremiumColors.platinum,
        fontWeight: FontWeight.w300,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        color: PremiumColors.platinum,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodyLarge: TextStyle(
        color: PremiumColors.platinum,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        color: PremiumColors.silverGrey,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
    ),
    
    // AppBar主题
    appBarTheme: const AppBarTheme(
      backgroundColor: PremiumColors.darkCharcoal,
      foregroundColor: PremiumColors.platinum,
      elevation: 0,
      centerTitle: true,
    ),
    
    // 按钮主题
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: PremiumColors.luxuryGold,
        foregroundColor: PremiumColors.premiumBlack,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // 输入框主题
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PremiumColors.darkCharcoal,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PremiumColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PremiumColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PremiumColors.luxuryGold, width: 2),
      ),
      labelStyle: const TextStyle(color: PremiumColors.silverGrey),
      hintStyle: const TextStyle(color: PremiumColors.smokeGrey),
    ),
    
    // 分割线主题
    dividerTheme: const DividerThemeData(
      color: PremiumColors.dividerSubtle,
      thickness: 1,
    ),
  );
}