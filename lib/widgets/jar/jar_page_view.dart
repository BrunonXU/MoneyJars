import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_record_hive.dart';
import '../gesture_handler.dart';
import 'jar_page_widget.dart';

/// 🍯 罐头页面视图组件
/// 
/// 这个组件负责管理MoneyJars应用的三罐头页面视图，包括：
/// - 垂直滑动的PageView管理
/// - 三个罐头页面的组织和展示
/// - 滑动物理效果和交互体验
/// - 手势检测和输入模式触发
/// 
/// 页面结构：
/// - 第0页：支出罐头页面
/// - 第1页：综合罐头页面（默认显示）
/// - 第2页：收入罐头页面
/// 
/// 设计特点：
/// - 垂直滑动方向
/// - iOS风格弹性滚动
/// - 隐式滚动支持
/// - 整页面手势检测
/// - 数据驱动的页面内容
class JarPageView extends StatefulWidget {
  /// 页面控制器
  final PageController pageController;
  
  /// 手势检测回调
  final VoidCallback? onExpenseSwipe;
  final VoidCallback? onIncomeSwipe;
  
  /// 输入模式状态
  final bool isInputMode;

  const JarPageView({
    Key? key,
    required this.pageController,
    this.onExpenseSwipe,
    this.onIncomeSwipe,
    this.isInputMode = false,
  }) : super(key: key);

  @override
  State<JarPageView> createState() => _JarPageViewState();
}

class _JarPageViewState extends State<JarPageView> {
  late GestureHandler _gestureHandler;
  int _currentPage = 1; // 默认在综合页面
  
  @override
  void initState() {
    super.initState();
    _gestureHandler = GestureHandler();
    
    // 监听页面变化
    widget.pageController.addListener(() {
      if (widget.pageController.hasClients) {
        final newPage = widget.pageController.page?.round() ?? 1;
        if (newPage != _currentPage) {
          setState(() {
            _currentPage = newPage;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return _buildPageViewWithGestures(provider);
      },
    );
  }

  /// 🎨 构建包含手势检测的页面视图
  /// 
  /// 创建包含三个罐头页面的垂直滑动视图，带有全页面手势检测
  Widget _buildPageViewWithGestures(TransactionProvider provider) {
    return Stack(
      children: [
        // 底层：PageView负责页面滑动
        PageView(
          controller: widget.pageController, // 页面控制器：管理滑动状态
          scrollDirection: Axis.vertical, // 滑动方向：垂直滑动
          physics: const BouncingScrollPhysics(), // 物理效果：iOS风格弹性滚动
          allowImplicitScrolling: true, // 隐式滚动：连续滚动体验
          children: [
            // 🍯 支出罐头页面 (index: 0)：绿色针织背景 + 红色主题 + 向下滑动提示
            JarPageFactory.createExpensePage(provider: provider),
            
            // 🍯 综合统计罐头页面 (index: 1, 默认页面)：小猪背景 + 动态主题色 + 无滑动提示
            JarPageFactory.createComprehensivePage(provider: provider),
            
            // 🍯 收入罐头页面 (index: 2)：红色针织背景 + 绿色主题 + 向上滑动提示
            JarPageFactory.createIncomePage(provider: provider),
          ],
        ),
        
        // 顶层：全屏手势检测器，确保任何位置都能触发记录
        Positioned.fill(
          child: SwipeDetector(
            gestureHandler: _gestureHandler,
            isInputMode: widget.isInputMode,
            currentPage: _currentPage,
            onExpenseSwipe: widget.onExpenseSwipe,
            onIncomeSwipe: widget.onIncomeSwipe,
            child: Container(
              color: Colors.transparent, // 透明容器，只捕获手势
            ),
          ),
        ),
      ],
    );
  }
}

/// 🎯 罐头页面视图管理器
/// 
/// 提供页面视图的管理和控制功能
class JarPageViewManager {
  /// 页面控制器
  final PageController _pageController;

  JarPageViewManager({
    int initialPage = 1, // 默认显示综合页面
  }) : _pageController = PageController(
          initialPage: initialPage,
          keepPage: true, // 保持页面状态
        );

  /// 获取页面控制器
  PageController get pageController => _pageController;

  /// 动画切换到指定页面
  Future<void> animateToPage(int page) async {
    await _pageController.animateToPage(
      page,
      duration: AppConstants.animationMedium, // 中等动画时长
      curve: AppConstants.curveSmooth, // 平滑曲线
    );
  }

  /// 跳转到指定页面（无动画）
  void jumpToPage(int page) {
    _pageController.jumpToPage(page);
  }

  /// 跳转到支出页面
  Future<void> goToExpensePage() async {
    await animateToPage(0);
  }

  /// 跳转到综合页面
  Future<void> goToComprehensivePage() async {
    await animateToPage(1);
  }

  /// 跳转到收入页面
  Future<void> goToIncomePage() async {
    await animateToPage(2);
  }

  /// 获取当前页面索引
  int? get currentPage {
    if (_pageController.hasClients) {
      return _pageController.page?.round();
    }
    return null;
  }

  /// 释放资源
  void dispose() {
    _pageController.dispose();
  }
}