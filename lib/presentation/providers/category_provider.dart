/*
 * 分类状态管理 (category_provider.dart)
 * 
 * 功能说明：
 * - 管理收支分类的状态
 * - 处理系统分类和自定义分类
 * - 提供分类的增删改查功能
 * 
 * 业务逻辑：
 * - 系统分类不可删除，只能禁用
 * - 自定义分类支持完整操作
 * - 分类使用频率自动统计
 */

import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/domain/entities/category.dart';
import '../../core/domain/repositories/category_repository.dart';

/// 分类状态管理器
/// 
/// 管理：
/// - 系统预设分类
/// - 用户自定义分类
/// - 分类的子分类
/// - 使用频率统计
class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _categoryRepository;
  
  /// 所有分类（系统 + 自定义）
  List<Category> _allCategories = [];
  
  /// 收入分类缓存
  List<Category> _incomeCategories = [];
  
  /// 支出分类缓存
  List<Category> _expenseCategories = [];
  
  /// 是否正在加载
  bool _isLoading = false;
  
  /// 错误信息
  String? _errorMessage;
  
  /// 当前编辑的分类
  Category? _editingCategory;
  
  CategoryProvider({
    CategoryRepository? categoryRepository,
  }) : _categoryRepository = categoryRepository ?? serviceLocator.categoryRepository;
  
  // ===== Getters =====
  
  /// 获取所有分类
  List<Category> get allCategories => _allCategories;
  
  /// 获取收入分类
  List<Category> get incomeCategories => _incomeCategories;
  
  /// 获取支出分类
  List<Category> get expenseCategories => _expenseCategories;
  
  /// 获取启用的收入分类
  List<Category> get enabledIncomeCategories => 
      _incomeCategories.where((cat) => cat.isEnabled).toList();
  
  /// 获取启用的支出分类
  List<Category> get enabledExpenseCategories => 
      _expenseCategories.where((cat) => cat.isEnabled).toList();
  
  /// 获取自定义分类
  List<Category> get customCategories => 
      _allCategories.where((cat) => !cat.isSystem).toList();
  
  /// 获取系统分类
  List<Category> get systemCategories => 
      _allCategories.where((cat) => cat.isSystem).toList();
  
  /// 是否正在加载
  bool get isLoading => _isLoading;
  
  /// 错误信息
  String? get errorMessage => _errorMessage;
  
  /// 当前编辑的分类
  Category? get editingCategory => _editingCategory;
  
  // ===== 初始化和加载 =====
  
  /// 初始化数据
  Future<void> initialize() async {
    await loadCategories();
  }
  
  /// 加载所有分类
  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();
    
    try {
      _allCategories = await _categoryRepository.getAllCategories();
      _updateCategoryCaches();
      notifyListeners();
    } catch (e) {
      _setError('加载分类失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== 分类查询 =====
  
  /// 根据ID获取分类
  Category? getCategoryById(String id) {
    try {
      return _allCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// 根据名称获取分类
  Category? getCategoryByName(String name, CategoryType type) {
    try {
      return _allCategories.firstWhere(
        (cat) => cat.name == name && cat.type == type,
      );
    } catch (e) {
      return null;
    }
  }
  
  /// 获取分类的子分类
  List<SubCategory> getSubCategories(String categoryId) {
    final category = getCategoryById(categoryId);
    return category?.subCategories ?? [];
  }
  
  /// 获取常用分类
  List<Category> getFrequentlyUsedCategories({
    int limit = 5,
    CategoryType? type,
  }) {
    List<Category> categories = _allCategories;
    
    if (type != null) {
      categories = categories.where((cat) => cat.type == type).toList();
    }
    
    // 按使用次数排序
    categories.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    
    return categories.take(limit).toList();
  }
  
  // ===== 分类操作 =====
  
  /// 添加自定义分类
  Future<void> addCategory(Category category) async {
    _setLoading(true);
    _clearError();
    
    try {
      // 确保不是系统分类
      final newCategory = Category(
        id: category.id,
        name: category.name,
        icon: category.icon,
        color: category.color,
        type: category.type,
        isSystem: false,
        isEnabled: true,
        subCategories: category.subCategories,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: category.userId,
        usageCount: 0,
      );
      
      await _categoryRepository.addCategory(newCategory);
      
      // 添加到本地列表
      _allCategories.add(newCategory);
      _updateCategoryCaches();
      notifyListeners();
    } catch (e) {
      _setError('添加分类失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 更新分类
  Future<void> updateCategory(Category category) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _categoryRepository.updateCategory(category);
      
      // 更新本地列表
      final index = _allCategories.indexWhere((cat) => cat.id == category.id);
      if (index != -1) {
        _allCategories[index] = category;
        _updateCategoryCaches();
        notifyListeners();
      }
    } catch (e) {
      _setError('更新分类失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 删除自定义分类
  Future<void> deleteCategory(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      final category = getCategoryById(id);
      if (category == null) {
        throw Exception('分类不存在');
      }
      
      if (category.isSystem) {
        throw Exception('系统分类不能删除');
      }
      
      await _categoryRepository.deleteCategory(id);
      
      // 从本地列表移除
      _allCategories.removeWhere((cat) => cat.id == id);
      _updateCategoryCaches();
      notifyListeners();
    } catch (e) {
      _setError('删除分类失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 切换分类启用状态
  Future<void> toggleCategoryStatus(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _categoryRepository.toggleCategoryStatus(id);
      
      // 更新本地状态
      final index = _allCategories.indexWhere((cat) => cat.id == id);
      if (index != -1) {
        final category = _allCategories[index];
        _allCategories[index] = Category(
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
        _updateCategoryCaches();
        notifyListeners();
      }
    } catch (e) {
      _setError('切换分类状态失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== 子分类操作 =====
  
  /// 添加子分类到现有分类
  Future<void> addSubCategory(
    String parentCategoryId,
    SubCategory subCategory,
  ) async {
    _setLoading(true);
    _clearError();
    
    try {
      final category = getCategoryById(parentCategoryId);
      if (category == null) {
        throw Exception('父分类不存在');
      }
      
      // 创建更新后的分类
      final updatedCategory = Category(
        id: category.id,
        name: category.name,
        icon: category.icon,
        color: category.color,
        type: category.type,
        isSystem: category.isSystem,
        isEnabled: category.isEnabled,
        subCategories: [...category.subCategories, subCategory],
        createdAt: category.createdAt,
        updatedAt: DateTime.now(),
        userId: category.userId,
        usageCount: category.usageCount,
      );
      
      await updateCategory(updatedCategory);
    } catch (e) {
      _setError('添加子分类失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 更新子分类
  Future<void> updateSubCategory(
    String parentCategoryId,
    SubCategory subCategory,
  ) async {
    _setLoading(true);
    _clearError();
    
    try {
      final category = getCategoryById(parentCategoryId);
      if (category == null) {
        throw Exception('父分类不存在');
      }
      
      // 更新子分类列表
      final subCategories = category.subCategories.map((sub) {
        if (sub.name == subCategory.name) {
          return subCategory;
        }
        return sub;
      }).toList();
      
      // 创建更新后的分类
      final updatedCategory = Category(
        id: category.id,
        name: category.name,
        icon: category.icon,
        color: category.color,
        type: category.type,
        isSystem: category.isSystem,
        isEnabled: category.isEnabled,
        subCategories: subCategories,
        createdAt: category.createdAt,
        updatedAt: DateTime.now(),
        userId: category.userId,
        usageCount: category.usageCount,
      );
      
      await updateCategory(updatedCategory);
    } catch (e) {
      _setError('更新子分类失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 删除子分类
  Future<void> deleteSubCategory(
    String parentCategoryId,
    String subCategoryId,
  ) async {
    _setLoading(true);
    _clearError();
    
    try {
      final category = getCategoryById(parentCategoryId);
      if (category == null) {
        throw Exception('父分类不存在');
      }
      
      // 移除子分类
      final subCategories = category.subCategories
          .where((sub) => sub.name != subCategoryId)
          .toList();
      
      // 创建更新后的分类
      final updatedCategory = Category(
        id: category.id,
        name: category.name,
        icon: category.icon,
        color: category.color,
        type: category.type,
        isSystem: category.isSystem,
        isEnabled: category.isEnabled,
        subCategories: subCategories,
        createdAt: category.createdAt,
        updatedAt: DateTime.now(),
        userId: category.userId,
        usageCount: category.usageCount,
      );
      
      await updateCategory(updatedCategory);
    } catch (e) {
      _setError('删除子分类失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== 编辑状态管理 =====
  
  /// 设置当前编辑的分类
  void setEditingCategory(Category? category) {
    _editingCategory = category;
    notifyListeners();
  }
  
  /// 清除编辑状态
  void clearEditingCategory() {
    _editingCategory = null;
    notifyListeners();
  }
  
  // ===== 私有方法 =====
  
  /// 更新分类缓存
  void _updateCategoryCaches() {
    _incomeCategories = _allCategories
        .where((cat) => cat.type == CategoryType.income)
        .toList();
    
    _expenseCategories = _allCategories
        .where((cat) => cat.type == CategoryType.expense)
        .toList();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
}