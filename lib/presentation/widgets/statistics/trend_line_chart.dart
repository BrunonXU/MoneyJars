/*
 * 趋势折线图组件 (trend_line_chart.dart)
 * 
 * 功能说明：
 * - 展示收支趋势变化
 * - 支持多条数据线
 * - 累计余额追踪
 * 
 * 特性：
 * - 平滑曲线
 * - 触点提示
 * - 自适应缩放
 * - 渐变填充效果
 */

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// 趋势折线图组件
class TrendLineChartWidget extends StatefulWidget {
  /// 日期数据 Map<日期, Map<类型, 金额>>
  final Map<DateTime, Map<String, double>> data;
  
  /// 是否显示收入线
  final bool showIncome;
  
  /// 是否显示支出线
  final bool showExpense;
  
  /// 是否显示余额线
  final bool showBalance;
  
  /// 图表高度
  final double height;
  
  /// 是否显示网格
  final bool showGrid;
  
  /// 是否启用触摸
  final bool enableTouch;
  
  const TrendLineChartWidget({
    Key? key,
    required this.data,
    this.showIncome = true,
    this.showExpense = true,
    this.showBalance = true,
    this.height = 300,
    this.showGrid = true,
    this.enableTouch = true,
  }) : super(key: key);
  
  @override
  State<TrendLineChartWidget> createState() => _TrendLineChartWidgetState();
}

class _TrendLineChartWidgetState extends State<TrendLineChartWidget> {
  List<int> _showingTooltipIndicators = [];
  
  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }
    
    final theme = Theme.of(context);
    final sortedDates = widget.data.keys.toList()..sort();
    
    return Column(
      children: [
        // 图例
        _buildLegend(theme),
        const SizedBox(height: 16),
        
        // 折线图
        SizedBox(
          height: widget.height,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                enabled: widget.enableTouch,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: _getTooltipItems,
                  tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                ),
                getTouchedSpotIndicator: _getTouchedSpotIndicator,
                touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                  if (response != null && response.lineBarSpots != null) {
                    setState(() {
                      _showingTooltipIndicators = response.lineBarSpots!
                          .map((spot) => spot.spotIndex)
                          .toList();
                    });
                  }
                },
              ),
              gridData: FlGridData(
                show: widget.showGrid,
                drawVerticalLine: false,
                horizontalInterval: _calculateYInterval(),
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  );
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
                    reservedSize: 30,
                    interval: _calculateXInterval(sortedDates.length),
                    getTitlesWidget: (value, meta) => _buildBottomTitle(
                      value,
                      sortedDates,
                      theme,
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: _calculateYInterval(),
                    reservedSize: 50,
                    getTitlesWidget: _buildLeftTitle,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              minX: 0,
              maxX: sortedDates.length.toDouble() - 1,
              minY: _calculateMinY(),
              maxY: _calculateMaxY(),
              lineBarsData: _buildLineBars(sortedDates),
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
        if (widget.showIncome)
          _LegendItem(
            color: Colors.green,
            label: '收入',
          ),
        if (widget.showIncome && (widget.showExpense || widget.showBalance))
          const SizedBox(width: 24),
        if (widget.showExpense)
          _LegendItem(
            color: Colors.red,
            label: '支出',
          ),
        if (widget.showExpense && widget.showBalance)
          const SizedBox(width: 24),
        if (widget.showBalance)
          _LegendItem(
            color: Colors.blue,
            label: '余额',
          ),
      ],
    );
  }
  
  /// 构建折线数据
  List<LineChartBarData> _buildLineBars(List<DateTime> sortedDates) {
    final lines = <LineChartBarData>[];
    
    // 收入线
    if (widget.showIncome) {
      final spots = <FlSpot>[];
      for (var i = 0; i < sortedDates.length; i++) {
        final date = sortedDates[i];
        final income = widget.data[date]?['income'] ?? 0;
        spots.add(FlSpot(i.toDouble(), income));
      }
      
      lines.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        color: Colors.green,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.green.withOpacity(0.1),
        ),
      ));
    }
    
    // 支出线
    if (widget.showExpense) {
      final spots = <FlSpot>[];
      for (var i = 0; i < sortedDates.length; i++) {
        final date = sortedDates[i];
        final expense = widget.data[date]?['expense'] ?? 0;
        spots.add(FlSpot(i.toDouble(), expense));
      }
      
      lines.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        color: Colors.red,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.red.withOpacity(0.1),
        ),
      ));
    }
    
    // 余额线
    if (widget.showBalance) {
      final spots = <FlSpot>[];
      for (var i = 0; i < sortedDates.length; i++) {
        final date = sortedDates[i];
        final balance = widget.data[date]?['balance'] ?? 0;
        spots.add(FlSpot(i.toDouble(), balance));
      }
      
      lines.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        color: Colors.blue,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.withOpacity(0.3),
              Colors.blue.withOpacity(0.0),
            ],
          ),
        ),
      ));
    }
    
    return lines;
  }
  
  /// 计算最小Y值
  double _calculateMinY() {
    double minValue = 0;
    widget.data.values.forEach((dayData) {
      final balance = dayData['balance'] ?? 0;
      if (balance < minValue) minValue = balance;
    });
    return minValue * 1.1; // 添加10%边距
  }
  
  /// 计算最大Y值
  double _calculateMaxY() {
    double maxValue = 0;
    widget.data.values.forEach((dayData) {
      final income = dayData['income'] ?? 0;
      final expense = dayData['expense'] ?? 0;
      final balance = dayData['balance'] ?? 0;
      
      final dayMax = [income, expense, balance].reduce((a, b) => a > b ? a : b);
      if (dayMax > maxValue) maxValue = dayMax;
    });
    return maxValue * 1.1; // 添加10%边距
  }
  
  /// 计算Y轴间隔
  double _calculateYInterval() {
    final maxY = _calculateMaxY();
    final minY = _calculateMinY();
    final range = maxY - minY;
    
    if (range <= 1000) return 200;
    if (range <= 5000) return 1000;
    if (range <= 10000) return 2000;
    if (range <= 50000) return 10000;
    return 20000;
  }
  
  /// 计算X轴间隔
  double _calculateXInterval(int dataPoints) {
    if (dataPoints <= 7) return 1;
    if (dataPoints <= 30) return 7;
    if (dataPoints <= 90) return 15;
    return 30;
  }
  
  /// 构建底部标题
  Widget _buildBottomTitle(double value, List<DateTime> dates, ThemeData theme) {
    final index = value.toInt();
    if (index < 0 || index >= dates.length) {
      return const SizedBox.shrink();
    }
    
    final date = dates[index];
    final formatter = dates.length <= 7
        ? DateFormat('MM/dd')
        : DateFormat('MM/dd');
    
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        formatter.format(date),
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 10,
          color: Colors.grey,
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
  List<LineTooltipItem?> _getTooltipItems(List<LineBarSpot> spots) {
    final dateFormatter = DateFormat('MM/dd');
    final moneyFormatter = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    
    // 获取日期
    String dateStr = '';
    if (spots.isNotEmpty) {
      final dates = widget.data.keys.toList()..sort();
      final index = spots.first.x.toInt();
      if (index >= 0 && index < dates.length) {
        dateStr = dateFormatter.format(dates[index]);
      }
    }
    
    return spots.map((spot) {
      String label = '';
      Color color = Colors.grey;
      
      // 根据线的索引确定类型
      if (widget.showIncome && spot.barIndex == 0) {
        label = '收入';
        color = Colors.green;
      } else if (widget.showExpense && 
                 spot.barIndex == (widget.showIncome ? 1 : 0)) {
        label = '支出';
        color = Colors.red;
      } else if (widget.showBalance) {
        label = '余额';
        color = Colors.blue;
      }
      
      return LineTooltipItem(
        '$dateStr\n$label: ${moneyFormatter.format(spot.y)}',
        TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();
  }
  
  /// 获取触点指示器
  List<TouchedSpotIndicatorData?> _getTouchedSpotIndicator(
    LineChartBarData barData,
    List<int> indicators,
  ) {
    return indicators.map((int index) {
      return TouchedSpotIndicatorData(
        FlLine(
          color: barData.color?.withOpacity(0.3),
          strokeWidth: 2,
          dashArray: [5, 5],
        ),
        FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 6,
              color: Colors.white,
              strokeWidth: 3,
              strokeColor: barData.color ?? Colors.grey,
            );
          },
        ),
      );
    }).toList();
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
              Icons.show_chart,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无趋势数据',
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
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
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

/// 迷你趋势图
/// 
/// 用于显示简单的趋势
class MiniTrendChart extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;
  final double width;
  
  const MiniTrendChart({
    Key? key,
    required this.values,
    required this.color,
    this.height = 40,
    this.width = 100,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        width: width,
      );
    }
    
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;
    
    return SizedBox(
      height: height,
      width: width,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minX: 0,
          maxX: values.length.toDouble() - 1,
          minY: minValue - range * 0.1,
          maxY: maxValue + range * 0.1,
          lineBarsData: [
            LineChartBarData(
              spots: values.asMap().entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}