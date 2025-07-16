/*
 * 罐头组件 (money_jar_widget.dart)
 * 
 * 功能说明：
 * - 绘制3D立体效果的金钱罐头
 * - 包含动态金币动画和进度显示
 * - 支持点击交互和触觉反馈
 * 
 * 相关修改位置：
 * - 修改2：布局位置调整 - 罐头标题位置优化 (第129行区域)
 * - 修改3：罐头点击动画 - 点击检测和弹性动画 (第268-327行区域)
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_record.dart';
import '../providers/transaction_provider.dart';
import '../constants/app_constants.dart';

class MoneyJarWidget extends StatefulWidget {
  final TransactionType type;
  final double amount;
  final String title;
  final VoidCallback? onTap;
  final VoidCallback? onSettings;

  const MoneyJarWidget({
    Key? key,
    required this.type,
    required this.amount,
    required this.title,
    this.onTap,
    this.onSettings,
  }) : super(key: key);

  @override
  State<MoneyJarWidget> createState() => _MoneyJarWidgetState();
}

class _MoneyJarWidgetState extends State<MoneyJarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getJarColor().withOpacity(0.1),
                  _getJarColor().withOpacity(0.05),
              ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图标
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getJarColor().withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getJarIcon(),
                    size: 30,
                    color: _getJarColor(),
                  ),
                ),
                const SizedBox(height: 12),
                
                // 标题
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getJarColor(),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
          ),
                const SizedBox(height: 8),
                
                // 金额
          Text(
                  '¥${widget.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
              fontWeight: FontWeight.bold,
                    color: _getJarColor(),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
        ),
                const SizedBox(height: 12),
                
                // 设置按钮
                if (widget.onSettings != null)
                  SizedBox(
                    width: 80,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: widget.onSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getJarColor(),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
            ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text(
                        '设置',
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                          ),
                      ),
                    ),
                  ],
            ),
            ),
          ),
      ),
    );
  }

  Color _getJarColor() {
    switch (widget.type) {
      case TransactionType.income:
        return AppConstants.incomeColor;
      case TransactionType.expense:
        return AppConstants.expenseColor;
      default:
        return widget.amount >= 0 
          ? AppConstants.comprehensivePositiveColor 
          : AppConstants.comprehensiveNegativeColor;
    }
  }

  IconData _getJarIcon() {
    switch (widget.type) {
      case TransactionType.income:
        return Icons.trending_up;
      case TransactionType.expense:
        return Icons.trending_down;
      default:
        return Icons.account_balance;
    }
  }
} 