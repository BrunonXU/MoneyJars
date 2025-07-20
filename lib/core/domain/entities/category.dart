/*
 * 分类实体 (category.dart)
 * 
 * 功能说明：
 * - 定义收入/支出分类的核心数据结构
 * - 支持两级分类（主分类和子分类）
 * - 独立于具体存储实现
 * 
 * 迁移说明：
 * - 从transaction_record_hive.dart提取Category相关定义
 * - 移除Hive注解，使其成为纯粹的领域实体
 * - 保持与原有数据结构的兼容性
 */

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'transaction.dart';

/// 分类类型别名
typedef CategoryType = TransactionType;

/// 主分类实体
/// 
/// 表示收入或支出的主要分类
class Category extends Equatable {
  /// 分类唯一标识符
  final String id;
  
  /// 分类名称
  final String name;
  
  /// 分类类型（收入/支出）
  final TransactionType type;
  
  /// 分类颜色（存储为int以便序列化）
  final int color;
  
  /// 分类图标（emoji或图标代码）
  final String icon;
  
  /// 子分类列表
  final List<SubCategory> subCategories;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;
  
  /// 是否为系统预设分类（不可删除）
  final bool isSystem;
  
  /// 是否启用
  final bool isEnabled;
  
  /// 使用次数（用于排序常用分类）
  final int usageCount;
  
  /// 用户ID（为未来多用户预留）
  final String? userId;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    required this.subCategories,
    required this.createdAt,
    required this.updatedAt,
    this.isSystem = false,
    this.isEnabled = true,
    this.usageCount = 0,
    this.userId,
  });

  /// 获取颜色对象
  Color get colorValue => Color(color);
  
  /// 获取完整的子分类数量
  int get subCategoryCount => subCategories.length;
  
  /// 检查是否包含指定的子分类
  bool hasSubCategory(String subCategoryName) {
    return subCategories.any((sub) => sub.name == subCategoryName);
  }
  
  /// 根据名称获取子分类
  SubCategory? getSubCategory(String name) {
    try {
      return subCategories.firstWhere((sub) => sub.name == name);
    } catch (_) {
      return null;
    }
  }
  
  /// 创建副本并修改部分字段
  Category copyWith({
    String? id,
    String? name,
    TransactionType? type,
    int? color,
    String? icon,
    List<SubCategory>? subCategories,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSystem,
    bool? isEnabled,
    int? usageCount,
    String? userId,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      subCategories: subCategories ?? this.subCategories,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSystem: isSystem ?? this.isSystem,
      isEnabled: isEnabled ?? this.isEnabled,
      usageCount: usageCount ?? this.usageCount,
      userId: userId ?? this.userId,
    );
  }
  
  /// 增加使用次数
  Category incrementUsage() {
    return copyWith(
      usageCount: usageCount + 1,
      updatedAt: DateTime.now(),
    );
  }
  
  /// 添加子分类
  Category addSubCategory(SubCategory subCategory) {
    return copyWith(
      subCategories: [...subCategories, subCategory],
      updatedAt: DateTime.now(),
    );
  }
  
  /// 移除子分类
  Category removeSubCategory(String subCategoryName) {
    return copyWith(
      subCategories: subCategories.where((sub) => sub.name != subCategoryName).toList(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    color,
    icon,
    subCategories,
    createdAt,
    updatedAt,
    isSystem,
    isEnabled,
    usageCount,
    userId,
  ];
}

/// 子分类实体
/// 
/// 表示主分类下的细分类别
class SubCategory extends Equatable {
  /// 子分类名称
  final String name;
  
  /// 子分类图标
  final String icon;
  
  /// 使用次数
  final int usageCount;
  
  /// 是否启用
  final bool isEnabled;

  const SubCategory({
    required this.name,
    required this.icon,
    this.usageCount = 0,
    this.isEnabled = true,
  });

  /// 创建副本并修改部分字段
  SubCategory copyWith({
    String? name,
    String? icon,
    int? usageCount,
    bool? isEnabled,
  }) {
    return SubCategory(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      usageCount: usageCount ?? this.usageCount,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
  
  /// 增加使用次数
  SubCategory incrementUsage() {
    return copyWith(usageCount: usageCount + 1);
  }

  @override
  List<Object?> get props => [name, icon, usageCount, isEnabled];
}

/// 分类统计信息
/// 
/// 用于展示分类的使用统计
class CategoryStatistics {
  /// 分类ID
  final String categoryId;
  
  /// 分类名称
  final String categoryName;
  
  /// 子分类名称（可选）
  final String? subCategoryName;
  
  /// 交易总额
  final double totalAmount;
  
  /// 交易数量
  final int transactionCount;
  
  /// 占总额的百分比
  final double percentage;
  
  /// 平均交易金额
  double get averageAmount => transactionCount > 0 ? totalAmount / transactionCount : 0;

  const CategoryStatistics({
    required this.categoryId,
    required this.categoryName,
    this.subCategoryName,
    required this.totalAmount,
    required this.transactionCount,
    required this.percentage,
  });
}