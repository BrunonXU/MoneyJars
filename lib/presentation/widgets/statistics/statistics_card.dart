/*
 * 统计卡片组件 (statistics_card.dart)
 * 
 * 功能说明：
 * - 展示关键统计数据
 * - 支持图标和颜色自定义
 * - 响应式设计适配不同屏幕
 * 
 * 特性：
 * - 数字动画效果
 * - 货币格式化显示
 * - 支持正负值区分
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 统计卡片组件
class StatisticsCard extends StatefulWidget {
  /// 标题
  final String title;
  
  /// 数值
  final double value;
  
  /// 图标
  final IconData icon;
  
  /// 主题颜色
  final Color color;
  
  /// 是否显示货币符号
  final bool showCurrency;
  
  /// 自定义格式化函数
  final String Function(double)? formatter;
  
  /// 子标题
  final String? subtitle;
  
  /// 趋势百分比（可选）
  final double? trendPercentage;
  
  const StatisticsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.showCurrency = true,
    this.formatter,
    this.subtitle,
    this.trendPercentage,
  }) : super(key: key);
  
  @override
  State<StatisticsCard> createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<StatisticsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _valueAnimation;
  double _previousValue = 0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _valueAnimation = Tween<double>(
      begin: 0,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  void didUpdateWidget(StatisticsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _valueAnimation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.forward(from: 0);
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.cardColor,
            widget.color.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标和标题行
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: widget.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 数值显示
          AnimatedBuilder(
            animation: _valueAnimation,
            builder: (context, child) {
              return Text(
                _formatValue(_valueAnimation.value),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          
          // 子标题或趋势显示
          if (widget.subtitle != null || widget.trendPercentage != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (widget.subtitle != null)
                  Expanded(
                    child: Text(
                      widget.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (widget.trendPercentage != null)
                  _buildTrendIndicator(),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  /// 格式化数值
  String _formatValue(double value) {
    if (widget.formatter != null) {
      return widget.formatter!(value);
    }
    
    if (widget.showCurrency) {
      final formatter = NumberFormat.currency(
        locale: 'zh_CN',
        symbol: '¥',
        decimalDigits: value.abs() >= 1000 ? 0 : 2,
      );
      return formatter.format(value);
    } else {
      final formatter = NumberFormat.compact(locale: 'zh_CN');
      return formatter.format(value);
    }
  }
  
  /// 构建趋势指示器
  Widget _buildTrendIndicator() {
    if (widget.trendPercentage == null) return const SizedBox.shrink();
    
    final isPositive = widget.trendPercentage! >= 0;
    final color = isPositive ? Colors.green : Colors.red;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${widget.trendPercentage!.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 迷你统计卡片
/// 
/// 用于空间受限的场景
class MiniStatisticsCard extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData? icon;
  final bool showCurrency;
  
  const MiniStatisticsCard({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
    this.icon,
    this.showCurrency = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = showCurrency
        ? NumberFormat.currency(locale: 'zh_CN', symbol: '¥')
        : NumberFormat.compact(locale: 'zh_CN');
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formatter.format(value),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}