/*
 * 交易仓库实现 (transaction_repository_impl.dart)
 * 
 * 功能说明：
 * - 实现交易仓库接口，提供交易数据的业务逻辑封装
 * - 协调本地数据源和缓存
 * - 处理数据转换和错误处理
 * 
 * 设计模式：
 * - 仓库模式：隔离数据访问逻辑和业务逻辑
 * - 依赖注入：通过构造函数注入数据源
 * - 适配器模式：在数据模型和领域实体之间转换
 */

import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/transaction_model.dart';

/// 交易仓库实现类
/// 
/// 负责：
/// - 数据源协调
/// - 错误处理
/// - 数据转换
/// - 缓存管理（未来实现）
class TransactionRepositoryImpl implements TransactionRepository {
  final LocalDataSource _localDataSource;
  
  /// 内存缓存，提高查询性能
  List<Transaction>? _cachedTransactions;
  DateTime? _lastCacheTime;
  static const Duration _cacheExpiration = Duration(minutes: 5);
  
  TransactionRepositoryImpl({
    required LocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;
  
  /// 检查缓存是否有效
  bool _isCacheValid() {
    return _cachedTransactions != null &&
        _lastCacheTime != null &&
        DateTime.now().difference(_lastCacheTime!) < _cacheExpiration;
  }
  
  /// 清除缓存
  void _clearCache() {
    _cachedTransactions = null;
    _lastCacheTime = null;
  }
  
  @override
  Future<List<Transaction>> getAllTransactions() async {
    try {
      // 检查缓存
      if (_isCacheValid()) {
        return _cachedTransactions!;
      }
      
      // 从数据源获取数据
      final models = await _localDataSource.getAllTransactions();
      
      // 转换为领域实体
      final transactions = models.map((model) => model.toEntity()).toList();
      
      // 更新缓存
      _cachedTransactions = transactions;
      _lastCacheTime = DateTime.now();
      
      return transactions;
    } catch (e) {
      debugPrint('获取所有交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    try {
      final models = await _localDataSource.getTransactionsByType(type);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      debugPrint('按类型获取交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final models = await _localDataSource.getTransactionsByDateRange(
        startDate,
        endDate,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      debugPrint('按日期范围获取交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    try {
      // 获取所有交易，然后过滤
      final allTransactions = await getAllTransactions();
      return allTransactions
          .where((tx) => tx.parentCategoryId == categoryId)
          .toList();
    } catch (e) {
      debugPrint('按分类获取交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      final model = await _localDataSource.getTransactionById(id);
      return model?.toEntity();
    } catch (e) {
      debugPrint('根据ID获取交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> addTransaction(Transaction transaction) async {
    try {
      // 转换为数据模型
      final model = TransactionModel.fromEntity(transaction);
      
      // 保存到数据源
      await _localDataSource.addTransaction(model);
      
      // 清除缓存
      _clearCache();
    } catch (e) {
      debugPrint('添加交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      // 转换为数据模型
      final model = TransactionModel.fromEntity(transaction);
      
      // 更新数据源
      await _localDataSource.updateTransaction(model);
      
      // 清除缓存
      _clearCache();
    } catch (e) {
      debugPrint('更新交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _localDataSource.deleteTransaction(id);
      _clearCache();
    } catch (e) {
      debugPrint('删除交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteTransactions(List<String> ids) async {
    try {
      await _localDataSource.deleteTransactions(ids);
      _clearCache();
    } catch (e) {
      debugPrint('批量删除交易记录失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<Map<String, double>> getStatisticsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // 获取指定日期范围的交易
      final transactions = await getTransactionsByDateRange(startDate, endDate);
      
      // 统计数据
      double totalIncome = 0;
      double totalExpense = 0;
      double totalComprehensive = 0;
      
      for (final transaction in transactions) {
        switch (transaction.type) {
          case TransactionType.income:
            totalIncome += transaction.amount;
            break;
          case TransactionType.expense:
            totalExpense += transaction.amount;
            break;
          case TransactionType.comprehensive:
            totalComprehensive += transaction.amount;
            break;
        }
      }
      
      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'totalComprehensive': totalComprehensive,
        'netIncome': totalIncome - totalExpense,
        'transactionCount': transactions.length.toDouble(),
      };
    } catch (e) {
      debugPrint('获取统计数据失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<Map<String, double>> getCategoryStatistics(
    TransactionType type,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // 获取指定类型和日期范围的交易
      final transactions = await getTransactionsByType(type);
      final filteredTransactions = transactions.where((tx) =>
          tx.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          tx.date.isBefore(endDate.add(const Duration(days: 1)))).toList();
      
      // 按分类统计
      final categoryStats = <String, double>{};
      
      for (final transaction in filteredTransactions) {
        final categoryName = transaction.parentCategoryName;
        categoryStats[categoryName] = (categoryStats[categoryName] ?? 0) + transaction.amount;
      }
      
      return categoryStats;
    } catch (e) {
      debugPrint('获取分类统计数据失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> exportData(String filePath) async {
    try {
      // 获取所有数据
      final data = await _localDataSource.exportAllData();
      
      // TODO: 实现文件写入逻辑
      // 这里需要根据平台选择合适的文件保存方式
      debugPrint('导出数据到: $filePath');
    } catch (e) {
      debugPrint('导出数据失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> importData(String filePath) async {
    try {
      // TODO: 实现文件读取逻辑
      // 这里需要根据平台选择合适的文件读取方式
      
      // 暂时使用模拟数据
      final Map<String, dynamic> data = {};
      
      await _localDataSource.importData(data);
      _clearCache();
    } catch (e) {
      debugPrint('导入数据失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> clearAllData() async {
    try {
      await _localDataSource.clearAllData();
      _clearCache();
    } catch (e) {
      debugPrint('清空所有数据失败: $e');
      rethrow;
    }
  }
}