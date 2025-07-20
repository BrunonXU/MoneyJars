/*
 * 罐头页面视图组件 (jar_page_view.dart)
 * 
 * 功能说明：
 * - 管理三个罐头页面的切换
 * - 处理页面滑动和导航
 * - 支持手势操作和动画效果
 * 
 * 设计特点：
 * - 使用PageView实现平滑切换
 * - 支持指示器和动画效果
 * - 响应式布局适配
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/domain/entities/jar_settings.dart';
import '../../../core/domain/entities/transaction.dart';
import '../../providers/transaction_provider_new.dart';
import '../../providers/settings_provider.dart';
import 'jar_card_widget.dart';

/// 罐头页面视图组件
/// 
/// 展示三个罐头（收入、支出、综合）的滑动页面
class JarPageView extends StatefulWidget {
  /// 页面控制器
  final PageController? pageController;
  
  /// 初始页面索引
  final int initialPage;
  
  /// 页面切换回调
  final ValueChanged<int>? onPageChanged;
  
  /// 是否显示页面指示器
  final bool showIndicator;
  
  /// 是否启用滑动切换
  final bool enableSwipe;
  
  const JarPageView({
    Key? key,
    this.pageController,
    this.initialPage = 0,
    this.onPageChanged,
    this.showIndicator = true,
    this.enableSwipe = true,
  }) : super(key: key);
  
  @override
  State<JarPageView> createState() => _JarPageViewState();
}

class _JarPageViewState extends State<JarPageView> {
  late PageController _pageController;
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _pageController = widget.pageController ?? 
        PageController(initialPage: widget.initialPage);
    _currentPage = widget.initialPage;
  }
  
  @override
  void dispose() {
    // 只释放自己创建的控制器
    if (widget.pageController == null) {
      _pageController.dispose();
    }
    super.dispose();
  }
  
  /// 处理页面切换
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    widget.onPageChanged?.call(page);
  }
  
  /// 获取罐头类型
  JarType _getJarType(int index) {
    switch (index) {
      case 0:
        return JarType.income;
      case 1:
        return JarType.expense;
      case 2:
        return JarType.comprehensive;
      default:
        return JarType.income;
    }
  }
  
  /// 计算罐头当前金额
  double _calculateJarAmount(JarType jarType, List<Transaction> transactions) {
    switch (jarType) {
      case JarType.income:
        return transactions
            .where((tx) => tx.type == TransactionType.income)
            .fold(0.0, (sum, tx) => sum + tx.amount);
            
      case JarType.expense:
        return transactions
            .where((tx) => tx.type == TransactionType.expense)
            .fold(0.0, (sum, tx) => sum + tx.amount);
            
      case JarType.comprehensive:
        final income = transactions
            .where((tx) => tx.type == TransactionType.income)
            .fold(0.0, (sum, tx) => sum + tx.amount);
        final expense = transactions
            .where((tx) => tx.type == TransactionType.expense)
            .fold(0.0, (sum, tx) => sum + tx.amount);
        return income - expense; // 净收入
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProviderNew, SettingsProvider>(
      builder: (context, transactionProvider, settingsProvider, child) {
        final transactions = transactionProvider.allTransactions;
        
        return Column(
          children: [
            // 罐头页面
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: widget.enableSwipe 
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  final jarType = _getJarType(index);
                  final jarSettings = settingsProvider.jarSettings[jarType];
                  final currentAmount = _calculateJarAmount(jarType, transactions);
                  
                  if (jarSettings == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: JarCardWidget(
                      jarType: jarType,
                      jarSettings: jarSettings,
                      currentAmount: currentAmount,
                      onTap: () => _handleJarTap(jarType),
                      onSettingsTap: () => _handleSettingsTap(jarType),
                    ),
                  );
                },
              ),
            ),
            
            // 页面指示器
            if (widget.showIndicator)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 8.0,
                      width: _currentPage == index ? 24.0 : 8.0,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    );
                  }),
                ),
              ),
          ],
        );
      },
    );
  }
  
  /// 处理罐头点击
  void _handleJarTap(JarType jarType) {
    // TODO: 导航到罐头详情页
    debugPrint('点击罐头: $jarType');
  }
  
  /// 处理设置按钮点击
  void _handleSettingsTap(JarType jarType) {
    // TODO: 打开罐头设置对话框
    debugPrint('打开设置: $jarType');
  }
  
  /// 切换到指定页面
  void animateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}