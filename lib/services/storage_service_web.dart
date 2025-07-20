import 'dart:html' as html;
import 'dart:convert';
import '../models/transaction_record_hive.dart' as hive;
import 'storage_service.dart';
import 'storage_service_adapter.dart';

/// 平台特定的存储服务实现选择器（Web端）
/// 使用新架构的适配器
StorageService createStorageService() => RepositoryStorageAdapter();

/// 🌐 Web存储服务实现（localStorage）
class WebStorageService extends StorageService {
  static const String _transactionsKey = 'money_jars_transactions';
  static const String _categoriesKey = 'money_jars_categories';
  static const String _settingsKey = 'money_jars_settings';

  html.Storage get _localStorage => html.window.localStorage;

  @override
  Future<void> initialize() async {
    // Web端localStorage无需特殊初始化
    // 验证localStorage可用性
    try {
      _localStorage.containsKey('test');
    } catch (e) {
      throw StateError('localStorage is not available in this browser');
    }
  }

  @override
  Future<void> dispose() async {
    // Web端无需特别的资源释放
  }

  // ===== 交易记录操作 =====

  @override
  Future<List<hive.TransactionRecord>> getTransactions() async {
    final dataStr = _localStorage[_transactionsKey];
    if (dataStr == null || dataStr.isEmpty) return [];
    
    try {
      final List<dynamic> dataList = json.decode(dataStr);
      final transactions = dataList
          .map((json) => hive.TransactionRecord.fromJson(json as Map<String, dynamic>))
          .where((record) => !record.isArchived)
          .toList();
      
      transactions.sort((a, b) => b.date.compareTo(a.date));
      return transactions;
    } catch (e) {
      print('Error parsing transactions from localStorage: $e');
      return [];
    }
  }

  @override
  Future<hive.TransactionRecord?> getTransaction(String id) async {
    final transactions = await getTransactions();
    try {
      return transactions.where((record) => record.id == id).first;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addTransaction(hive.TransactionRecord transaction) async {
    final transactions = await getTransactions();
    transactions.add(transaction);
    await _saveTransactions(transactions);
  }

  @override
  Future<void> updateTransaction(hive.TransactionRecord transaction) async {
    final transactions = await getTransactions();
    transaction.updatedAt = DateTime.now();
    
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await _saveTransactions(transactions);
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => t.id == id);
    await _saveTransactions(transactions);
  }

  @override
  Future<void> deleteTransactions(List<String> ids) async {
    final transactions = await getTransactions();
    transactions.removeWhere((t) => ids.contains(t.id));
    await _saveTransactions(transactions);
  }

  @override
  Future<void> clearTransactions() async {
    _localStorage.remove(_transactionsKey);
  }

  Future<void> _saveTransactions(List<hive.TransactionRecord> transactions) async {
    final jsonList = transactions.map((t) => t.toJson()).toList();
    _localStorage[_transactionsKey] = json.encode(jsonList);
  }

  // ===== 自定义分类操作 =====

  @override
  Future<List<hive.Category>> getCustomCategories() async {
    final dataStr = _localStorage[_categoriesKey];
    if (dataStr == null || dataStr.isEmpty) return [];
    
    try {
      final List<dynamic> dataList = json.decode(dataStr);
      final categories = dataList
          .map((json) => hive.Category.fromJson(json as Map<String, dynamic>))
          .toList();
      
      categories.sort((a, b) => a.name.compareTo(b.name));
      return categories;
    } catch (e) {
      print('Error parsing categories from localStorage: $e');
      return [];
    }
  }

  @override
  Future<void> addCustomCategory(hive.Category category) async {
    final categories = await getCustomCategories();
    categories.add(category);
    await _saveCategories(categories);
  }

  @override
  Future<void> updateCustomCategory(hive.Category category) async {
    final categories = await getCustomCategories();
    category.updatedAt = DateTime.now();
    
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      await _saveCategories(categories);
    }
  }

  @override
  Future<void> deleteCustomCategory(String id) async {
    final categories = await getCustomCategories();
    categories.removeWhere((c) => c.id == id);
    await _saveCategories(categories);
  }

  Future<void> _saveCategories(List<hive.Category> categories) async {
    final jsonList = categories.map((c) => c.toJson()).toList();
    _localStorage[_categoriesKey] = json.encode(jsonList);
  }

  // ===== 罐头设置操作 =====

  @override
  Future<hive.JarSettings?> getJarSettings() async {
    final dataStr = _localStorage[_settingsKey];
    if (dataStr == null || dataStr.isEmpty) return null;
    
    try {
      final json = jsonDecode(dataStr) as Map<String, dynamic>;
      return hive.JarSettings.fromJson(json);
    } catch (e) {
      print('Error parsing settings from localStorage: $e');
      return null;
    }
  }

  @override
  Future<void> saveJarSettings(hive.JarSettings settings) async {
    _localStorage[_settingsKey] = json.encode(settings.toJson());
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
    _localStorage.remove(_categoriesKey);
    _localStorage.remove(_settingsKey);

    // 导入交易记录
    final transactionsData = data['transactions'] as List?;
    if (transactionsData != null) {
      final transactions = transactionsData
          .map((json) => hive.TransactionRecord.fromJson(json as Map<String, dynamic>))
          .toList();
      await _saveTransactions(transactions);
    }

    // 导入自定义分类
    final categoriesData = data['categories'] as List?;
    if (categoriesData != null) {
      final categories = categoriesData
          .map((json) => hive.Category.fromJson(json as Map<String, dynamic>))
          .toList();
      await _saveCategories(categories);
    }

    // 导入设置
    final settingsData = data['settings'] as Map<String, dynamic>?;
    if (settingsData != null) {
      final settings = hive.JarSettings.fromJson(settingsData);
      await saveJarSettings(settings);
    }
  }
}