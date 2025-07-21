/*
 * 设置实体 (settings.dart)
 * 
 * 功能说明：
 * - 定义应用设置的数据结构
 * - 包含所有用户偏好设置
 * - 支持设置的导入导出
 */

import 'package:equatable/equatable.dart';

/// 应用设置实体
class Settings extends Equatable {
  /// 语言设置
  final String language;
  
  /// 货币符号
  final String currencySymbol;
  
  /// 主题模式
  final ThemeMode themeMode;
  
  /// 是否启用生物识别
  final bool biometricEnabled;
  
  /// 是否启用通知
  final bool notificationsEnabled;
  
  /// 每日提醒时间
  final String? dailyReminderTime;
  
  /// 月度预算
  final double? monthlyBudget;
  
  /// 默认交易类型
  final String defaultTransactionType;
  
  /// 是否显示拖拽提示
  final bool showDragTips;
  
  /// 是否启用声音效果
  final bool soundEffectsEnabled;
  
  /// 数据备份频率
  final BackupFrequency backupFrequency;
  
  /// 上次备份时间
  final DateTime? lastBackupTime;
  
  /// 导出格式
  final ExportFormat exportFormat;
  
  /// 设置版本
  final int version;

  const Settings({
    this.language = 'zh_CN',
    this.currencySymbol = '¥',
    this.themeMode = ThemeMode.system,
    this.biometricEnabled = false,
    this.notificationsEnabled = true,
    this.dailyReminderTime,
    this.monthlyBudget,
    this.defaultTransactionType = 'expense',
    this.showDragTips = true,
    this.soundEffectsEnabled = true,
    this.backupFrequency = BackupFrequency.weekly,
    this.lastBackupTime,
    this.exportFormat = ExportFormat.csv,
    this.version = 1,
  });

  /// 创建默认设置
  factory Settings.defaults() => const Settings();

  /// 创建副本并修改部分字段
  Settings copyWith({
    String? language,
    String? currencySymbol,
    ThemeMode? themeMode,
    bool? biometricEnabled,
    bool? notificationsEnabled,
    String? dailyReminderTime,
    double? monthlyBudget,
    String? defaultTransactionType,
    bool? showDragTips,
    bool? soundEffectsEnabled,
    BackupFrequency? backupFrequency,
    DateTime? lastBackupTime,
    ExportFormat? exportFormat,
    int? version,
  }) {
    return Settings(
      language: language ?? this.language,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      themeMode: themeMode ?? this.themeMode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      defaultTransactionType: defaultTransactionType ?? this.defaultTransactionType,
      showDragTips: showDragTips ?? this.showDragTips,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      backupFrequency: backupFrequency ?? this.backupFrequency,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      exportFormat: exportFormat ?? this.exportFormat,
      version: version ?? this.version,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'currencySymbol': currencySymbol,
      'themeMode': themeMode.index,
      'biometricEnabled': biometricEnabled,
      'notificationsEnabled': notificationsEnabled,
      'dailyReminderTime': dailyReminderTime,
      'monthlyBudget': monthlyBudget,
      'defaultTransactionType': defaultTransactionType,
      'showDragTips': showDragTips,
      'soundEffectsEnabled': soundEffectsEnabled,
      'backupFrequency': backupFrequency.index,
      'lastBackupTime': lastBackupTime?.toIso8601String(),
      'exportFormat': exportFormat.index,
      'version': version,
    };
  }

  /// 从Map创建
  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      language: map['language'] ?? 'zh_CN',
      currencySymbol: map['currencySymbol'] ?? '¥',
      themeMode: ThemeMode.values[map['themeMode'] ?? 0],
      biometricEnabled: map['biometricEnabled'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      dailyReminderTime: map['dailyReminderTime'],
      monthlyBudget: map['monthlyBudget']?.toDouble(),
      defaultTransactionType: map['defaultTransactionType'] ?? 'expense',
      showDragTips: map['showDragTips'] ?? true,
      soundEffectsEnabled: map['soundEffectsEnabled'] ?? true,
      backupFrequency: BackupFrequency.values[map['backupFrequency'] ?? 1],
      lastBackupTime: map['lastBackupTime'] != null 
        ? DateTime.parse(map['lastBackupTime']) 
        : null,
      exportFormat: ExportFormat.values[map['exportFormat'] ?? 0],
      version: map['version'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [
    language,
    currencySymbol,
    themeMode,
    biometricEnabled,
    notificationsEnabled,
    dailyReminderTime,
    monthlyBudget,
    defaultTransactionType,
    showDragTips,
    soundEffectsEnabled,
    backupFrequency,
    lastBackupTime,
    exportFormat,
    version,
  ];
}

/// 主题模式
enum ThemeMode {
  system,
  light,
  dark,
}

/// 备份频率
enum BackupFrequency {
  never,
  daily,
  weekly,
  monthly,
}

/// 导出格式
enum ExportFormat {
  csv,
  excel,
  json,
  pdf,
}