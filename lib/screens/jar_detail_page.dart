/*
 * 罐头详情页面 (jar_detail_page.dart)
 * 
 * 功能说明：
 * - 显示收入/支出/综合罐头的详细统计信息
 * - 展示金额卡片和分类统计列表
 * - 支持按分类查看交易记录
 * 
 * 相关修改位置：
 * - 从 home_screen.dart 中拆分出来的详情页面功能
 * - 布局位置调整：优化页面布局和间距
 */

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/transaction_record.dart';
import '../providers/transaction_provider.dart';
import '../widgets/common/error_widget.dart';

class JarDetailPage extends StatelessWidget {
  final TransactionType type;
  final TransactionProvider provider;
  final bool isComprehensive;

  const JarDetailPage({
    Key? key,
    required this.type,
    required this.provider,
    required this.isComprehensive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          isComprehensive 
              ? '综合统计' 
              : (type == TransactionType.income ? '收入详情' : '支出详情'),
          style: AppConstants.titleStyle.copyWith(
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppConstants.primaryGradient,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppConstants.backgroundGradient,
          ),
        ),
        child: _buildBodyContent(context),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: kToolbarHeight + MediaQuery.of(context).padding.top,
        left: AppConstants.spacingLarge,
        right: AppConstants.spacingLarge,
        bottom: AppConstants.spacingLarge,
      ),
      child: Column(
        children: [
          _buildAmountCard(),
          const SizedBox(height: AppConstants.spacingLarge),
          Expanded(child: _buildCategoryStats()),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    final amount = isComprehensive 
        ? provider.netIncome 
        : (type == TransactionType.income ? provider.totalIncome : provider.totalExpense);
    
    final color = isComprehensive 
        ? (provider.netIncome >= 0 ? AppConstants.comprehensivePositiveColor : AppConstants.comprehensiveNegativeColor)
        : (type == TransactionType.income ? AppConstants.incomeColor : AppConstants.expenseColor);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppConstants.cardGradient,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: AppConstants.shadowLarge,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            isComprehensive ? AppConstants.labelNetIncome : 
            (type == TransactionType.income ? '总收入' : '总支出'),
            style: AppConstants.bodyStyle.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            '¥${amount.toStringAsFixed(2)}',
            style: AppConstants.headingStyle.copyWith(
              color: color,
              fontSize: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats() {
    final stats = isComprehensive 
        ? {...provider.getCategoryStats(TransactionType.income), ...provider.getCategoryStats(TransactionType.expense)}
        : provider.getCategoryStats(type);
    
    if (stats.isEmpty) {
      return EmptyStateWidget(
        message: AppConstants.hintNoData,
        description: '开始记录您的第一笔交易吧！',
        icon: Icons.account_balance_wallet_outlined,
      );
    }
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: AppConstants.shadowMedium,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: Text(
              isComprehensive ? '分类统计' : '${type == TransactionType.income ? '收入' : '支出'}分类',
              style: AppConstants.titleStyle.copyWith(
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLarge,
                vertical: AppConstants.spacingMedium,
              ),
              itemCount: stats.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppConstants.spacingMedium),
              itemBuilder: (context, index) {
                final category = stats.keys.elementAt(index);
                final amount = stats[category]!;
                final total = stats.values.reduce((a, b) => a + b);
                final percentage = (amount / total * 100).toInt();
                
                return _buildCategoryItem(category, amount, percentage);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, double amount, int percentage) {
    final color = AppConstants.categoryColors[category.hashCode % AppConstants.categoryColors.length];
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMedium),
          Expanded(
            child: Text(
              category,
              style: AppConstants.bodyStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '¥${amount.toStringAsFixed(2)}',
                style: AppConstants.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$percentage%',
                style: AppConstants.captionStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 