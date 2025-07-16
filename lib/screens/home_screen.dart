/*
 * 主屏幕界面 (home_screen.dart)
 * 
 * 功能说明：
 * - 三罐头主界面显示：收入、支出、综合罐头
 * - 垂直PageView切换和页面指示器
 * - 集成手势处理和交易输入功能
 * 
 * 相关修改位置：
 * - 修改1：滑动手感问题 - 使用GestureHandler处理滑动手势 (第85-125行区域)
 * - 修改2：布局位置调整 - MoneyJars图标位置优化 (第224行区域)
 * - 修改2：布局位置调整 - 滑动提示位置调整 (第434行区域)
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_record.dart';
import '../widgets/money_jar_widget.dart';
import '../widgets/enhanced_transaction_input.dart';
import '../widgets/jar_settings_dialog.dart';
import '../widgets/gesture_handler.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/common/error_widget.dart';
import '../screens/jar_detail_page.dart';
import '../constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late AnimationController _swipeHintController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _swipeHintAnimation;
  
  int _currentPage = 1; // 默认显示综合罐头
  bool _isInputMode = false;
  TransactionType? _inputType;
  bool _isLoading = false;
  String? _errorMessage;
  
  // 修改1：滑动手感问题 - 使用独立的手势处理器
  late GestureHandler _gestureHandler;

  @override
  void initState() {
    super.initState();
    _gestureHandler = GestureHandler();
    _initializeControllers();
    _startAnimations();
  }

  void _initializeControllers() {
    _pageController = PageController(initialPage: _currentPage);
    
    _fadeController = AnimationController(
      duration: AppConstants.animationMedium,
      vsync: this,
    );
    
    _swipeHintController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: AppConstants.curveDefault),
    );
    
    _swipeHintAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _swipeHintController, curve: AppConstants.curveDefault),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _swipeHintController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _swipeHintController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    if (_currentPage != page) {
      setState(() {
        _currentPage = page;
        _isInputMode = false;
        _inputType = null;
      });
      HapticFeedback.selectionClick();
    }
  }

  // 修改1：滑动手感问题 - 使用手势处理器的回调方法
  void _onExpenseSwipe() {
    _enterInputMode(TransactionType.expense);
    GestureHandler.provideLightFeedback();
  }

  void _onIncomeSwipe() {
    _enterInputMode(TransactionType.income);
    GestureHandler.provideLightFeedback();
  }

  void _enterInputMode(TransactionType type) {
    HapticFeedback.lightImpact();
    setState(() {
      _isInputMode = true;
      _inputType = type;
    });
  }

  void _exitInputMode() {
    setState(() {
      _isInputMode = false;
      _inputType = null;
    });
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => const JarSettingsDialog(),
    );
  }

  void _showDetailPage(TransactionType type, TransactionProvider provider, bool isComprehensive) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => JarDetailPage(
          type: type,
          provider: provider,
          isComprehensive: isComprehensive,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
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
      backgroundColor: Colors.grey[100], // 设置外部背景色
      body: Center(
        child: Container(
          // ===== 强制手机尺寸显示 =====
          // 在Web端固定显示手机尺寸，模拟手机屏幕效果
          width: 375, // iPhone标准宽度
          height: 812, // iPhone标准高度
          margin: const EdgeInsets.symmetric(vertical: 20), // 上下留白
          constraints: const BoxConstraints(
            maxWidth: 375,
            maxHeight: 812,
          ),
          decoration: BoxDecoration(
            // 添加手机边框效果
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            color: Colors.white, // 手机屏幕背景色
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                // AppBar区域 - 包含在手机尺寸内
                _buildAppBar(),
                // 主要内容区域
                Expanded(
                  child: Stack(
                    children: [
                      _buildBackground(),  // 使用新的背景
                      _buildBodyContent(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (_isLoading) {
          return const LoadingWidget(message: '加载中...');
        }

        if (_errorMessage != null) {
          return AppErrorWidget(
            message: _errorMessage!,
            onRetry: () {
              setState(() {
                _errorMessage = null;
                _isLoading = true;
              });
              _loadData(provider);
            },
          );
        }

        return _buildContent(provider);
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: AppConstants.appBarHeight + 6,
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        boxShadow: AppConstants.shadowMedium,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppConstants.spacingSmall),
          child: Row(
            children: [
              // 左侧设置按钮
              Padding(
                padding: const EdgeInsets.only(left: AppConstants.spacingMedium),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(AppConstants.spacingSmall),
                    decoration: BoxDecoration(
                      color: AppConstants.backgroundColor,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      boxShadow: AppConstants.shadowSmall,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      child: Image.asset(
                        'assets/images/icons-1.png',
                        width: AppConstants.iconMedium,
                        height: AppConstants.iconMedium,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  onPressed: _showSettings,
                  tooltip: AppConstants.buttonSettings,
                ),
              ),
              // 中间标题
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'app_icon',
                      child: Container(
                        width: AppConstants.iconXLarge + 4,
                        height: AppConstants.iconXLarge + 4,
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          boxShadow: AppConstants.shadowMedium,
                        ),
                        child: Icon(
                          Icons.savings,
                          size: AppConstants.iconMedium,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Text(
                      'MoneyJars',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                        fontSize: AppConstants.fontSizeXLarge,
                      ),
                    ),
                  ],
                ),
              ),
              // 右侧占位，保持平衡
              const SizedBox(width: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TransactionProvider provider) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    
    return Stack(
      children: [
        // 主要内容区域 - 更大的空间分配给罐头
        Positioned(
          top: 5, // 减少顶部间距
          left: isSmallScreen ? 60 : 50, // 小屏幕时为导航栏预留更多空间
          right: isSmallScreen ? 60 : 50, // 小屏幕时为页面指示器预留更多空间
          bottom: 0,
          child: PageView(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            physics: const ClampingScrollPhysics(),
            children: [
              _buildJarPage(
                title: '${AppConstants.labelExpense}罐头',
                type: TransactionType.expense,
                currentAmount: provider.totalExpense,
                targetAmount: provider.jarSettings.targetAmount,
                color: AppConstants.expenseColor,
                provider: provider,
              ),
              _buildJarPage(
                title: provider.jarSettings.title,
                type: TransactionType.income,
                currentAmount: provider.netIncome,
                targetAmount: provider.jarSettings.targetAmount,
                color: provider.netIncome >= 0 
                    ? AppConstants.comprehensivePositiveColor 
                    : AppConstants.comprehensiveNegativeColor,
                provider: provider,
                isComprehensive: true,
              ),
              _buildJarPage(
                title: '${AppConstants.labelIncome}罐头',
                type: TransactionType.income,
                currentAmount: provider.totalIncome,
                targetAmount: provider.jarSettings.targetAmount,
                color: AppConstants.incomeColor,
                provider: provider,
              ),
            ],
          ),
        ),
        
        // ===== 左侧导航栏 - 与右侧同高对齐，缩小30% =====
        Positioned(
          left: 5, // 调整位置，更贴近屏幕边缘
          top: 230, // 稍微上移，适应更紧凑的布局
          child: Container(
            width: 42, // 与右侧导航栏宽度一致，缩小30%
            padding: const EdgeInsets.symmetric(vertical: 14), // 与右侧一致的padding，缩小30%
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(21), // 缩小30%
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 7, // 缩小30%
                  offset: const Offset(0, 1.4), // 缩小30%
                ),
              ],
            ),
            child: _buildLeftNavBar(),
          ),
        ),
        
        // ===== 右侧导航栏 - 白色字体和圆点，缩小30% =====
        Positioned(
          right: 5, // 调整位置，更贴近屏幕边缘
          top: 230, // 稍微上移，适应更紧凑的布局
          child: Container(
            width: 42, // 缩小30%：60 * 0.7 = 42
            padding: const EdgeInsets.symmetric(vertical: 14), // 缩小30%：20 * 0.7 = 14
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(21), // 缩小30%：30 * 0.7 = 21
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 7, // 缩小30%：10 * 0.7 = 7
                  offset: const Offset(0, 1.4), // 缩小30%：2 * 0.7 = 1.4
                ),
              ],
            ),
            child: _buildPageIndicators(),
          ),
        ),
        
        // 输入模式覆盖层
        if (_isInputMode && _inputType != null)
          EnhancedTransactionInput(
            type: _inputType!,
            onComplete: _exitInputMode,
            onCancel: _exitInputMode,
          ),
      ],
    );
  }

  // ===== 左侧导航栏样式控制 =====
  Widget _buildLeftNavBar() {
    return Column(
      children: [
        _buildLeftNavIcon(Icons.settings),
        const SizedBox(height: 15),
        _buildLeftNavIcon(Icons.help_outline),
        const SizedBox(height: 15),
        _buildLeftNavIcon(Icons.bar_chart),
        const SizedBox(height: 15),
        _buildLeftNavIcon(Icons.more_horiz),
      ],
    );
  }

  Widget _buildLeftNavIcon(IconData icon) {
    return GestureDetector(
      onTap: () {
        // 暂时没有功能，后续添加
      },
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: Colors.grey[600],
          size: 16,
        ),
      ),
    );
  }

  // ===== 右侧导航栏样式控制 =====
  Widget _buildPageIndicators() {
    return Column(
      children: [
        _buildPageIndicator(0, AppConstants.labelExpense),
        const SizedBox(height: 15),
        _buildPageIndicator(1, AppConstants.labelComprehensive),
        const SizedBox(height: 15),
        _buildPageIndicator(2, AppConstants.labelIncome),
      ],
    );
  }

  Widget _buildPageIndicator(int index, String label) {
    final isActive = _currentPage == index;
    return Container(
      child: Column(
        children: [
          // 白色圆点
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive 
                  ? AppConstants.primaryColor 
                  : Colors.grey.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 2),
          // 白色字体
          Text(
            label,
            style: TextStyle(
              color: isActive 
                  ? AppConstants.primaryColor 
                  : Colors.grey.withOpacity(0.7),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJarPage({
    required String title,
    required TransactionType type,
    required double currentAmount,
    required double targetAmount,
    required Color color,
    required TransactionProvider provider,
    bool isComprehensive = false,
  }) {
    return SwipeDetector(
      gestureHandler: _gestureHandler,
      isInputMode: _isInputMode,
      currentPage: _currentPage,
      onExpenseSwipe: _onExpenseSwipe,
      onIncomeSwipe: _onIncomeSwipe,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 罐头组件居中显示，占用更多空间
              Expanded(
                flex: 8,
                child: Center(
                  child: MoneyJarWidget(
                    amount: currentAmount,
                    type: type,
                    title: title,
                    onTap: () => _showDetailPage(type, provider, isComprehensive),
                    onSettings: null,
                  ),
                ),
              ),
              
              // 滑动提示移到底部，给罐头让出更多空间
              if (!isComprehensive) 
                Expanded(
                  flex: 2,
                  child: _buildSwipeHint(type, color),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== 浮动提示样式控制 - 缩小一半大小 =====
  Widget _buildSwipeHint(TransactionType type, Color color) {
    final isExpense = type == TransactionType.expense;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
      child: AnimatedBuilder(
        animation: _swipeHintAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _swipeHintAnimation.value * 0.8,
            child: Transform.scale(
              scale: 0.9 + (_swipeHintAnimation.value * 0.1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMedium, // 减小padding
                  vertical: AppConstants.spacingSmall,    // 减小padding
                ),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge), // 减小圆角
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), // 减少阴影
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingXSmall), // 减小padding
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpense ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        color: color,
                        size: AppConstants.iconSmall, // 减小图标大小
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingSmall), // 减小间距
                    Text(
                      isExpense ? AppConstants.hintSwipeDown : AppConstants.hintSwipeUp,
                      style: AppConstants.captionStyle.copyWith( // 使用更小的字体样式
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: AppConstants.fontSizeSmall, // 减小字体大小
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _loadData(TransactionProvider provider) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      await provider.initializeData();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppConstants.errorInitialization;
        });
      }
    }
  }

  // ===== 背景图片控制系统 =====
  // 根据当前页面返回对应的背景图片
  // 0: 支出页面 - 绿色针织背景
  // 1: 综合页面 - 小猪背景  
  // 2: 收入页面 - 红色针织背景
  Widget _buildBackground() {
    String backgroundImage;
    switch (_currentPage) {
      case 0: // 支出页面
        backgroundImage = 'assets/images/green_knitted_jar.png';
        break;
      case 1: // 综合页面
        backgroundImage = 'assets/images/festive_piggy_bank.png';
        break;
      case 2: // 收入页面
        backgroundImage = 'assets/images/red_knitted_jar.png';
        break;
      default:
        backgroundImage = 'assets/images/festive_piggy_bank.png';
    }
    
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.contain, // 保持图片完整显示，不拉伸变形
                alignment: Alignment.bottomCenter, // 图片贴合底部
              ),
            ),
          );
        },
      ),
    );
  }
}