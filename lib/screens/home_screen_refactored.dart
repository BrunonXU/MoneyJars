/*
 * MoneyJars 主屏幕界面 (home_screen.dart) - 重构版本
 * 
 * 模块化架构：
 * ┌─────────────────────────────────────────────┐
 * │  📱 AppBarWidget - 顶部导航栏模块              │
 * ├─────────────────────────────────────────────┤
 * │  🎨 BackgroundWidget - 动态背景模块           │
 * │  🧭 LeftNavigationWidget - 左侧导航模块        │
 * │  🍯 JarPageView - 罐头页面视图模块            │
 * │  💡 SwipeHintWidget - 滑动提示模块            │
 * └─────────────────────────────────────────────┘
 * 
 * 核心功能：
 * - 模块化组件架构，提升代码可维护性
 * - 清晰的职责分离，每个组件负责特定功能
 * - 统一的组件接口，便于扩展和测试
 * - 响应式设计，支持多平台适配
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 核心模块导入
import '../providers/transaction_provider.dart';
import '../models/transaction_record.dart';
import '../constants/app_constants.dart';
import '../utils/responsive_layout.dart';

// 重构组件导入
import '../widgets/background/background_widget.dart';
import '../widgets/navigation/app_bar_widget.dart';
import '../widgets/navigation/left_navigation_widget.dart';
import '../widgets/jar/jar_page_view.dart';
import '../widgets/jar/jar_page_widget.dart';

// 交互和输入组件
import '../widgets/enhanced_transaction_input.dart';
import '../widgets/jar_settings_dialog.dart';
import '../widgets/gesture_handler.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/error_widget.dart';

// 页面导入
import '../screens/jar_detail_page.dart';
import '../screens/settings_page.dart';
import '../screens/help_page.dart';
import '../screens/statistics_page.dart';
import '../screens/personalization_page.dart';

/// 🏠 MoneyJars主屏幕
/// 
/// 采用模块化架构的主屏幕组件，负责：
/// - 整体布局和组件协调
/// - 页面状态管理
/// - 用户交互处理
/// - 数据流管理
/// 
/// 设计理念：
/// - 单一职责原则：每个组件负责特定功能
/// - 依赖注入：通过构造函数传递依赖
/// - 状态提升：集中管理页面状态
/// - 响应式设计：适配不同屏幕尺寸
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ===== 📄 页面控制和状态管理 =====
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late GestureHandler _gestureHandler;

  // ===== 🎯 页面状态 =====
  int _currentPage = 1; // 默认显示综合页面
  bool _isInputMode = false; // 输入模式状态
  TransactionType? _inputType; // 当前输入类型
  bool _isLoading = false; // 加载状态
  String? _errorMessage; // 错误信息

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  /// 🔧 初始化控制器
  void _initializeControllers() {
    _pageController = PageController(initialPage: 1);
    _gestureHandler = GestureHandler();
    
    _fadeController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: AppConstants.curveDefault,
    ));
    
    _fadeController.forward();
  }

  /// 📊 加载初始数据
  void _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactions();
    } catch (e) {
      setState(() {
        _errorMessage = AppConstants.errorInitialization;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildMainContent(),
        ),
      ),
    );
  }

  /// 🎨 构建主要内容
  Widget _buildMainContent() {
    final layout = ResponsiveLayout.getLayout(context);
    
    if (layout['isDesktop']) {
      return _buildDesktopContent();
    } else {
      return _buildMobileContent();
    }
  }

  /// 🖥️ 构建桌面端内容
  Widget _buildDesktopContent() {
    final layout = ResponsiveLayout.getLayout(context);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(layout['borderRadius']),
        boxShadow: layout['showBorder'] ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ] : null,
        color: Colors.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(layout['borderRadius']),
        child: Column(
          children: [
            AppBarWidget(), // 使用重构的导航栏组件
            Expanded(
              child: ClipRect(
                child: Stack(
                  children: [
                    BackgroundWidget(pageController: _pageController), // 使用重构的背景组件
                    _buildDesktopJarContent(), // 桌面端罐头内容
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📱 构建移动端内容
  Widget _buildMobileContent() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        // 🔄 加载状态处理
        if (_isLoading) {
          return const LoadingWidget(message: '加载中...');
        }

        // ❌ 错误状态处理
        if (_errorMessage != null) {
          return AppErrorWidget(
            message: _errorMessage!,
            onRetry: () {
              setState(() {
                _errorMessage = null;
                _isLoading = true;
              });
              _loadInitialData();
            },
          );
        }

        // 📄 正常内容显示
        return Stack(
          children: [
            // 🎨 背景层
            BackgroundWidget(pageController: _pageController),
            
            // 🍯 罐头页面视图
            JarPageView(pageController: _pageController),
            
            // 🧭 左侧导航栏
            LeftNavigationWidget(
              onSettingsTap: _navigateToSettings,
              onHelpTap: _navigateToHelp,
              onStatisticsTap: _navigateToStatistics,
              onPersonalizationTap: _navigateToPersonalization,
            ),
            
            // 🎯 输入覆盖层
            if (_isInputMode) _buildInputOverlay(),
          ],
        );
      },
    );
  }

  /// 🖥️ 构建桌面端罐头内容
  Widget _buildDesktopJarContent() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Center(
          child: Text(
            '桌面端网格布局 - 待实现',
            style: TextStyle(
              fontSize: 24.sp,
              color: AppConstants.primaryColor,
            ),
          ),
        );
      },
    );
  }

  /// 📝 构建输入覆盖层
  Widget _buildInputOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: EnhancedTransactionInput(
          type: _inputType!,
          onSubmit: _handleTransactionSubmit,
          onCancel: _handleTransactionCancel,
        ),
      ),
    );
  }

  // ===== 🎯 导航处理方法 =====
  
  /// 导航到设置页面
  void _navigateToSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppConstants.curveSmooth)),
            ),
            child: child,
          );
        },
        transitionDuration: AppConstants.animationMedium,
      ),
    );
  }

  /// 导航到帮助页面
  void _navigateToHelp() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HelpPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppConstants.curveSmooth)),
            ),
            child: child,
          );
        },
        transitionDuration: AppConstants.animationMedium,
      ),
    );
  }

  /// 导航到统计页面
  void _navigateToStatistics() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const StatisticsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppConstants.curveSmooth)),
            ),
            child: child,
          );
        },
        transitionDuration: AppConstants.animationMedium,
      ),
    );
  }

  /// 导航到个性化页面
  void _navigateToPersonalization() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PersonalizationPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: AppConstants.curveSmooth)),
            ),
            child: child,
          );
        },
        transitionDuration: AppConstants.animationMedium,
      ),
    );
  }

  // ===== 🎯 交易处理方法 =====
  
  /// 处理交易提交
  void _handleTransactionSubmit(TransactionRecord transaction) {
    // 交易提交逻辑
    setState(() {
      _isInputMode = false;
      _inputType = null;
    });
  }

  /// 处理交易取消
  void _handleTransactionCancel() {
    setState(() {
      _isInputMode = false;
      _inputType = null;
    });
  }
}