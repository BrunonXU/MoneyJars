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
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import '../utils/responsive_layout.dart';
import '../screens/home_screen_content.dart';

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
      body: ResponsiveLayout.responsive(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  // 移动端布局 - 原始的垂直滑动体验
  Widget _buildMobileLayout() {
    final layout = ResponsiveLayout.getMainContainerLayout(context);
    
    return Container(
      width: layout['width'],
      height: layout['height'],
      margin: layout['margin'] ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        border: layout['showBorder'] ? Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1.w,
        ) : null,
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
            _buildAppBar(),
            Expanded(
              child: Stack(
                children: [
                  _buildBackground(),
                  _buildMobileContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 平板端布局 - 水平显示多个罐头
  Widget _buildTabletLayout() {
    final layout = ResponsiveLayout.getMainContainerLayout(context);
    
    return Center(
      child: Container(
        width: layout['width'],
        height: layout['height'],
        margin: layout['margin'] ?? EdgeInsets.zero,
        padding: layout['padding'] ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          border: layout['showBorder'] ? Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1.w,
          ) : null,
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
              _buildAppBar(),
              Expanded(
                child: Stack(
                  children: [
                    _buildBackground(),
                    _buildTabletContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 桌面端布局 - 网格显示所有罐头
  Widget _buildDesktopLayout() {
    final layout = ResponsiveLayout.getMainContainerLayout(context);
    
    return Center(
      child: Container(
        width: layout['width'],
        height: layout['height'],
        margin: layout['margin'] ?? EdgeInsets.zero,
        padding: layout['padding'] ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          border: layout['showBorder'] ? Border.all(
            color: Colors.grey.withOpacity(0.3),
            width: 1.w,
          ) : null,
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
              _buildAppBar(),
              Expanded(
                child: Stack(
                  children: [
                    _buildBackground(),
                    _buildDesktopContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 移动端内容 - 原始的PageView体验
  Widget _buildMobileContent() {
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
          padding: EdgeInsets.only(top: AppConstants.spacingSmall.h),
          child: Row(
            children: [
              // 左侧设置按钮
              Padding(
                padding: EdgeInsets.only(left: AppConstants.spacingMedium.w),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(AppConstants.spacingSmall.w),
                    decoration: BoxDecoration(
                      color: AppConstants.backgroundColor,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      boxShadow: AppConstants.shadowSmall,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      child: Image.asset(
                        'assets/images/icons-1.png',
                        width: AppConstants.iconMedium.w,
                        height: AppConstants.iconMedium.h,
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
                        width: (AppConstants.iconXLarge + 4).w,
                        height: (AppConstants.iconXLarge + 4).h,
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          boxShadow: AppConstants.shadowMedium,
                        ),
                        child: Icon(
                          Icons.savings,
                          size: AppConstants.iconMedium.sp,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: AppConstants.spacingMedium.w),
                    Text(
                      'MoneyJars',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                        fontSize: AppConstants.fontSizeXLarge.sp,
                      ),
                    ),
                  ],
                ),
              ),
              // 右侧占位，保持平衡
              SizedBox(width: 60.w),
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
            physics: const BouncingScrollPhysics(), // 更丝滑的物理效果
            allowImplicitScrolling: true, // 允许隐式滚动，更连续
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
        
        // ===== 左侧导航栏 - 贴墙放置，大15%，只留小白边 =====
        Positioned(
          left: 2.w, // 几乎贴墙，只留小白边
          top: 230.h,
          child: Container(
            width: 48.w, // 原42w增大15%: 42 * 1.15 = 48
            padding: EdgeInsets.symmetric(vertical: 16.h), // 增大15%: 14 * 1.15 = 16
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r), // 增大15%: 21 * 1.15 = 24
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8.r, // 增大15%: 7 * 1.15 = 8
                  offset: Offset(0, 1.6.h), // 增大15%: 1.4 * 1.15 = 1.6
                ),
              ],
            ),
            child: _buildLeftNavBar(),
          ),
        ),
        
        // ===== 右侧导航栏 - 贴墙放置，大15%，只留小白边 =====
        Positioned(
          right: 2.w, // 几乎贴墙，只留小白边
          top: 230.h,
          child: Container(
            width: 48.w, // 原42w增大15%: 42 * 1.15 = 48
            padding: EdgeInsets.symmetric(vertical: 16.h), // 增大15%: 14 * 1.15 = 16
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r), // 增大15%: 21 * 1.15 = 24
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8.r, // 增大15%: 7 * 1.15 = 8
                  offset: Offset(0, 1.6.h), // 增大15%: 1.4 * 1.15 = 1.6
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
        SizedBox(height: 15.h),
        _buildLeftNavIcon(Icons.help_outline),
        SizedBox(height: 15.h),
        _buildLeftNavIcon(Icons.bar_chart),
        SizedBox(height: 15.h),
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
        width: 28.w, // 增大15%: 24 * 1.15 = 28
        height: 28.h, // 增大15%: 24 * 1.15 = 28
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(7.r), // 增大15%: 6 * 1.15 = 7
        ),
        child: Icon(
          icon,
          color: Colors.grey[600],
          size: 18.sp, // 增大15%: 16 * 1.15 = 18
        ),
      ),
    );
  }

  // ===== 右侧导航栏样式控制 =====
  Widget _buildPageIndicators() {
    return Column(
      children: [
        _buildPageIndicator(0, AppConstants.labelExpense),
        SizedBox(height: 15.h),
        _buildPageIndicator(1, AppConstants.labelComprehensive),
        SizedBox(height: 15.h),
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
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: isActive 
                  ? AppConstants.primaryColor 
                  : Colors.grey.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 2.h),
          // 白色字体
          Text(
            label,
            style: TextStyle(
              color: isActive 
                  ? AppConstants.primaryColor 
                  : Colors.grey.withOpacity(0.7),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 8.sp,
            ),
          ),
        ],
      ),
    );
  }
  
  // 平板端内容 - 水平显示多个罐头
  Widget _buildTabletContent() {
    return buildTabletContent();
  }
  
  // 桌面端内容 - 网格显示所有罐头
  Widget _buildDesktopContent() {
    return buildDesktopContent();
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

  // ===== 浮动提示样式控制 - 宽度小70%，往下10% =====
  Widget _buildSwipeHint(TransactionType type, Color color) {
    final isExpense = type == TransactionType.expense;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge.w),
      child: AnimatedBuilder(
        animation: _swipeHintAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _swipeHintAnimation.value * 0.8,
            child: Transform.translate(
              offset: Offset(0, 30.h), // 往下10%移动
              child: Transform.scale(
                scale: 0.9 + (_swipeHintAnimation.value * 0.1),
                child: Center(
                  child: Container(
                    width: 150.w, // 宽度小70%: 原来约500w -> 150w
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingSmall.w, // 进一步减小padding
                      vertical: AppConstants.spacingXSmall.h,    // 进一步减小padding
                    ),
                decoration: BoxDecoration(
                  color: AppConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge.r), // 减小圆角
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), // 减少阴影
                      blurRadius: 5.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppConstants.spacingXSmall.w), // 减小padding
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpense ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                        color: color,
                        size: AppConstants.iconSmall.sp, // 减小图标大小
                      ),
                    ),
                    SizedBox(width: AppConstants.spacingXSmall.w), // 进一步减小间距
                    Text(
                      isExpense ? AppConstants.hintSwipeDown : AppConstants.hintSwipeUp,
                      style: AppConstants.captionStyle.copyWith( // 使用更小的字体样式
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp, // 进一步减小字体大小
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
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double page = 1.0; // 默认页面（综合页面）
        
        if (_pageController.hasClients && _pageController.page != null) {
          page = _pageController.page!;
        }
        
        // 根据页面滑动进度动态计算背景
        String backgroundImage;
        double opacity = 1.0;
        
        if (page <= 0.5) {
          // 在支出页面和综合页面之间
          backgroundImage = 'assets/images/green_knitted_jar.png';
          if (page > 0) {
            opacity = 1.0 - (page * 2); // 逐渐淡出
          }
        } else if (page <= 1.5) {
          // 在综合页面和收入页面之间
          backgroundImage = 'assets/images/festive_piggy_bank.png';
          if (page < 1) {
            opacity = page * 2; // 逐渐淡入
          } else {
            opacity = 2.0 - page; // 逐渐淡出
          }
        } else {
          // 在收入页面
          backgroundImage = 'assets/images/red_knitted_jar.png';
          opacity = (page - 1.0) * 2;
          if (opacity > 1.0) opacity = 1.0;
        }
        
        return Stack(
          children: [
            // 当前背景
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundImage),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
            
            // 如果在页面之间，显示渐变效果
            if (page > 0.5 && page < 1.0) 
              Opacity(
                opacity: (page - 0.5) * 2,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/festive_piggy_bank.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            
            if (page > 1.0 && page < 1.5) 
              Opacity(
                opacity: (page - 1.0) * 2,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/red_knitted_jar.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
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