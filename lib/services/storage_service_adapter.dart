/*
 * 存储服务适配器 (storage_service_adapter.dart)
 * 
 * 功能说明：
 * - 将新的仓库层适配为旧的StorageService接口
 * - 保持向后兼容，避免大规模修改现有代码
 * - 逐步迁移，降低风险
 * 
 * 迁移策略：
 * - 第一阶段：通过适配器使用新架构（当前）
 * - 第二阶段：逐步替换直接调用StorageService的代码
 * - 第三阶段：完全移除StorageService接口
 */

import 'package:flutter/foundation.dart';
import '../core/di/service_locator.dart';
import '../core/domain/entities/transaction.dart' as domain;
import '../core/domain/entities/category.dart' as domain;
import '../core/domain/entities/jar_settings.dart' as domain;
import '../models/transaction_record_hive.dart' as hive;
import 'storage_service.dart';

/// 新架构的存储服务适配器
/// 
/// 使用新的仓库层实现旧的StorageService接口
class RepositoryStorageAdapter extends StorageService {
  bool _initialized = false;
  
  @override
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // 初始化依赖注入
      await initServiceLocator();
      _initialized = true;
    } catch (e) {
      debugPrint('初始化存储服务失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> dispose() async {
    // 仓库层会自动管理资源
    _initialized = false;
  }
  
  // ===== 交易记录操作 =====
  
  @override
  Future<List<hive.TransactionRecord>> getTransactions() async {
    _ensureInitialized();
    
    try {
      // 从仓库获取领域实体
      final transactions = await serviceLocator.transactionRepository.getAllTransactions();
      
      // 转换为旧的数据模型
      return transactions.map(_convertTransactionToHiveModel).toList();
    } catch (e) {
      debugPrint('获取交易记录失败: $e');
      return [];
    }
  }
  
  @override
  Future<hive.TransactionRecord?> getTransaction(String id) async {
    _ensureInitialized();
    
    try {
      final transaction = await serviceLocator.transactionRepository.getTransactionById(id);
      return transaction != null ? _convertTransactionToHiveModel(transaction) : null;
    } catch (e) {
      debugPrint('获取单条交易记录失败: $e');
      return null;
    }
  }
  
  @override
  Future<void> addTransaction(hive.TransactionRecord transaction) async {
    _ensureInitialized();
    
    try {
      // 转换为领域实体
      final domainTransaction = _convertHiveModelToTransaction(transaction);
      
      // 通过仓库添加
      await serviceLocator.transactionRepository.addTransaction(domainTransaction);
      
      // 增加分类使用次数
      await serviceLocator.categoryRepository.incrementUsageCount(
        domainTransaction.parentCategoryId,
      );
    } catch (e) {
      debugPrint('添加交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updateTransaction(hive.TransactionRecord transaction) async {
    _ensureInitialized();
    
    try {
      final domainTransaction = _convertHiveModelToTransaction(transaction);
      await serviceLocator.transactionRepository.updateTransaction(domainTransaction);
    } catch (e) {
      debugPrint('更新交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteTransaction(String id) async {
    _ensureInitialized();
    
    try {
      await serviceLocator.transactionRepository.deleteTransaction(id);
    } catch (e) {
      debugPrint('删除交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteTransactions(List<String> ids) async {
    _ensureInitialized();
    
    try {
      await serviceLocator.transactionRepository.deleteTransactions(ids);
    } catch (e) {
      debugPrint('批量删除交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> clearTransactions() async {
    _ensureInitialized();
    
    try {
      await serviceLocator.transactionRepository.clearAllData();
    } catch (e) {
      debugPrint('清空交易记录失败: $e');
      rethrow;
    }
  }
  
  // ===== 自定义分类操作 =====
  
  @override
  Future<List<hive.Category>> getCustomCategories() async {
    _ensureInitialized();
    
    try {
      final categories = await serviceLocator.categoryRepository.getCustomCategories();
      return categories.map(_convertCategoryToHiveModel).toList();
    } catch (e) {
      debugPrint('获取自定义分类失败: $e');
      return [];
    }
  }
  
  @override
  Future<void> addCustomCategory(hive.Category category) async {
    _ensureInitialized();
    
    try {
      final domainCategory = _convertHiveModelToCategory(category);
      await serviceLocator.categoryRepository.addCategory(domainCategory);
    } catch (e) {
      debugPrint('添加自定义分类失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updateCustomCategory(hive.Category category) async {
    _ensureInitialized();
    
    try {
      final domainCategory = _convertHiveModelToCategory(category);
      await serviceLocator.categoryRepository.updateCategory(domainCategory);
    } catch (e) {
      debugPrint('更新自定义分类失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteCustomCategory(String id) async {
    _ensureInitialized();
    
    try {
      await serviceLocator.categoryRepository.deleteCategory(id);
    } catch (e) {
      debugPrint('删除自定义分类失败: $e');
      rethrow;
    }
  }
  
  // ===== 罐头设置操作 =====
  
  @override
  Future<hive.JarSettings?> getJarSettings() async {
    _ensureInitialized();
    
    try {
      // 获取所有罐头设置
      final allSettings = await serviceLocator.settingsRepository.getAllJarSettings();
      
      // 创建旧格式的JarSettings（包含所有罐头的设置）
      if (allSettings.isNotEmpty) {
        return _convertToHiveJarSettings(allSettings);
      }
      
      return null;
    } catch (e) {
      debugPrint('获取罐头设置失败: $e');
      return null;
    }
  }
  
  @override
  Future<void> saveJarSettings(hive.JarSettings settings) async {
    _ensureInitialized();
    
    try {
      // 分解为各个罐头的设置
      final domainSettings = _convertFromHiveJarSettings(settings);
      
      // 保存各个罐头的设置
      for (final setting in domainSettings) {
        await serviceLocator.settingsRepository.updateJarSettings(setting);
      }
    } catch (e) {
      debugPrint('保存罐头设置失败: $e');
      rethrow;
    }
  }
  
  // ===== 数据导入导出 =====
  
  @override
  Future<Map<String, dynamic>> exportAllData() async {
    _ensureInitialized();
    
    try {
      // 获取所有数据
      final transactions = await getTransactions();
      final categories = await getCustomCategories();
      final settings = await getJarSettings();
      
      return {
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'categories': categories.map((c) => c.toJson()).toList(),
        'settings': settings?.toJson(),
        'exportDate': DateTime.now().millisecondsSinceEpoch,
        'version': '1.0.0',
      };
    } catch (e) {
      debugPrint('导出数据失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> importData(Map<String, dynamic> data) async {
    _ensureInitialized();
    
    try {
      // 清空现有数据
      await clearTransactions();
      
      // 导入交易记录
      if (data.containsKey('transactions')) {
        final transactionsData = data['transactions'] as List;
        for (final transactionJson in transactionsData) {
          final transaction = hive.TransactionRecord.fromJson(
            transactionJson as Map<String, dynamic>,
          );
          await addTransaction(transaction);
        }
      }
      
      // 导入自定义分类
      if (data.containsKey('categories')) {
        final categoriesData = data['categories'] as List;
        for (final categoryJson in categoriesData) {
          final category = hive.Category.fromJson(
            categoryJson as Map<String, dynamic>,
          );
          await addCustomCategory(category);
        }
      }
      
      // 导入设置
      if (data.containsKey('settings') && data['settings'] != null) {
        final settings = hive.JarSettings.fromJson(
          data['settings'] as Map<String, dynamic>,
        );
        await saveJarSettings(settings);
      }
    } catch (e) {
      debugPrint('导入数据失败: $e');
      rethrow;
    }
  }
  
  // ===== 私有辅助方法 =====
  
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('RepositoryStorageAdapter not initialized');
    }
  }
  
  /// 将领域实体转换为Hive模型
  hive.TransactionRecord _convertTransactionToHiveModel(domain.Transaction transaction) {
    return hive.TransactionRecord()
      ..id = transaction.id
      ..amount = transaction.amount
      ..description = transaction.description
      ..parentCategory = transaction.parentCategoryName
      ..subCategory = transaction.subCategoryName ?? ''
      ..date = transaction.date
      ..createTime = transaction.createTime
      ..type = hive.TransactionType.values[transaction.type.index]
      ..isArchived = transaction.isArchived
      ..updatedAt = transaction.updatedAt ?? DateTime.now();
  }
  
  /// 将Hive模型转换为领域实体
  domain.Transaction _convertHiveModelToTransaction(hive.TransactionRecord record) {
    return domain.Transaction(
      id: record.id,
      amount: record.amount,
      description: record.description,
      parentCategoryId: record.parentCategory, // 使用名称作为ID（向后兼容）
      parentCategoryName: record.parentCategory,
      subCategoryId: record.subCategory.isNotEmpty ? record.subCategory : null,
      subCategoryName: record.subCategory.isNotEmpty ? record.subCategory : null,
      date: record.date,
      createTime: record.createTime,
      type: domain.TransactionType.values[record.type.index],
      isArchived: record.isArchived,
      updatedAt: record.updatedAt,
      notes: null,
      tags: [],
      attachments: [],
      location: null,
      userId: null,
      deviceId: null,
      syncedAt: null,
      metadata: {},
    );
  }
  
  /// 将领域分类转换为Hive模型
  hive.Category _convertCategoryToHiveModel(domain.Category category) {
    return hive.Category()
      ..id = category.id
      ..name = category.name
      ..icon = category.icon
      ..color = category.color
      ..type = category.type == domain.CategoryType.income 
          ? hive.TransactionType.income 
          : hive.TransactionType.expense
      ..subCategories = category.subCategories.map((sub) => 
        hive.SubCategory()
          ..id = sub.id
          ..name = sub.name
          ..icon = sub.icon
      ).toList()
      ..createdAt = category.createdAt
      ..updatedAt = category.updatedAt ?? DateTime.now();
  }
  
  /// 将Hive模型转换为领域分类
  domain.Category _convertHiveModelToCategory(hive.Category category) {
    return domain.Category(
      id: category.id,
      name: category.name,
      icon: category.icon,
      color: category.color,
      type: category.type == hive.TransactionType.income
          ? domain.CategoryType.income
          : domain.CategoryType.expense,
      isSystem: false, // 自定义分类
      isEnabled: true,
      subCategories: category.subCategories.map((sub) =>
        domain.SubCategory(
          id: sub.id,
          name: sub.name,
          icon: sub.icon,
        )
      ).toList(),
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      userId: null,
      usageCount: 0,
    );
  }
  
  /// 将新架构的罐头设置转换为旧格式
  hive.JarSettings _convertToHiveJarSettings(Map<domain.JarType, domain.JarSettings> settings) {
    // 获取各个罐头的设置
    final incomeSetting = settings[domain.JarType.income];
    final expenseSetting = settings[domain.JarType.expense];
    final comprehensiveSetting = settings[domain.JarType.comprehensive];
    
    return hive.JarSettings()
      ..incomeTarget = incomeSetting?.targetAmount ?? 0
      ..expenseTarget = expenseSetting?.targetAmount ?? 0
      ..comprehensiveTarget = comprehensiveSetting?.targetAmount ?? 0
      ..incomeTitle = incomeSetting?.title ?? '收入目标'
      ..expenseTitle = expenseSetting?.title ?? '支出预算'
      ..comprehensiveTitle = comprehensiveSetting?.title ?? '储蓄目标'
      ..enableReminder = expenseSetting?.enableTargetReminder ?? false
      ..reminderThreshold = expenseSetting?.reminderThreshold ?? 0.9
      ..updatedAt = DateTime.now();
  }
  
  /// 将旧格式的罐头设置转换为新架构
  List<domain.JarSettings> _convertFromHiveJarSettings(hive.JarSettings settings) {
    final now = DateTime.now();
    
    return [
      // 收入罐头
      domain.JarSettings(
        targetAmount: settings.incomeTarget,
        title: settings.incomeTitle,
        updatedAt: now,
        jarType: domain.JarType.income,
        enableTargetReminder: false,
        reminderThreshold: 0.8,
        showOnHome: true,
        displayOrder: 0,
      ),
      // 支出罐头
      domain.JarSettings(
        targetAmount: settings.expenseTarget,
        title: settings.expenseTitle,
        updatedAt: now,
        jarType: domain.JarType.expense,
        enableTargetReminder: settings.enableReminder,
        reminderThreshold: settings.reminderThreshold,
        showOnHome: true,
        displayOrder: 1,
      ),
      // 综合罐头
      domain.JarSettings(
        targetAmount: settings.comprehensiveTarget,
        title: settings.comprehensiveTitle,
        updatedAt: now,
        jarType: domain.JarType.comprehensive,
        enableTargetReminder: false,
        reminderThreshold: 0.8,
        showOnHome: true,
        displayOrder: 2,
      ),
    ];
  }
}