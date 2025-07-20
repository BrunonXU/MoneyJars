/*
 * 交易记录状态管理 (transaction_provider_new.dart)
 * 
 * 功能说明：
 * - 管理交易记录的状态和业务逻辑
 * - 使用新的仓库架构
 * - 提供交易统计和过滤功能
 * 
 * 设计原则：
 * - 单一职责：只负责交易相关逻辑
 * - 响应式：使用ChangeNotifier模式
 * - 缓存优化：减少不必要的数据库访问
 */

import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/domain/entities/transaction.dart';
import '../../core/domain/repositories/transaction_repository_simple.dart';
import '../../core/domain/repositories/category_repository.dart';

/// 交易记录状态管理器
/// 
/// 提供：
/// - 交易记录的增删改查
/// - 按类型、日期等过滤
/// - 统计数据计算
class TransactionProviderNew extends ChangeNotifier {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  
  /// 所有交易记录
  List<Transaction> _transactions = [];
  
  /// 当前过滤条件
  TransactionFilter _currentFilter = TransactionFilter.all;
  
  /// 当前选中的交易类型
  TransactionType? _selectedType;
  
  /// 日期范围过滤
  DateTimeRange? _dateRange;
  
  /// 是否正在加载
  bool _isLoading = false;
  
  /// 错误信息
  String? _errorMessage;
  
  TransactionProviderNew({
    TransactionRepository? transactionRepository,
    CategoryRepository? categoryRepository,
  }) : _transactionRepository = transactionRepository ?? serviceLocator.transactionRepository,
       _categoryRepository = categoryRepository ?? serviceLocator.categoryRepository;
  
  // ===== Getters =====
  
  /// 获取过滤后的交易记录
  List<Transaction> get transactions {
    List<Transaction> filtered = _transactions;
    
    // 按类型过滤
    if (_selectedType != null) {
      filtered = filtered.where((tx) => tx.type == _selectedType).toList();
    }
    
    // 按日期范围过滤
    if (_dateRange != null) {
      filtered = filtered.where((tx) =>
          tx.date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
          tx.date.isBefore(_dateRange!.end.add(const Duration(days: 1)))).toList();
    }
    
    // 按过滤条件过滤
    switch (_currentFilter) {
      case TransactionFilter.all:
        break;
      case TransactionFilter.income:
        filtered = filtered.where((tx) => tx.type == TransactionType.income).toList();
        break;
      case TransactionFilter.expense:
        filtered = filtered.where((tx) => tx.type == TransactionType.expense).toList();
        break;
      case TransactionFilter.comprehensive:
        // filtered = filtered.where((tx) => tx.type == TransactionType.comprehensive).toList();
        break;
      case TransactionFilter.today:
        final today = DateTime.now();
        filtered = filtered.where((tx) => 
          tx.date.year == today.year &&
          tx.date.month == today.month &&
          tx.date.day == today.day
        ).toList();
        break;
      case TransactionFilter.thisWeek:
        final now = DateTime.now();
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        filtered = filtered.where((tx) => tx.date.isAfter(weekStart.subtract(const Duration(days: 1)))).toList();
        break;
      case TransactionFilter.thisMonth:
        final now = DateTime.now();
        filtered = filtered.where((tx) => 
          tx.date.year == now.year &&
          tx.date.month == now.month
        ).toList();
        break;
    }
    
    // 按日期降序排序
    filtered.sort((a, b) => b.date.compareTo(a.date));
    
    return filtered;
  }
  
  /// 获取所有交易（未过滤）
  List<Transaction> get allTransactions => _transactions;
  
  /// 是否正在加载
  bool get isLoading => _isLoading;
  
  /// 错误信息
  String? get errorMessage => _errorMessage;
  
  /// 当前过滤条件
  TransactionFilter get currentFilter => _currentFilter;
  
  /// 当前选中的类型
  TransactionType? get selectedType => _selectedType;
  
  /// 当前日期范围
  DateTimeRange? get dateRange => _dateRange;
  
  // ===== 统计数据 =====
  
  /// 总收入
  double get totalIncome {
    return _transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
  
  /// 总支出
  double get totalExpense {
    return _transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
  
  /// 总综合
  double get totalComprehensive {
    // return _transactions
    //     .where((tx) => tx.type == TransactionType.comprehensive)
    //     .fold(0.0, (sum, tx) => sum + tx.amount);
    return 0.0;
  }
  
  /// 净收入（收入 - 支出）
  double get netIncome => totalIncome - totalExpense;
  
  /// 本月收入
  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((tx) => 
            tx.type == TransactionType.income &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
  
  /// 本月支出
  double get monthlyExpense {
    final now = DateTime.now();
    return _transactions
        .where((tx) => 
            tx.type == TransactionType.expense &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }
  
  // ===== 初始化和加载 =====
  
  /// 初始化数据
  Future<void> initialize() async {
    await loadTransactions();
  }
  
  /// 加载交易记录
  Future<void> loadTransactions() async {
    _setLoading(true);
    _clearError();
    
    try {
      _transactions = await _transactionRepository.getAllTransactions();
      notifyListeners();
    } catch (e) {
      _setError('加载交易记录失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== 交易操作 =====
  
  /// 添加交易记录
  Future<void> addTransaction(Transaction transaction) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _transactionRepository.addTransaction(transaction);
      
      // 添加到本地列表
      _transactions.insert(0, transaction);
      
      // 增加分类使用次数
      await _categoryRepository.incrementUsageCount(transaction.parentCategoryId);
      
      notifyListeners();
    } catch (e) {
      _setError('添加交易记录失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 更新交易记录
  Future<void> updateTransaction(Transaction transaction) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _transactionRepository.updateTransaction(transaction);
      
      // 更新本地列表
      final index = _transactions.indexWhere((tx) => tx.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        notifyListeners();
      }
    } catch (e) {
      _setError('更新交易记录失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 删除交易记录
  Future<void> deleteTransaction(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _transactionRepository.deleteTransaction(id);
      
      // 从本地列表移除
      _transactions.removeWhere((tx) => tx.id == id);
      notifyListeners();
    } catch (e) {
      _setError('删除交易记录失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 批量删除交易记录
  Future<void> deleteTransactions(List<String> ids) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _transactionRepository.deleteTransactions(ids);
      
      // 从本地列表移除
      _transactions.removeWhere((tx) => ids.contains(tx.id));
      notifyListeners();
    } catch (e) {
      _setError('批量删除交易记录失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 归档交易记录
  Future<void> archiveTransaction(String id) async {
    final transaction = _transactions.firstWhere(
      (tx) => tx.id == id,
      orElse: () => throw Exception('交易记录不存在'),
    );
    
    final archivedTransaction = Transaction(
      id: transaction.id,
      amount: transaction.amount,
      description: transaction.description,
      parentCategoryId: transaction.parentCategoryId,
      parentCategoryName: transaction.parentCategoryName,
      subCategoryId: transaction.subCategoryId,
      subCategoryName: transaction.subCategoryName,
      date: transaction.date,
      createTime: transaction.createTime,
      type: transaction.type,
      isArchived: true,
      updatedAt: DateTime.now(),
      notes: transaction.notes,
      tags: transaction.tags,
      attachments: transaction.attachments,
      location: transaction.location,
      userId: transaction.userId,
      deviceId: transaction.deviceId,
      syncedAt: transaction.syncedAt,
      metadata: transaction.metadata,
    );
    
    await updateTransaction(archivedTransaction);
  }
  
  // ===== 过滤和搜索 =====
  
  /// 设置过滤条件
  void setFilter(TransactionFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }
  
  /// 设置类型过滤
  void setTypeFilter(TransactionType? type) {
    _selectedType = type;
    notifyListeners();
  }
  
  /// 设置日期范围过滤
  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    notifyListeners();
  }
  
  /// 清除所有过滤条件
  void clearFilters() {
    _currentFilter = TransactionFilter.all;
    _selectedType = null;
    _dateRange = null;
    notifyListeners();
  }
  
  /// 搜索交易记录
  List<Transaction> searchTransactions(String query) {
    if (query.isEmpty) return transactions;
    
    final lowercaseQuery = query.toLowerCase();
    return transactions.where((tx) =>
        tx.description.toLowerCase().contains(lowercaseQuery) ||
        tx.parentCategoryName.toLowerCase().contains(lowercaseQuery) ||
        (tx.subCategoryName?.toLowerCase().contains(lowercaseQuery) ?? false) ||
        tx.amount.toString().contains(query)
    ).toList();
  }
  
  // ===== 统计分析 =====
  
  /// 获取分类统计
  Map<String, double> getCategoryStatistics(TransactionType type) {
    final typeTransactions = _transactions.where((tx) => tx.type == type);
    
    final stats = <String, double>{};
    for (final tx in typeTransactions) {
      stats[tx.parentCategoryName] = (stats[tx.parentCategoryName] ?? 0) + tx.amount;
    }
    
    return stats;
  }
  
  /// 获取月度统计
  Map<String, double> getMonthlyStatistics(int year) {
    final monthlyStats = <String, double>{};
    
    for (int month = 1; month <= 12; month++) {
      final monthKey = '$year-${month.toString().padLeft(2, '0')}';
      
      final monthTransactions = _transactions.where((tx) =>
          tx.date.year == year && tx.date.month == month);
      
      final income = monthTransactions
          .where((tx) => tx.type == TransactionType.income)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      
      final expense = monthTransactions
          .where((tx) => tx.type == TransactionType.expense)
          .fold(0.0, (sum, tx) => sum + tx.amount);
      
      monthlyStats['$monthKey-income'] = income;
      monthlyStats['$monthKey-expense'] = expense;
      monthlyStats['$monthKey-net'] = income - expense;
    }
    
    return monthlyStats;
  }
  
  // ===== 私有方法 =====
  
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

/// 交易过滤条件枚举
enum TransactionFilter {
  all,           // 全部
  income,        // 收入
  expense,       // 支出
  comprehensive, // 综合
  today,         // 今天
  thisWeek,      // 本周
  thisMonth,     // 本月
}