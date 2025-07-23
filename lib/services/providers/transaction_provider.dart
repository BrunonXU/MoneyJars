import 'package:flutter/material.dart';
import '../../models/transaction_record_hive.dart' as hive;
import '../storage_service.dart';
import '../sample_data_generator.dart';

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
    
    // 检查是否需要生成示例数据（首次使用）
    await _generateSampleDataIfNeeded();
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

  // 生成示例数据（如果需要）
  Future<void> _generateSampleDataIfNeeded() async {
    try {
      // 只有当完全没有交易记录时才生成示例数据
      if (SampleDataGenerator.shouldGenerateSampleData(_transactions)) {
        debugPrint('🎯 检测到首次使用，正在生成示例数据...');
        
        final sampleRecords = SampleDataGenerator.generateSampleData();
        
        // 批量添加示例数据
        for (final record in sampleRecords) {
          await _storageService.addTransaction(record);
        }
        
        // 重新加载数据以更新UI
        await _loadTransactions();
        
        debugPrint('✅ 成功生成 ${sampleRecords.length} 条示例数据');
      }
    } catch (e) {
      debugPrint('⚠️ 生成示例数据失败: $e');
      // 不抛出异常，避免影响应用正常启动
    }
  }

  // 手动重新生成示例数据（开发调试用）
  Future<void> regenerateSampleData() async {
    try {
      // 清空现有数据
      await _storageService.clearTransactions();
      _transactions.clear();
      
      // 生成新的示例数据
      final sampleRecords = SampleDataGenerator.generateSampleData();
      
      // 批量添加示例数据
      for (final record in sampleRecords) {
        await _storageService.addTransaction(record);
      }
      
      // 重新加载数据
      await _loadTransactions();
      
      debugPrint('✅ 重新生成了 ${sampleRecords.length} 条示例数据');
    } catch (e) {
      debugPrint('⚠️ 重新生成示例数据失败: $e');
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

  // ===== 分类管理方法 =====
  
  // 获取所有分类（内置 + 自定义）
  List<hive.Category> getCategories() {
    // 创建内置分类
    final defaultCategories = [
      // 支出分类
      hive.Category.create(id: 'food', name: '餐饮', type: hive.TransactionType.expense, color: 0xFFFF6B6B, icon: 'restaurant', subCategories: []),
      hive.Category.create(id: 'transport', name: '交通', type: hive.TransactionType.expense, color: 0xFF4ECDC4, icon: 'directions_car', subCategories: []),
      hive.Category.create(id: 'shopping', name: '购物', type: hive.TransactionType.expense, color: 0xFF45B7D1, icon: 'shopping_bag', subCategories: []),
      hive.Category.create(id: 'entertainment', name: '娱乐', type: hive.TransactionType.expense, color: 0xFFFFB07A, icon: 'movie', subCategories: []),
      hive.Category.create(id: 'housing', name: '住房', type: hive.TransactionType.expense, color: 0xFF98D8C8, icon: 'home', subCategories: []),
      hive.Category.create(id: 'medical', name: '医疗', type: hive.TransactionType.expense, color: 0xFFF7DC6F, icon: 'medical_services', subCategories: []),
      hive.Category.create(id: 'education', name: '教育', type: hive.TransactionType.expense, color: 0xFFBB8FCE, icon: 'school', subCategories: []),
      hive.Category.create(id: 'travel', name: '旅行', type: hive.TransactionType.expense, color: 0xFF85C1E9, icon: 'flight', subCategories: []),
      hive.Category.create(id: 'other_expense', name: '其他', type: hive.TransactionType.expense, color: 0xFFD5DBDB, icon: 'more_horiz', subCategories: []),
      
      // 收入分类
      hive.Category.create(id: 'salary', name: '工资', type: hive.TransactionType.income, color: 0xFF2ECC71, icon: 'work', subCategories: []),
      hive.Category.create(id: 'investment', name: '投资', type: hive.TransactionType.income, color: 0xFF3498DB, icon: 'show_chart', subCategories: []),
      hive.Category.create(id: 'part_time', name: '兼职', type: hive.TransactionType.income, color: 0xFFE74C3C, icon: 'work_outline', subCategories: []),
      hive.Category.create(id: 'gift', name: '礼金', type: hive.TransactionType.income, color: 0xFFF39C12, icon: 'card_giftcard', subCategories: []),
      hive.Category.create(id: 'other_income', name: '其他', type: hive.TransactionType.income, color: 0xFF9B59B6, icon: 'more_horiz', subCategories: []),
    ];
    
    return [...defaultCategories, ..._customCategories];
  }
  
  // 根据类型获取分类
  List<hive.Category> getCategoriesByType(hive.TransactionType type) {
    return getCategories().where((c) => c.type == type).toList();
  }
  
  // 根据ID查找分类
  hive.Category? getCategoryById(String id) {
    try {
      return getCategories().firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // 添加自定义分类
  Future<void> addCategory(hive.Category category) async {
    try {
      // 检查分类名称是否已存在
      final existingCategories = getCategoriesByType(category.type);
      final nameExists = existingCategories.any((c) => c.name == category.name);
      
      if (nameExists) {
        throw Exception('分类名称"${category.name}"已存在');
      }
      
      // 添加到自定义分类列表
      _customCategories.add(category);
      
      // 持久化存储（如果需要）
      // await _storageService.saveCustomCategories(_customCategories);
      
      _clearCache();
      notifyListeners();
      
      debugPrint('✅ 添加自定义分类: ${category.name}');
    } catch (e) {
      debugPrint('❌ 添加分类失败: $e');
      rethrow;
    }
  }
  
  // 更新自定义分类
  Future<void> updateCategory(hive.Category updatedCategory) async {
    try {
      final index = _customCategories.indexWhere((c) => c.id == updatedCategory.id);
      
      if (index == -1) {
        throw Exception('未找到要更新的分类');
      }
      
      // 检查新名称是否与其他分类冲突
      final otherCategories = getCategoriesByType(updatedCategory.type)
          .where((c) => c.id != updatedCategory.id);
      final nameExists = otherCategories.any((c) => c.name == updatedCategory.name);
      
      if (nameExists) {
        throw Exception('分类名称"${updatedCategory.name}"已存在');
      }
      
      // 更新分类
      _customCategories[index] = updatedCategory;
      
      // 持久化存储（如果需要）
      // await _storageService.saveCustomCategories(_customCategories);
      
      _clearCache();
      notifyListeners();
      
      debugPrint('✅ 更新自定义分类: ${updatedCategory.name}');
    } catch (e) {
      debugPrint('❌ 更新分类失败: $e');
      rethrow;
    }
  }
  
  // 删除自定义分类
  Future<void> deleteCategory(String categoryId) async {
    try {
      // 检查是否为内置分类
      const builtInIds = [
        'food', 'transport', 'shopping', 'entertainment', 'housing', 
        'medical', 'education', 'travel', 'other_expense',
        'salary', 'investment', 'part_time', 'gift', 'other_income'
      ];
      
      if (builtInIds.contains(categoryId)) {
        throw Exception('不能删除内置分类');
      }
      
      // 查找要删除的分类
      final categoryToDelete = _customCategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => throw Exception('未找到要删除的分类'),
      );
      
      // 将使用该分类的交易记录改为"其他"分类
      final otherCategoryId = categoryToDelete.type == hive.TransactionType.expense 
          ? 'other_expense' 
          : 'other_income';
      
      final affectedTransactions = _transactions.where((t) => t.parentCategory == categoryId).toList();
      for (final transaction in affectedTransactions) {
        final updatedTransaction = hive.TransactionRecord.create(
          id: transaction.id,
          amount: transaction.amount,
          description: transaction.description,
          parentCategory: otherCategoryId,
          subCategory: transaction.subCategory,
          type: transaction.type,
          date: transaction.date,
          isArchived: transaction.isArchived,
        );
        
        await updateTransaction(updatedTransaction);
      }
      
      // 从自定义分类列表中移除
      _customCategories.removeWhere((c) => c.id == categoryId);
      
      // 持久化存储（如果需要）
      // await _storageService.saveCustomCategories(_customCategories);
      
      _clearCache();
      notifyListeners();
      
      debugPrint('✅ 删除自定义分类: ${categoryToDelete.name}，影响了 ${affectedTransactions.length} 条交易记录');
    } catch (e) {
      debugPrint('❌ 删除分类失败: $e');
      rethrow;
    }
  }
} 