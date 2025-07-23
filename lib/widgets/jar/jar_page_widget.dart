import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/constants.dart';
import '../../models/transaction_record_hive.dart';
import '../../services/providers/transaction_provider.dart';
import '../jar/jar_widget.dart';
import '../hints/swipe_hint_widget.dart';

/// 🍯 罐头页面组件
/// 
/// 这个组件负责显示单个罐头页面，包括：
/// - 罐头主体显示（JarWidget）
/// - 滑动提示（SwipeHintWidget）
/// - 页面布局和定位
/// - 透明度效果应用
/// 
/// 支持的罐头类型：
/// - 支出罐头：显示支出总额和向下滑动提示
/// - 综合罐头：显示净收入，无滑动提示
/// - 收入罐头：显示收入总额和向上滑动提示
/// 
/// 设计特点：
/// - 支出/收入罐头下移30%对齐背景
/// - 所有罐头统一40%透明度
/// - 响应式布局适配
class JarPageWidget extends StatelessWidget {
  /// 罐头标题
  final String title;
  
  /// 交易类型
  final TransactionType type;
  
  /// 当前金额
  final double currentAmount;
  
  /// 目标金额
  final double targetAmount;
  
  /// 主题颜色
  final Color color;
  
  /// 数据提供者
  final TransactionProvider provider;
  
  /// 是否为支出/收入罐头（需要下移和显示滑动提示）
  final bool isExpenseOrIncome;
  
  /// 是否为综合罐头（不显示滑动提示）
  final bool isComprehensive;

  const JarPageWidget({
    Key? key,
    required this.title,
    required this.type,
    required this.currentAmount,
    required this.targetAmount,
    required this.color,
    required this.provider,
    this.isExpenseOrIncome = false,
    this.isComprehensive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 全宽布局
      height: double.infinity, // 全高布局
      child: Stack(
        children: [
          // 🍯 罐头主体：显示金额和进度
          _buildJarContainer(),
          
          // 💡 滑动提示：仅支出/收入罐头显示
          if (isExpenseOrIncome && !isComprehensive)
            _buildSwipeHint(context),
        ],
      ),
    );
  }

  /// 🍯 构建罐头容器
  /// 
  /// 包含罐头主体的定位和透明度效果
  Widget _buildJarContainer() {
    return Positioned(
      left: 0,
      right: 0,
      top: isExpenseOrIncome ? 30.h : 0, // 支出/收入罐头下移30%
      child: Opacity(
        opacity: 0.6, // 统一40%透明度 (1.0 - 0.4 = 0.6)
        child: _buildJarContent(),
      ),
    );
  }

  /// 🎨 构建罐头内容
  /// 
  /// 创建JarWidget实例并传入相关参数
  Widget _buildJarContent() {
    return JarWidget(
      title: title,
      type: type,
      amount: currentAmount,
    );
  }

  /// 💡 构建滑动提示
  /// 
  /// 根据交易类型显示不同的滑动提示
  Widget _buildSwipeHint(BuildContext context) {
    late Widget hintWidget;
    late double topPosition;
    
    if (type == TransactionType.expense) {
      // 支出页面：向下滑动提示
      hintWidget = SwipeHintFactory.createDownHint();
      topPosition = MediaQuery.of(context).size.height * 0.75; // 75%位置
    } else {
      // 收入页面：向上滑动提示
      hintWidget = SwipeHintFactory.createUpHint();
      topPosition = MediaQuery.of(context).size.height * 0.15; // 15%位置
    }
    
    return Positioned(
      left: 0,
      right: 0,
      top: topPosition,
      child: Align(
        alignment: Alignment.center, // 居中对齐
        child: hintWidget,
      ),
    );
  }
}

/// 🏭 罐头页面工厂类
/// 
/// 提供快速创建不同类型罐头页面的静态方法
class JarPageFactory {
  /// 创建支出罐头页面
  static JarPageWidget createExpensePage({
    required TransactionProvider provider,
  }) {
    return JarPageWidget(
      title: '${AppConstants.labelExpense}罐头',
      type: TransactionType.expense,
      currentAmount: provider.totalExpense,
      targetAmount: provider.jarSettings.targetAmount,
      color: AppConstants.expenseColor,
      provider: provider,
      isExpenseOrIncome: true,
    );
  }

  /// 创建综合罐头页面
  static JarPageWidget createComprehensivePage({
    required TransactionProvider provider,
  }) {
    return JarPageWidget(
      title: provider.jarSettings.title,
      type: TransactionType.income, // 用income类型显示
      currentAmount: provider.netIncome,
      targetAmount: provider.jarSettings.targetAmount,
      color: provider.netIncome >= 0
          ? AppConstants.comprehensivePositiveColor
          : AppConstants.comprehensiveNegativeColor,
      provider: provider,
      isComprehensive: true,
    );
  }

  /// 创建收入罐头页面
  static JarPageWidget createIncomePage({
    required TransactionProvider provider,
  }) {
    return JarPageWidget(
      title: '${AppConstants.labelIncome}罐头',
      type: TransactionType.income,
      currentAmount: provider.totalIncome,
      targetAmount: provider.jarSettings.targetAmount,
      color: AppConstants.incomeColor,
      provider: provider,
      isExpenseOrIncome: true,
    );
  }
}