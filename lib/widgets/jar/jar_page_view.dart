import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/transaction_provider.dart';
import 'jar_page_widget.dart';

/// 🍯 罐头页面视图组件
/// 
/// 这个组件负责管理MoneyJars应用的三罐头页面视图，包括：
/// - 垂直滑动的PageView管理
/// - 三个罐头页面的组织和展示
/// - 滑动物理效果和交互体验
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
/// - 数据驱动的页面内容
class JarPageView extends StatelessWidget {
  /// 页面控制器
  final PageController pageController;

  const JarPageView({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return _buildPageView(provider);
      },
    );
  }

  /// 🎨 构建页面视图
  /// 
  /// 创建包含三个罐头页面的垂直滑动视图
  Widget _buildPageView(TransactionProvider provider) {
    return PageView(
      controller: pageController, // 页面控制器：管理滑动状态
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