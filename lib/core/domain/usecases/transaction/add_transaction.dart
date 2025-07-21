/*
 * 添加交易用例 (add_transaction.dart)
 * 
 * 功能说明：
 * - 封装添加交易的业务逻辑
 * - 包含数据验证、业务规则检查
 * - 处理相关的副作用（如更新统计）
 * 
 * 设计模式：
 * - 用例模式（Use Case Pattern）
 * - 单一职责原则
 * - 依赖注入
 */

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';
import '../../../error/failures.dart';

/// 添加交易用例
/// 
/// 负责处理添加新交易记录的完整业务流程
class AddTransactionUseCase {
  /// 交易仓库
  final TransactionRepository _repository;
  
  AddTransactionUseCase({
    required TransactionRepository repository,
  }) : _repository = repository;
  
  /// 执行添加交易
  /// 
  /// [params] - 添加交易的参数
  /// 返回：成功时返回交易ID，失败时返回Failure
  Future<Either<Failure, String>> execute(AddTransactionParams params) async {
    // 1. 验证输入参数
    final validationResult = _validateParams(params);
    if (validationResult != null) {
      return Left(validationResult);
    }
    
    // 2. 创建交易实体
    final transaction = Transaction(
      id: _generateTransactionId(),
      amount: params.amount,
      description: params.description,
      parentCategoryId: params.parentCategoryId,
      parentCategoryName: params.parentCategoryName,
      subCategoryId: params.subCategoryId,
      subCategoryName: params.subCategoryName,
      type: params.type,
      date: params.date ?? DateTime.now(),
      createdAt: DateTime.now(),
      notes: params.notes,
      tags: params.tags,
    );
    
    // 3. 应用业务规则
    final businessRuleResult = _applyBusinessRules(transaction);
    if (businessRuleResult != null) {
      return Left(businessRuleResult);
    }
    
    // 4. 保存到仓库
    final result = await _repository.addTransaction(transaction);
    
    // 5. 处理结果
    return result.fold(
      (failure) => Left(failure),
      (transactionId) {
        // 触发相关事件（如更新统计缓存）
        _onTransactionAdded(transaction);
        return Right(transactionId);
      },
    );
  }
  
  /// 验证输入参数
  /// 
  /// 返回null表示验证通过，否则返回具体的失败信息
  Failure? _validateParams(AddTransactionParams params) {
    // 验证金额
    if (params.amount <= 0) {
      return ValidationFailure('交易金额必须大于0');
    }
    
    if (params.amount > 9999999.99) {
      return ValidationFailure('交易金额超出最大限制');
    }
    
    // 验证描述
    if (params.description.trim().isEmpty) {
      return ValidationFailure('交易描述不能为空');
    }
    
    if (params.description.length > 200) {
      return ValidationFailure('交易描述不能超过200个字符');
    }
    
    // 验证分类
    if (params.parentCategoryId.isEmpty || params.parentCategoryName.isEmpty) {
      return ValidationFailure('必须选择交易分类');
    }
    
    // 验证日期
    if (params.date != null) {
      final now = DateTime.now();
      final futureLimit = now.add(const Duration(days: 1)); // 允许记录明天的交易
      final pastLimit = now.subtract(const Duration(days: 365 * 2)); // 最多记录2年前
      
      if (params.date!.isAfter(futureLimit)) {
        return ValidationFailure('不能记录未来太远的交易');
      }
      
      if (params.date!.isBefore(pastLimit)) {
        return ValidationFailure('不能记录太久远的交易');
      }
    }
    
    return null;
  }
  
  /// 应用业务规则
  /// 
  /// 返回null表示规则检查通过，否则返回具体的失败信息
  Failure? _applyBusinessRules(Transaction transaction) {
    // 业务规则1：每日限额检查（示例）
    // TODO: 实现每日限额检查逻辑
    
    // 业务规则2：重复交易检查（示例）
    // TODO: 检查是否存在相同时间、金额、分类的交易
    
    // 业务规则3：分类有效性检查
    // TODO: 验证分类是否存在且未被禁用
    
    return null;
  }
  
  /// 生成交易ID
  /// 
  /// 使用时间戳和随机数生成唯一ID
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'TXN_${timestamp}_$random';
  }
  
  /// 交易添加成功后的处理
  /// 
  /// 触发相关的副作用，如更新缓存、发送通知等
  void _onTransactionAdded(Transaction transaction) {
    // TODO: 更新统计缓存
    // TODO: 更新分类使用频率
    // TODO: 发送本地通知（如果启用）
    // TODO: 触发数据同步（如果启用云同步）
  }
}

/// 添加交易的参数
/// 
/// 包含创建交易所需的所有信息
class AddTransactionParams extends Equatable {
  /// 交易金额
  final double amount;
  
  /// 交易描述
  final String description;
  
  /// 主分类ID
  final String parentCategoryId;
  
  /// 主分类名称
  final String parentCategoryName;
  
  /// 子分类ID（可选）
  final String? subCategoryId;
  
  /// 子分类名称（可选）
  final String? subCategoryName;
  
  /// 交易类型
  final TransactionType type;
  
  /// 交易日期（可选，默认为当前时间）
  final DateTime? date;
  
  /// 备注（可选）
  final String? notes;
  
  /// 标签列表（可选）
  final List<String> tags;

  const AddTransactionParams({
    required this.amount,
    required this.description,
    required this.parentCategoryId,
    required this.parentCategoryName,
    this.subCategoryId,
    this.subCategoryName,
    required this.type,
    this.date,
    this.notes,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
    amount,
    description,
    parentCategoryId,
    parentCategoryName,
    subCategoryId,
    subCategoryName,
    type,
    date,
    notes,
    tags,
  ];
}