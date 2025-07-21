#!/usr/bin/env dart

import 'dart:io';
import 'package:money_jars/services/storage_service.dart';
import 'package:money_jars/core/data/datasources/local/hive_datasource.dart';
import 'package:money_jars/tools/migration/migration_runner.dart';
import 'package:money_jars/tools/migration/migration_validator.dart';
import 'package:hive/hive.dart';

/// 命令行迁移工具
/// 使用方法: dart run bin/migrate.dart [command]
/// 命令:
///   check    - 检查是否需要迁移
///   run      - 执行迁移
///   validate - 验证迁移结果
///   report   - 生成验证报告
void main(List<String> args) async {
  print('MoneyJars 数据迁移工具');
  print('=' * 50);
  
  if (args.isEmpty) {
    printUsage();
    exit(0);
  }
  
  final command = args[0];
  
  try {
    // 初始化Hive
    Hive.init('./hive_data');
    
    // 初始化服务
    final storageService = StorageService();
    await storageService.init();
    
    final hiveDataSource = HiveLocalDataSource();
    await hiveDataSource.initialize();
    
    switch (command) {
      case 'check':
        await checkMigration(storageService, hiveDataSource);
        break;
      case 'run':
        await runMigration(storageService, hiveDataSource);
        break;
      case 'validate':
        await validateMigration(storageService, hiveDataSource);
        break;
      case 'report':
        await generateReport(storageService, hiveDataSource);
        break;
      default:
        print('⚠️  未知命令: $command');
        printUsage();
        exit(1);
    }
  } catch (e) {
    print('❌ 错误: $e');
    exit(1);
  }
  
  exit(0);
}

void printUsage() {
  print('');
  print('使用方法: dart run bin/migrate.dart [command]');
  print('');
  print('可用命令:');
  print('  check    - 检查是否需要迁移');
  print('  run      - 执行数据迁移');
  print('  validate - 验证迁移结果');
  print('  report   - 生成详细验证报告');
  print('');
}

/// 检查是否需要迁移
Future<void> checkMigration(
  StorageService storageService,
  HiveLocalDataSource hiveDataSource,
) async {
  print('\n🔍 检查迁移状态...');
  
  final runner = MigrationRunner(
    storageService: storageService,
    hiveDataSource: hiveDataSource,
  );
  
  final needsMigration = await runner.needsMigration();
  
  if (needsMigration) {
    print('⚠️  需要迁移数据');
    
    // 统计待迁移数据
    final categories = await storageService.getAllCategories();
    final transactions = await storageService.getAllTransactions();
    
    print('');
    print('待迁移数据:');
    print('  - 分类: ${categories.length} 个');
    print('  - 交易: ${transactions.length} 条');
    print('');
    print('运行 "dart run bin/migrate.dart run" 开始迁移');
  } else {
    print('✅ 数据已迁移，无需操作');
    
    // 显示迁移信息
    final timestamp = await storageService.getData('migration_timestamp');
    if (timestamp != null) {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      print('迁移时间: ${date.toLocal()}');
    }
  }
}

/// 执行迁移
Future<void> runMigration(
  StorageService storageService,
  HiveLocalDataSource hiveDataSource,
) async {
  print('\n🚀 开始执行数据迁移...');
  
  final runner = MigrationRunner(
    storageService: storageService,
    hiveDataSource: hiveDataSource,
  );
  
  // 检查是否需要迁移
  final needsMigration = await runner.needsMigration();
  if (!needsMigration) {
    print('⚠️  数据已经迁移过，无需重复迁移');
    print('如果需要重新迁移，请先清理迁移标记');
    return;
  }
  
  // 确认操作
  print('');
  print('⚠️  注意：迁移操作将会：');
  print('  1. 备份当前数据');
  print('  2. 将数据转换到新格式');
  print('  3. 保存到新的存储系统');
  print('');
  stdout.write('确认继续？(y/N): ');
  final confirm = stdin.readLineSync()?.toLowerCase();
  
  if (confirm != 'y') {
    print('已取消');
    return;
  }
  
  print('');
  
  // 执行迁移
  final result = await runner.runFullMigration();
  
  // 显示结果
  print('');
  print(result);
  
  if (result.isSuccess) {
    print('\n✅ 迁移成功！');
  } else {
    print('\n❌ 迁移失败！');
  }
}

/// 验证迁移结果
Future<void> validateMigration(
  StorageService storageService,
  HiveLocalDataSource hiveDataSource,
) async {
  print('\n🔍 验证迁移结果...');
  
  final validator = MigrationValidator(
    storageService: storageService,
    hiveDataSource: hiveDataSource,
  );
  
  final result = await validator.validateMigration();
  
  print('');
  print('验证结果: ${result.summary}');
  print('');
  
  if (result.errors.isNotEmpty) {
    print('错误:');
    for (final error in result.errors) {
      print('  ❌ $error');
    }
    print('');
  }
  
  if (result.warnings.isNotEmpty) {
    print('警告:');
    for (final warning in result.warnings) {
      print('  ⚠️ $warning');
    }
    print('');
  }
  
  if (result.successes.isNotEmpty) {
    print('通过:');
    for (final success in result.successes) {
      print('  ✅ $success');
    }
  }
}

/// 生成详细报告
Future<void> generateReport(
  StorageService storageService,
  HiveLocalDataSource hiveDataSource,
) async {
  print('\n📄 生成验证报告...');
  
  final validator = MigrationValidator(
    storageService: storageService,
    hiveDataSource: hiveDataSource,
  );
  
  final report = await validator.generateValidationReport();
  
  // 保存报告
  final filename = 'migration_report_${DateTime.now().millisecondsSinceEpoch}.md';
  final file = File(filename);
  await file.writeAsString(report);
  
  print('✅ 报告已保存: $filename');
  print('');
  print('报告预览:');
  print('-' * 50);
  print(report.split('\n').take(20).join('\n'));
  print('...');
  print('-' * 50);
}