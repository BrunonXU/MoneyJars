/*
 * 月度柱状图组件 (monthly_bar_chart.dart)
 * 
 * 功能说明：
 * - 展示月度收支对比
 * - 支持多数据系列
 * - 交互式提示
 * 
 * 特性：
 * - 分组柱状图
 * - 触摸显示详情
 * - 自适应Y轴范围
 * - 平滑动画过渡
 */

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// 月度柱状图组件
class MonthlyBarChartWidget extends StatefulWidget {
  /// 月度数据 Map<月份, Map<类型, 金额>>
  final Map<String, Map<String, double>> data;
  
  /// 月份列表（有序）
  final List<String> months;
  
  /// 图表高度
  final double height;
  
  /// 是否显示网格
  final bool showGrid;
  
  /// 最多显示月份数
  final int maxMonths;
  
  const MonthlyBarChartWidget({
    Key? key,
    required this.data,
    required this.months,
    this.height = 300,
    this.showGrid = true,
    this.maxMonths = 6,
  }) : super(key: key);
  
  @override
  State<MonthlyBarChartWidget> createState() => _MonthlyBarChartWidgetState();
}

class _MonthlyBarChartWidgetState extends State<MonthlyBarChartWidget> {
  int? _touchedGroupIndex;
  
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }
    
    final theme = Theme.of(context);
    final displayMonths = widget.months.length > widget.maxMonths
        ? widget.months.sublist(widget.months.length - widget.maxMonths)
        : widget.months;
    
    return Column(
      children: [
        // 图例
        _buildLegend(theme),
        const SizedBox(height: 16),
        
        // 柱状图
        SizedBox(
          height: widget.height,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _calculateMaxY(),
              minY: 0,
              groupsSpace: 20,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: _getTooltipItem,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                ),
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      _touchedGroupIndex = -1;
                      return;
                    }
                    _touchedGroupIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                  });
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => _buildBottomTitle(
                      value.toInt(),
                      displayMonths,
                      theme,
                    ),
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: _buildLeftTitle,
                    reservedSize: 50,
                    interval: _calculateInterval(),
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              gridData: FlGridData(
                show: widget.showGrid,
                drawVerticalLine: false,
                horizontalInterval: _calculateInterval(),
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  );
                },
              ),
              barGroups: _buildBarGroups(displayMonths),
            ),
          ),
        ),
      ],
    );
  }
  
  /// 构建图例
  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: Colors.green,
          label: '收入',
        ),
        const SizedBox(width: 24),
        _LegendItem(
          color: Colors.red,
          label: '支出',
        ),
        const SizedBox(width: 24),
        _LegendItem(
          color: Colors.blue,
          label: '净收入',
        ),
      ],
    );
  }
  
  /// 构建柱状图组
  List<BarChartGroupData> _buildBarGroups(List<String> displayMonths) {
    return displayMonths.asMap().entries.map((entry) {
      final index = entry.key;
      final month = entry.value;
      final monthData = widget.data[month] ?? {};
      
      final income = monthData['income'] ?? 0;
      final expense = monthData['expense'] ?? 0;
      final net = income - expense;
      
      return BarChartGroupData(
        x: index,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: income,
            color: Colors.green,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: expense,
            color: Colors.red,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          BarChartRodData(
            toY: net.abs(),
            color: net >= 0 ? Colors.blue : Colors.orange,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
        showingTooltipIndicators: _touchedGroupIndex == index ? [0, 1, 2] : [],
      );
    }).toList();
  }
  
  /// 计算最大Y值
  double _calculateMaxY() {
    double maxValue = 0;
    widget.data.values.forEach((monthData) {
      final income = monthData['income'] ?? 0;
      final expense = monthData['expense'] ?? 0;
      final net = (income - expense).abs();
      
      maxValue = [maxValue, income, expense, net].reduce((a, b) => a > b ? a : b);
    });
    
    // 添加10%的边距
    return maxValue * 1.1;
  }
  
  /// 计算Y轴间隔
  double _calculateInterval() {
    final maxY = _calculateMaxY();
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 1000;
    if (maxY <= 10000) return 2000;
    if (maxY <= 50000) return 10000;
    return 20000;
  }
  
  /// 构建底部标题
  Widget _buildBottomTitle(int index, List<String> months, ThemeData theme) {
    if (index < 0 || index >= months.length) {
      return const SizedBox.shrink();
    }
    
    final month = months[index];
    final parts = month.split('-');
    final displayText = parts.length == 2 ? '${parts[1]}月' : month;
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        displayText,
        style: theme.textTheme.bodySmall?.copyWith(
          color: _touchedGroupIndex == index
              ? theme.primaryColor
              : theme.textTheme.bodySmall?.color,
          fontWeight: _touchedGroupIndex == index
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }
  
  /// 构建左侧标题
  Widget _buildLeftTitle(double value, TitleMeta meta) {
    final formatter = NumberFormat.compact(locale: 'zh_CN');
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        formatter.format(value),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
        ),
      ),
    );
  }
  
  /// 获取提示项
  BarTooltipItem? _getTooltipItem(
    BarChartGroupData group,
    int groupIndex,
    BarChartRodData rod,
    int rodIndex,
  ) {
    final formatter = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    String label;
    
    switch (rodIndex) {
      case 0:
        label = '收入';
        break;
      case 1:
        label = '支出';
        break;
      case 2:
        label = '净收入';
        break;
      default:
        label = '';
    }
    
    return BarTooltipItem(
      '$label\n${formatter.format(rod.toY)}',
      TextStyle(
        color: rod.color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
  
  /// 构建空状态
  Widget _buildEmptyState() {
    return SizedBox(
      height: widget.height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无月度数据',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 图例项组件
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  
  const _LegendItem({
    required this.color,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// 水平柱状图
/// 
/// 用于展示分类排名
class HorizontalBarChart extends StatelessWidget {
  /// 数据项列表
  final List<BarChartItem> items;
  
  /// 图表高度
  final double height;
  
  /// 最多显示项数
  final int maxItems;
  
  const HorizontalBarChart({
    Key? key,
    required this.items,
    this.height = 200,
    this.maxItems = 5,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final displayItems = items.length > maxItems
        ? items.sublist(0, maxItems)
        : items;
    
    if (displayItems.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('暂无数据'),
        ),
      );
    }
    
    final maxValue = displayItems
        .map((item) => item.value)
        .reduce((a, b) => a > b ? a : b);
    
    return SizedBox(
      height: height,
      child: Column(
        children: displayItems.map((item) {
          final percentage = maxValue > 0 ? item.value / maxValue : 0;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    item.label,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 24,
                        width: MediaQuery.of(context).size.width * percentage * 0.5,
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Text(
                            NumberFormat.currency(
                              locale: 'zh_CN',
                              symbol: '¥',
                              decimalDigits: 0,
                            ).format(item.value),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
}

/// 柱状图数据项
class BarChartItem {
  final String label;
  final double value;
  final Color color;
  
  const BarChartItem({
    required this.label,
    required this.value,
    required this.color,
  });
}