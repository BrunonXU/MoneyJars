/*
 * 设置仓库接口 (settings_repository.dart)
 * 
 * 功能说明：
 * - 定义应用设置的抽象接口
 * - 管理用户偏好设置
 * - 支持设置导入导出
 * 
 * 设计原则：
 * - 类型安全的设置访问
 * - 支持默认值
 * - 易于扩展
 */

import '../entities/settings.dart';

/// 设置仓库接口
/// 
/// 管理应用程序的各种设置
abstract class SettingsRepository {
  /// 获取所有设置
  Future<Settings> getSettings();
  
  /// 保存设置
  Future<void> saveSettings(Settings settings);
  
  /// 获取单个设置值
  Future<T?> getSetting<T>(String key);
  
  /// 设置单个值
  Future<void> setSetting<T>(String key, T value);
  
  /// 删除设置
  Future<void> removeSetting(String key);
  
  /// 重置为默认设置
  Future<void> resetToDefaults();
  
  /// 导出设置
  Future<String> exportSettings();
  
  /// 导入设置
  Future<void> importSettings(String data);
  
  /// 清空所有设置
  Future<void> clearAllSettings();
  
  /// 获取设置版本
  Future<int> getSettingsVersion();
  
  /// 迁移设置（版本升级时使用）
  Future<void> migrateSettings(int fromVersion, int toVersion);
}