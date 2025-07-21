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
import '../models/transaction_record_hive.dart';
import '../providers/transaction_provider.dart';
import '../constants/app_constants.dart';
import '../utils/modern_ui_styles.dart';

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

class _MoneyJarWidgetState extends State<MoneyJarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverScaleAnimation;
  late Animation<double> _hoverGlowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: ModernUIStyles.shortAnimationDuration,
      vsync: this,
    );
    _hoverScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
    _hoverGlowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHover(bool hovering) {
    setState(() {
      _isHovered = hovering;
    });
    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _hoverScaleAnimation.value,
            child: Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.all(8.0),
              child: Container(
        decoration: ModernUIStyles.elevatedCardDecoration.copyWith(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernUIStyles.cardBackgroundColor.withOpacity(0.95),
              ModernUIStyles.cardBackgroundColor.withOpacity(0.85),
            ],
          ),
          border: Border.all(
            color: _getJarColor().withOpacity(0.5 + (_hoverGlowAnimation.value * 0.3)),
            width: _isHovered ? 3 : 2,
          ),
          boxShadow: [
            ...ModernUIStyles.elevatedCardDecoration.boxShadow!,
            if (_isHovered)
              BoxShadow(
                color: _getJarColor().withOpacity(0.3 * _hoverGlowAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 图标
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getJarColor().withOpacity(0.3),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getJarColor().withOpacity(0.3 + (_hoverGlowAnimation.value * 0.3)),
                        blurRadius: 8 + (_hoverGlowAnimation.value * 4),
                        spreadRadius: 2 + (_hoverGlowAnimation.value * 2),
                      ),
                    ],
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
                      style: ModernUIStyles.primaryButtonStyle.copyWith(
                        backgroundColor: MaterialStateProperty.all(_getJarColor()),
                        padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
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
      ),
            ),
          );
        },
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