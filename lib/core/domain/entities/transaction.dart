/*
 * 交易实体 (transaction.dart)
 * 
 * 功能说明：
 * - 定义交易的核心数据结构
 * - 独立于具体实现，不依赖任何框架
 * - 包含业务逻辑验证
 * 
 * 迁移说明：
 * - 从transaction_record_hive.dart提取核心字段
 * - 移除Hive相关注解
 * - 添加业务验证方法
 */

import 'package:equatable/equatable.dart';

/// 交易类型枚举
enum TransactionType {
  /// 收入
  income,
  /// 支出
  expense,
}

/// 交易实体类
/// 
/// 表示一条收入或支出记录的核心数据
class Transaction extends Equatable {
  /// 唯一标识符
  final String id;
  
  /// 交易金额（必须大于0）
  final double amount;
  
  /// 交易描述
  final String description;
  
  /// 主分类ID
  final String parentCategoryId;
  
  /// 主分类名称
  final String parentCategoryName;
  
  /// 子分类ID（可选）
  final String? subCategoryId;
  
  /// 子分类名称（可选）
  final String? subCategoryName;
  
  /// 交易类型
  final TransactionType type;
  
  /// 交易时间
  final DateTime date;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime? updatedAt;
  
  /// 是否已归档
  final bool isArchived;
  
  /// 附加备注
  final String? notes;
  
  /// 标签列表
  final List<String> tags;

  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.parentCategoryId,
    required this.parentCategoryName,
    this.subCategoryId,
    this.subCategoryName,
    required this.type,
    required this.date,
    required this.createdAt,
    this.updatedAt,
    this.isArchived = false,
    this.notes,
    this.tags = const [],
  });

  /// 验证交易数据是否有效
  bool get isValid {
    return amount > 0 && 
           description.isNotEmpty && 
           parentCategoryId.isNotEmpty;
  }
  
  /// 获取格式化的金额字符串
  String get formattedAmount {
    final prefix = type == TransactionType.income ? '+' : '-';
    return '$prefix¥${amount.toStringAsFixed(2)}';
  }
  
  /// 获取完整的分类路径
  String get categoryPath {
    if (subCategoryName != null && subCategoryName!.isNotEmpty) {
      return '$parentCategoryName / $subCategoryName';
    }
    return parentCategoryName;
  }
  
  /// 检查是否为今天的交易
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// 检查是否为本月的交易
  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// 创建副本并修改部分字段
  Transaction copyWith({
    String? id,
    double? amount,
    String? description,
    String? parentCategoryId,
    String? parentCategoryName,
    String? subCategoryId,
    String? subCategoryName,
    TransactionType? type,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    String? notes,
    List<String>? tags,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      parentCategoryName: parentCategoryName ?? this.parentCategoryName,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      subCategoryName: subCategoryName ?? this.subCategoryName,
      type: type ?? this.type,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    description,
    parentCategoryId,
    parentCategoryName,
    subCategoryId,
    subCategoryName,
    type,
    date,
    createdAt,
    updatedAt,
    isArchived,
    notes,
    tags,
  ];
}