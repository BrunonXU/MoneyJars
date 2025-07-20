/*
 * 分类仓库接口 (category_repository.dart)
 * 
 * 功能说明：
 * - 定义分类数据访问的抽象接口
 * - 支持收入/支出分类管理
 * - 提供分类统计功能
 * 
 * 设计原则：
 * - 依赖倒置：域层定义接口，数据层实现
 * - 支持多种数据源
 * - 面向接口编程
 */

import '../entities/category.dart';

/// 分类仓库接口
/// 
/// 定义分类相关的数据操作接口
abstract class CategoryRepository {
  /// 获取所有分类
  Future<List<Category>> getAllCategories();
  
  /// 根据类型获取分类
  Future<List<Category>> getCategoriesByType(CategoryType type);
  
  /// 根据ID获取分类
  Future<Category?> getCategoryById(String id);
  
  /// 添加分类
  Future<void> addCategory(Category category);
  
  /// 更新分类
  Future<void> updateCategory(Category category);
  
  /// 删除分类
  Future<void> deleteCategory(String id);
  
  /// 批量删除分类
  Future<void> deleteCategories(List<String> ids);
  
  /// 搜索分类
  Future<List<Category>> searchCategories({
    String? keyword,
    CategoryType? type,
  });
  
  /// 获取分类使用统计
  Future<Map<String, int>> getCategoryUsageStats();
  
  /// 增加分类使用次数
  Future<void> incrementUsageCount(String categoryId);
  
  /// 重置分类使用次数
  Future<void> resetUsageCount(String categoryId);
  
  /// 检查分类是否被使用
  Future<bool> isCategoryInUse(String categoryId);
  
  /// 获取默认分类
  Future<Category> getDefaultCategory(CategoryType type);
  
  /// 导出分类数据
  Future<String> exportCategories();
  
  /// 导入分类数据
  Future<void> importCategories(String data);
  
  /// 清空所有分类
  Future<void> clearAllCategories();
}