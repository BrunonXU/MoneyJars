/*
 * 用户实体 (user.dart)
 * 
 * 功能说明：
 * - 定义用户的基本信息
 * - 为未来多用户功能预留
 * - 支持本地用户和云端用户
 * 
 * 设计说明：
 * - 当前应用主要在本地运行，userId可以是设备ID
 * - 未来扩展云同步时，可以升级为真实用户系统
 * - 所有用户相关字段都是可选的，保持向后兼容
 */

import 'package:equatable/equatable.dart';

/// 用户类型枚举
enum UserType {
  /// 本地用户（默认）
  local,
  /// 云端注册用户
  cloud,
  /// 访客用户
  guest,
}

/// 用户角色枚举
enum UserRole {
  /// 普通用户
  user,
  /// 高级用户（付费）
  premium,
  /// 家庭管理员
  familyAdmin,
  /// 家庭成员
  familyMember,
}

/// 用户实体
/// 
/// 表示应用的用户信息
class User extends Equatable {
  /// 用户唯一标识符
  /// 本地用户：设备ID
  /// 云端用户：服务器分配的UUID
  final String id;
  
  /// 用户名（可选）
  final String? username;
  
  /// 邮箱（可选）
  final String? email;
  
  /// 显示名称
  final String displayName;
  
  /// 头像URL（可选）
  final String? avatarUrl;
  
  /// 用户类型
  final UserType userType;
  
  /// 用户角色
  final UserRole userRole;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 最后登录时间
  final DateTime lastLoginAt;
  
  /// 设备信息
  final DeviceInfo? deviceInfo;
  
  /// 用户偏好设置
  final UserPreferences preferences;
  
  /// 订阅信息（可选）
  final SubscriptionInfo? subscription;
  
  /// 家庭ID（可选）
  final String? familyId;
  
  /// 是否已验证邮箱
  final bool isEmailVerified;
  
  /// 是否启用
  final bool isActive;

  const User({
    required this.id,
    this.username,
    this.email,
    required this.displayName,
    this.avatarUrl,
    this.userType = UserType.local,
    this.userRole = UserRole.user,
    required this.createdAt,
    required this.lastLoginAt,
    this.deviceInfo,
    required this.preferences,
    this.subscription,
    this.familyId,
    this.isEmailVerified = false,
    this.isActive = true,
  });

  /// 检查是否为高级用户
  bool get isPremium => userRole == UserRole.premium || subscription?.isActive == true;
  
  /// 检查是否为家庭用户
  bool get isFamilyUser => familyId != null && (userRole == UserRole.familyAdmin || userRole == UserRole.familyMember);
  
  /// 检查是否为本地用户
  bool get isLocalUser => userType == UserType.local;
  
  /// 创建本地用户
  factory User.createLocal({
    required String deviceId,
    String? displayName,
    DeviceInfo? deviceInfo,
  }) {
    final now = DateTime.now();
    return User(
      id: deviceId,
      displayName: displayName ?? '本地用户',
      userType: UserType.local,
      createdAt: now,
      lastLoginAt: now,
      deviceInfo: deviceInfo,
      preferences: UserPreferences.defaults(),
    );
  }
  
  /// 创建副本并修改部分字段
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? avatarUrl,
    UserType? userType,
    UserRole? userRole,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DeviceInfo? deviceInfo,
    UserPreferences? preferences,
    SubscriptionInfo? subscription,
    String? familyId,
    bool? isEmailVerified,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      userType: userType ?? this.userType,
      userRole: userRole ?? this.userRole,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      preferences: preferences ?? this.preferences,
      subscription: subscription ?? this.subscription,
      familyId: familyId ?? this.familyId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    displayName,
    avatarUrl,
    userType,
    userRole,
    createdAt,
    lastLoginAt,
    deviceInfo,
    preferences,
    subscription,
    familyId,
    isEmailVerified,
    isActive,
  ];
}

/// 设备信息
class DeviceInfo extends Equatable {
  /// 设备ID
  final String deviceId;
  
  /// 设备名称
  final String deviceName;
  
  /// 操作系统
  final String platform;
  
  /// 系统版本
  final String osVersion;
  
  /// 应用版本
  final String appVersion;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.platform,
    required this.osVersion,
    required this.appVersion,
  });

  @override
  List<Object> get props => [deviceId, deviceName, platform, osVersion, appVersion];
}

/// 用户偏好设置
class UserPreferences extends Equatable {
  /// 主题模式
  final String themeMode; // 'light', 'dark', 'system'
  
  /// 语言代码
  final String languageCode;
  
  /// 货币符号
  final String currencySymbol;
  
  /// 是否启用提醒
  final bool enableNotifications;
  
  /// 是否启用触觉反馈
  final bool enableHapticFeedback;
  
  /// 是否显示引导提示
  final bool showTutorials;
  
  /// 默认视图（哪个罐头）
  final int defaultJarIndex;

  const UserPreferences({
    this.themeMode = 'system',
    this.languageCode = 'zh',
    this.currencySymbol = '¥',
    this.enableNotifications = true,
    this.enableHapticFeedback = true,
    this.showTutorials = true,
    this.defaultJarIndex = 1, // 默认显示综合罐头
  });

  /// 创建默认偏好设置
  factory UserPreferences.defaults() => const UserPreferences();

  @override
  List<Object> get props => [
    themeMode,
    languageCode,
    currencySymbol,
    enableNotifications,
    enableHapticFeedback,
    showTutorials,
    defaultJarIndex,
  ];
}

/// 订阅信息
class SubscriptionInfo extends Equatable {
  /// 订阅ID
  final String subscriptionId;
  
  /// 订阅计划
  final String planId;
  
  /// 开始时间
  final DateTime startDate;
  
  /// 结束时间
  final DateTime? endDate;
  
  /// 是否自动续费
  final bool autoRenew;
  
  /// 是否激活
  bool get isActive => endDate == null || endDate!.isAfter(DateTime.now());

  const SubscriptionInfo({
    required this.subscriptionId,
    required this.planId,
    required this.startDate,
    this.endDate,
    this.autoRenew = false,
  });

  @override
  List<Object?> get props => [subscriptionId, planId, startDate, endDate, autoRenew];
}