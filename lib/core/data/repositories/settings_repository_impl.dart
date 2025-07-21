/*
 * 设置仓库实现 (settings_repository_impl.dart)
 * 
 * 功能说明：
 * - 实现设置仓库接口，管理应用设置数据
 * - 包括罐头设置、用户偏好等
 * - 提供设置的持久化和缓存
 * 
 * 设计考虑：
 * - 支持多种设置类型扩展
 * - 设置变更监听机制
 * - 默认值管理
 */

import 'package:flutter/foundation.dart';
import '../../domain/entities/jar_settings.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/hive_datasource.dart';
import '../models/jar_settings_model.dart';

/// 设置仓库实现类
/// 
/// 管理：
/// - 罐头设置（目标金额、提醒等）
/// - 用户偏好设置
/// - 应用配置
class SettingsRepositoryImpl implements SettingsRepository {
  final LocalDataSource _localDataSource;
  
  /// 罐头设置缓存
  Map<JarType, JarSettings>? _cachedJarSettings;
  
  /// 当前用户缓存
  User? _cachedCurrentUser;
  
  SettingsRepositoryImpl({
    required LocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;
  
  /// 清除所有缓存
  void _clearCache() {
    _cachedJarSettings = null;
    _cachedCurrentUser = null;
  }
  
  @override
  Future<JarSettings> getJarSettings(JarType jarType) async {
    try {
      // 检查缓存
      if (_cachedJarSettings != null && _cachedJarSettings!.containsKey(jarType)) {
        return _cachedJarSettings![jarType]!;
      }
      
      // 从数据源获取
      final model = await _localDataSource.getJarSettings(jarType.index);
      
      if (model != null) {
        final settings = model.toEntity();
        
        // 更新缓存
        _cachedJarSettings ??= {};
        _cachedJarSettings![jarType] = settings;
        
        return settings;
      }
      
      // 如果没有设置，返回默认值
      return _createDefaultJarSettings(jarType);
    } catch (e) {
      debugPrint('获取罐头设置失败: $e');
      // 返回默认设置
      return _createDefaultJarSettings(jarType);
    }
  }
  
  @override
  Future<Map<JarType, JarSettings>> getAllJarSettings() async {
    try {
      final models = await _localDataSource.getAllJarSettings();
      
      final settingsMap = <JarType, JarSettings>{};
      
      // 转换模型到实体
      for (final model in models) {
        final jarType = JarType.values[model.jarTypeIndex];
        settingsMap[jarType] = model.toEntity();
      }
      
      // 确保所有类型都有设置
      for (final jarType in JarType.values) {
        if (!settingsMap.containsKey(jarType)) {
          settingsMap[jarType] = _createDefaultJarSettings(jarType);
        }
      }
      
      // 更新缓存
      _cachedJarSettings = settingsMap;
      
      return settingsMap;
    } catch (e) {
      debugPrint('获取所有罐头设置失败: $e');
      
      // 返回默认设置
      final defaultSettings = <JarType, JarSettings>{};
      for (final jarType in JarType.values) {
        defaultSettings[jarType] = _createDefaultJarSettings(jarType);
      }
      return defaultSettings;
    }
  }
  
  @override
  Future<void> updateJarSettings(JarSettings settings) async {
    try {
      // 转换为数据模型
      final model = JarSettingsModel.fromEntity(settings);
      
      // 保存到数据源
      await _localDataSource.saveJarSettings(model);
      
      // 更新缓存
      _cachedJarSettings ??= {};
      _cachedJarSettings![settings.jarType] = settings;
    } catch (e) {
      debugPrint('更新罐头设置失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> resetJarSettings(JarType jarType) async {
    try {
      // 创建默认设置
      final defaultSettings = _createDefaultJarSettings(jarType);
      
      // 保存默认设置
      await updateJarSettings(defaultSettings);
    } catch (e) {
      debugPrint('重置罐头设置失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> resetAllSettings() async {
    try {
      // 清空所有数据
      await _localDataSource.clearAllData();
      
      // 清除缓存
      _clearCache();
      
      // 重新初始化会自动创建默认设置
      await _localDataSource.initialize();
    } catch (e) {
      debugPrint('重置所有设置失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<User> getCurrentUser() async {
    try {
      // 检查缓存
      if (_cachedCurrentUser != null) {
        return _cachedCurrentUser!;
      }
      
      // 当前阶段总是返回本地用户
      // 使用设备唯一标识作为用户ID
      const deviceId = 'local_device_001'; // TODO: 使用真实的设备ID
      
      _cachedCurrentUser = User.createLocal(deviceId: deviceId);
      
      return _cachedCurrentUser!;
    } catch (e) {
      debugPrint('获取当前用户失败: $e');
      // 返回默认本地用户
      return User.createLocal(deviceId: 'default_local');
    }
  }
  
  @override
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    try {
      // 获取当前用户
      final currentUser = await getCurrentUser();
      
      // 创建更新后的用户
      final updatedUser = User(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        userType: currentUser.userType,
        createdAt: currentUser.createdAt,
        lastActiveAt: DateTime.now(),
        preferences: preferences,
      );
      
      // 更新缓存
      _cachedCurrentUser = updatedUser;
      
      // TODO: 在未来版本中持久化用户偏好设置
    } catch (e) {
      debugPrint('更新用户偏好设置失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      // 获取所有设置数据
      final jarSettings = await getAllJarSettings();
      final currentUser = await getCurrentUser();
      
      // 构建导出数据
      final exportData = {
        'jarSettings': jarSettings.map((key, value) => 
          MapEntry(key.toString(), JarSettingsModel.fromEntity(value).toJson())
        ),
        'userPreferences': {
          'theme': currentUser.preferences.theme.toString(),
          'language': currentUser.preferences.language,
          'currency': currentUser.preferences.currency,
          'enableNotifications': currentUser.preferences.enableNotifications,
          'notificationTime': currentUser.preferences.notificationTime,
          'enableAutoBackup': currentUser.preferences.enableAutoBackup,
          'backupFrequency': currentUser.preferences.backupFrequency,
        },
        'exportDate': DateTime.now().toIso8601String(),
        'version': '2.0',
      };
      
      return exportData;
    } catch (e) {
      debugPrint('导出设置失败: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> importSettings(Map<String, dynamic> data) async {
    try {
      // 导入罐头设置
      if (data.containsKey('jarSettings')) {
        final jarSettingsData = data['jarSettings'] as Map<String, dynamic>;
        
        for (final entry in jarSettingsData.entries) {
          // 解析JarType
          final jarTypeStr = entry.key.replaceAll('JarType.', '');
          final jarType = JarType.values.firstWhere(
            (type) => type.toString().endsWith(jarTypeStr),
            orElse: () => JarType.income,
          );
          
          // 解析设置数据
          final settingsJson = entry.value as Map<String, dynamic>;
          final model = JarSettingsModel.fromJson(settingsJson);
          final settings = model.toEntity();
          
          // 更新设置
          await updateJarSettings(settings);
        }
      }
      
      // TODO: 导入用户偏好设置
      
      // 清除缓存以确保数据更新
      _clearCache();
    } catch (e) {
      debugPrint('导入设置失败: $e');
      rethrow;
    }
  }
  
  /// 创建默认的罐头设置
  JarSettings _createDefaultJarSettings(JarType jarType) {
    final now = DateTime.now();
    
    switch (jarType) {
      case JarType.income:
        return JarSettings(
          targetAmount: 10000.0,
          title: '收入目标',
          updatedAt: now,
          jarType: jarType,
          enableTargetReminder: false,
          reminderThreshold: 0.8,
          showOnHome: true,
          displayOrder: 0,
        );
        
      case JarType.expense:
        return JarSettings(
          targetAmount: 5000.0,
          title: '支出预算',
          updatedAt: now,
          jarType: jarType,
          enableTargetReminder: true,
          reminderThreshold: 0.9,
          showOnHome: true,
          displayOrder: 1,
        );
        
      case JarType.comprehensive:
        return JarSettings(
          targetAmount: 5000.0,
          title: '储蓄目标',
          updatedAt: now,
          jarType: jarType,
          enableTargetReminder: false,
          reminderThreshold: 0.8,
          showOnHome: true,
          displayOrder: 2,
        );
    }
  }
}