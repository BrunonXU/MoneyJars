/*
 * 时间范围选择器 (period_selector.dart)
 * 
 * 功能说明：
 * - 提供快捷时间范围选择
 * - 支持自定义日期范围
 * - 响应式UI设计
 * 
 * 主要功能：
 * - 预设时间段：今日、本周、本月、本年
 * - 自定义日期范围选择
 * - 时间范围变更回调
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// 时间范围选择器组件
class PeriodSelector extends StatelessWidget {
  /// 当前选中的时间范围
  final DateTimeRange selectedRange;
  
  /// 时间范围变更回调
  final ValueChanged<DateTimeRange> onRangeChanged;
  
  /// 是否显示快捷选项
  final bool showQuickOptions;
  
  const PeriodSelector({
    Key? key,
    required this.selectedRange,
    required this.onRangeChanged,
    this.showQuickOptions = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 当前选中的日期范围显示
          _buildDateRangeDisplay(context),
          
          if (showQuickOptions) ...[
            const SizedBox(height: 8),
            // 快捷选项
            _buildQuickOptions(context),
          ],
        ],
      ),
    );
  }
  
  /// 构建日期范围显示
  Widget _buildDateRangeDisplay(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy/MM/dd');
    
    return InkWell(
      onTap: () => _selectCustomRange(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: theme.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              '${dateFormat.format(selectedRange.start)} - ${dateFormat.format(selectedRange.end)}',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down,
              color: theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建快捷选项
  Widget _buildQuickOptions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickOption(
            label: '今日',
            isSelected: _isToday(),
            onTap: () => _selectToday(),
          ),
          const SizedBox(width: 8),
          _QuickOption(
            label: '本周',
            isSelected: _isThisWeek(),
            onTap: () => _selectThisWeek(),
          ),
          const SizedBox(width: 8),
          _QuickOption(
            label: '本月',
            isSelected: _isThisMonth(),
            onTap: () => _selectThisMonth(),
          ),
          const SizedBox(width: 8),
          _QuickOption(
            label: '本年',
            isSelected: _isThisYear(),
            onTap: () => _selectThisYear(),
          ),
          const SizedBox(width: 8),
          _QuickOption(
            label: '最近30天',
            isSelected: _isLast30Days(),
            onTap: () => _selectLast30Days(),
          ),
          const SizedBox(width: 8),
          _QuickOption(
            label: '自定义',
            isSelected: !_isPresetRange(),
            onTap: () => _selectCustomRange(context),
          ),
        ],
      ),
    );
  }
  
  /// 选择自定义日期范围
  Future<void> _selectCustomRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: selectedRange,
      locale: const Locale('zh', 'CN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (range != null) {
      onRangeChanged(range);
    }
  }
  
  /// 选择今日
  void _selectToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    onRangeChanged(DateTimeRange(
      start: today,
      end: today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)),
    ));
  }
  
  /// 选择本周
  void _selectThisWeek() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    final sundayNext = monday.add(const Duration(days: 6));
    
    onRangeChanged(DateTimeRange(
      start: DateTime(monday.year, monday.month, monday.day),
      end: DateTime(sundayNext.year, sundayNext.month, sundayNext.day, 23, 59, 59),
    ));
  }
  
  /// 选择本月
  void _selectThisMonth() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    onRangeChanged(DateTimeRange(
      start: firstDay,
      end: lastDay,
    ));
  }
  
  /// 选择本年
  void _selectThisYear() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, 1, 1);
    final lastDay = DateTime(now.year, 12, 31, 23, 59, 59);
    
    onRangeChanged(DateTimeRange(
      start: firstDay,
      end: lastDay,
    ));
  }
  
  /// 选择最近30天
  void _selectLast30Days() {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final start = end.subtract(const Duration(days: 29));
    
    onRangeChanged(DateTimeRange(
      start: DateTime(start.year, start.month, start.day),
      end: end,
    ));
  }
  
  /// 判断是否为今日
  bool _isToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return selectedRange.start.year == today.year &&
           selectedRange.start.month == today.month &&
           selectedRange.start.day == today.day &&
           selectedRange.duration.inDays == 0;
  }
  
  /// 判断是否为本周
  bool _isThisWeek() {
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    
    return selectedRange.start.year == monday.year &&
           selectedRange.start.month == monday.month &&
           selectedRange.start.day == monday.day &&
           selectedRange.duration.inDays == 6;
  }
  
  /// 判断是否为本月
  bool _isThisMonth() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    
    return selectedRange.start.year == firstDay.year &&
           selectedRange.start.month == firstDay.month &&
           selectedRange.start.day == firstDay.day &&
           selectedRange.end.year == lastDay.year &&
           selectedRange.end.month == lastDay.month &&
           selectedRange.end.day == lastDay.day;
  }
  
  /// 判断是否为本年
  bool _isThisYear() {
    final now = DateTime.now();
    return selectedRange.start.year == now.year &&
           selectedRange.start.month == 1 &&
           selectedRange.start.day == 1 &&
           selectedRange.end.year == now.year &&
           selectedRange.end.month == 12 &&
           selectedRange.end.day == 31;
  }
  
  /// 判断是否为最近30天
  bool _isLast30Days() {
    return selectedRange.duration.inDays == 29;
  }
  
  /// 判断是否为预设范围
  bool _isPresetRange() {
    return _isToday() || _isThisWeek() || _isThisMonth() || 
           _isThisYear() || _isLast30Days();
  }
}

/// 快捷选项组件
class _QuickOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _QuickOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}