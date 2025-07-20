/*
 * 交易列表组件 (transaction_list_widget.dart)
 * 
 * 功能说明：
 * - 展示交易记录列表
 * - 支持分组显示（按日期）
 * - 支持下拉刷新和加载更多
 * 
 * 交互特性：
 * - 滑动删除
 * - 点击编辑
 * - 批量选择
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/domain/entities/transaction.dart';
import '../../providers/transaction_provider_new.dart';
import 'transaction_list_item.dart';

/// 交易列表组件
/// 
/// 展示交易记录的分组列表
class TransactionListWidget extends StatefulWidget {
  /// 交易类型过滤
  final TransactionType? filterType;
  
  /// 是否显示空状态
  final bool showEmptyState;
  
  /// 是否启用下拉刷新
  final bool enableRefresh;
  
  /// 是否启用滑动删除
  final bool enableSwipeDelete;
  
  /// 点击交易回调
  final ValueChanged<Transaction>? onTransactionTap;
  
  /// 删除交易回调
  final ValueChanged<Transaction>? onTransactionDelete;
  
  /// 空状态组件
  final Widget? emptyStateWidget;
  
  /// 列表头部组件
  final Widget? headerWidget;
  
  const TransactionListWidget({
    Key? key,
    this.filterType,
    this.showEmptyState = true,
    this.enableRefresh = true,
    this.enableSwipeDelete = true,
    this.onTransactionTap,
    this.onTransactionDelete,
    this.emptyStateWidget,
    this.headerWidget,
  }) : super(key: key);
  
  @override
  State<TransactionListWidget> createState() => _TransactionListWidgetState();
}

class _TransactionListWidgetState extends State<TransactionListWidget> {
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dateFormat = DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'zh_CN',
    symbol: '¥',
    decimalDigits: 2,
  );
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  /// 刷新数据
  Future<void> _onRefresh() async {
    final provider = context.read<TransactionProviderNew>();
    await provider.loadTransactions();
  }
  
  /// 处理删除
  void _handleDelete(Transaction transaction) {
    if (widget.onTransactionDelete != null) {
      widget.onTransactionDelete!(transaction);
    } else {
      // 默认删除逻辑
      _showDeleteConfirmDialog(transaction);
    }
  }
  
  /// 显示删除确认对话框
  void _showDeleteConfirmDialog(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除"${transaction.description}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final provider = context.read<TransactionProviderNew>();
              try {
                await provider.deleteTransaction(transaction.id);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('删除成功'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('删除失败: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              '删除',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 按日期分组交易
  Map<String, List<Transaction>> _groupTransactionsByDate(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};
    
    for (final transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }
    
    return grouped;
  }
  
  /// 获取日期标题
  String _getDateTitle(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date == today) {
      return '今天';
    } else if (date == yesterday) {
      return '昨天';
    } else {
      return _dateFormat.format(date);
    }
  }
  
  /// 计算日期组的总金额
  Map<TransactionType, double> _calculateDateGroupTotal(List<Transaction> transactions) {
    final totals = <TransactionType, double>{
      TransactionType.income: 0.0,
      TransactionType.expense: 0.0,
      TransactionType.comprehensive: 0.0,
    };
    
    for (final transaction in transactions) {
      totals[transaction.type] = (totals[transaction.type] ?? 0) + transaction.amount;
    }
    
    return totals;
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<TransactionProviderNew>(
      builder: (context, provider, child) {
        // 过滤交易
        List<Transaction> transactions = provider.transactions;
        if (widget.filterType != null) {
          transactions = transactions
              .where((tx) => tx.type == widget.filterType)
              .toList();
        }
        
        // 如果没有数据，显示空状态
        if (transactions.isEmpty && widget.showEmptyState) {
          return widget.emptyStateWidget ?? _buildDefaultEmptyState();
        }
        
        // 按日期分组
        final groupedTransactions = _groupTransactionsByDate(transactions);
        final sortedDates = groupedTransactions.keys.toList()
          ..sort((a, b) => b.compareTo(a)); // 降序排列
        
        // 构建列表
        Widget listView = CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 头部组件
            if (widget.headerWidget != null)
              SliverToBoxAdapter(child: widget.headerWidget!),
            
            // 交易列表
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final dateKey = sortedDates[index];
                  final dateTransactions = groupedTransactions[dateKey]!;
                  final dateTotals = _calculateDateGroupTotal(dateTransactions);
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 日期标题
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        color: theme.scaffoldBackgroundColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getDateTitle(dateKey),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // 日期总计
                            Row(
                              children: [
                                if (dateTotals[TransactionType.income]! > 0) ...[
                                  Text(
                                    '收入: ${_currencyFormat.format(dateTotals[TransactionType.income])}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (dateTotals[TransactionType.expense]! > 0) ...[
                                  Text(
                                    '支出: ${_currencyFormat.format(dateTotals[TransactionType.expense])}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // 该日期的交易列表
                      ...dateTransactions.map((transaction) {
                        return TransactionListItem(
                          transaction: transaction,
                          enableSwipeDelete: widget.enableSwipeDelete,
                          onTap: () => widget.onTransactionTap?.call(transaction),
                          onDelete: () => _handleDelete(transaction),
                        );
                      }).toList(),
                      
                      // 分隔线
                      if (index < sortedDates.length - 1)
                        const Divider(height: 1),
                    ],
                  );
                },
                childCount: sortedDates.length,
              ),
            ),
          ],
        );
        
        // 如果启用下拉刷新
        if (widget.enableRefresh) {
          listView = RefreshIndicator(
            onRefresh: _onRefresh,
            child: listView,
          );
        }
        
        return listView;
      },
    );
  }
  
  /// 构建默认空状态
  Widget _buildDefaultEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无交易记录',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮添加您的第一笔交易',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}