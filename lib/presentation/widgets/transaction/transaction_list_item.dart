/*
 * 交易列表项组件 (transaction_list_item.dart)
 * 
 * 功能说明：
 * - 展示单条交易记录
 * - 支持滑动删除
 * - 显示分类图标和金额
 * 
 * 视觉设计：
 * - 分类图标和颜色
 * - 金额高亮显示
 * - 时间和描述信息
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/domain/entities/transaction.dart';

/// 交易列表项组件
/// 
/// 展示单条交易记录的详细信息
class TransactionListItem extends StatelessWidget {
  /// 交易记录
  final Transaction transaction;
  
  /// 是否启用滑动删除
  final bool enableSwipeDelete;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 删除回调
  final VoidCallback? onDelete;
  
  /// 是否显示日期
  final bool showDate;
  
  /// 是否显示子分类
  final bool showSubCategory;
  
  /// 自定义前导组件
  final Widget? leading;
  
  /// 自定义尾部组件
  final Widget? trailing;
  
  const TransactionListItem({
    Key? key,
    required this.transaction,
    this.enableSwipeDelete = true,
    this.onTap,
    this.onDelete,
    this.showDate = false,
    this.showSubCategory = true,
    this.leading,
    this.trailing,
  }) : super(key: key);
  
  /// 获取交易类型颜色
  Color _getTypeColor(BuildContext context) {
    switch (transaction.type) {
      case TransactionType.income:
        return Colors.green;
      case TransactionType.expense:
        return Colors.red;
      case TransactionType.comprehensive:
        return Colors.blue;
    }
  }
  
  /// 获取金额文本
  String _getAmountText() {
    final formatter = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: '¥',
      decimalDigits: 2,
    );
    
    final amount = formatter.format(transaction.amount);
    
    switch (transaction.type) {
      case TransactionType.income:
        return '+$amount';
      case TransactionType.expense:
        return '-$amount';
      case TransactionType.comprehensive:
        return amount;
    }
  }
  
  /// 获取时间文本
  String _getTimeText() {
    final now = DateTime.now();
    final transactionDate = transaction.date;
    
    // 如果是今天
    if (transactionDate.year == now.year &&
        transactionDate.month == now.month &&
        transactionDate.day == now.day) {
      return DateFormat('HH:mm').format(transaction.createTime);
    }
    
    // 如果显示日期
    if (showDate) {
      return DateFormat('MM-dd HH:mm').format(transaction.createTime);
    }
    
    // 默认只显示时间
    return DateFormat('HH:mm').format(transaction.createTime);
  }
  
  /// 构建分类图标
  Widget _buildCategoryIcon(BuildContext context) {
    // TODO: 从分类数据中获取实际图标
    // 这里暂时使用默认图标
    String icon = '📝';
    
    switch (transaction.parentCategoryName) {
      case '工资收入':
        icon = '💰';
        break;
      case '投资理财':
        icon = '📈';
        break;
      case '饮食':
        icon = '🍔';
        break;
      case '交通':
        icon = '🚗';
        break;
      case '购物':
        icon = '🛍️';
        break;
      case '娱乐':
        icon = '🎮';
        break;
      default:
        icon = '📝';
    }
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _getTypeColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _getTypeColor(context);
    
    Widget listTile = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          child: Row(
            children: [
              // 前导组件（分类图标）
              leading ?? _buildCategoryIcon(context),
              
              const SizedBox(width: 12),
              
              // 中间内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 第一行：描述和金额
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.description,
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getAmountText(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // 第二行：分类和时间
                    Row(
                      children: [
                        // 分类
                        Expanded(
                          child: Text(
                            showSubCategory && transaction.subCategoryName != null
                                ? '${transaction.parentCategoryName} · ${transaction.subCategoryName}'
                                : transaction.parentCategoryName,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // 时间
                        Text(
                          _getTimeText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    
                    // 备注（如果有）
                    if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        transaction.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // 标签（如果有）
                    if (transaction.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: transaction.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#$tag',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.primaryColor,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              
              // 尾部组件
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
    
    // 如果启用滑动删除
    if (enableSwipeDelete && onDelete != null) {
      return Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDelete!(),
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        child: listTile,
      );
    }
    
    return listTile;
  }
}