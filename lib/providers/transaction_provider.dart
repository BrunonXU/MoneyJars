import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_record.dart';
import '../services/database_service.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<TransactionRecord> _transactions = [];
  List<Category> _customCategories = [];
  JarSettings _jarSettings = JarSettings(
    targetAmount: 1000.0,
    title: '我的储蓄罐',
  );

  // Getters
  List<TransactionRecord> get transactions => _transactions;
  List<Category> get customCategories => _customCategories;
  JarSettings get jarSettings => _jarSettings;

  // 获取收入记录
  List<TransactionRecord> get incomeRecords => 
      _transactions.where((t) => t.type == TransactionType.income).toList();

  // 获取支出记录
  List<TransactionRecord> get expenseRecords => 
      _transactions.where((t) => t.type == TransactionType.expense).toList();

  // 获取未归档的记录
  List<TransactionRecord> get unArchivedRecords => 
      _transactions.where((t) => !t.isArchived).toList();

  // 计算总收入
  double get totalIncome => incomeRecords.fold(0.0, (sum, record) => sum + record.amount);

  // 计算总支出
  double get totalExpense => expenseRecords.fold(0.0, (sum, record) => sum + record.amount);

  // 计算净收入
  double get netIncome => totalIncome - totalExpense;

  // 获取罐头进度 (0.0 - 1.0)
  double get jarProgress => _jarSettings.targetAmount > 0 
      ? (netIncome / _jarSettings.targetAmount).clamp(0.0, 1.0) 
      : 0.0;

  // 获取所有分类 (预定义 + 自定义)
  List<Category> getAllCategories(TransactionType type) {
    List<Category> defaultCategories = type == TransactionType.income 
        ? DefaultCategories.incomeCategories 
        : DefaultCategories.expenseCategories;
    
    List<Category> typeCustomCategories = _customCategories
        .where((c) => c.type == type)
        .toList();

    return [...defaultCategories, ...typeCustomCategories];
  }

  // 获取指定大类别的子分类
  List<SubCategory> getSubCategories(String parentCategoryName, TransactionType type) {
    final allCategories = getAllCategories(type);
    final parentCategory = allCategories.firstWhere(
      (cat) => cat.name == parentCategoryName,
      orElse: () => allCategories.first,
    );
    return parentCategory.subCategories;
  }

  // 根据分类计算统计数据
  Map<String, double> getCategoryStats(TransactionType type) {
    List<TransactionRecord> records = type == TransactionType.income 
        ? incomeRecords 
        : expenseRecords;

    Map<String, double> stats = {};
    for (var record in records) {
      stats[record.parentCategory] = (stats[record.parentCategory] ?? 0) + record.amount;
    }
    return stats;
  }

  // 根据子分类计算统计数据
  Map<String, double> getSubCategoryStats(String parentCategory, TransactionType type) {
    List<TransactionRecord> records = type == TransactionType.income 
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
    await _databaseService.initDatabase();
    await _loadTransactions();
    await _loadCustomCategories();
    await _loadJarSettings();
  }

  // 加载交易记录
  Future<void> _loadTransactions() async {
    try {
      _transactions = await _databaseService.getTransactions();
      notifyListeners();
    } catch (e) {
      debugPrint('加载交易记录失败: $e');
    }
  }

  // 加载自定义分类
  Future<void> _loadCustomCategories() async {
    try {
      _customCategories = await _databaseService.getCustomCategories();
      notifyListeners();
    } catch (e) {
      debugPrint('加载自定义分类失败: $e');
    }
  }

  // 加载罐头设置
  Future<void> _loadJarSettings() async {
    try {
      final settings = await _databaseService.getJarSettings();
      if (settings != null) {
        _jarSettings = settings;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('加载罐头设置失败: $e');
    }
  }

  // 添加交易记录
  Future<void> addTransaction(TransactionRecord transaction) async {
    try {
      await _databaseService.insertTransaction(transaction);
      _transactions.add(transaction);
      notifyListeners();
    } catch (e) {
      debugPrint('添加交易记录失败: $e');
      rethrow;
    }
  }

  // 更新交易记录
  Future<void> updateTransaction(TransactionRecord transaction) async {
    try {
      await _databaseService.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
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
      await _databaseService.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('删除交易记录失败: $e');
      rethrow;
    }
  }

  // 添加自定义分类
  Future<void> addCustomCategory(Category category) async {
    try {
      await _databaseService.insertCustomCategory(category);
      _customCategories.add(category);
      notifyListeners();
    } catch (e) {
      debugPrint('添加自定义分类失败: $e');
      rethrow;
    }
  }

  // 添加子分类到现有分类
  Future<void> addSubCategoryToExisting(String parentCategoryName, TransactionType type, SubCategory subCategory) async {
    try {
      // 查找现有分类
      final categoryIndex = _customCategories.indexWhere(
        (cat) => cat.name == parentCategoryName && cat.type == type,
      );
      
      if (categoryIndex != -1) {
        // 更新现有自定义分类
        final updatedCategory = Category(
          name: _customCategories[categoryIndex].name,
          color: _customCategories[categoryIndex].color,
          icon: _customCategories[categoryIndex].icon,
          type: _customCategories[categoryIndex].type,
          subCategories: [..._customCategories[categoryIndex].subCategories, subCategory],
        );
        
        await _databaseService.updateCustomCategory(updatedCategory);
        _customCategories[categoryIndex] = updatedCategory;
      } else {
        // 检查是否是默认分类，如果是，创建自定义版本
        final defaultCategories = type == TransactionType.income 
            ? DefaultCategories.incomeCategories 
            : DefaultCategories.expenseCategories;
        
        final defaultCategory = defaultCategories.firstWhere(
          (cat) => cat.name == parentCategoryName,
          orElse: () => throw Exception('分类不存在'),
        );
        
        final newCategory = Category(
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
  Future<void> updateJarSettings(JarSettings settings) async {
    try {
      await _databaseService.saveJarSettings(settings);
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
      await _databaseService.clearAllData();
      _transactions.clear();
      _customCategories.clear();
      _jarSettings = JarSettings(targetAmount: 1000.0, title: '我的储蓄罐');
      notifyListeners();
    } catch (e) {
      debugPrint('清空数据失败: $e');
      rethrow;
    }
  }
} 