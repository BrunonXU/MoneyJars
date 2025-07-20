/*
 * Hive数据源 (hive_datasource.dart)
 * 
 * 功能说明：
 * - 封装Hive数据库的所有操作
 * - 提供统一的本地数据访问接口
 * - 支持Web和移动端的不同实现
 * 
 * 迁移说明：
 * - 从storage_service.dart迁移核心功能
 * - 使用新的数据模型
 * - 保持接口稳定，便于测试
 */

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/transaction_model.dart';
import '../../models/category_model.dart';
import '../../models/jar_settings_model.dart';
import '../../../domain/entities/transaction.dart';

/// 本地数据源抽象接口
/// 
/// 定义所有本地数据操作的接口
abstract class LocalDataSource {
  /// 初始化数据源
  Future<void> initialize();
  
  /// 释放资源
  Future<void> dispose();
  
  // ===== 交易记录操作 =====
  
  /// 获取所有交易记录
  Future<List<TransactionModel>> getAllTransactions();
  
  /// 根据类型获取交易记录
  Future<List<TransactionModel>> getTransactionsByType(TransactionType type);
  
  /// 根据日期范围获取交易记录
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
  
  /// 根据ID获取单条交易记录
  Future<TransactionModel?> getTransactionById(String id);
  
  /// 添加交易记录
  Future<void> addTransaction(TransactionModel transaction);
  
  /// 更新交易记录
  Future<void> updateTransaction(TransactionModel transaction);
  
  /// 删除交易记录
  Future<void> deleteTransaction(String id);
  
  /// 批量删除交易记录
  Future<void> deleteTransactions(List<String> ids);
  
  // ===== 分类操作 =====
  
  /// 获取所有分类（包括系统预设和自定义）
  Future<List<CategoryModel>> getAllCategories();
  
  /// 获取自定义分类
  Future<List<CategoryModel>> getCustomCategories();
  
  /// 添加自定义分类
  Future<void> addCategory(CategoryModel category);
  
  /// 更新分类
  Future<void> updateCategory(CategoryModel category);
  
  /// 删除分类
  Future<void> deleteCategory(String id);
  
  // ===== 罐头设置操作 =====
  
  /// 获取所有罐头设置
  Future<List<JarSettingsModel>> getAllJarSettings();
  
  /// 获取特定罐头的设置
  Future<JarSettingsModel?> getJarSettings(int jarTypeIndex);
  
  /// 保存罐头设置
  Future<void> saveJarSettings(JarSettingsModel settings);
  
  // ===== 数据导入导出 =====
  
  /// 导出所有数据
  Future<Map<String, dynamic>> exportAllData();
  
  /// 导入数据
  Future<void> importData(Map<String, dynamic> data);
  
  /// 清空所有数据
  Future<void> clearAllData();
}

/// Hive本地数据源实现
/// 
/// 使用Hive数据库存储数据
class HiveLocalDataSource implements LocalDataSource {
  static const String _transactionsBoxName = 'transactions_v2';
  static const String _categoriesBoxName = 'categories_v2';
  static const String _settingsBoxName = 'jar_settings_v2';
  
  Box<TransactionModel>? _transactionsBox;
  Box<CategoryModel>? _categoriesBox;
  Box<JarSettingsModel>? _settingsBox;
  
  /// 是否已初始化系统分类
  bool _systemCategoriesInitialized = false;
  
  @override
  Future<void> initialize() async {
    // Web平台使用不同的初始化方式
    if (kIsWeb) {
      // Web平台不需要特殊初始化
    } else {
      await Hive.initFlutter();
    }
    
    // 注册适配器（如果尚未注册）
    _registerAdapters();
    
    // 打开数据盒子
    _transactionsBox = await Hive.openBox<TransactionModel>(_transactionsBoxName);
    _categoriesBox = await Hive.openBox<CategoryModel>(_categoriesBoxName);
    _settingsBox = await Hive.openBox<JarSettingsModel>(_settingsBoxName);
    
    // 初始化默认数据
    await _initializeDefaultData();
  }
  
  /// 注册Hive适配器
  void _registerAdapters() {
    // 注册枚举适配器
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }
    
    // 注册模型适配器
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SubCategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(JarSettingsModelAdapter());
    }
  }
  
  /// 初始化默认数据
  Future<void> _initializeDefaultData() async {
    // 初始化系统预设分类
    if (!_systemCategoriesInitialized && _categoriesBox != null) {
      final existingCategories = _categoriesBox!.values.toList();
      if (existingCategories.isEmpty || 
          !existingCategories.any((cat) => cat.isSystem)) {
        // 添加默认分类
        final defaultIncomeCategories = DefaultCategoriesData.getDefaultIncomeCategories();
        final defaultExpenseCategories = DefaultCategoriesData.getDefaultExpenseCategories();
        
        for (final category in [...defaultIncomeCategories, ...defaultExpenseCategories]) {
          await _categoriesBox!.add(category);
        }
        
        _systemCategoriesInitialized = true;
      }
    }
    
    // 初始化默认罐头设置
    if (_settingsBox != null && _settingsBox!.isEmpty) {
      final defaultSettings = JarSettingsModel.createDefaultSettings();
      for (int i = 0; i < defaultSettings.length; i++) {
        await _settingsBox!.put(i, defaultSettings[i]);
      }
    }
  }
  
  @override
  Future<void> dispose() async {
    await _transactionsBox?.close();
    await _categoriesBox?.close();
    await _settingsBox?.close();
  }
  
  // ===== 交易记录操作实现 =====
  
  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    _ensureInitialized();
    
    final transactions = _transactionsBox!.values
        .where((tx) => !tx.isArchived)
        .toList();
    
    // 按日期降序排序
    transactions.sort((a, b) => b.date.compareTo(a.date));
    
    return transactions;
  }
  
  @override
  Future<List<TransactionModel>> getTransactionsByType(TransactionType type) async {
    _ensureInitialized();
    
    final transactions = _transactionsBox!.values
        .where((tx) => !tx.isArchived && tx.typeIndex == type.index)
        .toList();
    
    transactions.sort((a, b) => b.date.compareTo(a.date));
    
    return transactions;
  }
  
  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _ensureInitialized();
    
    final transactions = _transactionsBox!.values
        .where((tx) => 
            !tx.isArchived &&
            tx.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            tx.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
    
    transactions.sort((a, b) => b.date.compareTo(a.date));
    
    return transactions;
  }
  
  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    _ensureInitialized();
    
    return _transactionsBox!.values
        .where((tx) => tx.id == id)
        .firstOrNull;
  }
  
  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    _ensureInitialized();
    
    await _transactionsBox!.add(transaction);
  }
  
  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    _ensureInitialized();
    
    // 更新时间戳
    transaction.updatedAt = DateTime.now();
    
    // 如果是HiveObject，直接保存
    if (transaction.isInBox) {
      await transaction.save();
    } else {
      // 否则找到原记录并更新
      final index = _transactionsBox!.values
          .toList()
          .indexWhere((tx) => tx.id == transaction.id);
      
      if (index != -1) {
        await _transactionsBox!.putAt(index, transaction);
      }
    }
  }
  
  @override
  Future<void> deleteTransaction(String id) async {
    _ensureInitialized();
    
    final transaction = await getTransactionById(id);
    if (transaction != null && transaction.isInBox) {
      await transaction.delete();
    }
  }
  
  @override
  Future<void> deleteTransactions(List<String> ids) async {
    _ensureInitialized();
    
    for (final id in ids) {
      await deleteTransaction(id);
    }
  }
  
  // ===== 分类操作实现 =====
  
  @override
  Future<List<CategoryModel>> getAllCategories() async {
    _ensureInitialized();
    
    final categories = _categoriesBox!.values
        .where((cat) => cat.isEnabled)
        .toList();
    
    // 按使用频率排序
    categories.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    
    return categories;
  }
  
  @override
  Future<List<CategoryModel>> getCustomCategories() async {
    _ensureInitialized();
    
    final categories = _categoriesBox!.values
        .where((cat) => !cat.isSystem && cat.isEnabled)
        .toList();
    
    categories.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    
    return categories;
  }
  
  @override
  Future<void> addCategory(CategoryModel category) async {
    _ensureInitialized();
    
    await _categoriesBox!.add(category);
  }
  
  @override
  Future<void> updateCategory(CategoryModel category) async {
    _ensureInitialized();
    
    category.updatedAt = DateTime.now();
    
    if (category.isInBox) {
      await category.save();
    } else {
      final index = _categoriesBox!.values
          .toList()
          .indexWhere((cat) => cat.id == category.id);
      
      if (index != -1) {
        await _categoriesBox!.putAt(index, category);
      }
    }
  }
  
  @override
  Future<void> deleteCategory(String id) async {
    _ensureInitialized();
    
    final category = _categoriesBox!.values
        .where((cat) => cat.id == id && !cat.isSystem)
        .firstOrNull;
    
    if (category != null && category.isInBox) {
      await category.delete();
    }
  }
  
  // ===== 罐头设置操作实现 =====
  
  @override
  Future<List<JarSettingsModel>> getAllJarSettings() async {
    _ensureInitialized();
    
    final settings = <JarSettingsModel>[];
    
    // 按jarTypeIndex顺序获取
    for (int i = 0; i < 3; i++) {
      final setting = _settingsBox!.get(i);
      if (setting != null) {
        settings.add(setting);
      }
    }
    
    return settings;
  }
  
  @override
  Future<JarSettingsModel?> getJarSettings(int jarTypeIndex) async {
    _ensureInitialized();
    
    return _settingsBox!.get(jarTypeIndex);
  }
  
  @override
  Future<void> saveJarSettings(JarSettingsModel settings) async {
    _ensureInitialized();
    
    settings.updatedAt = DateTime.now();
    await _settingsBox!.put(settings.jarTypeIndex, settings);
  }
  
  // ===== 数据导入导出实现 =====
  
  @override
  Future<Map<String, dynamic>> exportAllData() async {
    _ensureInitialized();
    
    final transactions = _transactionsBox!.values
        .map((tx) => tx.toJson())
        .toList();
    
    final categories = _categoriesBox!.values
        .where((cat) => !cat.isSystem)
        .map((cat) => cat.toJson())
        .toList();
    
    final settings = <String, dynamic>{};
    for (int i = 0; i < 3; i++) {
      final setting = _settingsBox!.get(i);
      if (setting != null) {
        settings[i.toString()] = setting.toJson();
      }
    }
    
    return {
      'version': '2.0',
      'exportDate': DateTime.now().toIso8601String(),
      'transactions': transactions,
      'categories': categories,
      'jarSettings': settings,
    };
  }
  
  @override
  Future<void> importData(Map<String, dynamic> data) async {
    _ensureInitialized();
    
    // 导入交易记录
    if (data.containsKey('transactions')) {
      final transactions = (data['transactions'] as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
      
      for (final transaction in transactions) {
        await _transactionsBox!.add(transaction);
      }
    }
    
    // 导入自定义分类
    if (data.containsKey('categories')) {
      final categories = (data['categories'] as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
      
      for (final category in categories) {
        await _categoriesBox!.add(category);
      }
    }
    
    // 导入罐头设置
    if (data.containsKey('jarSettings')) {
      final settings = data['jarSettings'] as Map<String, dynamic>;
      for (final entry in settings.entries) {
        final index = int.parse(entry.key);
        final setting = JarSettingsModel.fromJson(entry.value);
        await _settingsBox!.put(index, setting);
      }
    }
  }
  
  @override
  Future<void> clearAllData() async {
    _ensureInitialized();
    
    await _transactionsBox!.clear();
    await _categoriesBox!.clear();
    await _settingsBox!.clear();
    
    // 重新初始化默认数据
    _systemCategoriesInitialized = false;
    await _initializeDefaultData();
  }
  
  /// 确保已初始化
  void _ensureInitialized() {
    if (_transactionsBox == null || 
        _categoriesBox == null || 
        _settingsBox == null) {
      throw StateError('HiveLocalDataSource not initialized');
    }
  }
}

/// 枚举适配器 - TransactionType
class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 0;

  @override
  TransactionType read(BinaryReader reader) {
    return TransactionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    writer.writeByte(obj.index);
  }
}