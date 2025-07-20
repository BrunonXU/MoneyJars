/*
 * 默认分类数据 (default_categories_data.dart)
 * 
 * 功能说明：
 * - 提供系统预设的收支分类
 * - 包含常用的分类和子分类
 * - 支持中文界面
 * 
 * 分类设计：
 * - 收入分类：工资、投资、副业等
 * - 支出分类：饮食、交通、购物等
 * - 每个分类都有对应的图标和颜色
 */

import 'category_model.dart';
import 'package:flutter/material.dart';

/// 默认分类数据提供者
class DefaultCategoriesData {
  /// 获取默认的收入分类
  static List<CategoryModel> getDefaultIncomeCategories() {
    final now = DateTime.now();
    
    return [
      CategoryModel()
        ..id = 'income_salary'
        ..name = '工资收入'
        ..icon = '💰'
        ..color = Colors.green.value
        ..typeIndex = 0 // income
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0
        ..subCategories = [
          SubCategoryModel()
            ..id = 'salary_basic'
            ..name = '基本工资'
            ..icon = '💵',
          SubCategoryModel()
            ..id = 'salary_bonus'
            ..name = '奖金'
            ..icon = '🎁',
          SubCategoryModel()
            ..id = 'salary_overtime'
            ..name = '加班费'
            ..icon = '⏰',
        ]
        ..createdAt = now
        ..updatedAt = now,
      
      CategoryModel()
        ..id = 'income_investment'
        ..name = '投资理财'
        ..icon = '📈'
        ..color = Colors.blue.value
        ..typeIndex = 0 // income
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0
        ..subCategories = [
          SubCategoryModel()
            ..id = 'invest_stock'
            ..name = '股票'
            ..icon = '📊',
          SubCategoryModel()
            ..id = 'invest_fund'
            ..name = '基金'
            ..icon = '💹',
          SubCategoryModel()
            ..id = 'invest_interest'
            ..name = '利息'
            ..icon = '🏦',
        ]
        ..createdAt = now
        ..updatedAt = now,
      
      CategoryModel()
        ..id = 'income_business'
        ..name = '副业收入'
        ..icon = '💼'
        ..color = Colors.orange.value
        ..typeIndex = 0 // income
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0
        ..subCategories = [
          SubCategoryModel()
            ..id = 'business_freelance'
            ..name = '兼职'
            ..icon = '👨‍💻',
          SubCategoryModel()
            ..id = 'business_shop'
            ..name = '店铺'
            ..icon = '🏪',
        ]
        ..createdAt = now
        ..updatedAt = now,
      
      CategoryModel()
        ..id = 'income_other'
        ..name = '其他收入'
        ..icon = '💸'
        ..color = Colors.purple.value
        ..typeIndex = 0 // income
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0
        ..subCategories = [
          SubCategoryModel()
            ..id = 'other_gift'
            ..name = '礼金'
            ..icon = '🎁',
          SubCategoryModel()
            ..id = 'other_refund'
            ..name = '退款'
            ..icon = '💱',
        ]
        ..createdAt = now
        ..updatedAt = now,
    ];
  }
  
  /// 获取默认的支出分类
  static List<CategoryModel> getDefaultExpenseCategories() {
    final now = DateTime.now();
    
    return [
      CategoryModel()
        ..id = 'expense_food'
        ..name = '饮食'
        ..icon = '🍔'
        ..color = Colors.red.value
        ..typeIndex = 1 // expense
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0
        ..subCategories = [
          SubCategoryModel()
            ..id = 'food_breakfast'
            ..name = '早餐'
            ..icon = '🥐',
          SubCategoryModel()
            ..id = 'food_lunch'
            ..name = '午餐'
            ..icon = '🍱',
          SubCategoryModel()
            ..id = 'food_dinner'
            ..name = '晚餐'
            ..icon = '🍽️',
          SubCategoryModel()
            ..id = 'food_snack'
            ..name = '零食'
            ..icon = '🍿',
        ]
        ..createdAt = now
        ..updatedAt = now,
      
      CategoryModel()
        ..id = 'expense_transport'
        ..name = '交通'
        ..icon = '🚗'
        ..color = Colors.indigo.value
        ..typeIndex = 1 // expense
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0
        ..subCategories = [
          SubCategoryModel()
            ..id = 'transport_bus'
            ..name = '公交地铁'
            ..icon = '🚇',
          SubCategoryModel()
            ..id = 'transport_taxi'
            ..name = '打车'
            ..icon = '🚕',
          SubCategoryModel()
            ..id = 'transport_fuel'
            ..name = '加油'
            ..icon = '⛽',
        ]
        ..createdAt = now
        ..updatedAt = now,
      
      CategoryModel()
        ..id = 'expense_shopping'
        ..name = '购物'
        ..icon = '🛍️'
        ..color = Colors.pink.value
        ..typeIndex = 1 // expense
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0
        ..subCategories = [
          SubCategoryModel()
            ..id = 'shopping_clothes'
            ..name = '服装'
            ..icon = '👔',
          SubCategoryModel()
            ..id = 'shopping_daily'
            ..name = '日用品'
            ..icon = '🧴',
          SubCategoryModel()
            ..id = 'shopping_digital'
            ..name = '数码'
            ..icon = '📱',
        ]
        ..createdAt = now
        ..updatedAt = now,
      
      CategoryModel()
        ..id = 'expense_entertainment'
        ..name = '娱乐'
        ..icon = '🎮'
        ..color = Colors.teal.value
        ..typeIndex = 1 // expense
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0
        ..subCategories = [
          SubCategoryModel()
            ..id = 'entertain_movie'
            ..name = '电影'
            ..icon = '🎬',
          SubCategoryModel()
            ..id = 'entertain_game'
            ..name = '游戏'
            ..icon = '🎯',
          SubCategoryModel()
            ..id = 'entertain_sport'
            ..name = '运动'
            ..icon = '⚽',
        ]
        ..createdAt = now
        ..updatedAt = now,
      
      CategoryModel()
        ..id = 'expense_housing'
        ..name = '居住'
        ..icon = '🏠'
        ..color = Colors.brown.value
        ..typeIndex = 1 // expense
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0
        ..subCategories = [
          SubCategoryModel()
            ..id = 'housing_rent'
            ..name = '房租'
            ..icon = '🏘️',
          SubCategoryModel()
            ..id = 'housing_utility'
            ..name = '水电费'
            ..icon = '💡',
          SubCategoryModel()
            ..id = 'housing_internet'
            ..name = '网费'
            ..icon = '📶',
        ]
        ..createdAt = now
        ..updatedAt = now,
      
      CategoryModel()
        ..id = 'expense_medical'
        ..name = '医疗健康'
        ..icon = '🏥'
        ..color = Colors.lightBlue.value
        ..typeIndex = 1 // expense
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0
        ..subCategories = [
          SubCategoryModel()
            ..id = 'medical_hospital'
            ..name = '看病'
            ..icon = '🩺',
          SubCategoryModel()
            ..id = 'medical_medicine'
            ..name = '买药'
            ..icon = '💊',
        ]
        ..createdAt = now
        ..updatedAt = now,
      
      CategoryModel()
        ..id = 'expense_education'
        ..name = '教育学习'
        ..icon = '📚'
        ..color = Colors.deepPurple.value
        ..typeIndex = 1 // expense
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0
        ..subCategories = [
          SubCategoryModel()
            ..id = 'edu_course'
            ..name = '课程'
            ..icon = '🎓',
          SubCategoryModel()
            ..id = 'edu_book'
            ..name = '书籍'
            ..icon = '📖',
        ]
        ..createdAt = now
        ..updatedAt = now,
      
      CategoryModel()
        ..id = 'expense_other'
        ..name = '其他支出'
        ..icon = '📌'
        ..color = Colors.grey.value
        ..typeIndex = 1 // expense
        ..isSystem = true
        ..isEnabled = true
        ..usageCount = 0
        ..subCategories = []
        ..createdAt = now
        ..updatedAt = now,
    ];
  }
}