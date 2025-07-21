import 'package:flutter/material.dart';
import '../models/transaction_record_hive.dart' as hive;
import '../services/storage_service.dart';

class TransactionProvider extends ChangeNotifier {
  final StorageService _storageService = StorageServiceFactory.getInstance();
  
  List<hive.TransactionRecord> _transactions = [];
  List<hive.Category> _customCategories = [];
  hive.JarSettings _jarSettings = hive.JarSettings.create(
    targetAmount: 1000.0,
    title: '我的储蓄罐',
  );

  // 缓存相关字段
  double? _cachedTotalIncome;
  double? _cachedTotalExpense;
  double? _cachedNetIncome;
  Map<hive.TransactionType, Map<String, double>>? _cachedCategoryStats;
  DateTime? _lastCacheUpdate;
  
  // 缓存有效期（毫秒）
  static const int _cacheValidityDuration = 60000; // 1分钟

  // Getters
  List<hive.TransactionRecord> get transactions => _transactions;
  List<hive.Category> get customCategories => _customCategories;
  hive.JarSettings get jarSettings => _jarSettings;

  // 获取收入记录
  List<hive.TransactionRecord> get incomeRecords => 
      _transactions.where((t) => t.type == hive.TransactionType.income).toList();

  // 获取支出记录
  List<hive.TransactionRecord> get expenseRecords => 
      _transactions.where((t) => t.type == hive.TransactionType.expense).toList();

  // 获取未归档的记录
  List<hive.TransactionRecord> get unArchivedRecords => 
      _transactions.where((t) => !t.isArchived).toList();

  // 检查缓存是否有效
  bool get _isCacheValid {
    if (_lastCacheUpdate == null) return false;
    return DateTime.now().difference(_lastCacheUpdate!).inMilliseconds < _cacheValidityDuration;
  }

  // 清除缓存
  void _clearCache() {
    _cachedTotalIncome = null;
    _cachedTotalExpense = null;
    _cachedNetIncome = null;
    _cachedCategoryStats = null;
    _lastCacheUpdate = null;
  }

  // 计算总收入（带缓存）
  double get totalIncome {
    if (_isCacheValid && _cachedTotalIncome != null) {
      return _cachedTotalIncome!;
    }
    _cachedTotalIncome = incomeRecords.fold<double>(0.0, (sum, record) => sum + record.amount);
    _lastCacheUpdate = DateTime.now();
    return _cachedTotalIncome!;
  }

  // 计算总支出（带缓存）
  double get totalExpense {
    if (_isCacheValid && _cachedTotalExpense != null) {
      return _cachedTotalExpense!;
    }
    _cachedTotalExpense = expenseRecords.fold<double>(0.0, (sum, record) => sum + record.amount);
    _lastCacheUpdate = DateTime.now();
    return _cachedTotalExpense!;
  }

  // 计算净收入（带缓存）
  double get netIncome {
    if (_isCacheValid && _cachedNetIncome != null) {
      return _cachedNetIncome!;
    }
    _cachedNetIncome = totalIncome - totalExpense;
    return _cachedNetIncome!;
  }

  // 获取罐头进度 (0.0 - 1.0)
  double get jarProgress => _jarSettings.targetAmount > 0 
      ? (netIncome / _jarSettings.targetAmount).clamp(0.0, 1.0) 
      : 0.0;

  // 获取所有分类 (预定义 + 自定义)
  List<hive.Category> getAllCategories(hive.TransactionType type) {
    List<hive.Category> defaultCategories = type == hive.TransactionType.income 
        ? hive.DefaultCategories.incomeCategories 
        : hive.DefaultCategories.expenseCategories;
    
    List<hive.Category> typeCustomCategories = _customCategories
        .where((c) => c.type == type)
        .toList();

    return [...defaultCategories, ...typeCustomCategories];
  }

  // 获取指定大类别的子分类
  List<hive.SubCategory> getSubCategories(String parentCategoryName, hive.TransactionType type) {
    final allCategories = getAllCategories(type);
    final parentCategory = allCategories.firstWhere(
      (cat) => cat.name == parentCategoryName,
      orElse: () => allCategories.first,
    );
    return parentCategory.subCategories;
  }

  // 根据分类计算统计数据（带缓存）
  Map<String, double> getCategoryStats(hive.TransactionType type) {
    // 检查缓存
    if (_isCacheValid && _cachedCategoryStats != null && _cachedCategoryStats![type] != null) {
      return Map.from(_cachedCategoryStats![type]!);
    }

    // 计算统计数据
    List<hive.TransactionRecord> records = type == hive.TransactionType.income 
        ? incomeRecords 
        : expenseRecords;

    Map<String, double> stats = {};
    for (var record in records) {
      stats[record.parentCategory] = (stats[record.parentCategory] ?? 0) + record.amount;
    }
    
    // 更新缓存
    _cachedCategoryStats ??= {};
    _cachedCategoryStats![type] = Map.from(stats);
    _lastCacheUpdate = DateTime.now();
    
    return stats;
  }

  // 根据子分类计算统计数据
  Map<String, double> getSubCategoryStats(String parentCategory, hive.TransactionType type) {
    List<hive.TransactionRecord> records = type == hive.TransactionType.income 
        ? incomeRecords 
        : expenseRecords;

    Map<String, double> stats = {};
    for (var record in records.where((r) => r.parentCategory == parentCategory)) {
      stats[record.subCategory] = (stats[record.subCategory] ?? 0) + record.amount;
    }
    return stats;
  }

  // 初始化数据
  Future<void> initializeData() async {
    await _storageService.initialize();
    await _loadTransactions();
    await _loadCustomCategories();
    await _loadJarSettings();
  }

  // 加载交易记录
  Future<void> _loadTransactions() async {
    try {
      _transactions = await _storageService.getTransactions();
      notifyListeners();
    } catch (e) {
      debugPrint('加载交易记录失败: $e');
    }
  }

  // 加载自定义分类
  Future<void> _loadCustomCategories() async {
    try {
      _customCategories = await _storageService.getCustomCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('加载自定义分类失败: $e');
    }
  }

  // 加载罐头设置
  Future<void> _loadJarSettings() async {
    try {
      final settings = await _storageService.getJarSettings();
      if (settings != null) {
        _jarSettings = settings;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('加载罐头设置失败: $e');
    }
  }

  // 添加交易记录
  Future<void> addTransaction(hive.TransactionRecord transaction) async {
    try {
      await _storageService.addTransaction(transaction);
      _transactions.add(transaction);
      _clearCache(); // 清除缓存
      notifyListeners();
    } catch (e) {
      debugPrint('添加交易记录失败: $e');
      rethrow;
    }
  }

  // 更新交易记录
  Future<void> updateTransaction(hive.TransactionRecord transaction) async {
    try {
      await _storageService.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        _clearCache(); // 清除缓存
        notifyListeners();
      }
    } catch (e) {
      debugPrint('更新交易记录失败: $e');
      rethrow;
    }
  }

  // 删除交易记录
  Future<void> deleteTransaction(String id) async {
    try {
      await _storageService.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      _clearCache(); // 清除缓存
      notifyListeners();
    } catch (e) {
      debugPrint('删除交易记录失败: $e');
      rethrow;
    }
  }

  // 添加自定义分类
  Future<void> addCustomCategory(hive.Category category) async {
    try {
      await _storageService.addCustomCategory(category);
      _customCategories.add(category);
      notifyListeners();
    } catch (e) {
      debugPrint('添加自定义分类失败: $e');
      rethrow;
    }
  }

  // 添加子分类到现有分类
  Future<void> addSubCategoryToExisting(String parentCategoryName, hive.TransactionType type, hive.SubCategory subCategory) async {
    try {
      // 查找现有分类
      final categoryIndex = _customCategories.indexWhere(
        (cat) => cat.name == parentCategoryName && cat.type == type,
      );
      
      if (categoryIndex != -1) {
        // 更新现有自定义分类
        final updatedCategory = hive.Category.create(
          id: _customCategories[categoryIndex].id,
          name: _customCategories[categoryIndex].name,
          color: _customCategories[categoryIndex].color,
          icon: _customCategories[categoryIndex].icon,
          type: _customCategories[categoryIndex].type,
          subCategories: [..._customCategories[categoryIndex].subCategories, subCategory],
        );
        
        await _storageService.updateCustomCategory(updatedCategory);
        _customCategories[categoryIndex] = updatedCategory;
      } else {
        // 检查是否是默认分类，如果是，创建自定义版本
        final defaultCategories = type == hive.TransactionType.income 
            ? hive.DefaultCategories.incomeCategories 
            : hive.DefaultCategories.expenseCategories;
        
        final defaultCategory = defaultCategories.firstWhere(
          (cat) => cat.name == parentCategoryName,
          orElse: () => throw Exception('分类不存在'),
        );
        
        final newCategory = hive.Category.create(
          id: 'custom_${defaultCategory.id}',
          name: defaultCategory.name,
          color: defaultCategory.color,
          icon: defaultCategory.icon,
          type: defaultCategory.type,
          subCategories: [...defaultCategory.subCategories, subCategory],
        );
        
        await addCustomCategory(newCategory);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('添加子分类失败: $e');
      rethrow;
    }
  }

  // 更新罐头设置
  Future<void> updateJarSettings(hive.JarSettings settings) async {
    try {
      await _storageService.saveJarSettings(settings);
      _jarSettings = settings;
      notifyListeners();
    } catch (e) {
      debugPrint('更新罐头设置失败: $e');
      rethrow;
    }
  }

  // 归档交易记录
  Future<void> archiveTransaction(String id) async {
    try {
      final transaction = _transactions.firstWhere((t) => t.id == id);
      final archivedTransaction = transaction.copyWith(isArchived: true);
      await updateTransaction(archivedTransaction);
    } catch (e) {
      debugPrint('归档交易记录失败: $e');
      rethrow;
    }
  }

  // 清空所有数据
  Future<void> clearAllData() async {
    try {
      await _storageService.clearTransactions();
      _transactions.clear();
      _customCategories.clear();
      _jarSettings = hive.JarSettings.create(targetAmount: 1000.0, title: '我的储蓄罐');
      notifyListeners();
    } catch (e) {
      debugPrint('清空数据失败: $e');
      rethrow;
    }
  }
} 