/*
 * 依赖注入配置 (service_locator.dart)
 * 
 * 功能说明：
 * - 集中管理所有依赖项的创建和配置
 * - 使用 get_it 实现服务定位器模式
 * - 支持单例和工厂模式
 * 
 * 设计原则：
 * - 依赖倒置：高层模块不依赖低层模块
 * - 单一职责：每个服务只负责一个功能
 * - 开闭原则：易于扩展，不修改现有代码
 */

import 'package:get_it/get_it.dart';
import '../data/datasources/local/hive_datasource.dart';
import '../data/repositories/transaction_repository_simple_impl.dart';
import '../data/repositories/category_repository_simple_impl.dart';
import '../data/repositories/settings_repository_simple_impl.dart';
import '../data/services/local_sync_service.dart';
import '../domain/repositories/transaction_repository_simple.dart';
import '../domain/repositories/category_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/services/sync_service.dart';

/// 服务定位器实例
final GetIt serviceLocator = GetIt.instance;

/// 初始化依赖注入
/// 
/// 调用时机：
/// - 在 main() 函数中，runApp() 之前
/// - 在测试环境中，setUp() 中
Future<void> initServiceLocator() async {
  // ===== 数据源 =====
  
  // 注册本地数据源（单例）
  serviceLocator.registerLazySingleton<LocalDataSource>(
    () => HiveLocalDataSource(),
  );
  
  // ===== 仓库 =====
  
  // 注册交易仓库（单例）
  serviceLocator.registerLazySingleton<TransactionRepository>(
    () => TransactionRepositoryImpl(
      localDataSource: serviceLocator<LocalDataSource>(),
    ),
  );
  
  // 注册分类仓库（单例）
  serviceLocator.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      localDataSource: serviceLocator<LocalDataSource>(),
    ),
  );
  
  // 注册设置仓库（单例）
  serviceLocator.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: serviceLocator<LocalDataSource>(),
    ),
  );
  
  // ===== 服务 =====
  
  // 注册同步服务（单例）
  serviceLocator.registerLazySingleton<SyncService>(
    () => LocalSyncService(),
  );
  
  // ===== 用例（Use Cases）=====
  // TODO: 在需要时添加用例层
  
  // ===== Provider =====
  // Provider 将在 UI 层初始化时注册
  
  // 初始化数据源
  final dataSource = serviceLocator<LocalDataSource>();
  await dataSource.initialize();
  
  // 初始化同步服务
  final syncService = serviceLocator<SyncService>();
  await syncService.initialize();
}

/// 重置依赖注入（主要用于测试）
Future<void> resetServiceLocator() async {
  await serviceLocator.reset();
}

/// 依赖注入扩展方法
/// 
/// 提供便捷的依赖获取方法
extension ServiceLocatorExtension on GetIt {
  /// 获取交易仓库
  TransactionRepository get transactionRepository => get<TransactionRepository>();
  
  /// 获取分类仓库
  CategoryRepository get categoryRepository => get<CategoryRepository>();
  
  /// 获取设置仓库
  SettingsRepository get settingsRepository => get<SettingsRepository>();
  
  /// 获取本地数据源
  LocalDataSource get localDataSource => get<LocalDataSource>();
  
  /// 获取同步服务
  SyncService get syncService => get<SyncService>();
}