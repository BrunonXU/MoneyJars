/*
 * 应用常量配置 (app_constants.dart)
 * 
 * 功能说明：
 * - 统一管理应用的颜色、尺寸、文本等常量
 * - 提供设计规范和主题配置
 * - 集中管理动画参数和UI配置
 * 
 * 相关修改位置：
 * - 修改6：环状图视觉增强 - 颜色优化，色轮等距分布的12种鲜艳颜色 (第28-40行)
 */

import 'package:flutter/material.dart';

/// 应用设计常量
class AppConstants {
  // 私有构造函数，防止实例化
  AppConstants._();

  /// 颜色主题 - 圣诞节主题配色
  static const Color primaryColor = Color(0xFFDC143C);  // 圣诞红主色
  static const Color incomeColor = Color(0xFFDC143C);   // 圣诞红 - 收入罐头
  static const Color expenseColor = Color(0xFF228B22);  // 圣诞绿 - 支出罐头  
  static const Color comprehensivePositiveColor = Color(0xFF4CAF50);  // 中性绿色 - 综合盈余
  static const Color comprehensiveNegativeColor = Color(0xFFE57373);  // 柔和红色 - 综合亏损
  static const Color backgroundColor = Color(0xFFF5F5F5);  // 浅灰背景色，简化
  static const Color cardColor = Color(0xFF1A3D2E);       // 圣诞卡片色
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFBBBBBB);
  static const Color dividerColor = Color(0xFFE8E8E8);
  static const Color shadowColor = Color(0x1A000000);
  
  /// 圣诞主题阴影配色
  static const Color shadowLight = Color(0xFF2A5D3E);    // 亮阴影
  static const Color shadowDark = Color(0xFF051A0E);     // 暗阴影
  
  /// 神经形态渐变配置
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF9C88FF),
  ];
  
  static const List<Color> backgroundGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF5F5F5),
  ];
  
  static const List<Color> cardGradient = [
    Color(0xFFF0F0F3),
    Color(0xFFF0F0F3),
  ];

  /// 金币颜色
  static const List<Color> coinGradient = [
    Color(0xFFFFE082), // 浅金色
    Color(0xFFFFB300), // 深金色
    Color(0xFFFF8F00), // 边缘金色
  ];

  /// 分类颜色调色板 - 色轮上等距分布的鲜艳颜色
  static const List<Color> categoryColors = [
    Color(0xFFE74C3C), // 红色 (0°)
    Color(0xFFFF8C00), // 橙色 (30°)
    Color(0xFFF1C40F), // 黄色 (60°)
    Color(0xFF2ECC71), // 绿色 (120°)
    Color(0xFF1ABC9C), // 青绿色 (150°)
    Color(0xFF3498DB), // 蓝色 (210°)
    Color(0xFF9B59B6), // 紫色 (270°)
    Color(0xFFE91E63), // 粉红色 (330°)
    Color(0xFF795548), // 棕色
    Color(0xFF607D8B), // 蓝灰色
    Color(0xFFFF5722), // 深橙色
    Color(0xFF8BC34A), // 亮绿色
  ];

  /// 字体大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeXLarge = 24.0;
  static const double fontSizeXXLarge = 32.0;

  /// 间距
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  /// 圆角
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusCircular = 50.0;

  /// 神经形态阴影系统
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: shadowDark,
      offset: Offset(4, 4),
      blurRadius: 8,
    ),
    BoxShadow(
      color: shadowLight,
      offset: Offset(-4, -4),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: shadowDark,
      offset: Offset(6, 6),
      blurRadius: 12,
    ),
    BoxShadow(
      color: shadowLight,
      offset: Offset(-6, -6),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: shadowDark,
      offset: Offset(10, 10),
      blurRadius: 20,
    ),
    BoxShadow(
      color: shadowLight,
      offset: Offset(-10, -10),
      blurRadius: 20,
    ),
  ];
  
  /// 神经形态内阴影效果
  static const List<BoxShadow> shadowInset = [
    BoxShadow(
      color: shadowDark,
      offset: Offset(2, 2),
      blurRadius: 5,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: shadowLight,
      offset: Offset(-2, -2),
      blurRadius: 5,
      spreadRadius: -1,
    ),
  ];
  
  /// 特殊效果阴影  
  static const List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: Color(0x206C63FF),
      offset: Offset(0, 0),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
  
  static const List<BoxShadow> shadowPressed = [
    BoxShadow(
      color: shadowDark,
      offset: Offset(2, 2),
      blurRadius: 4,
    ),
    BoxShadow(
      color: shadowLight,
      offset: Offset(-1, -1),
      blurRadius: 2,
    ),
  ];

  /// 现代化动画配置
  static const Duration animationVeryFast = Duration(milliseconds: 100);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationVeryDeep = Duration(milliseconds: 800);
  
  /// 特殊动画时长
  static const Duration animationSpring = Duration(milliseconds: 600);
  static const Duration animationBounce = Duration(milliseconds: 1000);
  static const Duration animationMicro = Duration(milliseconds: 50);

  // ===== 罐头尺寸控制参数 =====
  // 这些参数控制罐头组件的基础尺寸，调整这些值可以改变罐头大小
  static const double jarWidth = 320.0;   // 罐头宽度 - 调整此值改变罐头宽度
  static const double jarHeight = 450.0;  // 罐头高度 - 调整此值改变罐头高度
  static const double jarProgressHeight = 12.0;  // 进度条高度 - 调整此值改变进度条厚度

  // ===== 拖拽和图表尺寸控制参数 =====
  // 这些参数控制拖拽记录和环状图的尺寸
  static const double dragRecordSize = 60.0;  // 拖拽记录大小 - 调整此值改变拖拽元素大小
  static const double pieChartSize = 350.0;   // 环状图大小 - 调整此值改变图表大小
  static const double pieChartRadius = 165.0; // 环状图半径 - 调整此值改变图表半径
  static const double pieChartCenterRadius = 70.0; // 中心圆半径 - 调整此值改变中心空洞大小
  static const double dragHoverDistance = 200.0; // 拖拽悬停距离
  static const double dragDropDistance = 100.0;  // 拖拽释放距离

  // ===== 应用栏和页面布局控制参数 =====
  // 这些参数控制应用栏和页面整体布局的尺寸
  static const double appBarHeight = 100.0; // 应用栏高度 - 调整此值改变顶部栏高度

  /// 页面指示器
  static const double pageIndicatorSize = 8.0;
  static const double pageIndicatorSpacing = 20.0;

  /// 输入相关
  static const double inputBorderRadius = 12.0;
  static const double inputPadding = 16.0;

  /// 图标尺寸
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  /// 文本样式
  static const TextStyle headingStyle = TextStyle(
    fontSize: fontSizeXXLarge,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: fontSizeXLarge,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: fontSizeSmall,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
  );

  /// 默认设置
  static const double defaultTargetAmount = 1000.0;
  static const String defaultJarTitle = '我的储蓄罐';
  static const int maxCoinCount = 60;
  static const int coinsPerLayer = 6;
  static const double coinSize = 8.0;
  static const double coinLayerSpacing = 15.0;

  /// 数据库
  static const String databaseName = 'money_jars.db';
  static const int databaseVersion = 2;
  static const Duration databaseTimeout = Duration(seconds: 10);

  /// 错误消息
  static const String errorInitialization = '应用初始化失败';
  static const String errorDatabaseConnection = '数据库连接失败';
  static const String errorTransactionSave = '保存交易记录失败';
  static const String errorCategorySave = '保存分类失败';
  static const String errorSettingsSave = '保存设置失败';
  static const String errorInvalidAmount = '请输入有效金额';
  static const String errorEmptyCategory = '请选择分类';

  /// 成功消息
  static const String successTransactionSaved = '交易记录已保存';
  static const String successCategorySaved = '分类已保存';
  static const String successSettingsSaved = '设置已保存';

  /// 提示文本
  static const String hintSwipeUp = '向上滑动记录收入';
  static const String hintSwipeDown = '向下滑动记录支出';
  static const String hintDragToCategory = '拖拽到分类中完成记录';
  static const String hintDragToCreateCategory = '拖拽到环外创建新分类';
  static const String hintTapForDetails = '点击查看详情';
  static const String hintNoData = '暂无数据';

  /// 按钮文本
  static const String buttonCancel = '取消';
  static const String buttonConfirm = '确认';
  static const String buttonSave = '保存';
  static const String buttonCreate = '创建';
  static const String buttonNext = '下一步';
  static const String buttonBack = '返回';
  static const String buttonRetry = '重试';
  static const String buttonSettings = '设置';

  /// 标签文本
  static const String labelIncome = '收入';
  static const String labelExpense = '支出';
  static const String labelComprehensive = '综合';
  static const String labelAmount = '金额';
  static const String labelDescription = '描述';
  static const String labelCategory = '分类';
  static const String labelTarget = '目标';
  static const String labelProgress = '进度';
  static const String labelTotal = '总计';
  static const String labelNetIncome = '净收入';
  static const String labelSurplus = '盈余';
  static const String labelDeficit = '亏损';

  /// 分类名称
  static const String categoryOther = '其他';
  static const String categoryDefault = '默认';

  /// 现代化动画曲线
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveElastic = Curves.elasticOut;
  static const Curve curveBounce = Curves.bounceOut;
  static const Curve curveSmooth = Curves.easeInOutCubic;
  static const Curve curveQuart = Curves.easeInOutQuart;
  static const Curve curveBack = Curves.easeInOutBack;
  static const Curve curveFastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve curveAnticipate = Curves.easeOutBack;
  static const Curve curveOvershoot = Curves.elasticOut;
} 