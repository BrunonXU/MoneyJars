/*
 * 简化版设置仓库实现 (settings_repository_simple_impl.dart)
 * 
 * 功能说明：
 * - 实现设置仓库接口的基本功能
 * - 管理应用设置
 */

import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/hive_datasource.dart';

/// 简化版设置仓库实现类
class SettingsRepositoryImpl implements SettingsRepository {
  final LocalDataSource _localDataSource;
  static const String _settingsKey = 'app_settings';
  
  SettingsRepositoryImpl({
    required LocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;
  
  @override
  Future<Settings> getSettings() async {
    try {
      final data = await _localDataSource.getValue(_settingsKey);
      if (data != null && data is Map<String, dynamic>) {
        return Settings.fromMap(data);
      }
      return Settings.defaults();
    } catch (e) {
      print('Error getting settings: $e');
      return Settings.defaults();
    }
  }
  
  @override
  Future<void> saveSettings(Settings settings) async {
    try {
      await _localDataSource.setValue(_settingsKey, settings.toMap());
    } catch (e) {
      print('Error saving settings: $e');
      rethrow;
    }
  }
  
  @override
  Future<T?> getSetting<T>(String key) async {
    try {
      final settings = await getSettings();
      final map = settings.toMap();
      return map[key] as T?;
    } catch (e) {
      print('Error getting setting: $e');
      return null;
    }
  }
  
  @override
  Future<void> setSetting<T>(String key, T value) async {
    try {
      final settings = await getSettings();
      final map = settings.toMap();
      map[key] = value;
      await saveSettings(Settings.fromMap(map));
    } catch (e) {
      print('Error setting value: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> removeSetting(String key) async {
    await setSetting(key, null);
  }
  
  @override
  Future<void> resetToDefaults() async {
    await saveSettings(Settings.defaults());
  }
  
  @override
  Future<String> exportSettings() async {
    final settings = await getSettings();
    return settings.toMap().toString();
  }
  
  @override
  Future<void> importSettings(String data) async {
    // 简化实现
  }
  
  @override
  Future<void> clearAllSettings() async {
    await _localDataSource.deleteValue(_settingsKey);
  }
  
  @override
  Future<int> getSettingsVersion() async {
    final settings = await getSettings();
    return settings.version;
  }
  
  @override
  Future<void> migrateSettings(int fromVersion, int toVersion) async {
    // 简化实现
  }
}