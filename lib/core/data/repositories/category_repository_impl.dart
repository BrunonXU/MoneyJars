/*
 * 分类仓库实现 (category_repository_impl.dart)
 * 
 * 功能说明：
 * - 实现分类仓库接口，管理收支分类数据
 * - 处理系统预设分类和自定义分类
 * - 提供分类使用统计和管理功能
 * 
 * 业务规则：
 * - 系统预设分类不可删除，但可以禁用
 * - 自定义分类支持完整的CRUD操作
 * - 分类使用次数自动统计
 */

import 'package:flutter/foundation.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/category_model.dart';

/// 分类仓库实现类
/// 
/// 管理：
/// - 系统预设分类
/// - 用户自定义分类
/// - 分类使用统计
/// - 分类启用/禁用状态
class CategoryRepositoryImpl implements CategoryRepository {
  final LocalDataSource _localDataSource;
  
  /// 分类缓存
  List<Category>? _cachedCategories;
  DateTime? _lastCacheTime;
  static const Duration _cacheExpiration = Duration(minutes: 10);
  
  CategoryRepositoryImpl({
    required LocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;
  
  /// 检查缓存是否有效
  bool _isCacheValid() {
    return _cachedCategories != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < _cacheExpiration;
  }
  
  /// 清除缓存
  void _clearCache() {
    _cachedCategories = null;
    _lastCacheTime = null;
  }
  
  @override
  Future<List<Category>> getAllCategories() async {
    try {
      // 检查缓存
      if (_isCacheValid()) {
        return _cachedCategories!;
      }
      
      // 从数据源获取
      final models = await _localDataSource.getAllCategories();
      
      // 转换为领域实体
      final categories = models.map((model) => model.toEntity()).toList();
      
      // 更新缓存
      _cachedCategories = categories;
      _lastCacheTime = DateTime.now();
      
      return categories;
    } catch (e) {
      debugPrint('获取所有分类失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<Category>> getCategoriesByType(CategoryType type) async {
    try {
      final allCategories = await getAllCategories();
      return allCategories
          .where((category) => category.type == type)
          .toList();
    } catch (e) {
      debugPrint('按类型获取分类失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<Category>> getSystemCategories() async {
    try {
      final allCategories = await getAllCategories();
      return allCategories
          .where((category) => category.isSystem)
          .toList();
    } catch (e) {
      debugPrint('获取系统分类失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<Category>> getCustomCategories() async {
    try {
      final models = await _localDataSource.getCustomCategories();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      debugPrint('获取自定义分类失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      final allCategories = await getAllCategories();
      return allCategories
          .where((category) => category.id == id)
          .firstOrNull;
    } catch (e) {
      debugPrint('根据ID获取分类失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<Category> addCategory(Category category) async {
    try {
      // 确保不是系统分类
      if (category.isSystem) {
        throw Exception('不能添加系统分类');
      }
      
      // 转换为数据模型
      final model = CategoryModel.fromEntity(category);
      
      // 保存到数据源
      await _localDataSource.addCategory(model);
      
      // 清除缓存
      _clearCache();
      
      return category;
    } catch (e) {
      debugPrint('添加分类失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updateCategory(Category category) async {
    try {
      // 系统分类只能更新部分字段
      if (category.isSystem) {
        // 只允许更新启用状态等有限字段
        final existingCategory = await getCategoryById(category.id);
        if (existingCategory == null) {
          throw Exception('分类不存在');
        }
        
        // 创建一个只更新允许字段的副本
        final updatedCategory = Category(
          id: existingCategory.id,
          name: existingCategory.name,
          icon: existingCategory.icon,
          color: existingCategory.color,
          type: existingCategory.type,
          isSystem: true,
          isEnabled: category.isEnabled,
          subCategories: existingCategory.subCategories,
          createdAt: existingCategory.createdAt,
          updatedAt: DateTime.now(),
          userId: existingCategory.userId,
          usageCount: existingCategory.usageCount,
        );
        
        final model = CategoryModel.fromEntity(updatedCategory);
        await _localDataSource.updateCategory(model);
      } else {
        // 自定义分类可以完全更新
        final model = CategoryModel.fromEntity(category);
        await _localDataSource.updateCategory(model);
      }
      
      // 清除缓存
      _clearCache();
    } catch (e) {
      debugPrint('更新分类失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteCategory(String id) async {
    try {
      // 检查是否是系统分类
      final category = await getCategoryById(id);
      if (category == null) {
        throw Exception('分类不存在');
      }
      
      if (category.isSystem) {
        throw Exception('系统分类不能删除');
      }
      
      // 删除分类
      await _localDataSource.deleteCategory(id);
      
      // 清除缓存
      _clearCache();
    } catch (e) {
      debugPrint('删除分类失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> toggleCategoryStatus(String id) async {
    try {
      final category = await getCategoryById(id);
      if (category == null) {
        throw Exception('分类不存在');
      }
      
      // 切换启用状态
      final updatedCategory = Category(
        id: category.id,
        name: category.name,
        icon: category.icon,
        color: category.color,
        type: category.type,
        isSystem: category.isSystem,
        isEnabled: !category.isEnabled,
        subCategories: category.subCategories,
        createdAt: category.createdAt,
        updatedAt: DateTime.now(),
        userId: category.userId,
        usageCount: category.usageCount,
      );
      
      await updateCategory(updatedCategory);
    } catch (e) {
      debugPrint('切换分类状态失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> incrementUsageCount(String categoryId) async {
    try {
      final category = await getCategoryById(categoryId);
      if (category == null) {
        throw Exception('分类不存在');
      }
      
      // 增加使用次数
      final updatedCategory = Category(
        id: category.id,
        name: category.name,
        icon: category.icon,
        color: category.color,
        type: category.type,
        isSystem: category.isSystem,
        isEnabled: category.isEnabled,
        subCategories: category.subCategories,
        createdAt: category.createdAt,
        updatedAt: category.updatedAt,
        userId: category.userId,
        usageCount: category.usageCount + 1,
      );
      
      final model = CategoryModel.fromEntity(updatedCategory);
      await _localDataSource.updateCategory(model);
      
      // 更新缓存中的数据
      if (_cachedCategories != null) {
        final index = _cachedCategories!.indexWhere((c) => c.id == categoryId);
        if (index != -1) {
          _cachedCategories![index] = updatedCategory;
        }
      }
    } catch (e) {
      debugPrint('增加分类使用次数失败: $e');
      // 不抛出异常，避免影响主流程
    }
  }
  
  @override
  Future<List<Category>> getFrequentlyUsedCategories({
    int limit = 5,
    CategoryType? type,
  }) async {
    try {
      List<Category> categories;
      
      if (type != null) {
        categories = await getCategoriesByType(type);
      } else {
        categories = await getAllCategories();
      }
      
      // 按使用次数排序
      categories.sort((a, b) => b.usageCount.compareTo(a.usageCount));
      
      // 返回前N个
      return categories.take(limit).toList();
    } catch (e) {
      debugPrint('获取常用分类失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<Map<String, List<Category>>> getCategoriesGroupedByType() async {
    try {
      final allCategories = await getAllCategories();
      
      final groupedCategories = <String, List<Category>>{};
      
      // 按类型分组
      for (final type in CategoryType.values) {
        groupedCategories[type.toString()] = allCategories
            .where((category) => category.type == type)
            .toList();
      }
      
      return groupedCategories;
    } catch (e) {
      debugPrint('获取分组分类失败: $e');
      rethrow;
    }
  }
}