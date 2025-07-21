/*
 * 简化版交易仓库接口 (transaction_repository_simple.dart)
 * 
 * 功能说明：
 * - 定义交易数据的存取接口
 * - 暂时移除Either错误处理以简化实现
 */

import '../entities/transaction.dart';

/// 交易仓库抽象接口（简化版）
abstract class TransactionRepository {
  /// 获取所有交易记录
  Future<List<Transaction>> getAllTransactions();
  
  /// 获取指定ID的交易
  Future<Transaction?> getTransactionById(String id);
  
  /// 添加交易记录
  Future<void> addTransaction(Transaction transaction);
  
  /// 更新交易记录
  Future<void> updateTransaction(Transaction transaction);
  
  /// 删除交易记录
  Future<void> deleteTransaction(String id);
  
  /// 批量删除交易记录
  Future<void> deleteTransactions(List<String> ids);
}