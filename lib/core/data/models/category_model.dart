/*
 * 分类数据模型 (category_model.dart)
 * 
 * 功能说明：
 * - 用于数据存储和传输的分类模型
 * - 支持Hive数据库和JSON序列化
 * - 与领域实体Category相互转换
 * 
 * 迁移说明：
 * - 基于现有的Category结构
 * - 保持向后兼容性
 * - 支持自定义分类的持久化
 */

import 'package:hive/hive.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';

part 'category_model.g.dart';

/// 分类数据模型
@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late int typeIndex; // TransactionType枚举的索引

  @HiveField(3)
  late int color;

  @HiveField(4)
  late String icon;

  @HiveField(5)
  late List<SubCategoryModel> subCategories;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  late DateTime updatedAt;
  
  @HiveField(8, defaultValue: false)
  late bool isSystem;
  
  @HiveField(9, defaultValue: true)
  late bool isEnabled;
  
  @HiveField(10, defaultValue: 0)
  late int usageCount;
  
  @HiveField(11)
  String? userId;

  CategoryModel();

  /// 从领域实体创建数据模型
  factory CategoryModel.fromEntity(Category entity) {
    final model = CategoryModel()
      ..id = entity.id
      ..name = entity.name
      ..typeIndex = entity.type.index
      ..color = entity.color
      ..icon = entity.icon
      ..subCategories = entity.subCategories
          .map((sub) => SubCategoryModel.fromEntity(sub))
          .toList()
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..isSystem = entity.isSystem
      ..isEnabled = entity.isEnabled
      ..usageCount = entity.usageCount
      ..userId = entity.userId;
    
    return model;
  }

  /// 转换为领域实体
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      type: TransactionType.values[typeIndex],
      color: color,
      icon: icon,
      subCategories: subCategories.map((sub) => sub.toEntity()).toList(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSystem: isSystem,
      isEnabled: isEnabled,
      usageCount: usageCount,
      userId: userId,
    );
  }

  /// 从JSON创建
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final model = CategoryModel()
      ..id = json['id'] as String
      ..name = json['name'] as String
      ..typeIndex = json['typeIndex'] as int? ?? json['type'] as int
      ..color = json['color'] as int
      ..icon = json['icon'] as String
      ..subCategories = (json['subCategories'] as List)
          .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
          .toList()
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
      ..updatedAt = DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
      ..isSystem = json['isSystem'] as bool? ?? false
      ..isEnabled = json['isEnabled'] as bool? ?? true
      ..usageCount = json['usageCount'] as int? ?? 0
      ..userId = json['userId'] as String?;
    
    return model;
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'typeIndex': typeIndex,
      'type': typeIndex, // 向后兼容
      'color': color,
      'icon': icon,
      'subCategories': subCategories.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isSystem': isSystem,
      'isEnabled': isEnabled,
      'usageCount': usageCount,
      'userId': userId,
    };
  }
}

/// 子分类数据模型
@HiveType(typeId: 3)
class SubCategoryModel extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String icon;
  
  @HiveField(2, defaultValue: 0)
  late int usageCount;
  
  @HiveField(3, defaultValue: true)
  late bool isEnabled;

  SubCategoryModel();

  /// 从领域实体创建数据模型
  factory SubCategoryModel.fromEntity(SubCategory entity) {
    final model = SubCategoryModel()
      ..name = entity.name
      ..icon = entity.icon
      ..usageCount = entity.usageCount
      ..isEnabled = entity.isEnabled;
    
    return model;
  }

  /// 转换为领域实体
  SubCategory toEntity() {
    return SubCategory(
      name: name,
      icon: icon,
      usageCount: usageCount,
      isEnabled: isEnabled,
    );
  }

  /// 从JSON创建
  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel()
      ..name = json['name'] as String
      ..icon = json['icon'] as String
      ..usageCount = json['usageCount'] as int? ?? 0
      ..isEnabled = json['isEnabled'] as bool? ?? true;
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'usageCount': usageCount,
      'isEnabled': isEnabled,
    };
  }
}

/// 预定义分类数据
/// 迁移自DefaultCategories，保持数据不变
class DefaultCategoriesData {
  /// 获取默认收入分类
  static List<CategoryModel> getDefaultIncomeCategories() {
    return [
      CategoryModel.fromJson({
        'id': 'income_salary',
        'name': '工资',
        'typeIndex': TransactionType.income.index,
        'color': 0xFF81C784,
        'icon': '💼',
        'isSystem': true,
        'subCategories': [
          {'name': '基本工资', 'icon': '💰'},
          {'name': '奖金', 'icon': '⭐'},
          {'name': '加班费', 'icon': '⏰'},
        ],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
      CategoryModel.fromJson({
        'id': 'income_parttime',
        'name': '兼职',
        'typeIndex': TransactionType.income.index,
        'color': 0xFF64B5F6,
        'icon': '💼',
        'isSystem': true,
        'subCategories': [
          {'name': '自由职业', 'icon': '💻'},
          {'name': '临时工', 'icon': '🔧'},
          {'name': '咨询', 'icon': '🧠'},
        ],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
      CategoryModel.fromJson({
        'id': 'income_investment',
        'name': '投资',
        'typeIndex': TransactionType.income.index,
        'color': 0xFF4DB6AC,
        'icon': '📈',
        'isSystem': true,
        'subCategories': [
          {'name': '股票', 'icon': '📊'},
          {'name': '基金', 'icon': '🥧'},
          {'name': '理财', 'icon': '💾'},
        ],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
      CategoryModel.fromJson({
        'id': 'income_other',
        'name': '其他',
        'typeIndex': TransactionType.income.index,
        'color': 0xFF90A4AE,
        'icon': '⋯',
        'isSystem': true,
        'subCategories': [
          {'name': '礼金', 'icon': '🎁'},
          {'name': '退款', 'icon': '↩️'},
          {'name': '意外收入', 'icon': '💰'},
        ],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
    ];
  }

  /// 获取默认支出分类
  static List<CategoryModel> getDefaultExpenseCategories() {
    return [
      CategoryModel.fromJson({
        'id': 'expense_food',
        'name': '餐饮',
        'typeIndex': TransactionType.expense.index,
        'color': 0xFFFFAB91,
        'icon': '🍽️',
        'isSystem': true,
        'subCategories': [
          {'name': '早餐', 'icon': '🥐'},
          {'name': '午餐', 'icon': '🍱'},
          {'name': '晚餐', 'icon': '🍽️'},
          {'name': '零食', 'icon': '🍪'},
          {'name': '饮料', 'icon': '🥤'},
        ],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
      CategoryModel.fromJson({
        'id': 'expense_transport',
        'name': '交通',
        'typeIndex': TransactionType.expense.index,
        'color': 0xFF90CAF9,
        'icon': '🚗',
        'isSystem': true,
        'subCategories': [
          {'name': '公交', 'icon': '🚌'},
          {'name': '地铁', 'icon': '🚇'},
          {'name': '打车', 'icon': '🚕'},
          {'name': '油费', 'icon': '⛽'},
        ],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
      CategoryModel.fromJson({
        'id': 'expense_shopping',
        'name': '购物',
        'typeIndex': TransactionType.expense.index,
        'color': 0xFFCE93D8,
        'icon': '🛍️',
        'isSystem': true,
        'subCategories': [
          {'name': '服装', 'icon': '👕'},
          {'name': '日用品', 'icon': '🛒'},
          {'name': '电子产品', 'icon': '📱'},
          {'name': '化妆品', 'icon': '💄'},
        ],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
      CategoryModel.fromJson({
        'id': 'expense_entertainment',
        'name': '娱乐',
        'typeIndex': TransactionType.expense.index,
        'color': 0xFFF48FB1,
        'icon': '🎬',
        'isSystem': true,
        'subCategories': [
          {'name': '电影', 'icon': '🎬'},
          {'name': '游戏', 'icon': '🎮'},
          {'name': '旅游', 'icon': '✈️'},
          {'name': '运动', 'icon': '⚽'},
        ],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
      CategoryModel.fromJson({
        'id': 'expense_medical',
        'name': '医疗',
        'typeIndex': TransactionType.expense.index,
        'color': 0xFFEF9A9A,
        'icon': '🏥',
        'isSystem': true,
        'subCategories': [
          {'name': '挂号费', 'icon': '📋'},
          {'name': '药费', 'icon': '💊'},
          {'name': '检查费', 'icon': '🔬'},
          {'name': '住院费', 'icon': '🏨'},
        ],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
      CategoryModel.fromJson({
        'id': 'expense_other',
        'name': '其他',
        'typeIndex': TransactionType.expense.index,
        'color': 0xFFBCAAA4,
        'icon': '⋯',
        'isSystem': true,
        'subCategories': [
          {'name': '转账', 'icon': '💸'},
          {'name': '手续费', 'icon': '🧾'},
          {'name': '杂费', 'icon': '📦'},
        ],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
    ];
  }
}