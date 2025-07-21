/*
 * 默认分类数据 (default_categories.dart)
 * 
 * 功能说明：
 * - 提供系统预设的收支分类
 * - 初始化时自动创建
 */

import '../../models/category_model.dart' hide SubCategoryModel;
import '../../models/subcategory_model.dart';
import '../../../domain/entities/transaction.dart';

/// 默认分类数据提供者
class DefaultCategoriesData {
  /// 获取默认收入分类
  static List<CategoryModel> getDefaultIncomeCategories() {
    return [
      CategoryModel()
        ..id = 'income_salary'
        ..name = '工资'
        ..typeIndex = TransactionType.income.index
        ..color = 0xFF4CAF50
        ..icon = '💰'
        ..subCategories = [
          SubCategoryModel(
            name: '基本工资',
            icon: '💵',
          ),
          SubCategoryModel(
            name: '奖金',
            icon: '🎁',
          ),
          SubCategoryModel(
            name: '补贴',
            icon: '💸',
          ),
        ]
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0,
      CategoryModel()
        ..id = 'income_investment'
        ..name = '投资'
        ..typeIndex = TransactionType.income.index
        ..color = 0xFF2196F3
        ..icon = '📈'
        ..subCategories = [
          SubCategoryModel(
            name: '股票',
            icon: '📊',
          ),
          SubCategoryModel(
            name: '基金',
            icon: '💹',
          ),
          SubCategoryModel(
            name: '理财',
            icon: '🏦',
          ),
        ]
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0,
      CategoryModel()
        ..id = 'income_other'
        ..name = '其他收入'
        ..typeIndex = TransactionType.income.index
        ..color = 0xFFFFD700
        ..icon = '🎯'
        ..subCategories = [
          SubCategoryModel(
            name: '兼职',
            icon: '👨‍💼',
          ),
          SubCategoryModel(
            name: '礼金',
            icon: '🧧',
          ),
          SubCategoryModel(
            name: '其他',
            icon: '📦',
          ),
        ]
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0,
    ];
  }

  /// 获取默认支出分类
  static List<CategoryModel> getDefaultExpenseCategories() {
    return [
      CategoryModel()
        ..id = 'expense_food'
        ..name = '餐饮'
        ..typeIndex = TransactionType.expense.index
        ..color = 0xFFFF5722
        ..icon = '🍔'
        ..subCategories = [
          SubCategoryModel(
            name: '早餐',
            icon: '🥐',
          ),
          SubCategoryModel(
            name: '午餐',
            icon: '🍱',
          ),
          SubCategoryModel(
            name: '晚餐',
            icon: '🍽️',
          ),
          SubCategoryModel(
            name: '外卖',
            icon: '📦',
          ),
        ]
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0,
      CategoryModel()
        ..id = 'expense_shopping'
        ..name = '购物'
        ..typeIndex = TransactionType.expense.index
        ..color = 0xFFE91E63
        ..icon = '🛍️'
        ..subCategories = [
          SubCategoryModel(
            name: '服装',
            icon: '👔',
          ),
          SubCategoryModel(
            name: '日用品',
            icon: '🧴',
          ),
          SubCategoryModel(
            name: '电子产品',
            icon: '📱',
          ),
        ]
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0,
      CategoryModel()
        ..id = 'expense_transport'
        ..name = '交通'
        ..typeIndex = TransactionType.expense.index
        ..color = 0xFF9C27B0
        ..icon = '🚗'
        ..subCategories = [
          SubCategoryModel(
            name: '公交地铁',
            icon: '🚇',
          ),
          SubCategoryModel(
            name: '打车',
            icon: '🚕',
          ),
          SubCategoryModel(
            name: '加油',
            icon: '⛽',
          ),
        ]
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0,
      CategoryModel()
        ..id = 'expense_entertainment'
        ..name = '娱乐'
        ..typeIndex = TransactionType.expense.index
        ..color = 0xFF3F51B5
        ..icon = '🎮'
        ..subCategories = [
          SubCategoryModel(
            name: '电影',
            icon: '🎬',
          ),
          SubCategoryModel(
            name: '游戏',
            icon: '🎯',
          ),
          SubCategoryModel(
            name: '旅游',
            icon: '✈️',
          ),
        ]
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0,
      CategoryModel()
        ..id = 'expense_housing'
        ..name = '住房'
        ..typeIndex = TransactionType.expense.index
        ..color = 0xFF795548
        ..icon = '🏠'
        ..subCategories = [
          SubCategoryModel(
            name: '房租',
            icon: '🏢',
          ),
          SubCategoryModel(
            name: '水电费',
            icon: '💡',
          ),
          SubCategoryModel(
            name: '物业费',
            icon: '🏘️',
          ),
        ]
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0,
    ];
  }
}