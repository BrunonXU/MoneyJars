/*
 * 交易仓库接口 (transaction_repository.dart)
 * 
 * 功能说明：
 * - 定义交易数据的存取接口
 * - 抽象层，不依赖具体实现
 * - 支持本地和远程数据源
 * 
 * 设计原则：
 * - 接口隔离：只定义必要的方法
 * - 依赖倒置：高层模块不依赖低层模块
 * - 错误处理：通过Either返回成功或失败
 */

import 'package:dartz/dartz.dart';
import '../entities/transaction.dart';
import '../../error/failures.dart';

/// 交易仓库抽象接口
/// 
/// 定义所有交易相关的数据操作方法
abstract class TransactionRepository {
  /// 获取所有交易记录
  /// 
  /// [includeArchived] - 是否包含已归档的记录，默认false
  /// 返回：成功时返回交易列表，失败时返回Failure
  Future<Either<Failure, List<Transaction>>> getAllTransactions({
    bool includeArchived = false,
  });
  
  /// 根据类型获取交易记录
  /// 
  /// [type] - 交易类型（收入/支出）
  /// [includeArchived] - 是否包含已归档的记录
  /// 返回：成功时返回交易列表，失败时返回Failure
  Future<Either<Failure, List<Transaction>>> getTransactionsByType(
    TransactionType type, {
    bool includeArchived = false,
  });
  
  /// 获取日期范围内的交易记录
  /// 
  /// [startDate] - 开始日期
  /// [endDate] - 结束日期
  /// [type] - 交易类型（可选）
  /// 返回：成功时返回交易列表，失败时返回Failure
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    TransactionType? type,
  });
  
  /// 根据分类获取交易记录
  /// 
  /// [categoryId] - 分类ID
  /// [includeSubCategories] - 是否包含子分类
  /// 返回：成功时返回交易列表，失败时返回Failure
  Future<Either<Failure, List<Transaction>>> getTransactionsByCategory(
    String categoryId, {
    bool includeSubCategories = true,
  });
  
  /// 根据ID获取单条交易记录
  /// 
  /// [id] - 交易ID
  /// 返回：成功时返回交易记录，失败时返回Failure
  Future<Either<Failure, Transaction>> getTransactionById(String id);
  
  /// 添加新交易记录
  /// 
  /// [transaction] - 要添加的交易
  /// 返回：成功时返回交易ID，失败时返回Failure
  Future<Either<Failure, String>> addTransaction(Transaction transaction);
  
  /// 更新交易记录
  /// 
  /// [transaction] - 要更新的交易
  /// 返回：成功时返回true，失败时返回Failure
  Future<Either<Failure, bool>> updateTransaction(Transaction transaction);
  
  /// 删除交易记录
  /// 
  /// [id] - 要删除的交易ID
  /// 返回：成功时返回true，失败时返回Failure
  Future<Either<Failure, bool>> deleteTransaction(String id);
  
  /// 批量删除交易记录
  /// 
  /// [ids] - 要删除的交易ID列表
  /// 返回：成功时返回删除数量，失败时返回Failure
  Future<Either<Failure, int>> deleteTransactions(List<String> ids);
  
  /// 归档交易记录
  /// 
  /// [id] - 要归档的交易ID
  /// 返回：成功时返回true，失败时返回Failure
  Future<Either<Failure, bool>> archiveTransaction(String id);
  
  /// 恢复归档的交易记录
  /// 
  /// [id] - 要恢复的交易ID
  /// 返回：成功时返回true，失败时返回Failure
  Future<Either<Failure, bool>> unarchiveTransaction(String id);
  
  /// 搜索交易记录
  /// 
  /// [query] - 搜索关键词
  /// [filters] - 搜索过滤条件
  /// 返回：成功时返回匹配的交易列表，失败时返回Failure
  Future<Either<Failure, List<Transaction>>> searchTransactions(
    String query, {
    Map<String, dynamic>? filters,
  });
  
  /// 获取交易统计信息
  /// 
  /// [startDate] - 统计开始日期
  /// [endDate] - 统计结束日期
  /// 返回：成功时返回统计数据，失败时返回Failure
  Future<Either<Failure, TransactionStatistics>> getStatistics(
    DateTime startDate,
    DateTime endDate,
  );
  
  /// 导出交易数据
  /// 
  /// [format] - 导出格式（csv, json等）
  /// [transactions] - 要导出的交易列表
  /// 返回：成功时返回导出文件路径，失败时返回Failure
  Future<Either<Failure, String>> exportTransactions(
    String format,
    List<Transaction> transactions,
  );
  
  /// 导入交易数据
  /// 
  /// [filePath] - 导入文件路径
  /// [format] - 文件格式
  /// 返回：成功时返回导入的交易数量，失败时返回Failure
  Future<Either<Failure, int>> importTransactions(
    String filePath,
    String format,
  );
}

/// 交易统计数据类
class TransactionStatistics {
  /// 总收入
  final double totalIncome;
  
  /// 总支出
  final double totalExpense;
  
  /// 净收入
  final double netIncome;
  
  /// 交易数量
  final int transactionCount;
  
  /// 分类统计
  final Map<String, CategoryStatistics> categoryStats;
  
  /// 日统计
  final Map<DateTime, DailyStatistics> dailyStats;

  const TransactionStatistics({
    required this.totalIncome,
    required this.totalExpense,
    required this.netIncome,
    required this.transactionCount,
    required this.categoryStats,
    required this.dailyStats,
  });
}

/// 分类统计数据
class CategoryStatistics {
  /// 分类ID
  final String categoryId;
  
  /// 分类名称
  final String categoryName;
  
  /// 总金额
  final double totalAmount;
  
  /// 交易数量
  final int transactionCount;
  
  /// 占比
  final double percentage;

  const CategoryStatistics({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.transactionCount,
    required this.percentage,
  });
}

/// 日统计数据
class DailyStatistics {
  /// 日期
  final DateTime date;
  
  /// 当日收入
  final double income;
  
  /// 当日支出
  final double expense;
  
  /// 当日净额
  final double net;

  const DailyStatistics({
    required this.date,
    required this.income,
    required this.expense,
    required this.net,
  });
}