/*
 * 简化版交易仓库实现 (transaction_repository_simple_impl.dart)
 * 
 * 功能说明：
 * - 实现简化版交易仓库接口
 * - 提供基本的CRUD操作
 */

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository_simple.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/transaction_model.dart';

/// 简化版交易仓库实现类
class TransactionRepositoryImpl implements TransactionRepository {
  final LocalDataSource _localDataSource;
  
  TransactionRepositoryImpl({
    required LocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;
  
  @override
  Future<List<Transaction>> getAllTransactions() async {
    try {
      final models = await _localDataSource.getAllTransactions();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      print('Error getting all transactions: $e');
      return [];
    }
  }
  
  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      final model = await _localDataSource.getTransaction(id);
      return model?.toEntity();
    } catch (e) {
      print('Error getting transaction by id: $e');
      return null;
    }
  }
  
  @override
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _localDataSource.saveTransaction(model);
    } catch (e) {
      print('Error adding transaction: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _localDataSource.updateTransaction(model);
    } catch (e) {
      print('Error updating transaction: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _localDataSource.deleteTransaction(id);
    } catch (e) {
      print('Error deleting transaction: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteTransactions(List<String> ids) async {
    try {
      await _localDataSource.deleteTransactions(ids);
    } catch (e) {
      print('Error deleting transactions: $e');
      rethrow;
    }
  }
}