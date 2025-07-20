import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_record_hive.dart' as hive;
import 'storage_service.dart';
import 'storage_service_adapter.dart';

/// 平台特定的存储服务实现选择器（移动端）
/// 使用新架构的适配器
StorageService createStorageService() => RepositoryStorageAdapter();

/// 📱 Hive存储服务实现（移动端）
class HiveStorageService extends StorageService {
  static const String _transactionsBoxName = 'transactions';
  static const String _categoriesBoxName = 'custom_categories';
  static const String _settingsBoxName = 'jar_settings';

  Box<hive.TransactionRecord>? _transactionsBox;
  Box<hive.Category>? _categoriesBox;
  Box<hive.JarSettings>? _settingsBox;

  @override
  Future<void> initialize() async {
    // 初始化Hive Flutter
    await Hive.initFlutter();
    
    // 注册Hive适配器
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(hive.TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(hive.TransactionRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(hive.CategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(hive.SubCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(hive.JarSettingsAdapter());
    }

    // 打开Hive box
    _transactionsBox = await Hive.openBox<hive.TransactionRecord>(_transactionsBoxName);
    _categoriesBox = await Hive.openBox<hive.Category>(_categoriesBoxName);
    _settingsBox = await Hive.openBox<hive.JarSettings>(_settingsBoxName);
  }

  @override
  Future<void> dispose() async {
    await _transactionsBox?.close();
    await _categoriesBox?.close();
    await _settingsBox?.close();
  }

  // ===== 交易记录操作 =====

  @override
  Future<List<hive.TransactionRecord>> getTransactions() async {
    final box = _transactionsBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    return box.values.where((record) => !record.isArchived).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<hive.TransactionRecord?> getTransaction(String id) async {
    final box = _transactionsBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    return box.values.where((record) => record.id == id).firstOrNull;
  }

  @override
  Future<void> addTransaction(hive.TransactionRecord transaction) async {
    final box = _transactionsBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    await box.add(transaction);
  }

  @override
  Future<void> updateTransaction(hive.TransactionRecord transaction) async {
    final box = _transactionsBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    transaction.updatedAt = DateTime.now();
    await transaction.save();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final box = _transactionsBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    final transaction = box.values.where((record) => record.id == id).firstOrNull;
    if (transaction != null) {
      await transaction.delete();
    }
  }

  @override
  Future<void> deleteTransactions(List<String> ids) async {
    final box = _transactionsBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    for (final id in ids) {
      final transaction = box.values.where((record) => record.id == id).firstOrNull;
      if (transaction != null) {
        await transaction.delete();
      }
    }
  }

  @override
  Future<void> clearTransactions() async {
    final box = _transactionsBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    await box.clear();
  }

  // ===== 自定义分类操作 =====

  @override
  Future<List<hive.Category>> getCustomCategories() async {
    final box = _categoriesBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    return box.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Future<void> addCustomCategory(hive.Category category) async {
    final box = _categoriesBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    await box.add(category);
  }

  @override
  Future<void> updateCustomCategory(hive.Category category) async {
    final box = _categoriesBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    category.updatedAt = DateTime.now();
    await category.save();
  }

  @override
  Future<void> deleteCustomCategory(String id) async {
    final box = _categoriesBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    final category = box.values.where((cat) => cat.id == id).firstOrNull;
    if (category != null) {
      await category.delete();
    }
  }

  // ===== 罐头设置操作 =====

  @override
  Future<hive.JarSettings?> getJarSettings() async {
    final box = _settingsBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    return box.values.firstOrNull;
  }

  @override
  Future<void> saveJarSettings(hive.JarSettings settings) async {
    final box = _settingsBox;
    if (box == null) throw StateError('HiveStorageService not initialized');
    
    await box.clear();
    await box.add(settings);
  }

  // ===== 数据导入导出 =====

  @override
  Future<Map<String, dynamic>> exportAllData() async {
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
  }

  @override
  Future<void> importData(Map<String, dynamic> data) async {
    // 清空现有数据
    await clearTransactions();
    await _categoriesBox?.clear();
    await _settingsBox?.clear();

    // 导入交易记录
    final transactionsData = data['transactions'] as List?;
    if (transactionsData != null) {
      for (final transactionJson in transactionsData) {
        final transaction = hive.TransactionRecord.fromJson(transactionJson as Map<String, dynamic>);
        await addTransaction(transaction);
      }
    }

    // 导入自定义分类
    final categoriesData = data['categories'] as List?;
    if (categoriesData != null) {
      for (final categoryJson in categoriesData) {
        final category = hive.Category.fromJson(categoryJson as Map<String, dynamic>);
        await addCustomCategory(category);
      }
    }

    // 导入设置
    final settingsData = data['settings'] as Map<String, dynamic>?;
    if (settingsData != null) {
      final settings = hive.JarSettings.fromJson(settingsData);
      await saveJarSettings(settings);
    }
  }
}