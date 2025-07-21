/*
 * 分类饼图组件 (category_pie_chart.dart)
 * 
 * 功能说明：
 * - 展示分类占比分布
 * - 支持交互式选择
 * - 动画过渡效果
 * 
 * 特性：
 * - 3D视觉效果
 * - 触摸高亮
 * - 图例自动布局
 * - 百分比显示
 */

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/domain/entities/category.dart';
import '../../../core/domain/entities/transaction.dart';

/// 分类饼图组件
class CategoryPieChartWidget extends StatefulWidget {
  /// 分类数据 Map<分类名称, 金额>
  final Map<String, double> data;
  
  /// 分类列表（用于获取颜色）
  final List<Category> categories;
  
  /// 图表高度
  final double height;
  
  /// 是否显示图例
  final bool showLegend;
  
  /// 是否显示百分比
  final bool showPercentage;
  
  /// 选中回调
  final ValueChanged<String>? onCategorySelected;
  
  const CategoryPieChartWidget({
    Key? key,
    required this.data,
    required this.categories,
    this.height = 300,
    this.showLegend = true,
    this.showPercentage = true,
    this.onCategorySelected,
  }) : super(key: key);
  
  @override
  State<CategoryPieChartWidget> createState() => _CategoryPieChartWidgetState();
}

class _CategoryPieChartWidgetState extends State<CategoryPieChartWidget> {
  int? _touchedIndex;
  
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }
    
    final theme = Theme.of(context);
    final total = widget.data.values.fold(0.0, (sum, value) => sum + value);
    
    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          // 饼图
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                          
                          if (_touchedIndex != -1 && widget.onCategorySelected != null) {
                            final categoryName = widget.data.keys.toList()[_touchedIndex!];
                            widget.onCategorySelected!(categoryName);
                          }
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: _buildSections(total),
                  ),
                ),
                
                // 中心文字
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '总计',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        NumberFormat.currency(
                          locale: 'zh_CN',
                          symbol: '¥',
                          decimalDigits: 0,
                        ).format(total),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 图例
          if (widget.showLegend)
            Expanded(
              flex: 1,
              child: _buildLegend(theme, total),
            ),
        ],
      ),
    );
  }
  
  /// 构建饼图扇区
  List<PieChartSectionData> _buildSections(double total) {
    final sections = <PieChartSectionData>[];
    var index = 0;
    
    widget.data.forEach((categoryName, amount) {
      final isTouched = index == _touchedIndex;
      final percentage = (amount / total * 100);
      final radius = isTouched ? 60.0 : 50.0;
      
      sections.add(
        PieChartSectionData(
          color: _getCategoryColor(categoryName),
          value: amount,
          title: widget.showPercentage && percentage >= 5
              ? '${percentage.toStringAsFixed(1)}%'
              : '',
          radius: radius,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          badgeWidget: isTouched ? _buildBadge(categoryName, amount) : null,
          badgePositionPercentageOffset: 1.3,
        ),
      );
      index++;
    });
    
    return sections;
  }
  
  /// 构建图例
  Widget _buildLegend(ThemeData theme, double total) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.data.entries.map((entry) {
          final percentage = (entry.value / total * 100);
          final color = _getCategoryColor(entry.key);
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
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
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: theme.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  /// 构建徽章
  Widget _buildBadge(String categoryName, double amount) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            categoryName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            NumberFormat.currency(
              locale: 'zh_CN',
              symbol: '¥',
              decimalDigits: 0,
            ).format(amount),
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 获取分类颜色
  Color _getCategoryColor(String categoryName) {
    final category = widget.categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => Category(
        id: '',
        name: categoryName,
        type: TransactionType.expense,
        icon: '🛒',
        color: Colors.grey.value,
        userId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        subCategories: [],
        isSystem: false,
        isEnabled: true,
      ),
    );
    
    return Color(category.color ?? Colors.grey.value);
  }
}

/// 环形进度图
/// 
/// 用于显示单个分类的占比
class CategoryRingChart extends StatelessWidget {
  final String categoryName;
  final double value;
  final double total;
  final Color color;
  final double size;
  
  const CategoryRingChart({
    Key? key,
    required this.categoryName,
    required this.value,
    required this.total,
    required this.color,
    this.size = 100,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (value / total * 100) : 0;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: size * 0.35,
              sections: [
                PieChartSectionData(
                  value: value,
                  color: color,
                  radius: size * 0.15,
                  title: '',
                ),
                PieChartSectionData(
                  value: total - value,
                  color: Colors.grey.shade200,
                  radius: size * 0.15,
                  title: '',
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  categoryName,
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}