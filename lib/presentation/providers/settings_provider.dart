/*
 * 设置状态管理 (settings_provider.dart)
 * 
 * 功能说明：
 * - 管理应用设置状态
 * - 包括罐头设置、用户偏好等
 * - 提供设置的持久化
 * 
 * 设计特点：
 * - 响应式更新
 * - 设置变更监听
 * - 默认值管理
 */

import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/domain/entities/jar_settings.dart';
import '../../core/domain/entities/user.dart';
import '../../core/domain/repositories/settings_repository.dart';

/// 设置状态管理器
/// 
/// 管理：
/// - 罐头设置（目标金额、提醒等）
/// - 用户偏好（主题、语言等）
/// - 应用配置
class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _settingsRepository;
  
  /// 罐头设置映射
  Map<JarType, JarSettings> _jarSettings = {};
  
  /// 当前用户
  User? _currentUser;
  
  /// 是否正在加载
  bool _isLoading = false;
  
  /// 错误信息
  String? _errorMessage;
  
  /// 当前编辑的罐头类型
  JarType? _editingJarType;
  
  SettingsProvider({
    SettingsRepository? settingsRepository,
  }) : _settingsRepository = settingsRepository ?? serviceLocator.settingsRepository;
  
  // ===== Getters =====
  
  /// 获取所有罐头设置
  Map<JarType, JarSettings> get jarSettings => _jarSettings;
  
  /// 获取收入罐头设置
  JarSettings? get incomeJarSettings => _jarSettings[JarType.income];
  
  /// 获取支出罐头设置
  JarSettings? get expenseJarSettings => _jarSettings[JarType.expense];
  
  /// 获取综合罐头设置
  JarSettings? get comprehensiveJarSettings => _jarSettings[JarType.comprehensive];
  
  /// 获取当前用户
  User? get currentUser => _currentUser;
  
  /// 获取用户偏好设置
  UserPreferences? get userPreferences => _currentUser?.preferences;
  
  /// 是否正在加载
  bool get isLoading => _isLoading;
  
  /// 错误信息
  String? get errorMessage => _errorMessage;
  
  /// 当前编辑的罐头类型
  JarType? get editingJarType => _editingJarType;
  
  // ===== 罐头设置计算属性 =====
  
  /// 获取罐头进度
  double getJarProgress(JarType jarType, double currentAmount) {
    final settings = _jarSettings[jarType];
    if (settings == null || settings.targetAmount <= 0) return 0.0;
    
    return (currentAmount / settings.targetAmount).clamp(0.0, 1.0);
  }
  
  /// 是否需要提醒
  bool shouldRemind(JarType jarType, double currentAmount) {
    final settings = _jarSettings[jarType];
    if (settings == null || !settings.enableTargetReminder) return false;
    
    final progress = getJarProgress(jarType, currentAmount);
    return progress >= settings.reminderThreshold;
  }
  
  /// 获取罐头标题
  String getJarTitle(JarType jarType) {
    final settings = _jarSettings[jarType];
    return settings?.title ?? _getDefaultTitle(jarType);
  }
  
  /// 获取罐头目标金额
  double getJarTargetAmount(JarType jarType) {
    final settings = _jarSettings[jarType];
    return settings?.targetAmount ?? 0.0;
  }
  
  // ===== 初始化和加载 =====
  
  /// 初始化数据
  Future<void> initialize() async {
    await Future.wait([
      loadJarSettings(),
      loadCurrentUser(),
    ]);
  }
  
  /// 加载罐头设置
  Future<void> loadJarSettings() async {
    _setLoading(true);
    _clearError();
    
    try {
      _jarSettings = await _settingsRepository.getAllJarSettings();
      notifyListeners();
    } catch (e) {
      _setError('加载罐头设置失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// 加载当前用户
  Future<void> loadCurrentUser() async {
    try {
      _currentUser = await _settingsRepository.getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('加载用户信息失败: $e');
    }
  }
  
  // ===== 罐头设置操作 =====
  
  /// 更新罐头设置
  Future<void> updateJarSettings(JarSettings settings) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _settingsRepository.updateJarSettings(settings);
      
      // 更新本地缓存
      _jarSettings[settings.jarType] = settings;
      notifyListeners();
    } catch (e) {
      _setError('更新罐头设置失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 更新罐头目标金额
  Future<void> updateJarTargetAmount(JarType jarType, double amount) async {
    final currentSettings = _jarSettings[jarType];
    if (currentSettings == null) return;
    
    final updatedSettings = JarSettings(
      targetAmount: amount,
      title: currentSettings.title,
      updatedAt: DateTime.now(),
      deadline: currentSettings.deadline,
      jarType: currentSettings.jarType,
      enableTargetReminder: currentSettings.enableTargetReminder,
      reminderThreshold: currentSettings.reminderThreshold,
      customColor: currentSettings.customColor,
      customIcon: currentSettings.customIcon,
      description: currentSettings.description,
      showOnHome: currentSettings.showOnHome,
      displayOrder: currentSettings.displayOrder,
      userId: currentSettings.userId,
    );
    
    await updateJarSettings(updatedSettings);
  }
  
  /// 更新罐头标题
  Future<void> updateJarTitle(JarType jarType, String title) async {
    final currentSettings = _jarSettings[jarType];
    if (currentSettings == null) return;
    
    final updatedSettings = JarSettings(
      targetAmount: currentSettings.targetAmount,
      title: title,
      updatedAt: DateTime.now(),
      deadline: currentSettings.deadline,
      jarType: currentSettings.jarType,
      enableTargetReminder: currentSettings.enableTargetReminder,
      reminderThreshold: currentSettings.reminderThreshold,
      customColor: currentSettings.customColor,
      customIcon: currentSettings.customIcon,
      description: currentSettings.description,
      showOnHome: currentSettings.showOnHome,
      displayOrder: currentSettings.displayOrder,
      userId: currentSettings.userId,
    );
    
    await updateJarSettings(updatedSettings);
  }
  
  /// 切换罐头提醒
  Future<void> toggleJarReminder(JarType jarType) async {
    final currentSettings = _jarSettings[jarType];
    if (currentSettings == null) return;
    
    final updatedSettings = JarSettings(
      targetAmount: currentSettings.targetAmount,
      title: currentSettings.title,
      updatedAt: DateTime.now(),
      deadline: currentSettings.deadline,
      jarType: currentSettings.jarType,
      enableTargetReminder: !currentSettings.enableTargetReminder,
      reminderThreshold: currentSettings.reminderThreshold,
      customColor: currentSettings.customColor,
      customIcon: currentSettings.customIcon,
      description: currentSettings.description,
      showOnHome: currentSettings.showOnHome,
      displayOrder: currentSettings.displayOrder,
      userId: currentSettings.userId,
    );
    
    await updateJarSettings(updatedSettings);
  }
  
  /// 重置罐头设置
  Future<void> resetJarSettings(JarType jarType) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _settingsRepository.resetJarSettings(jarType);
      
      // 重新加载设置
      await loadJarSettings();
    } catch (e) {
      _setError('重置罐头设置失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 重置所有设置
  Future<void> resetAllSettings() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _settingsRepository.resetAllSettings();
      
      // 重新加载所有设置
      await initialize();
    } catch (e) {
      _setError('重置所有设置失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== 用户偏好设置 =====
  
  /// 更新用户偏好设置
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _settingsRepository.updateUserPreferences(preferences);
      
      // 更新本地用户信息
      if (_currentUser != null) {
        _currentUser = User(
          id: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          userType: _currentUser!.userType,
          createdAt: _currentUser!.createdAt,
          lastActiveAt: DateTime.now(),
          preferences: preferences,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('更新用户偏好设置失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  /// 切换主题
  Future<void> toggleTheme() async {
    if (_currentUser == null) return;
    
    final currentTheme = _currentUser!.preferences.theme;
    final newTheme = currentTheme == AppTheme.light ? AppTheme.dark : AppTheme.light;
    
    final updatedPreferences = UserPreferences(
      theme: newTheme,
      language: _currentUser!.preferences.language,
      currency: _currentUser!.preferences.currency,
      dateFormat: _currentUser!.preferences.dateFormat,
      firstDayOfWeek: _currentUser!.preferences.firstDayOfWeek,
      enableNotifications: _currentUser!.preferences.enableNotifications,
      notificationTime: _currentUser!.preferences.notificationTime,
      enableSound: _currentUser!.preferences.enableSound,
      enableVibration: _currentUser!.preferences.enableVibration,
      enableAutoBackup: _currentUser!.preferences.enableAutoBackup,
      backupFrequency: _currentUser!.preferences.backupFrequency,
      lastBackupDate: _currentUser!.preferences.lastBackupDate,
    );
    
    await updateUserPreferences(updatedPreferences);
  }
  
  /// 更新语言设置
  Future<void> updateLanguage(String language) async {
    if (_currentUser == null) return;
    
    final updatedPreferences = UserPreferences(
      theme: _currentUser!.preferences.theme,
      language: language,
      currency: _currentUser!.preferences.currency,
      dateFormat: _currentUser!.preferences.dateFormat,
      firstDayOfWeek: _currentUser!.preferences.firstDayOfWeek,
      enableNotifications: _currentUser!.preferences.enableNotifications,
      notificationTime: _currentUser!.preferences.notificationTime,
      enableSound: _currentUser!.preferences.enableSound,
      enableVibration: _currentUser!.preferences.enableVibration,
      enableAutoBackup: _currentUser!.preferences.enableAutoBackup,
      backupFrequency: _currentUser!.preferences.backupFrequency,
      lastBackupDate: _currentUser!.preferences.lastBackupDate,
    );
    
    await updateUserPreferences(updatedPreferences);
  }
  
  /// 更新货币设置
  Future<void> updateCurrency(String currency) async {
    if (_currentUser == null) return;
    
    final updatedPreferences = UserPreferences(
      theme: _currentUser!.preferences.theme,
      language: _currentUser!.preferences.language,
      currency: currency,
      dateFormat: _currentUser!.preferences.dateFormat,
      firstDayOfWeek: _currentUser!.preferences.firstDayOfWeek,
      enableNotifications: _currentUser!.preferences.enableNotifications,
      notificationTime: _currentUser!.preferences.notificationTime,
      enableSound: _currentUser!.preferences.enableSound,
      enableVibration: _currentUser!.preferences.enableVibration,
      enableAutoBackup: _currentUser!.preferences.enableAutoBackup,
      backupFrequency: _currentUser!.preferences.backupFrequency,
      lastBackupDate: _currentUser!.preferences.lastBackupDate,
    );
    
    await updateUserPreferences(updatedPreferences);
  }
  
  // ===== 编辑状态管理 =====
  
  /// 设置当前编辑的罐头类型
  void setEditingJarType(JarType? jarType) {
    _editingJarType = jarType;
    notifyListeners();
  }
  
  /// 清除编辑状态
  void clearEditingJarType() {
    _editingJarType = null;
    notifyListeners();
  }
  
  // ===== 导入导出 =====
  
  /// 导出设置
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      return await _settingsRepository.exportSettings();
    } catch (e) {
      _setError('导出设置失败: $e');
      rethrow;
    }
  }
  
  /// 导入设置
  Future<void> importSettings(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _settingsRepository.importSettings(data);
      
      // 重新加载设置
      await initialize();
    } catch (e) {
      _setError('导入设置失败: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
  
  // ===== 私有方法 =====
  
  String _getDefaultTitle(JarType jarType) {
    switch (jarType) {
      case JarType.income:
        return '收入目标';
      case JarType.expense:
        return '支出预算';
      case JarType.comprehensive:
        return '储蓄目标';
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
}