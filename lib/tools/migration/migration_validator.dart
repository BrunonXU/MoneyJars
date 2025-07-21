import 'package:money_jar/services/storage_service.dart';
import 'package:money_jar/core/data/datasources/local/hive_datasource.dart';
import 'package:money_jar/core/domain/entities/transaction.dart' as domain;
import 'package:money_jar/core/domain/entities/category.dart' as domain;
import 'package:money_jar/models/transaction.dart' as legacy;
import 'package:money_jar/models/category.dart' as legacy;

/// 迁移验证器
/// 用于验证数据迁移的完整性和正确性
class MigrationValidator {
  final StorageService _storageService;
  final HiveLocalDataSource _hiveDataSource;

  MigrationValidator({
    required StorageService storageService,
    required HiveLocalDataSource hiveDataSource,
  })  : _storageService = storageService,
        _hiveDataSource = hiveDataSource;

  /// 执行完整验证
  Future<ValidationResult> validateMigration() async {
    final result = ValidationResult();

    try {
      // 1. 验证数据数量
      await _validateDataCount(result);

      // 2. 验证分类数据
      await _validateCategories(result);

      // 3. 验证交易数据
      await _validateTransactions(result);

      // 4. 验证数据关联
      await _validateDataRelationships(result);

      // 5. 验证金额总计
      await _validateAmountTotals(result);

      result.isValid = result.errors.isEmpty;
    } catch (e) {
      result.isValid = false;
      result.errors.add('验证过程出错: $e');
    }

    return result;
  }

  /// 验证数据数量
  Future<void> _validateDataCount(ValidationResult result) async {
    result.addCheck('验证数据数量');

    // 验证分类数量
    final oldCategories = await _storageService.getAllCategories();
    final newCategories = await _hiveDataSource.getAllCategories();

    if (oldCategories.length != newCategories.length) {
      result.addError(
        '分类数量不匹配: 旧系统=${oldCategories.length}, 新系统=${newCategories.length}',
      );
    } else {
      result.addSuccess('分类数量匹配: ${oldCategories.length} 个');
    }

    // 验证交易数量
    final oldTransactions = await _storageService.getAllTransactions();
    final newTransactions = await _hiveDataSource.getAllTransactions();

    if (oldTransactions.length != newTransactions.length) {
      result.addError(
        '交易数量不匹配: 旧系统=${oldTransactions.length}, 新系统=${newTransactions.length}',
      );
    } else {
      result.addSuccess('交易数量匹配: ${oldTransactions.length} 条');
    }
  }

  /// 验证分类数据
  Future<void> _validateCategories(ValidationResult result) async {
    result.addCheck('验证分类数据完整性');

    final oldCategories = await _storageService.getAllCategories();
    final newCategories = await _hiveDataSource.getAllCategories();

    // 创建映射以便快速查找
    final newCategoryMap = Map.fromEntries(
      newCategories.map((c) => MapEntry(c.id, c)),
    );

    for (final oldCat in oldCategories) {
      final newCat = newCategoryMap[oldCat.id];
      
      if (newCat == null) {
        result.addError('分类缺失: ${oldCat.name} (ID: ${oldCat.id})');
        continue;
      }

      // 验证基本属性
      if (oldCat.name != newCat.name) {
        result.addWarning(
          '分类名称不匹配: ${oldCat.name} -> ${newCat.name}',
        );
      }

      // 验证类型
      final expectedType = oldCat.isIncome 
          ? domain.TransactionType.income 
          : domain.TransactionType.expense;
      if (newCat.type != expectedType) {
        result.addError(
          '分类类型不匹配: ${oldCat.name}',
        );
      }
    }

    if (result.errors.isEmpty) {
      result.addSuccess('所有分类数据验证通过');
    }
  }

  /// 验证交易数据
  Future<void> _validateTransactions(ValidationResult result) async {
    result.addCheck('验证交易数据完整性');

    final oldTransactions = await _storageService.getAllTransactions();
    final newTransactions = await _hiveDataSource.getAllTransactions();

    // 创建映射
    final newTransMap = Map.fromEntries(
      newTransactions.map((t) => MapEntry(t.id, t)),
    );

    int validatedCount = 0;
    
    for (final oldTrans in oldTransactions) {
      final transId = oldTrans.id ?? 
          DateTime.now().millisecondsSinceEpoch.toString();
      final newTrans = newTransMap[transId];
      
      if (newTrans == null) {
        result.addError('交易记录缺失: ${oldTrans.description}');
        continue;
      }

      // 验证金额
      if (oldTrans.amount != newTrans.amount) {
        result.addError(
          '交易金额不匹配: ${oldTrans.description} '
          '(旧: ${oldTrans.amount}, 新: ${newTrans.amount})',
        );
      }

      // 验证描述
      if (oldTrans.description != newTrans.description) {
        result.addWarning(
          '交易描述不匹配: ${oldTrans.description} -> ${newTrans.description}',
        );
      }

      validatedCount++;
    }

    result.addSuccess('验证 $validatedCount 条交易记录');
  }

  /// 验证数据关联
  Future<void> _validateDataRelationships(ValidationResult result) async {
    result.addCheck('验证数据关联性');

    final transactions = await _hiveDataSource.getAllTransactions();
    final categories = await _hiveDataSource.getAllCategories();
    
    final categoryIds = categories.map((c) => c.id).toSet();
    int orphanedTransactions = 0;

    for (final transaction in transactions) {
      if (!categoryIds.contains(transaction.parentCategoryId)) {
        orphanedTransactions++;
        result.addWarning(
          '交易没有有效的分类: ${transaction.description} '
          '(分类ID: ${transaction.parentCategoryId})',
        );
      }
    }

    if (orphanedTransactions == 0) {
      result.addSuccess('所有交易都有有效的分类关联');
    } else {
      result.addWarning('发现 $orphanedTransactions 条孤儿交易');
    }
  }

  /// 验证金额总计
  Future<void> _validateAmountTotals(ValidationResult result) async {
    result.addCheck('验证金额总计');

    // 计算旧系统总额
    final oldTransactions = await _storageService.getAllTransactions();
    double oldTotalIncome = 0;
    double oldTotalExpense = 0;
    
    for (final trans in oldTransactions) {
      // 根据分类ID判断收支类型
      // 这里需要根据实际逻辑调整
      if (trans.amount > 0) {
        oldTotalIncome += trans.amount;
      } else {
        oldTotalExpense += trans.amount.abs();
      }
    }

    // 计算新系统总额
    final newTransactions = await _hiveDataSource.getAllTransactions();
    double newTotalIncome = 0;
    double newTotalExpense = 0;
    
    for (final trans in newTransactions) {
      if (trans.type == domain.TransactionType.income) {
        newTotalIncome += trans.amount;
      } else {
        newTotalExpense += trans.amount;
      }
    }

    // 比较总额
    final incomeDiff = (oldTotalIncome - newTotalIncome).abs();
    final expenseDiff = (oldTotalExpense - newTotalExpense).abs();
    
    if (incomeDiff < 0.01 && expenseDiff < 0.01) {
      result.addSuccess('金额总计验证通过');
      result.addDetail('总收入: ¥${newTotalIncome.toStringAsFixed(2)}');
      result.addDetail('总支出: ¥${newTotalExpense.toStringAsFixed(2)}');
    } else {
      if (incomeDiff >= 0.01) {
        result.addError(
          '收入总额不匹配: '
          '旧=¥${oldTotalIncome.toStringAsFixed(2)}, '
          '新=¥${newTotalIncome.toStringAsFixed(2)}',
        );
      }
      if (expenseDiff >= 0.01) {
        result.addError(
          '支出总额不匹配: '
          '旧=¥${oldTotalExpense.toStringAsFixed(2)}, '
          '新=¥${newTotalExpense.toStringAsFixed(2)}',
        );
      }
    }
  }

  /// 生成验证报告
  Future<String> generateValidationReport() async {
    final result = await validateMigration();
    
    final buffer = StringBuffer();
    buffer.writeln('# 数据迁移验证报告');
    buffer.writeln();
    buffer.writeln('生成时间: ${DateTime.now().toLocal()}');
    buffer.writeln();
    
    buffer.writeln('## 验证结果: ${result.isValid ? "✅ 通过" : "❌ 失败"}');
    buffer.writeln();
    
    if (result.errors.isNotEmpty) {
      buffer.writeln('## 错误 (${result.errors.length})');
      for (final error in result.errors) {
        buffer.writeln('- ❌ $error');
      }
      buffer.writeln();
    }
    
    if (result.warnings.isNotEmpty) {
      buffer.writeln('## 警告 (${result.warnings.length})');
      for (final warning in result.warnings) {
        buffer.writeln('- ⚠️ $warning');
      }
      buffer.writeln();
    }
    
    if (result.successes.isNotEmpty) {
      buffer.writeln('## 通过项 (${result.successes.length})');
      for (final success in result.successes) {
        buffer.writeln('- ✅ $success');
      }
      buffer.writeln();
    }
    
    buffer.writeln('## 检查项');
    for (final check in result.checks) {
      buffer.writeln('- $check');
    }
    
    if (result.details.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('## 详细信息');
      for (final detail in result.details) {
        buffer.writeln('- $detail');
      }
    }
    
    return buffer.toString();
  }
}

/// 验证结果
class ValidationResult {
  bool isValid = true;
  final List<String> errors = [];
  final List<String> warnings = [];
  final List<String> successes = [];
  final List<String> checks = [];
  final List<String> details = [];
  
  void addError(String error) {
    errors.add(error);
  }
  
  void addWarning(String warning) {
    warnings.add(warning);
  }
  
  void addSuccess(String success) {
    successes.add(success);
  }
  
  void addCheck(String check) {
    checks.add(check);
  }
  
  void addDetail(String detail) {
    details.add(detail);
  }
  
  int get totalIssues => errors.length + warnings.length;
  
  String get summary {
    if (isValid) {
      return '验证通过：${successes.length} 项检查完成';
    } else {
      return '验证失败：${errors.length} 个错误, ${warnings.length} 个警告';
    }
  }
}