/*
 * 简化版分类仓库实现 (category_repository_simple_impl.dart)
 * 
 * 功能说明：
 * - 实现分类仓库接口的基本功能
 * - 提供分类CRUD操作
 */

import 'package:flutter/foundation.dart' hide Category;
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/category_model.dart';

/// 简化版分类仓库实现类
class CategoryRepositoryImpl implements CategoryRepository {
  final LocalDataSource _localDataSource;
  
  CategoryRepositoryImpl({
    required LocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;
  
  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final models = await _localDataSource.getAllCategories();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      print('Error getting all categories: $e');
      return [];
    }
  }
  
  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    try {
      final allCategories = await getAllCategories();
      return allCategories.where((cat) => cat.type == type).toList();
    } catch (e) {
      print('Error getting categories by type: $e');
      return [];
    }
  }
  
  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      final model = await _localDataSource.getCategory(id);
      return model?.toEntity();
    } catch (e) {
      print('Error getting category by id: $e');
      return null;
    }
  }
  
  @override
  Future<void> addCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await _localDataSource.saveCategory(model);
    } catch (e) {
      print('Error adding category: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updateCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await _localDataSource.updateCategory(model);
    } catch (e) {
      print('Error updating category: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _localDataSource.deleteCategory(id);
    } catch (e) {
      print('Error deleting category: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteCategories(List<String> ids) async {
    for (final id in ids) {
      await deleteCategory(id);
    }
  }
  
  @override
  Future<List<Category>> searchCategories({
    String? keyword,
    CategoryType? type,
  }) async {
    final categories = await getAllCategories();
    return categories.where((cat) {
      final matchesKeyword = keyword == null || 
        cat.name.toLowerCase().contains(keyword.toLowerCase());
      final matchesType = type == null || cat.type == type;
      return matchesKeyword && matchesType;
    }).toList();
  }
  
  @override
  Future<Map<String, int>> getCategoryUsageStats() async {
    final categories = await getAllCategories();
    return Map.fromEntries(
      categories.map((cat) => MapEntry(cat.id, cat.usageCount))
    );
  }
  
  @override
  Future<void> incrementUsageCount(String categoryId) async {
    final category = await getCategoryById(categoryId);
    if (category != null) {
      await updateCategory(category.incrementUsage());
    }
  }
  
  @override
  Future<void> resetUsageCount(String categoryId) async {
    final category = await getCategoryById(categoryId);
    if (category != null) {
      await updateCategory(category.copyWith(usageCount: 0));
    }
  }
  
  @override
  Future<bool> isCategoryInUse(String categoryId) async {
    // 简化实现：假设所有分类都可能被使用
    return false;
  }
  
  @override
  Future<Category> getDefaultCategory(CategoryType type) async {
    final categories = await getCategoriesByType(type);
    if (categories.isEmpty) {
      // 创建默认分类
      final defaultCategory = Category(
        id: 'default_${type.name}',
        name: type == CategoryType.income ? '默认收入' : '默认支出',
        type: type,
        color: type == CategoryType.income ? 0xFFFFD700 : 0xFFDC143C,
        icon: '💰',
        subCategories: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSystem: true,
      );
      await addCategory(defaultCategory);
      return defaultCategory;
    }
    return categories.first;
  }
  
  @override
  Future<String> exportCategories() async {
    // 简化实现
    return 'export not implemented';
  }
  
  @override
  Future<void> importCategories(String data) async {
    // 简化实现
  }
  
  @override
  Future<void> toggleCategoryStatus(String categoryId) async {
    final category = await getCategoryById(categoryId);
    if (category != null) {
      await updateCategory(category.copyWith(isEnabled: !category.isEnabled));
    }
  }
  
  @override
  Future<void> clearAllCategories() async {
    final categories = await getAllCategories();
    for (final cat in categories) {
      if (!cat.isSystem) {
        await deleteCategory(cat.id);
      }
    }
  }
}