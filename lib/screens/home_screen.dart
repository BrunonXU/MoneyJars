/*
 * MoneyJars 主屏幕界面 (home_screen.dart)
 * 
 * 页面结构：
 * ┌─────────────────────────────────────────────┐
 * │  📱 顶部导航栏 (AppBar)                      │
 * │  [设置] MoneyJars图标+标题 [占位]             │
 * ├─────────────────────────────────────────────┤
 * │  🎨 主内容区域 (背景图片 + 罐头组件)              │
 * │  🧭 左侧导航栏    📄 垂直PageView    🎯 右侧指示器  │
 * │  [设置]         ┌─────────────┐      [支出]    │
 * │  [帮助]         │ 🍯 支出罐头    │      [综合]    │
 * │  [统计]         │   (index:0)  │      [收入]    │
 * │  [个性化]        └─────────────┘               │
 * │                ┌─────────────┐               │
 * │                │ 🍯 综合罐头    │               │
 * │                │  (index:1)   │               │ 
 * │                │   默认页面     │               │
 * │                └─────────────┘               │
 * │                ┌─────────────┐               │
 * │                │ 🍯 收入罐头    │               │
 * │                │  (index:2)   │               │
 * │                └─────────────┘               │
 * │                                              │
 * │         💫 滑动提示区域 (支出/收入页面)            │
 * │         [⬇ 向下滑记录支出] [⬆ 向上滑记录收入]       │
 * └─────────────────────────────────────────────┘
 * 
 * 核心功能：
 * - 三罐头系统：支出罐头(绿色背景) + 综合罐头(小猪背景) + 收入罐头(红色背景)
 * - 垂直滑动切换：BouncingScrollPhysics + allowImplicitScrolling 实现连续丝滑体验
 * - 动态背景：根据当前页面显示对应背景图片，支持透明度渐变过渡
 * - 手势识别：支出页面向下滑/收入页面向上滑 触发对应的交易输入模式
 * - 响应式布局：移动端全屏显示，平板/桌面端居中显示并适配不同屏幕尺寸
 * - 左侧功能导航：设置/帮助/统计/个性化 四个功能页面入口，带平滑左滑动画
 * - 右侧页面指示器：实时显示当前页面位置，支持文字标签和圆点指示
 * 
 * 关键尺寸定义：
 * - 2.w = 导航栏距离屏幕边缘的小白边 (2逻辑像素)
 * - 48.w = 导航栏宽度 (比原来42w大15%)
 * - 145.h = 罐头组件向下偏移量 (与背景罐头底部平齐)
 * - 22.h = 导航栏垂直内边距 (比原来16h长20%)
 * - 18.h = 导航栏按钮间距 (比原来15h长20%)
 * - 150.w = 滑动提示框宽度 (比原来小70%)
 * - 0.35 = 导航栏垂直位置 (屏幕高度的35%处，相对背景图片居中)
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_record_hive.dart';
import '../widgets/money_jar_widget.dart';
import '../widgets/enhanced_transaction_input.dart';
import '../widgets/jar_settings_dialog.dart';
import '../widgets/gesture_handler.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/error_widget.dart';
import '../screens/jar_detail_page.dart';
import '../screens/settings_page.dart';
import '../screens/help_page.dart';
import '../screens/statistics_page.dart';
import '../screens/personalization_page.dart';
import '../constants/app_constants.dart';
import '../utils/responsive_layout.dart';
import '../screens/home_screen_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ===== 📄 页面控制器 =====
  late PageController _pageController;         // PageView滚动控制器：管理三个罐头页面的垂直滑动切换
  
  // ===== 🎭 动画控制器系统 =====
  late AnimationController _fadeController;    // 页面淡入动画控制器：控制整个页面的淡入效果
  late AnimationController _swipeHintController; // 滑动提示动画控制器：控制提示框的呼吸动画(1秒周期，反向重复)
  late Animation<double> _fadeAnimation;       // 淡入动画：0.0→1.0 渐变，使用curveDefault曲线
  late Animation<double> _swipeHintAnimation;  // 提示动画：0.5→1.0 循环变化，用于呼吸效果
  
  // ===== 📱 页面状态管理 =====
  int _currentPage = 1;                        // 当前页面索引：0=支出罐头, 1=综合罐头(默认), 2=收入罐头
  bool _isInputMode = false;                   // 输入模式状态：true时显示EnhancedTransactionInput覆盖层
  TransactionType? _inputType;                 // 当前输入类型：TransactionType.income 或 TransactionType.expense
  bool _isLoading = false;                     // 加载状态：控制LoadingWidget的显示
  String? _errorMessage;                       // 错误信息：不为null时显示AppErrorWidget
  
  // ===== 🤏 手势识别系统 =====
  late GestureHandler _gestureHandler;        // 独立手势处理器：处理上下滑动手势，触发交易输入模式

  @override
  void initState() {
    super.initState();
    _gestureHandler = GestureHandler();        // 初始化手势处理器：用于检测上下滑动手势
    _initializeControllers();                  // 初始化所有控制器：页面控制器和动画控制器
    _startAnimations();                        // 启动动画：淡入动画和提示呼吸动画
  }

  /// 🎛️ 初始化控制器系统
  /// 设置PageController和AnimationController，配置动画参数
  void _initializeControllers() {
    // 📄 PageView控制器：初始页面设为综合罐头(index: 1)
    _pageController = PageController(initialPage: _currentPage);
    
    // 🎭 页面淡入动画控制器：使用中等持续时间(约300ms)
    _fadeController = AnimationController(
      duration: AppConstants.animationMedium,   // 动画持续时间：中等速度
      vsync: this,                             // 同步信号：防止不可见时继续动画
    );
    
    // 💫 滑动提示呼吸动画控制器：1秒周期的循环动画
    _swipeHintController = AnimationController(
      duration: const Duration(seconds: 1),    // 动画周期：1秒完整循环
      vsync: this,                             // 同步信号：优化性能
    );
    
    // 🎨 淡入动画：从完全透明(0.0)到完全不透明(1.0)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: AppConstants.curveDefault), // 使用默认缓动曲线
    );
    
    // 💡 提示呼吸动画：从半透明(0.5)到不透明(1.0)循环变化
    _swipeHintAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _swipeHintController, curve: AppConstants.curveDefault), // 平滑的呼吸效果
    );
  }

  /// 🚀 启动动画系统
  /// 开始页面淡入动画和滑动提示的持续呼吸动画
  void _startAnimations() {
    _fadeController.forward();                 // 启动淡入动画：页面从透明到不透明
    _swipeHintController.repeat(reverse: true); // 启动呼吸动画：反向重复(0.5↔1.0循环)
  }

  @override
  void dispose() {
    _pageController.dispose();                 // 释放PageView控制器：防止内存泄漏
    _fadeController.dispose();                 // 释放淡入动画控制器
    _swipeHintController.dispose();            // 释放提示动画控制器
    super.dispose();
  }

  /// 📄 页面切换回调
  /// 当PageView滚动到新页面时触发，更新当前页面状态并退出输入模式
  void _onPageChanged(int page) {
    if (_currentPage != page) {
      setState(() {
        _currentPage = page;                   // 更新当前页面索引：0=支出, 1=综合, 2=收入
        _isInputMode = false;                  // 退出输入模式：隐藏EnhancedTransactionInput覆盖层
        _inputType = null;                     // 清除输入类型：重置交易类型状态
      });
      HapticFeedback.selectionClick();        // 触觉反馈：提供页面切换的物理反馈感
    }
  }

  // ===== 🤏 手势识别回调系统 =====
  
  /// 💰 支出手势回调
  /// 在支出页面向下滑动时触发，进入支出记录模式
  void _onExpenseSwipe() {
    _enterInputMode(TransactionType.expense); // 进入支出输入模式
    GestureHandler.provideLightFeedback();    // 轻微触觉反馈：确认手势识别成功
  }

  /// 💰 收入手势回调  
  /// 在收入页面向上滑动时触发，进入收入记录模式
  void _onIncomeSwipe() {
    _enterInputMode(TransactionType.income);  // 进入收入输入模式
    GestureHandler.provideLightFeedback();    // 轻微触觉反馈：确认手势识别成功
  }

  /// 🎯 进入交易输入模式
  /// 显示EnhancedTransactionInput覆盖层，开始交易记录流程
  void _enterInputMode(TransactionType type) {
    HapticFeedback.lightImpact();             // 轻微震动反馈：模式切换确认
    setState(() {
      _isInputMode = true;                    // 启用输入模式：显示输入界面覆盖层
      _inputType = type;                      // 设置交易类型：支出或收入
    });
  }

  /// ❌ 退出交易输入模式  
  /// 隐藏输入界面，返回正常浏览模式
  void _exitInputMode() {
    setState(() {
      _isInputMode = false;                   // 禁用输入模式：隐藏输入界面覆盖层
      _inputType = null;                      // 清除交易类型：重置状态
    });
  }

  /// ⚙️ 显示设置对话框
  /// 弹出JarSettingsDialog，允许用户配置罐头设置
  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => const JarSettingsDialog(), // 罐头设置对话框组件
    );
  }

  /// 📊 显示罐头详情页面
  /// 点击罐头组件时触发，导航到JarDetailPage查看详细统计和交易记录
  void _showDetailPage(TransactionType type, TransactionProvider provider, bool isComprehensive) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => JarDetailPage(
          type: type,                         // 交易类型：收入、支出或综合
          provider: provider,                 // 数据提供者：TransactionProvider实例
          isComprehensive: isComprehensive,   // 是否为综合统计：true=综合罐头, false=单类型罐头
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero) // 从右侧滑入：(1.0,0.0)→(0,0)
                  .chain(CurveTween(curve: AppConstants.curveSmooth)), // 使用平滑曲线
            ),
            child: child,
          );
        },
        transitionDuration: AppConstants.animationMedium, // 中等动画时长：约300ms
      ),
    );
  }

  // ===== 🧭 左侧导航栏功能页面导航方法 =====
  
  /// ⚙️ 导航到设置页面
  /// 左侧导航栏第1个按钮(Icons.settings)的点击回调
  void _navigateToSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero) // 从左侧滑入：(-1.0,0.0)→(0,0)
                  .chain(CurveTween(curve: AppConstants.curveSmooth)),  // 平滑滑动曲线
            ),
            child: child,
          );
        },
        transitionDuration: AppConstants.animationMedium, // 中等动画时长
      ),
    );
  }

  /// ❓ 导航到使用指南页面
  /// 左侧导航栏第2个按钮(Icons.help_outline)的点击回调
  void _navigateToHelp() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HelpPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero) // 从左侧滑入动画
                  .chain(CurveTween(curve: AppConstants.curveSmooth)),
            ),
            child: child,
          );
        },
        transitionDuration: AppConstants.animationMedium,
      ),
    );
  }

  /// 📈 导航到统计分析页面
  /// 左侧导航栏第3个按钮(Icons.bar_chart)的点击回调
  void _navigateToStatistics() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const StatisticsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero) // 从左侧滑入动画
                  .chain(CurveTween(curve: AppConstants.curveSmooth)),
            ),
            child: child,
          );
        },
        transitionDuration: AppConstants.animationMedium,
      ),
    );
  }

  /// 🎨 导航到个性化设置页面
  /// 左侧导航栏第4个按钮(Icons.more_horiz)的点击回调
  void _navigateToPersonalization() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PersonalizationPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero) // 从左侧滑入动画
                  .chain(CurveTween(curve: AppConstants.curveSmooth)),
            ),
            child: child,
          );
        },
        transitionDuration: AppConstants.animationMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],   // 外部背景色：浅灰色(#F5F5F5)，在平板/桌面端可见
      body: ResponsiveLayout.responsive(  // 响应式布局系统：根据屏幕宽度自动选择布局
        mobile: _buildMobileLayout(),     // 移动端布局：<600px，全屏垂直滑动体验
        tablet: _buildTabletLayout(),     // 平板端布局：600-1200px，居中显示带边框
        desktop: _buildDesktopLayout(),   // 桌面端布局：>1200px，更大居中容器
      ),
    );
  }

  // ===== 📱 移动端布局系统 =====
  
  /// 📱 移动端主布局容器 (<600px屏幕)
  /// 全屏显示，无边框，垂直滑动的三罐头体验
  Widget _buildMobileLayout() {
    final layout = ResponsiveLayout.getMainContainerLayout(context); // 获取响应式布局参数
    
    return Container(
      width: layout['width'],                    // 容器宽度：移动端为screenWidth(全屏宽度)
      height: layout['height'],                  // 容器高度：移动端为screenHeight(全屏高度)
      margin: layout['margin'] ?? EdgeInsets.zero, // 外边距：移动端为zero(无边距)
      decoration: BoxDecoration(
        border: layout['showBorder'] ? Border.all( // 边框：移动端showBorder=false(无边框)
          color: Colors.grey.withOpacity(0.3),    // 边框颜色：30%透明灰色
          width: 1.w,                             // 边框宽度：1逻辑像素
        ) : null,
        borderRadius: BorderRadius.circular(layout['borderRadius']), // 圆角：移动端为0.0(无圆角)
        boxShadow: layout['showBorder'] ? [      // 阴影：移动端无阴影
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // 阴影颜色：10%透明黑色
            blurRadius: 20.r,                     // 模糊半径：20逻辑像素
            offset: Offset(0, 10.h),              // 阴影偏移：向下10逻辑像素
          ),
        ] : null,
        color: Colors.white,                     // 容器背景：白色
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(layout['borderRadius']), // 裁剪圆角：与容器保持一致
        child: Column(
          children: [
            _buildAppBar(),                      // 📱 顶部导航栏：设置按钮 + MoneyJars标题
            Expanded(
              child: ClipRect(                   // 🎨 裁剪背景：确保背景不会溢出到AppBar区域
                child: Stack(                    // 🎨 主内容区域：背景层 + 内容层的层叠结构
                  children: [
                    _buildBackground(),          // 🎨 背景图片层：动态三张背景图，支持透明度过渡
                    _buildMobileContent(),       // 📄 移动端内容层：PageView + 导航栏 + 提示区域
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 📟 平板端主布局容器 (600-1200px屏幕)
  /// 居中显示，带边框和阴影，水平排列罐头
  Widget _buildTabletLayout() {
    final layout = ResponsiveLayout.getMainContainerLayout(context); // 获取平板端布局参数
    
    return Center(                                   // 居中对齐：平板端在屏幕中央显示
      child: Container(
        width: layout['width'],                      // 容器宽度：平板端约为screenWidth*0.8(80%屏宽)
        height: layout['height'],                    // 容器高度：平板端约为screenHeight*0.9(90%屏高)
        margin: layout['margin'] ?? EdgeInsets.zero, // 外边距：平板端有适当边距
        padding: layout['padding'] ?? EdgeInsets.zero, // 内边距：布局参数控制
        decoration: BoxDecoration(
          border: layout['showBorder'] ? Border.all( // 边框：平板端showBorder=true(显示边框)
            color: Colors.grey.withOpacity(0.3),     // 边框颜色：30%透明灰色
            width: 1.w,                              // 边框宽度：1逻辑像素
          ) : null,
          borderRadius: BorderRadius.circular(layout['borderRadius']), // 圆角：平板端约12.0逻辑像素
          boxShadow: layout['showBorder'] ? [       // 阴影：平板端显示卡片阴影效果
            BoxShadow(
              color: Colors.black.withOpacity(0.1),  // 阴影颜色：10%透明黑色
              blurRadius: 20.r,                      // 模糊半径：20逻辑像素的软阴影
              offset: Offset(0, 10.h),               // 阴影偏移：向下10逻辑像素
            ),
          ] : null,
          color: Colors.white,                      // 容器背景：白色卡片背景
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(layout['borderRadius']), // 裁剪圆角：与容器保持一致
          child: Column(
            children: [
              _buildAppBar(),                        // 📱 顶部导航栏：与移动端相同的导航栏
              Expanded(
                child: ClipRect(                     // 🎨 裁剪背景：确保背景不会溢出到AppBar区域
                  child: Stack(                      // 🎨 主内容区域：背景层 + 内容层的层叠结构
                    children: [
                      _buildBackground(),            // 🎨 背景图片层：与移动端相同的动态背景
                      _buildTabletContent(),         // 📄 平板端内容层：水平布局显示三个罐头
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 🖥️ 桌面端主布局容器 (>1200px屏幕)
  /// 居中显示，大尺寸卡片，网格布局显示所有罐头
  Widget _buildDesktopLayout() {
    final layout = ResponsiveLayout.getMainContainerLayout(context); // 获取桌面端布局参数
    
    return Center(                                   // 居中对齐：桌面端在屏幕中央显示
      child: Container(
        width: layout['width'],                      // 容器宽度：桌面端约为screenWidth*0.7(70%屏宽)
        height: layout['height'],                    // 容器高度：桌面端约为screenHeight*0.85(85%屏高)
        margin: layout['margin'] ?? EdgeInsets.zero, // 外边距：桌面端有较大边距
        padding: layout['padding'] ?? EdgeInsets.zero, // 内边距：布局参数控制
        decoration: BoxDecoration(
          border: layout['showBorder'] ? Border.all( // 边框：桌面端showBorder=true(显示边框)
            color: Colors.grey.withOpacity(0.3),     // 边框颜色：30%透明灰色
            width: 1.w,                              // 边框宽度：1逻辑像素
          ) : null,
          borderRadius: BorderRadius.circular(layout['borderRadius']), // 圆角：桌面端约16.0逻辑像素
          boxShadow: layout['showBorder'] ? [       // 阴影：桌面端显示更强烈的卡片阴影
            BoxShadow(
              color: Colors.black.withOpacity(0.1),  // 阴影颜色：10%透明黑色
              blurRadius: 20.r,                      // 模糊半径：20逻辑像素的柔和阴影
              offset: Offset(0, 10.h),               // 阴影偏移：向下10逻辑像素
            ),
          ] : null,
          color: Colors.white,                      // 容器背景：白色卡片背景
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(layout['borderRadius']), // 裁剪圆角：与容器保持一致
          child: Column(
            children: [
              _buildAppBar(),                        // 📱 顶部导航栏：与其他端相同的导航栏
              Expanded(
                child: ClipRect(                     // 🎨 裁剪背景：确保背景不会溢出到AppBar区域
                  child: Stack(                      // 🎨 主内容区域：背景层 + 内容层的层叠结构
                    children: [
                      _buildBackground(),            // 🎨 背景图片层：与其他端相同的动态背景
                      _buildDesktopContent(),        // 📄 桌面端内容层：网格布局显示所有罐头
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 📄 移动端内容区域构建器
  /// 包含PageView三罐头系统 + 左右导航栏 + 滑动提示 + 输入覆盖层
  Widget _buildMobileContent() {
    return Consumer<TransactionProvider>(              // 🔄 数据消费者：监听TransactionProvider变化
      builder: (context, provider, child) {
        // 🔄 加载状态处理：显示加载指示器
        if (_isLoading) {
          return const LoadingWidget(message: '加载中...'); // 全屏加载组件：转圈 + 文字提示
        }

        // ❌ 错误状态处理：显示错误信息和重试按钮
        if (_errorMessage != null) {
          return AppErrorWidget(
            message: _errorMessage!,                   // 错误信息：从_errorMessage获取
            onRetry: () {                             // 重试回调：重新加载数据
              setState(() {
                _errorMessage = null;                  // 清除错误信息
                _isLoading = true;                     // 设置加载状态
              });
              _loadData(provider);                     // 重新加载数据
            },
          );
        }

        // ✅ 正常状态：构建完整的移动端内容
        return _buildContent(provider);               // 📱 核心内容构建：PageView + 导航 + 提示
      },
    );
  }

  /// 📱 顶部导航栏构建器 
  /// 包含设置按钮(左) + MoneyJars标题(中) + 平衡占位(右)
  Widget _buildAppBar() {
    return Container(
      height: AppConstants.appBarHeight + 6,           // 导航栏高度：基础高度+6px额外空间
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,           // 背景色：白色(#FFFFFF)
        boxShadow: AppConstants.shadowMedium,          // 阴影：中等强度阴影，提供层次感
      ),
      child: SafeArea(                                 // 安全区域：避免状态栏遮挡
        child: Padding(
          padding: EdgeInsets.only(top: AppConstants.spacingSmall.h), // 顶部内边距：小间距
          child: Row(
            children: [
              // ⚙️ 左侧设置按钮：带阴影的图标按钮
              Padding(
                padding: EdgeInsets.only(left: AppConstants.spacingMedium.w), // 左边距：中等间距
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(AppConstants.spacingSmall.w), // 图标内边距：小间距
                    decoration: BoxDecoration(
                      color: AppConstants.backgroundColor,     // 容器背景：白色
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium), // 圆角：中等圆角
                      boxShadow: AppConstants.shadowSmall,     // 阴影：小阴影效果
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium), // 裁剪圆角
                      child: Image.asset(
                        'assets/images/icons-1.png',           // 设置图标图片：icons-1.png
                        width: AppConstants.iconMedium.w,      // 图标宽度：中等尺寸
                        height: AppConstants.iconMedium.h,     // 图标高度：中等尺寸
                        fit: BoxFit.contain,                   // 适配方式：保持比例缩放
                      ),
                    ),
                  ),
                  onPressed: _showSettings,                    // 点击回调：显示设置对话框
                  tooltip: AppConstants.buttonSettings,       // 工具提示：设置按钮提示文字
                ),
              ),
              // 🏷️ 中间标题区域：MoneyJars应用标题 + Hero图标
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 水平居中对齐
                  mainAxisSize: MainAxisSize.min,              // 最小尺寸：紧凑布局
                  children: [
                    Hero(                                      // Hero动画：页面转场时的共享元素动画
                      tag: 'app_icon',                         // Hero标签：唯一标识符
                      child: Container(
                        width: (AppConstants.iconXLarge + 4).w,  // 容器宽度：超大图标+4px
                        height: (AppConstants.iconXLarge + 4).h, // 容器高度：超大图标+4px
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,   // 背景色：白色
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium), // 圆角：中等圆角
                          boxShadow: AppConstants.shadowMedium,  // 阴影：中等强度阴影
                        ),
                        child: Icon(
                          Icons.savings,                         // 储蓄图标：代表金钱罐头概念
                          size: AppConstants.iconMedium.sp,      // 图标尺寸：中等尺寸
                          color: AppConstants.primaryColor,      // 图标颜色：主题色(蓝色)
                        ),
                      ),
                    ),
                    SizedBox(width: AppConstants.spacingMedium.w), // 图标与文字间距：中等间距
                    Text(
                      'MoneyJars',                             // 应用名称：MoneyJars金钱罐头
                      style: TextStyle(
                        fontWeight: FontWeight.bold,           // 字体粗细：粗体
                        color: AppConstants.primaryColor,      // 文字颜色：主题色(蓝色)
                        fontSize: AppConstants.fontSizeXLarge.sp, // 字体大小：超大字体
                      ),
                    ),
                  ],
                ),
              ),
              // ⚖️ 右侧占位区域：保持左右平衡，确保标题居中
              SizedBox(width: 60.w),                           // 右侧占位宽度：60逻辑像素，与左侧设置按钮区域平衡
            ],
          ),
        ),
      ),
    );
  }

  /// 📱 核心内容构建器：移动端主要UI结构
  /// Stack层级：PageView(底层) + 左导航栏 + 右指示器 + 输入覆盖层(顶层)
  Widget _buildContent(TransactionProvider provider) {
    final screenSize = MediaQuery.of(context).size;         // 📏 屏幕尺寸：获取当前设备屏幕宽高
    final isSmallScreen = screenSize.width < 600;           // 📱 小屏判断：宽度<600px为小屏设备
    
    return Stack(                                           // 🎯 层叠布局：多层UI元素叠加
      children: [
        // ===== 📄 主要内容区域：垂直滑动的三罐头PageView =====
        Positioned(
          top: 5,                                           // 顶部间距：5逻辑像素，减少顶部空白
          left: isSmallScreen ? 60 : 50,                   // 左侧间距：小屏60px，大屏50px，为左导航栏预留空间
          right: isSmallScreen ? 60 : 50,                  // 右侧间距：小屏60px，大屏50px，为右指示器预留空间
          bottom: 0,                                        // 底部对齐：延伸到屏幕底部
          child: PageView(                                  // 📄 页面视图：垂直滑动的三个罐头页面
            controller: _pageController,                    // 控制器：管理页面滚动和当前页面状态
            scrollDirection: Axis.vertical,                // 滚动方向：垂直滚动(上下滑动)
            onPageChanged: _onPageChanged,                  // 页面变化回调：更新_currentPage状态
            physics: const BouncingScrollPhysics(),        // 滚动物理：iOS风格弹性滚动，丝滑手感
            allowImplicitScrolling: true,                   // 隐式滚动：支持连续滚动，提升体验
            children: [
              // 🍯 支出罐头页面 (index: 0)：绿色针织背景 + 红色主题 + 向下滑动提示
              _buildJarPage(
                title: '${AppConstants.labelExpense}罐头',    // 标题："支出罐头" (labelExpense="支出")
                type: TransactionType.expense,               // 交易类型：支出类型
                currentAmount: provider.totalExpense,        // 当前金额：支出总额(实时计算)
                targetAmount: provider.jarSettings.targetAmount, // 目标金额：用户设置的目标值
                color: AppConstants.expenseColor,            // 主题颜色：支出红色(用于图标、文字、提示)
                provider: provider,                          // 数据提供者：TransactionProvider实例
                isExpenseOrIncome: true,                     // 特殊标记：标识为支出/收入罐头(用于位置偏移)
              ),
              
              // 🍯 综合统计罐头页面 (index: 1, 默认页面)：小猪背景 + 动态主题色 + 无滑动提示
              _buildJarPage(
                title: provider.jarSettings.title,          // 标题：用户自定义罐头名称
                type: TransactionType.income,                // 交易类型：用income类型显示(实际为综合)
                currentAmount: provider.netIncome,           // 当前金额：净收入(总收入-总支出)
                targetAmount: provider.jarSettings.targetAmount, // 目标金额：用户设置的目标值
                color: provider.netIncome >= 0               // 动态主题颜色：根据净收入正负切换
                    ? AppConstants.comprehensivePositiveColor // 净收入≥0：正数颜色(通常为绿色)
                    : AppConstants.comprehensiveNegativeColor, // 净收入<0：负数颜色(通常为红色)
                provider: provider,                          // 数据提供者：TransactionProvider实例
                isComprehensive: true,                       // 综合标记：标识为综合罐头(无滑动提示)
              ),
              
              // 🍯 收入罐头页面 (index: 2)：红色针织背景 + 绿色主题 + 向上滑动提示
              _buildJarPage(
                title: '${AppConstants.labelIncome}罐头',     // 标题："收入罐头" (labelIncome="收入")
                type: TransactionType.income,                // 交易类型：收入类型
                currentAmount: provider.totalIncome,         // 当前金额：收入总额(实时计算)
                targetAmount: provider.jarSettings.targetAmount, // 目标金额：用户设置的目标值
                color: AppConstants.incomeColor,             // 主题颜色：收入绿色(用于图标、文字、提示)
                provider: provider,                          // 数据提供者：TransactionProvider实例
                isExpenseOrIncome: true,                     // 特殊标记：标识为支出/收入罐头(用于位置偏移)
              ),
            ],
          ),
        ),
        
        // ===== 🧭 左侧导航栏：4个功能页面快速入口，相对背景图片居中，长度延长20% =====
        Positioned(
          left: 2.w,                                         // 左侧位置：几乎贴左边缘，只留2px白边
          top: MediaQuery.of(context).size.height * 0.32,   // 垂直位置：调整为32%避免溢出
          child: Container(
            width: 48.w,                                     // 容器宽度：48逻辑像素(原42增大15%)
            padding: EdgeInsets.symmetric(vertical: 16.h),   // 垂直内边距：减少为16逻辑像素避免溢出
            decoration: BoxDecoration(
              color: Colors.white,                           // 背景颜色：白色
              borderRadius: BorderRadius.circular(24.r),     // 圆角半径：24逻辑像素(原21增大15%)
              boxShadow: [                                   // 阴影效果：单一阴影
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),     // 阴影颜色：10%透明黑色
                  blurRadius: 8.r,                          // 模糊半径：8逻辑像素(原7增大15%)
                  offset: Offset(0, 1.6.h),                 // 阴影偏移：向下1.6逻辑像素(原1.4增大15%)
                ),
              ],
            ),
            child: _buildLeftNavBar(),                       // 左导航栏内容：4个功能按钮(设置/帮助/统计/个性化)
          ),
        ),
        
        // ===== 📊 右侧指示器栏：页面状态显示，相对背景图片居中，长度延长20% =====
        Positioned(
          right: 2.w,                                        // 右侧位置：几乎贴右边缘，只留2px白边
          top: MediaQuery.of(context).size.height * 0.32,   // 垂直位置：调整为32%与左导航栏对齐
          child: Container(
            width: 48.w,                                     // 容器宽度：48逻辑像素(与左导航栏相同)
            padding: EdgeInsets.symmetric(vertical: 16.h),   // 垂直内边距：减少为16逻辑像素避免溢出
            decoration: BoxDecoration(
              color: Colors.white,                           // 背景颜色：白色
              borderRadius: BorderRadius.circular(26.r),     // 圆角半径：26逻辑像素(与左导航栏相同)
              boxShadow: [                                   // 阴影效果：与左导航栏相同的阴影
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),     // 阴影颜色：10%透明黑色
                  blurRadius: 8.r,                          // 模糊半径：8逻辑像素(增大15%)
                  offset: Offset(0, 1.6.h),                 // 阴影偏移：向下1.6逻辑像素(增大15%)
                ),
              ],
            ),
            child: _buildPageIndicators(),                   // 右指示器内容：页面圆点指示器
          ),
        ),
        
        // ===== 💰 输入模式覆盖层：交易输入界面，覆盖整个屏幕 =====
        if (_isInputMode && _inputType != null)             // 条件显示：仅在输入模式且有交易类型时显示
          EnhancedTransactionInput(                          // 增强型交易输入组件：全屏输入界面
            type: _inputType!,                               // 交易类型：支出或收入(从_inputType获取)
            onComplete: _exitInputMode,                      // 完成回调：输入完成后退出输入模式
            onCancel: _exitInputMode,                        // 取消回调：用户取消时退出输入模式
          ),
      ],
    );
  }

  // ===== 🧭 左侧导航栏内容构建器：4个功能页面入口 =====
  /// 垂直排列的4个功能按钮：设置、帮助、统计、个性化
  Widget _buildLeftNavBar() {
    return Column(
      children: [
        _buildLeftNavIcon(Icons.settings, _navigateToSettings),        // ⚙️ 设置按钮：跳转到SettingsPage
        SizedBox(height: 12.h),                                       // 按钮间距：减少为12逻辑像素避免溢出
        _buildLeftNavIcon(Icons.help_outline, _navigateToHelp),        // ❓ 帮助按钮：跳转到HelpPage
        SizedBox(height: 12.h),                                       // 按钮间距：减少为12逻辑像素避免溢出
        _buildLeftNavIcon(Icons.bar_chart, _navigateToStatistics),     // 📈 统计按钮：跳转到StatisticsPage
        SizedBox(height: 12.h),                                       // 按钮间距：减少为12逻辑像素避免溢出
        _buildLeftNavIcon(Icons.more_horiz, _navigateToPersonalization), // 🎨 个性化按钮：跳转到PersonalizationPage
      ],
    );
  }

  /// 🔘 左导航栏单个图标按钮构建器
  /// 创建带背景和点击交互的图标按钮
  Widget _buildLeftNavIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,                                    // 点击回调：执行对应的导航方法
      child: Container(
        width: 28.w,                                   // 按钮宽度：28逻辑像素(增大15%)
        height: 28.h,                                  // 按钮高度：28逻辑像素(增大15%)
        decoration: BoxDecoration(
          color: Colors.grey[100],                     // 背景颜色：浅灰色(#F5F5F5)
          borderRadius: BorderRadius.circular(7.r),    // 圆角半径：7逻辑像素(增大15%)
        ),
        child: Icon(
          icon,                                        // 图标：传入的IconData(如Icons.settings)
          color: Colors.grey[600],                     // 图标颜色：中灰色(#757575)
          size: 18.sp,                                 // 图标尺寸：18逻辑像素(增大15%)
        ),
      ),
    );
  }

  // ===== 📊 右侧页面指示器内容构建器：3个罐头页面状态显示 =====
  /// 垂直排列的3个圆点指示器：支出、综合、收入页面状态
  Widget _buildPageIndicators() {
    return Column(
      children: [
        _buildPageIndicator(0, AppConstants.labelExpense),      // 🔴 支出指示器：索引0，标签"支出"
        SizedBox(height: 12.h),                                // 指示器间距：减少为12逻辑像素避免溢出
        _buildPageIndicator(1, AppConstants.labelComprehensive), // 🔵 综合指示器：索引1，标签"综合"
        SizedBox(height: 12.h),                                // 指示器间距：减少为12逻辑像素避免溢出
        _buildPageIndicator(2, AppConstants.labelIncome),       // 🟢 收入指示器：索引2，标签"收入"
      ],
    );
  }

  /// 🔘 单个页面指示器构建器
  /// 包含圆点状态 + 文字标签，根据当前页面高亮显示
  Widget _buildPageIndicator(int index, String label) {
    final isActive = _currentPage == index;               // 是否为当前活跃页面
    return Container(
      child: Column(
        children: [
          // ⚪ 状态圆点：活跃时为主题色，非活跃时为半透明灰色
          Container(
            width: 8.w,                                   // 圆点宽度：8逻辑像素
            height: 8.h,                                  // 圆点高度：8逻辑像素
            decoration: BoxDecoration(
              color: isActive                             // 动态颜色：
                  ? AppConstants.primaryColor             // 活跃状态：主题蓝色
                  : Colors.grey.withOpacity(0.5),        // 非活跃状态：50%透明灰色
              shape: BoxShape.circle,                     // 形状：正圆形
            ),
          ),
          SizedBox(height: 2.h),                          // 圆点与文字间距：2逻辑像素
          // 🏷️ 页面标签：显示"支出"/"综合"/"收入"文字
          Text(
            label,                                        // 标签文字：从AppConstants获取
            style: TextStyle(
              color: isActive                             // 动态颜色：
                  ? AppConstants.primaryColor             // 活跃状态：主题蓝色
                  : Colors.grey.withOpacity(0.7),        // 非活跃状态：70%透明灰色
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal, // 活跃时加粗
              fontSize: 8.sp,                             // 字体大小：8逻辑像素(小号文字)
            ),
          ),
        ],
      ),
    );
  }
  
  // ===== 📟 平板端内容构建器：水平排列显示多个罐头 =====
  /// 调用ResponsiveLayout的水平布局方法，适配平板端显示
  Widget _buildTabletContent() {
    return buildTabletContent();                     // 平板端内容：水平排列的多罐头布局(来自ResponsiveLayout)
  }
  
  // ===== 🖥️ 桌面端内容构建器：网格布局显示所有罐头 =====
  /// 调用ResponsiveLayout的网格布局方法，适配桌面端大屏显示
  Widget _buildDesktopContent() {
    return buildDesktopContent();                    // 桌面端内容：网格布局的多罐头显示(来自ResponsiveLayout)
  }

  /// 🍯 单个罐头页面构建器：完整的罐头展示页面
  /// 包含SwipeDetector手势检测 + MoneyJarWidget罐头组件 + 滑动提示
  Widget _buildJarPage({
    required String title,                           // 罐头标题：如"支出罐头"、"收入罐头"或用户自定义名称
    required TransactionType type,                   // 交易类型：支出、收入或综合(使用income类型显示)
    required double currentAmount,                   // 当前金额：实时计算的总额
    required double targetAmount,                    // 目标金额：用户设置的目标值
    required Color color,                            // 主题颜色：用于图标、文字和提示的颜色
    required TransactionProvider provider,           // 数据提供者：TransactionProvider实例
    bool isComprehensive = false,                    // 是否为综合罐头：true=无滑动提示
    bool isExpenseOrIncome = false,                  // 是否为支出/收入罐头：true=应用位置偏移
  }) {
    return SwipeDetector(                            // 🎯 手势检测器：处理左右滑动手势
      gestureHandler: _gestureHandler,               // 手势处理器：统一的手势处理逻辑
      isInputMode: _isInputMode,                     // 输入模式状态：决定是否响应手势
      currentPage: _currentPage,                     // 当前页面索引：用于手势逻辑判断
      onExpenseSwipe: _onExpenseSwipe,               // 支出滑动回调：触发支出输入模式
      onIncomeSwipe: _onIncomeSwipe,                 // 收入滑动回调：触发收入输入模式
      child: Container(
        width: double.infinity,                      // 容器宽度：占满父容器
        height: double.infinity,                     // 容器高度：占满父容器
        child: Center(                               // 居中对齐：内容在页面中央
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 垂直居中对齐
            children: [
              // 🍯 罐头组件区域：占用80%空间，包含位置偏移
              Expanded(
                flex: 8,                             // 弹性比例：8/10 = 80%的垂直空间
                child: Center(
                  child: Transform.translate(
                    // 🎯 位置偏移：所有罐头统一往下145逻辑像素(已调整30%+原有偏移)
                    offset: Offset(0, 145.h ),        // X轴偏移：0, Y轴偏移：145逻辑像素向下
                    child: Opacity(                   // 🎨 所有罐头统一40%透明度效果
                      opacity: 0.6,                   // 透明度：60%显示，即40%透明
                      child: MoneyJarWidget(          // 💰 金钱罐头组件：核心的罐头显示组件
                        amount: currentAmount,        // 显示金额：当前总额
                        type: type,                   // 罐头类型：决定图标和颜色
                        title: title,                 // 罐头标题：显示的文字标题
                        onTap: () => _showDetailPage(type, provider, isComprehensive), // 点击回调：跳转详情页
                        onSettings: null,             // 设置按钮：null=不显示设置按钮
                      ),
                    ),
                  ),
                ),
              ),
              
              // 👆 滑动提示区域：仅非综合罐头显示，占用20%空间
              if (!isComprehensive)                   // 条件渲染：综合罐头不显示滑动提示
                Expanded(
                  flex: 2,                           // 弹性比例：2/10 = 20%的垂直空间
                  child: _buildSwipeHint(type, color), // 滑动提示组件：显示向上/向下滑动提示
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== 👆 滑动提示组件构建器：动画提示向上/向下滑动，尺寸增大15% =====
  /// 显示向上或向下滑动的提示信息，支持动画效果和主题色适配
  Widget _buildSwipeHint(TransactionType type, Color color) {
    final isExpense = type == TransactionType.expense;    // 是否为支出类型：决定箭头方向和提示文字
    
    return Container(
      width: double.infinity,                             // 容器宽度：占满父容器
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge.w), // 水平内边距：大间距
      child: AnimatedBuilder(                             // 🎬 动画构建器：监听_swipeHintAnimation动画
        animation: _swipeHintAnimation,                   // 动画对象：控制透明度和缩放的循环动画
        builder: (context, child) {
          return Opacity(
            opacity: _swipeHintAnimation.value * 0.8,     // 透明度：动画值*0.8，最大80%透明度
            child: Transform.translate(
              offset: Offset(0, 25.h),                   // 位置偏移：向下25逻辑像素(往下10%移动)
              child: Transform.scale(
                scale: (0.9 + (_swipeHintAnimation.value * 0.1)) * 1.15, // 缩放：基础0.9 + 动画变化0.1，再整体放大15%
                child: Center(                            // 居中对齐：提示框在页面中央
                  child: Container(
                    width: 150.w,                         // 容器宽度：150逻辑像素(宽度缩小70%)
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSmall.w,  // 水平内边距：小间距
                      vertical: AppConstants.spacingXSmall.h,   // 垂直内边距：超小间距
                    ),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,   // 背景颜色：白色
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge.r), // 圆角：大圆角
                  boxShadow: [                            // 阴影效果：轻微阴影
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), // 阴影颜色：5%透明黑色(减少阴影)
                      blurRadius: 5.r,                    // 模糊半径：5逻辑像素
                      offset: Offset(0, 2.h),             // 阴影偏移：向下2逻辑像素
                    ),
                  ],
                  border: Border.all(                     // 边框：主题色边框
                    color: color.withOpacity(0.3),       // 边框颜色：主题色30%透明度
                    width: 1.w,                           // 边框宽度：1逻辑像素
                  ),
                ),
                child: Row(                               // 水平布局：图标 + 文字
                  mainAxisAlignment: MainAxisAlignment.center, // 水平居中对齐
                  mainAxisSize: MainAxisSize.min,         // 最小尺寸：紧凑布局
                  children: [
                    Container(                            // 🔵 图标容器：圆形背景 + 箭头图标
                      padding: EdgeInsets.all(AppConstants.spacingXSmall.w), // 图标内边距：超小间距
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),   // 背景颜色：主题色15%透明度
                        shape: BoxShape.circle,            // 形状：正圆形
                      ),
                      child: Icon(
                        isExpense ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, // 箭头图标：支出向下，收入向上
                        color: color,                     // 图标颜色：主题色
                        size: AppConstants.iconSmall.sp, // 图标尺寸：小尺寸
                      ),
                    ),
                    SizedBox(width: AppConstants.spacingXSmall.w), // 图标与文字间距：超小间距
                    Text(                                 // 📝 提示文字：滑动方向说明
                      isExpense ? AppConstants.hintSwipeDown : AppConstants.hintSwipeUp, // 提示文字：支出"向下滑动"，收入"向上滑动"
                      style: AppConstants.captionStyle.copyWith( // 文字样式：使用标题样式
                        color: color,                     // 文字颜色：主题色
                        fontWeight: FontWeight.w600,      // 字体粗细：半粗体
                        fontSize: 10.sp,                  // 字体大小：10逻辑像素(进一步减小)
                      ),
                    ),
                  ],
                ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 📊 数据加载方法：异步初始化TransactionProvider数据
  /// 包含加载状态管理和错误处理，确保UI状态正确更新
  void _loadData(TransactionProvider provider) async {
    try {
      setState(() {
        _isLoading = true;                           // 设置加载状态：显示LoadingWidget
        _errorMessage = null;                        // 清除错误信息：重置错误状态
      });
      
      await provider.initializeData();              // 初始化数据：加载用户设置和交易记录
      
      if (mounted) {                                 // 检查组件状态：避免在组件销毁后调用setState
        setState(() {
          _isLoading = false;                        // 取消加载状态：隐藏LoadingWidget
        });
      }
    } catch (e) {                                    // 异常处理：捕获初始化错误
      if (mounted) {                                 // 检查组件状态：确保安全调用setState
        setState(() {
          _isLoading = false;                        // 取消加载状态：隐藏LoadingWidget
          _errorMessage = AppConstants.errorInitialization; // 设置错误信息：显示AppErrorWidget
        });
      }
    }
  }

  // ===== 🎨 动态背景图片系统：3张背景图随页面切换，支持跟随移动 =====
  /// 根据当前页面索引显示对应背景，背景图片随PageView滚动而移动
  /// 0: 支出页面 - 绿色针织背景 (background1.png)
  /// 1: 综合页面 - 小猪背景 (background2.png)
  /// 2: 收入页面 - 红色针织背景 (background3.png)
  Widget _buildBackground() {
    return AnimatedBuilder(                          // 🎬 动画构建器：监听_pageController变化
      animation: _pageController,                    // 动画对象：PageController的滚动动画
      builder: (context, child) {
        double page = 1.0;                           // 默认页面：1.0=综合页面(小猪背景)
        
        if (_pageController.hasClients && _pageController.page != null) { // 检查控制器状态
          page = _pageController.page!;              // 获取当前页面：实时滚动进度(0.0-2.0)
        }
        
        // 🎯 背景固定：禁用背景跟随移动，保持背景图片固定位置
        final screenHeight = MediaQuery.of(context).size.height; // 屏幕高度：用于尺寸计算
        final backgroundOffset = 0.0; // 背景偏移：固定为0，不跟随页面移动
        
        // 🎨 动态背景选择：根据页面滑动进度智能切换背景图片和背景色
        String backgroundImage;                      // 背景图片路径：动态选择的背景图片文件
        Color backgroundColor;                       // 背景颜色：与背景图片主色调匹配的填充色
        double opacity = 1.0;                        // 背景透明度：用于平滑过渡效果
        
        if (page < 0.5) {
          // 📍 支出页面区域 (0.0 - 0.5)：绿色针织背景占主导
          backgroundImage = 'assets/images/green_knitted_jar.png'; // 绿色针织罐头背景
          backgroundColor = const Color(0xFF104812);   // 深绿色：与绿色针织背景匹配
          opacity = 1.0;                             // 支出页面区域完全不透明
        } else if (page <= 1.5) {
          // 📍 综合页面区域 (0.5 - 1.5)：小猪背景占主导
          backgroundImage = 'assets/images/festive_piggy_bank.png'; // 节日小猪存钱罐背景
          backgroundColor = const Color.fromARGB(255, 255, 255, 255);  // 
          if (page < 1) {
            opacity = page * 2;                      // 淡入效果：page=0.5时opacity=1.0，page=1.0时opacity=2.0
          } else {
            opacity = 2.0 - page;                    // 淡出效果：page=1.0时opacity=1.0，page=1.5时opacity=0.5
          }
        } else {
          // 📍 收入页面区域 (1.5 - 2.0)：红色针织背景占主导
          backgroundImage = 'assets/images/red_knitted_jar.png'; // 红色针织罐头背景
          backgroundColor = const Color(0xFF66120D);  // 深红色：与红色针织背景匹配
          opacity = (page - 1.0) * 2;                // 透明度计算：page=1.5时opacity=1.0，page=2.0时opacity=2.0
          if (opacity > 1.0) opacity = 1.0;         // 透明度限制：最大值1.0，避免过度透明
        }
        
        return Stack(                                // 🎯 层叠布局：多背景图片叠加，实现平滑过渡
          children: [
            // 🖼️ 主要背景层：固定位置的背景图片，宽度与屏幕完全吻合，配色填充白边
            Container(
              width: double.infinity,                // 容器宽度：占满屏幕宽度
              height: double.infinity,               // 容器高度：占满屏幕高度
              decoration: BoxDecoration(
                color: backgroundColor,              // 背景颜色：与图片主色调匹配，填充白边区域
                image: DecorationImage(
                  image: AssetImage(backgroundImage), // 背景图片：动态选择的背景图片文件
                  fit: BoxFit.fitWidth,              // 填充模式：宽度完全匹配，高度可能裁剪
                  alignment: Alignment.center,       // 对齐方式：居中对齐
                ),
              ),
            ),
            
            // 🌅 过渡背景层1：支出→综合页面过渡 (0.5 < page < 1.0)
            if (page > 0.5 && page < 1.0)           // 条件渲染：仅在支出和综合页面之间显示
              Opacity(
                opacity: (page - 0.5) * 2,          // 渐变透明度：page=0.5时opacity=0，page=1.0时opacity=1
                child: Container(
                  width: double.infinity,            // 容器宽度：占满屏幕宽度
                  height: double.infinity,           // 容器高度：占满屏幕高度
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),  // 白色：与小猪背景匹配，填充白边区域
                    image: DecorationImage(
                      image: AssetImage('assets/images/festive_piggy_bank.png'), // 小猪背景：渐入效果
                      fit: BoxFit.fitWidth,          // 填充模式：宽度完全匹配，高度可能裁剪
                      alignment: Alignment.center,   // 对齐方式：居中对齐
                    ),
                  ),
                ),
              ),
            
            // 🌅 过渡背景层2：综合→收入页面过渡 (1.0 < page < 1.5)
            if (page > 1.0 && page < 1.5)           // 条件渲染：仅在综合和收入页面之间显示
              Opacity(
                opacity: (page - 1.0) * 2,          // 渐变透明度：page=1.0时opacity=0，page=1.5时opacity=1
                child: Container(
                  width: double.infinity,            // 容器宽度：占满屏幕宽度
                  height: double.infinity,           // 容器高度：占满屏幕高度
                  decoration: BoxDecoration(
                    color: const Color(0xFFB71C1C),  // 深红色：与红色针织背景匹配，填充白边区域
                    image: DecorationImage(
                      image: AssetImage('assets/images/red_knitted_jar.png'), // 红色针织背景：渐入效果
                      fit: BoxFit.fitWidth,          // 填充模式：宽度完全匹配，高度可能裁剪
                      alignment: Alignment.center,   // 对齐方式：居中对齐
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}