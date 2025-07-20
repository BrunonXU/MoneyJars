/*
 * 本地同步服务实现 (local_sync_service.dart)
 * 
 * 功能说明：
 * - 实现同步服务接口的本地版本
 * - 模拟同步行为，为未来云同步做准备
 * - 管理本地数据版本和变更追踪
 * 
 * 设计说明：
 * - 当前仅实现本地功能
 * - 保留同步接口，便于未来扩展
 * - 支持数据导入导出
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/services/sync_service.dart';

/// 本地同步服务实现
/// 
/// 当前阶段的占位实现，为未来云同步预留接口
class LocalSyncService implements SyncService {
  /// 同步状态
  SyncStatus _status = SyncStatus.idle;
  
  /// 最后同步时间
  DateTime? _lastSyncTime;
  
  /// 同步配置
  SyncConfig _config = const SyncConfig();
  
  /// 同步监听器列表
  final List<SyncListener> _listeners = [];
  
  /// 模拟的冲突列表
  final List<SyncConflict> _pendingConflicts = [];
  
  /// 自动同步定时器
  Timer? _autoSyncTimer;
  
  @override
  Future<void> initialize() async {
    debugPrint('初始化本地同步服务');
    
    // 如果启用了自动同步，设置定时器
    if (_config.autoSyncEnabled) {
      _scheduleAutoSync();
    }
  }
  
  @override
  Future<void> dispose() async {
    _autoSyncTimer?.cancel();
    _listeners.clear();
  }
  
  // ===== 同步操作 =====
  
  @override
  Future<SyncResult> performFullSync() async {
    _notifyListeners((listener) => listener.onSyncStarted());
    _updateStatus(SyncStatus.syncing);
    
    final startTime = DateTime.now();
    
    try {
      // 模拟同步过程
      await Future.delayed(const Duration(seconds: 2));
      
      // 在本地版本中，总是返回成功
      final result = SyncResult(
        success: true,
        syncedCount: 0,
        addedCount: 0,
        updatedCount: 0,
        deletedCount: 0,
        conflictCount: 0,
        startTime: startTime,
        endTime: DateTime.now(),
      );
      
      _lastSyncTime = DateTime.now();
      _updateStatus(SyncStatus.success);
      _notifyListeners((listener) => listener.onSyncCompleted(result));
      
      return result;
    } catch (e) {
      _updateStatus(SyncStatus.failed);
      _notifyListeners((listener) => listener.onSyncFailed(e.toString()));
      
      return SyncResult(
        success: false,
        syncedCount: 0,
        addedCount: 0,
        updatedCount: 0,
        deletedCount: 0,
        conflictCount: 0,
        error: e.toString(),
        startTime: startTime,
        endTime: DateTime.now(),
      );
    }
  }
  
  @override
  Future<SyncResult> syncTransactions({
    DateTime? lastSyncTime,
    List<String>? specificIds,
  }) async {
    // 本地版本暂不实现具体同步
    return SyncResult(
      success: true,
      syncedCount: 0,
      addedCount: 0,
      updatedCount: 0,
      deletedCount: 0,
      conflictCount: 0,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
    );
  }
  
  @override
  Future<SyncResult> syncCategories({DateTime? lastSyncTime}) async {
    // 本地版本暂不实现具体同步
    return SyncResult(
      success: true,
      syncedCount: 0,
      addedCount: 0,
      updatedCount: 0,
      deletedCount: 0,
      conflictCount: 0,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
    );
  }
  
  @override
  Future<SyncResult> syncSettings({DateTime? lastSyncTime}) async {
    // 本地版本暂不实现具体同步
    return SyncResult(
      success: true,
      syncedCount: 0,
      addedCount: 0,
      updatedCount: 0,
      deletedCount: 0,
      conflictCount: 0,
      startTime: DateTime.now(),
      endTime: DateTime.now(),
    );
  }
  
  // ===== 冲突解决 =====
  
  @override
  Future<ConflictResolution> resolveConflict(
    SyncConflict conflict,
    ConflictResolutionStrategy strategy,
  ) async {
    // 从待处理列表中移除
    _pendingConflicts.removeWhere((c) => c.id == conflict.id);
    
    // 根据策略选择数据
    Map<String, dynamic>? selectedData;
    switch (strategy) {
      case ConflictResolutionStrategy.useLocal:
        selectedData = conflict.localData;
        break;
      case ConflictResolutionStrategy.useRemote:
        selectedData = conflict.remoteData;
        break;
      case ConflictResolutionStrategy.merge:
        // 简单合并：使用更新时间较新的数据
        selectedData = conflict.localUpdatedAt.isAfter(conflict.remoteUpdatedAt)
            ? conflict.localData
            : conflict.remoteData;
        break;
      case ConflictResolutionStrategy.skip:
      case ConflictResolutionStrategy.manual:
        selectedData = null;
        break;
    }
    
    return ConflictResolution(
      resolved: selectedData != null,
      selectedData: selectedData,
      strategy: strategy,
    );
  }
  
  @override
  Future<List<SyncConflict>> getPendingConflicts() async {
    return List.from(_pendingConflicts);
  }
  
  // ===== 同步状态 =====
  
  @override
  SyncStatus getSyncStatus() => _status;
  
  @override
  DateTime? getLastSyncTime() => _lastSyncTime;
  
  @override
  Future<bool> needsSync() async {
    // 本地版本始终不需要同步
    return false;
  }
  
  @override
  Future<SyncPendingCount> getPendingSyncCount() async {
    // 本地版本没有待同步项
    return const SyncPendingCount(
      transactions: 0,
      categories: 0,
      settings: 0,
    );
  }
  
  // ===== 同步监听 =====
  
  @override
  void addSyncListener(SyncListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }
  
  @override
  void removeSyncListener(SyncListener listener) {
    _listeners.remove(listener);
  }
  
  // ===== 同步配置 =====
  
  @override
  Future<void> setSyncConfig(SyncConfig config) async {
    _config = config;
    
    // 重新调度自动同步
    _autoSyncTimer?.cancel();
    if (config.autoSyncEnabled) {
      _scheduleAutoSync();
    }
  }
  
  @override
  SyncConfig getSyncConfig() => _config;
  
  @override
  Future<void> setAutoSyncEnabled(bool enabled) async {
    _config = _config.copyWith(autoSyncEnabled: enabled);
    
    if (enabled) {
      _scheduleAutoSync();
    } else {
      _autoSyncTimer?.cancel();
    }
  }
  
  @override
  Future<void> setSyncInterval(Duration interval) async {
    _config = _config.copyWith(syncInterval: interval);
    
    // 重新调度
    if (_config.autoSyncEnabled) {
      _autoSyncTimer?.cancel();
      _scheduleAutoSync();
    }
  }
  
  // ===== 私有方法 =====
  
  /// 更新同步状态
  void _updateStatus(SyncStatus status) {
    if (_status != status) {
      _status = status;
      _notifyListeners((listener) => listener.onSyncStatusChanged(status));
    }
  }
  
  /// 通知所有监听器
  void _notifyListeners(void Function(SyncListener) callback) {
    for (final listener in List.from(_listeners)) {
      callback(listener);
    }
  }
  
  /// 调度自动同步
  void _scheduleAutoSync() {
    _autoSyncTimer = Timer.periodic(_config.syncInterval, (_) {
      if (_status == SyncStatus.idle) {
        performFullSync();
      }
    });
  }
}

/// 简单的同步监听器实现
/// 
/// 用于调试和日志记录
class SimpleSyncListener implements SyncListener {
  final String name;
  
  SimpleSyncListener({this.name = 'SyncListener'});
  
  @override
  void onSyncStarted() {
    debugPrint('[$name] 同步开始');
  }
  
  @override
  void onSyncProgress(double progress, String message) {
    debugPrint('[$name] 同步进度: ${(progress * 100).toStringAsFixed(1)}% - $message');
  }
  
  @override
  void onSyncCompleted(SyncResult result) {
    debugPrint('[$name] 同步完成: ${result.syncedCount}项, 耗时${result.duration.inSeconds}秒');
  }
  
  @override
  void onSyncFailed(String error) {
    debugPrint('[$name] 同步失败: $error');
  }
  
  @override
  void onConflictFound(List<SyncConflict> conflicts) {
    debugPrint('[$name] 发现${conflicts.length}个冲突');
  }
  
  @override
  void onSyncStatusChanged(SyncStatus status) {
    debugPrint('[$name] 同步状态: $status');
  }
}