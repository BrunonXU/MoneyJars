/*
 * 同步服务接口 (sync_service.dart)
 * 
 * 功能说明：
 * - 定义数据同步服务的抽象接口
 * - 支持未来的云端同步功能
 * - 预留多设备同步接口
 * 
 * 设计考虑：
 * - 策略模式：支持不同的同步策略
 * - 观察者模式：同步状态监听
 * - 冲突解决机制
 */

import '../entities/transaction.dart';
import '../entities/category.dart';
import '../entities/jar_settings.dart';
import '../entities/user.dart';

/// 同步服务抽象接口
/// 
/// 提供数据同步的核心功能
abstract class SyncService {
  /// 初始化同步服务
  Future<void> initialize();
  
  /// 释放资源
  Future<void> dispose();
  
  // ===== 同步操作 =====
  
  /// 执行完整同步
  /// 
  /// 同步所有数据类型
  Future<SyncResult> performFullSync();
  
  /// 同步交易记录
  Future<SyncResult> syncTransactions({
    DateTime? lastSyncTime,
    List<String>? specificIds,
  });
  
  /// 同步分类
  Future<SyncResult> syncCategories({
    DateTime? lastSyncTime,
  });
  
  /// 同步设置
  Future<SyncResult> syncSettings({
    DateTime? lastSyncTime,
  });
  
  // ===== 冲突解决 =====
  
  /// 解决同步冲突
  /// 
  /// 当本地和远程数据冲突时调用
  Future<ConflictResolution> resolveConflict(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy,
  );
  
  /// 获取冲突列表
  Future<List<SyncConflict>> getPendingConflicts();
  
  // ===== 同步状态 =====
  
  /// 获取同步状态
  SyncStatus getSyncStatus();
  
  /// 获取最后同步时间
  DateTime? getLastSyncTime();
  
  /// 检查是否需要同步
  Future<bool> needsSync();
  
  /// 获取待同步项目数量
  Future<SyncPendingCount> getPendingSyncCount();
  
  // ===== 同步监听 =====
  
  /// 添加同步状态监听器
  void addSyncListener(SyncListener listener);
  
  /// 移除同步状态监听器
  void removeSyncListener(SyncListener listener);
  
  // ===== 同步配置 =====
  
  /// 设置同步配置
  Future<void> setSyncConfig(SyncConfig config);
  
  /// 获取同步配置
  SyncConfig getSyncConfig();
  
  /// 启用/禁用自动同步
  Future<void> setAutoSyncEnabled(bool enabled);
  
  /// 设置同步间隔
  Future<void> setSyncInterval(Duration interval);
}

/// 同步结果
class SyncResult {
  /// 是否成功
  final bool success;
  
  /// 同步的项目数量
  final int syncedCount;
  
  /// 添加的项目数量
  final int addedCount;
  
  /// 更新的项目数量
  final int updatedCount;
  
  /// 删除的项目数量
  final int deletedCount;
  
  /// 冲突数量
  final int conflictCount;
  
  /// 错误信息
  final String? error;
  
  /// 同步开始时间
  final DateTime startTime;
  
  /// 同步结束时间
  final DateTime endTime;
  
  const SyncResult({
    required this.success,
    required this.syncedCount,
    required this.addedCount,
    required this.updatedCount,
    required this.deletedCount,
    required this.conflictCount,
    this.error,
    required this.startTime,
    required this.endTime,
  });
  
  /// 同步耗时
  Duration get duration => endTime.difference(startTime);
}

/// 同步冲突
class SyncConflict {
  /// 冲突ID
  final String id;
  
  /// 数据类型
  final SyncDataType dataType;
  
  /// 本地数据
  final Map<String, dynamic> localData;
  
  /// 远程数据
  final Map<String, dynamic> remoteData;
  
  /// 本地更新时间
  final DateTime localUpdatedAt;
  
  /// 远程更新时间
  final DateTime remoteUpdatedAt;
  
  /// 冲突原因
  final String reason;
  
  const SyncConflict({
    required this.id,
    required this.dataType,
    required this.localData,
    required this.remoteData,
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
    required this.reason,
  });
}

/// 冲突解决结果
class ConflictResolution {
  /// 是否解决成功
  final bool resolved;
  
  /// 选择的数据（local/remote/merged）
  final Map<String, dynamic>? selectedData;
  
  /// 解决策略
  final ConflictResolutionStrategy strategy;
  
  const ConflictResolution({
    required this.resolved,
    this.selectedData,
    required this.strategy,
  });
}

/// 同步状态
enum SyncStatus {
  /// 空闲
  idle,
  
  /// 同步中
  syncing,
  
  /// 同步成功
  success,
  
  /// 同步失败
  failed,
  
  /// 有冲突
  conflict,
  
  /// 离线
  offline,
}

/// 同步数据类型
enum SyncDataType {
  transaction,
  category,
  jarSettings,
  userPreferences,
}

/// 冲突解决策略
enum ConflictResolutionStrategy {
  /// 使用本地数据
  useLocal,
  
  /// 使用远程数据
  useRemote,
  
  /// 合并数据
  merge,
  
  /// 跳过
  skip,
  
  /// 手动解决
  manual,
}

/// 待同步计数
class SyncPendingCount {
  /// 待同步交易数
  final int transactions;
  
  /// 待同步分类数
  final int categories;
  
  /// 待同步设置数
  final int settings;
  
  const SyncPendingCount({
    required this.transactions,
    required this.categories,
    required this.settings,
  });
  
  /// 总计
  int get total => transactions + categories + settings;
  
  /// 是否有待同步项
  bool get hasPending => total > 0;
}

/// 同步监听器
abstract class SyncListener {
  /// 同步开始
  void onSyncStarted();
  
  /// 同步进度更新
  void onSyncProgress(double progress, String message);
  
  /// 同步完成
  void onSyncCompleted(SyncResult result);
  
  /// 同步失败
  void onSyncFailed(String error);
  
  /// 发现冲突
  void onConflictFound(List<SyncConflict> conflicts);
  
  /// 同步状态改变
  void onSyncStatusChanged(SyncStatus status);
}

/// 同步配置
class SyncConfig {
  /// 是否启用自动同步
  final bool autoSyncEnabled;
  
  /// 同步间隔
  final Duration syncInterval;
  
  /// 仅在WiFi下同步
  final bool wifiOnly;
  
  /// 电量低时不同步
  final bool batteryOptimized;
  
  /// 冲突解决策略
  final ConflictResolutionStrategy defaultStrategy;
  
  /// 同步范围（天数）
  final int syncDaysRange;
  
  const SyncConfig({
    this.autoSyncEnabled = true,
    this.syncInterval = const Duration(hours: 6),
    this.wifiOnly = true,
    this.batteryOptimized = true,
    this.defaultStrategy = ConflictResolutionStrategy.useRemote,
    this.syncDaysRange = 365,
  });
  
  /// 创建副本
  SyncConfig copyWith({
    bool? autoSyncEnabled,
    Duration? syncInterval,
    bool? wifiOnly,
    bool? batteryOptimized,
    ConflictResolutionStrategy? defaultStrategy,
    int? syncDaysRange,
  }) {
    return SyncConfig(
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      syncInterval: syncInterval ?? this.syncInterval,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      batteryOptimized: batteryOptimized ?? this.batteryOptimized,
      defaultStrategy: defaultStrategy ?? this.defaultStrategy,
      syncDaysRange: syncDaysRange ?? this.syncDaysRange,
    );
  }
}