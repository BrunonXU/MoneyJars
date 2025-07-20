import 'dart:async';
import 'package:money_jar/services/storage_service.dart';
import 'package:money_jar/core/data/datasources/local/hive_datasource.dart';
import 'package:money_jar/core/domain/entities/transaction.dart' as domain;
import 'package:money_jar/core/domain/entities/category.dart' as domain;
import 'package:money_jar/models/transaction.dart' as legacy;
import 'package:money_jar/models/category.dart' as legacy;
import 'package:money_jar/models/constants.dart';

/// 迁移运行器
/// 负责执行数据迁移任务
class MigrationRunner {
  final StorageService _storageService;
  final HiveLocalDataSource _hiveDataSource;
  
  MigrationRunner({
    required StorageService storageService,
    required HiveLocalDataSource hiveDataSource,
  })  : _storageService = storageService,
        _hiveDataSource = hiveDataSource;

  /// 执行完整迁移
  Future<MigrationResult> runFullMigration() async {
    final result = MigrationResult();
    
    try {
      // 1. 备份现有数据
      result.addStep('开始备份现有数据...');
      await _backupCurrentData(result);
      
      // 2. 迁移分类数据
      result.addStep('迁移分类数据...');
      await _migrateCategories(result);
      
      // 3. 迁移交易数据
      result.addStep('迁移交易数据...');
      await _migrateTransactions(result);
      
      // 4. 验证迁移结果
      result.addStep('验证迁移结果...');
      await _validateMigration(result);
      
      // 5. 设置迁移标记
      await _setMigrationFlag();
      
      result.isSuccess = true;
      result.addStep('迁移完成！');
    } catch (e) {
      result.isSuccess = false;
      result.errorMessage = e.toString();
      result.addStep('迁移失败: $e');
      
      // 回滚
      await _rollbackMigration(result);
    }
    
    return result;
  }

  /// 备份当前数据
  Future<void> _backupCurrentData(MigrationResult result) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // 备份分类
      final categories = await _storageService.getAllCategories();
      await _storageService.setData('backup_categories_$timestamp', categories.map((c) => c.toJson()).toList());
      result.addDetail('备份 ${categories.length} 个分类');
      
      // 备份交易
      final transactions = await _storageService.getAllTransactions();
      await _storageService.setData('backup_transactions_$timestamp', transactions.map((t) => t.toJson()).toList());
      result.addDetail('备份 ${transactions.length} 条交易记录');
      
      // 保存备份时间戳
      await _storageService.setData('last_backup_timestamp', timestamp);
    } catch (e) {
      throw Exception('备份失败: $e');
    }
  }

  /// 迁移分类数据
  Future<void> _migrateCategories(MigrationResult result) async {
    try {
      final legacyCategories = await _storageService.getAllCategories();
      final migratedCategories = <domain.Category>[];
      
      for (final legacy in legacyCategories) {
        final migrated = _convertLegacyCategory(legacy);
        migratedCategories.add(migrated);
      }
      
      // 保存到新数据源
      for (final category in migratedCategories) {
        await _hiveDataSource.saveCategory(category);
      }
      
      result.addDetail('成功迁移 ${migratedCategories.length} 个分类');
      result.migratedCategories = migratedCategories.length;
    } catch (e) {
      throw Exception('分类迁移失败: $e');
    }
  }

  /// 迁移交易数据
  Future<void> _migrateTransactions(MigrationResult result) async {
    try {
      final legacyTransactions = await _storageService.getAllTransactions();
      final migratedTransactions = <domain.Transaction>[];
      
      for (final legacy in legacyTransactions) {
        final migrated = _convertLegacyTransaction(legacy);
        migratedTransactions.add(migrated);
      }
      
      // 保存到新数据源
      for (final transaction in migratedTransactions) {
        await _hiveDataSource.saveTransaction(transaction);
      }
      
      result.addDetail('成功迁移 ${migratedTransactions.length} 条交易记录');
      result.migratedTransactions = migratedTransactions.length;
    } catch (e) {
      throw Exception('交易迁移失败: $e');
    }
  }

  /// 转换旧版分类到新版
  domain.Category _convertLegacyCategory(legacy.Category legacy) {
    return domain.Category(
      id: legacy.id,
      name: legacy.name,
      type: legacy.isIncome ? domain.TransactionType.income : domain.TransactionType.expense,
      icon: legacy.iconName ?? 'category',
      color: legacy.color?.value ?? 0xFF000000,
      userId: 'default_user', // 默认用户
      sortIndex: legacy.sortIndex ?? 0,
      parentId: null, // 旧版本没有父分类
      isActive: legacy.isActive ?? true,
      createdAt: legacy.createdAt ?? DateTime.now(),
      updatedAt: legacy.updatedAt ?? DateTime.now(),
    );
  }

  /// 转换旧版交易到新版
  domain.Transaction _convertLegacyTransaction(legacy.Transaction legacy) {
    return domain.Transaction(
      id: legacy.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      amount: legacy.amount,
      description: legacy.description ?? '',
      parentCategoryId: legacy.parentCategoryId ?? 'unknown',
      parentCategoryName: legacy.parentCategoryName ?? '未分类',
      subCategoryId: legacy.subCategoryId,
      subCategoryName: legacy.subCategoryName,
      type: _getTransactionType(legacy.parentCategoryId ?? ''),
      userId: 'default_user',
      tags: [], // 旧版本没有标签
      attachments: [], // 旧版本没有附件
      notes: '', // 旧版本没有备注
      location: null, // 旧版本没有位置
      syncedAt: null,
      createdAt: legacy.timestamp ?? DateTime.now(),
      updatedAt: legacy.timestamp ?? DateTime.now(),
    );
  }

  /// 获取交易类型
  domain.TransactionType _getTransactionType(String categoryId) {
    // 根据分类ID判断类型
    // 这里需要根据实际的分类ID规则进行判断
    return domain.TransactionType.expense;
  }

  /// 验证迁移结果
  Future<void> _validateMigration(MigrationResult result) async {
    // 验证分类数量
    final oldCategories = await _storageService.getAllCategories();
    final newCategories = await _hiveDataSource.getAllCategories();
    
    if (oldCategories.length != newCategories.length) {
      throw Exception('分类数量不匹配: 旧=${oldCategories.length}, 新=${newCategories.length}');
    }
    
    // 验证交易数量
    final oldTransactions = await _storageService.getAllTransactions();
    final newTransactions = await _hiveDataSource.getAllTransactions();
    
    if (oldTransactions.length != newTransactions.length) {
      throw Exception('交易数量不匹配: 旧=${oldTransactions.length}, 新=${newTransactions.length}');
    }
    
    result.addDetail('验证通过: 数据完整性检查成功');
  }

  /// 设置迁移标记
  Future<void> _setMigrationFlag() async {
    await _storageService.setData('migration_completed', true);
    await _storageService.setData('migration_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  /// 回滚迁移
  Future<void> _rollbackMigration(MigrationResult result) async {
    try {
      result.addStep('正在回滚...');
      
      // 清理新数据
      await _hiveDataSource.clearAllData();
      
      result.addDetail('回滚完成');
    } catch (e) {
      result.addDetail('回滚失败: $e');
    }
  }

  /// 检查是否需要迁移
  Future<bool> needsMigration() async {
    final migrationCompleted = await _storageService.getData('migration_completed') ?? false;
    return !migrationCompleted;
  }
}

/// 迁移结果
class MigrationResult {
  bool isSuccess = false;
  String? errorMessage;
  final List<String> steps = [];
  final List<String> details = [];
  int migratedCategories = 0;
  int migratedTransactions = 0;
  
  void addStep(String step) {
    steps.add('[${DateTime.now().toIso8601String()}] $step');
  }
  
  void addDetail(String detail) {
    details.add(detail);
  }
  
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('=== 迁移结果 ===');
    buffer.writeln('状态: ${isSuccess ? "成功" : "失败"}');
    
    if (errorMessage != null) {
      buffer.writeln('错误: $errorMessage');
    }
    
    buffer.writeln('\n执行步骤:');
    for (final step in steps) {
      buffer.writeln('  $step');
    }
    
    buffer.writeln('\n详细信息:');
    for (final detail in details) {
      buffer.writeln('  - $detail');
    }
    
    if (isSuccess) {
      buffer.writeln('\n迁移统计:');
      buffer.writeln('  - 分类: $migratedCategories 个');
      buffer.writeln('  - 交易: $migratedTransactions 条');
    }
    
    return buffer.toString();
  }
}