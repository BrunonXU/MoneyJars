/*
 * 统计页面 (statistics_page.dart)
 * 
 * 功能说明：
 * - 展示收支统计数据
 * - 支持多种图表展示
 * - 时间范围筛选
 * 
 * 主要特性：
 * - 饼图：分类占比
 * - 柱状图：月度趋势
 * - 折线图：收支走势
 * - 数据导出功能
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/domain/entities/transaction.dart';
import '../../providers/transaction_provider_new.dart';
import '../../providers/category_provider.dart';
import '../../widgets/statistics/period_selector.dart';
import '../../widgets/statistics/statistics_card.dart';
import '../../widgets/statistics/category_pie_chart.dart';
import '../../widgets/statistics/monthly_bar_chart.dart';
import '../../widgets/statistics/trend_line_chart.dart';

/// 统计页面
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);
  
  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  /// 当前选择的时间范围
  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  
  /// 当前选择的交易类型
  TransactionType? _selectedType;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('统计分析'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
            tooltip: '导出数据',
          ),
        ],
      ),
      body: Consumer2<TransactionProviderNew, CategoryProvider>(
        builder: (context, transactionProvider, categoryProvider, child) {
          // 过滤交易数据
          final transactions = _filterTransactions(
            transactionProvider.allTransactions,
          );
          
          // 计算统计数据
          final stats = _calculateStatistics(transactions);
          
          return Column(
            children: [
              // 时间范围选择器
              PeriodSelector(
                selectedRange: _selectedRange,
                onRangeChanged: (range) {
                  setState(() {
                    _selectedRange = range;
                  });
                },
              ),
              
              // 统计卡片
              _buildStatisticsCards(stats),
              
              // 类型过滤
              _buildTypeFilter(),
              
              // 图表标签页
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '分类分析'),
                  Tab(text: '月度统计'),
                  Tab(text: '趋势走向'),
                ],
              ),
              
              // 图表内容
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // 分类分析
                    _buildCategoryAnalysis(
                      transactions,
                      categoryProvider,
                    ),
                    
                    // 月度统计
                    _buildMonthlyStatistics(transactions),
                    
                    // 趋势走向
                    _buildTrendAnalysis(transactions),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// 过滤交易数据
  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    return transactions.where((tx) {
      // 时间范围过滤
      if (tx.date.isBefore(_selectedRange.start) ||
          tx.date.isAfter(_selectedRange.end)) {
        return false;
      }
      
      // 类型过滤
      if (_selectedType != null && tx.type != _selectedType) {
        return false;
      }
      
      return true;
    }).toList();
  }
  
  /// 计算统计数据
  Map<String, double> _calculateStatistics(List<Transaction> transactions) {
    double totalIncome = 0;
    double totalExpense = 0;
    double totalComprehensive = 0;
    
    for (final tx in transactions) {
      switch (tx.type) {
        case TransactionType.income:
          totalIncome += tx.amount;
          break;
        case TransactionType.expense:
          totalExpense += tx.amount;
          break;
        case TransactionType.comprehensive:
          totalComprehensive += tx.amount;
          break;
      }
    }
    
    return {
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'totalComprehensive': totalComprehensive,
      'netIncome': totalIncome - totalExpense,
      'transactionCount': transactions.length.toDouble(),
      'dailyAverage': transactions.isEmpty
          ? 0
          : (totalIncome + totalExpense) / _selectedRange.duration.inDays,
    };
  }
  
  /// 构建统计卡片
  Widget _buildStatisticsCards(Map<String, double> stats) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          StatisticsCard(
            title: '总收入',
            value: stats['totalIncome']!,
            icon: Icons.arrow_downward,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          StatisticsCard(
            title: '总支出',
            value: stats['totalExpense']!,
            icon: Icons.arrow_upward,
            color: Colors.red,
          ),
          const SizedBox(width: 12),
          StatisticsCard(
            title: '净收入',
            value: stats['netIncome']!,
            icon: Icons.account_balance_wallet,
            color: stats['netIncome']! >= 0 ? Colors.blue : Colors.orange,
          ),
          const SizedBox(width: 12),
          StatisticsCard(
            title: '日均消费',
            value: stats['dailyAverage']!,
            icon: Icons.trending_up,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
  
  /// 构建类型过滤器
  Widget _buildTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _TypeFilterChip(
            label: '全部',
            selected: _selectedType == null,
            onSelected: () {
              setState(() {
                _selectedType = null;
              });
            },
          ),
          const SizedBox(width: 8),
          _TypeFilterChip(
            label: '收入',
            selected: _selectedType == TransactionType.income,
            color: Colors.green,
            onSelected: () {
              setState(() {
                _selectedType = TransactionType.income;
              });
            },
          ),
          const SizedBox(width: 8),
          _TypeFilterChip(
            label: '支出',
            selected: _selectedType == TransactionType.expense,
            color: Colors.red,
            onSelected: () {
              setState(() {
                _selectedType = TransactionType.expense;
              });
            },
          ),
          const SizedBox(width: 8),
          _TypeFilterChip(
            label: '综合',
            selected: _selectedType == TransactionType.comprehensive,
            color: Colors.blue,
            onSelected: () {
              setState(() {
                _selectedType = TransactionType.comprehensive;
              });
            },
          ),
        ],
      ),
    );
  }
  
  /// 构建分类分析
  Widget _buildCategoryAnalysis(
    List<Transaction> transactions,
    CategoryProvider categoryProvider,
  ) {
    // 按分类统计
    final categoryStats = <String, double>{};
    for (final tx in transactions) {
      categoryStats[tx.parentCategoryName] = 
          (categoryStats[tx.parentCategoryName] ?? 0) + tx.amount;
    }
    
    // 排序并取前10
    final sortedCategories = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(10).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 饼图
          SizedBox(
            height: 300,
            child: CategoryPieChartWidget(
              data: Map.fromEntries(topCategories),
              categories: categoryProvider.allCategories,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 分类列表
          ...topCategories.map((entry) {
            final percentage = (entry.value / 
                transactions.fold(0.0, (sum, tx) => sum + tx.amount) * 100);
            
            return _CategoryListItem(
              categoryName: entry.key,
              amount: entry.value,
              percentage: percentage,
              color: _getCategoryColor(entry.key, categoryProvider),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  /// 构建月度统计
  Widget _buildMonthlyStatistics(List<Transaction> transactions) {
    // 按月份分组
    final monthlyData = <String, Map<String, double>>{};
    
    for (final tx in transactions) {
      final monthKey = DateFormat('yyyy-MM').format(tx.date);
      monthlyData.putIfAbsent(monthKey, () => {
        'income': 0,
        'expense': 0,
        'comprehensive': 0,
      });
      
      switch (tx.type) {
        case TransactionType.income:
          monthlyData[monthKey]!['income'] = 
              monthlyData[monthKey]!['income']! + tx.amount;
          break;
        case TransactionType.expense:
          monthlyData[monthKey]!['expense'] = 
              monthlyData[monthKey]!['expense']! + tx.amount;
          break;
        case TransactionType.comprehensive:
          monthlyData[monthKey]!['comprehensive'] = 
              monthlyData[monthKey]!['comprehensive']! + tx.amount;
          break;
      }
    }
    
    // 排序
    final sortedMonths = monthlyData.keys.toList()..sort();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 柱状图
          SizedBox(
            height: 300,
            child: MonthlyBarChartWidget(
              data: monthlyData,
              months: sortedMonths,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 月度数据列表
          ...sortedMonths.reversed.map((month) {
            final data = monthlyData[month]!;
            return _MonthlyListItem(
              month: month,
              income: data['income']!,
              expense: data['expense']!,
              comprehensive: data['comprehensive']!,
            );
          }).toList(),
        ],
      ),
    );
  }
  
  /// 构建趋势分析
  Widget _buildTrendAnalysis(List<Transaction> transactions) {
    // 按日期分组
    final dailyData = <DateTime, Map<String, double>>{};
    
    for (final tx in transactions) {
      final dateKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      dailyData.putIfAbsent(dateKey, () => {
        'income': 0,
        'expense': 0,
        'balance': 0,
      });
      
      switch (tx.type) {
        case TransactionType.income:
          dailyData[dateKey]!['income'] = 
              dailyData[dateKey]!['income']! + tx.amount;
          break;
        case TransactionType.expense:
          dailyData[dateKey]!['expense'] = 
              dailyData[dateKey]!['expense']! + tx.amount;
          break;
        case TransactionType.comprehensive:
          // 综合类型计入余额
          break;
      }
    }
    
    // 计算累计余额
    double cumulativeBalance = 0;
    final sortedDates = dailyData.keys.toList()..sort();
    for (final date in sortedDates) {
      final data = dailyData[date]!;
      cumulativeBalance += data['income']! - data['expense']!;
      data['balance'] = cumulativeBalance;
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 折线图
          SizedBox(
            height: 300,
            child: TrendLineChartWidget(
              data: dailyData,
              showIncome: _selectedType == null || 
                         _selectedType == TransactionType.income,
              showExpense: _selectedType == null || 
                          _selectedType == TransactionType.expense,
              showBalance: true,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 趋势说明
          _buildTrendSummary(dailyData),
        ],
      ),
    );
  }
  
  /// 构建趋势总结
  Widget _buildTrendSummary(Map<DateTime, Map<String, double>> data) {
    if (data.isEmpty) {
      return const Center(
        child: Text('暂无数据'),
      );
    }
    
    // 计算趋势
    final sortedDates = data.keys.toList()..sort();
    final firstBalance = data[sortedDates.first]!['balance']!;
    final lastBalance = data[sortedDates.last]!['balance']!;
    final balanceChange = lastBalance - firstBalance;
    
    final totalIncome = data.values
        .fold(0.0, (sum, day) => sum + day['income']!);
    final totalExpense = data.values
        .fold(0.0, (sum, day) => sum + day['expense']!);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '趋势分析',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _TrendItem(
              label: '期间总收入',
              value: totalIncome,
              color: Colors.green,
            ),
            _TrendItem(
              label: '期间总支出',
              value: totalExpense,
              color: Colors.red,
            ),
            _TrendItem(
              label: '余额变化',
              value: balanceChange,
              color: balanceChange >= 0 ? Colors.blue : Colors.orange,
              showSign: true,
            ),
            const SizedBox(height: 8),
            Text(
              balanceChange >= 0
                  ? '财务状况良好，继续保持！'
                  : '支出超过收入，请注意控制开支。',
              style: TextStyle(
                color: balanceChange >= 0 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 获取分类颜色
  Color _getCategoryColor(String categoryName, CategoryProvider provider) {
    final category = provider.allCategories
        .firstWhere(
          (cat) => cat.name == categoryName,
          orElse: () => provider.allCategories.first,
        );
    
    return category.color != null
        ? Color(category.color!)
        : Colors.grey;
  }
  
  /// 导出数据
  void _exportData() {
    // TODO: 实现数据导出功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('数据导出功能开发中...'),
      ),
    );
  }
}

/// 类型过滤芯片
class _TypeFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onSelected;
  
  const _TypeFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: color?.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: selected ? color : null,
        fontWeight: selected ? FontWeight.bold : null,
      ),
    );
  }
}

/// 分类列表项
class _CategoryListItem extends StatelessWidget {
  final String categoryName;
  final double amount;
  final double percentage;
  final Color color;
  
  const _CategoryListItem({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
      title: Text(categoryName),
      subtitle: Text('${percentage.toStringAsFixed(1)}%'),
      trailing: Text(
        formatter.format(amount),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

/// 月度列表项
class _MonthlyListItem extends StatelessWidget {
  final String month;
  final double income;
  final double expense;
  final double comprehensive;
  
  const _MonthlyListItem({
    required this.month,
    required this.income,
    required this.expense,
    required this.comprehensive,
  });
  
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    final net = income - expense;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              month,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MonthlyDataItem(
                  label: '收入',
                  value: income,
                  color: Colors.green,
                ),
                _MonthlyDataItem(
                  label: '支出',
                  value: expense,
                  color: Colors.red,
                ),
                _MonthlyDataItem(
                  label: '净额',
                  value: net,
                  color: net >= 0 ? Colors.blue : Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 月度数据项
class _MonthlyDataItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  
  const _MonthlyDataItem({
    required this.label,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          formatter.format(value),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// 趋势项
class _TrendItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool showSign;
  
  const _TrendItem({
    required this.label,
    required this.value,
    required this.color,
    this.showSign = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'zh_CN', symbol: '¥');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '${showSign && value > 0 ? '+' : ''}${formatter.format(value)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}