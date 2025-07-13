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
      backgroundColor: AppConstants.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Consumer<TransactionProvider>(
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
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(AppConstants.appBarHeight + 6), // 增加高度
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: AppConstants.spacingSmall), // 向上调整
            child: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: AppConstants.spacingMedium),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(AppConstants.spacingSmall),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: AppConstants.primaryColor,
                      size: AppConstants.iconMedium,
                    ),
                  ),
                  onPressed: _showSettings,
                  tooltip: AppConstants.buttonSettings,
                ),
              ),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'app_icon',
                    child: Container(
                      width: AppConstants.iconXLarge + 4,
                      height: AppConstants.iconXLarge + 4,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.savings,
                        size: AppConstants.iconMedium,
                        color: AppConstants.cardColor,
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
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(TransactionProvider provider) {
    return Stack(
      children: [
        // 主要内容 - 垂直方向的PageView
        PageView(
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
        
        // 页面指示器
        Positioned(
          right: AppConstants.spacingLarge,
          top: MediaQuery.of(context).size.height / 2 - 50,
          child: _buildPageIndicators(),
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

  Widget _buildPageIndicators() {
    return Column(
      children: [
        _buildPageIndicator(0, AppConstants.labelExpense),
        const SizedBox(height: AppConstants.pageIndicatorSpacing),
        _buildPageIndicator(1, AppConstants.labelComprehensive),
        const SizedBox(height: AppConstants.pageIndicatorSpacing),
        _buildPageIndicator(2, AppConstants.labelIncome),
      ],
    );
  }

  Widget _buildPageIndicator(int index, String label) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: AppConstants.animationFast,
      child: Column(
        children: [
          Container(
            width: AppConstants.pageIndicatorSize,
            height: AppConstants.pageIndicatorSize,
            decoration: BoxDecoration(
              color: isActive 
                  ? AppConstants.primaryColor 
                  : AppConstants.primaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: AppConstants.spacingXSmall),
          Text(
            label,
            style: AppConstants.captionStyle.copyWith(
              color: isActive 
                  ? AppConstants.primaryColor 
                  : AppConstants.primaryColor.withOpacity(0.5),
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
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
        padding: const EdgeInsets.only(top: AppConstants.appBarHeight),
        child: Stack(
          children: [
            MoneyJarWidget(
              currentAmount: currentAmount,
              targetAmount: targetAmount,
              color: color,
              type: type,
              title: title,
              isComprehensive: isComprehensive,
              onJarTap: () => _showDetailPage(type, provider, isComprehensive),
            ),
            
            // 滑动提示
            if (!isComprehensive) 
              _buildSwipeHint(type, color),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeHint(TransactionType type, Color color) {
    final isExpense = type == TransactionType.expense;
    
    return Positioned(
      bottom: isExpense ? 200 : 50,  // 支出罐头提示往下一点，避免重叠
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _swipeHintAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _swipeHintAnimation.value,
            child: Transform.scale(
              scale: 0.8 + (_swipeHintAnimation.value * 0.2),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingLarge),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withOpacity(0.5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      isExpense ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                      color: color,
                      size: AppConstants.iconLarge,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),
                                      Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingLarge,
                        vertical: AppConstants.spacingMedium,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                        border: Border.all(
                          color: color.withOpacity(0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        isExpense ? AppConstants.hintSwipeDown : AppConstants.hintSwipeUp,
                        style: AppConstants.bodyStyle.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
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
}