/*
 * 失败类型定义 (failures.dart)
 * 
 * 功能说明：
 * - 定义应用中所有可能的失败类型
 * - 用于错误处理和用户反馈
 * - 支持错误信息的国际化
 * 
 * 设计理念：
 * - 区分异常(Exception)和失败(Failure)
 * - 失败是预期的业务错误，需要处理
 * - 异常是未预期的系统错误
 */

import 'package:equatable/equatable.dart';

/// 失败基类
/// 
/// 所有失败类型的抽象基类
abstract class Failure extends Equatable {
  /// 错误消息
  final String message;
  
  /// 错误代码（用于国际化）
  final String? code;
  
  /// 额外的错误信息
  final Map<String, dynamic>? extra;

  const Failure({
    required this.message,
    this.code,
    this.extra,
  });

  @override
  List<Object?> get props => [message, code, extra];
}

/// 服务器失败
/// 
/// 与服务器通信相关的失败
class ServerFailure extends Failure {
  /// HTTP状态码
  final int? statusCode;

  const ServerFailure({
    required String message,
    this.statusCode,
    String? code,
    Map<String, dynamic>? extra,
  }) : super(message: message, code: code, extra: extra);
}

/// 缓存失败
/// 
/// 本地缓存操作相关的失败
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
    Map<String, dynamic>? extra,
  }) : super(message: message, code: code, extra: extra);
}

/// 网络失败
/// 
/// 网络连接相关的失败
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = '网络连接失败，请检查网络设置',
    String? code = 'NETWORK_ERROR',
    Map<String, dynamic>? extra,
  }) : super(message: message, code: code, extra: extra);
}

/// 验证失败
/// 
/// 数据验证相关的失败
class ValidationFailure extends Failure {
  /// 验证失败的字段名
  final String? field;

  const ValidationFailure(
    String message, {
    this.field,
    String? code,
    Map<String, dynamic>? extra,
  }) : super(message: message, code: code, extra: extra);
}

/// 权限失败
/// 
/// 权限验证相关的失败
class PermissionFailure extends Failure {
  /// 缺少的权限类型
  final String? permissionType;

  const PermissionFailure({
    String message = '权限不足',
    this.permissionType,
    String? code = 'PERMISSION_DENIED',
    Map<String, dynamic>? extra,
  }) : super(message: message, code: code, extra: extra);
}

/// 数据库失败
/// 
/// 数据库操作相关的失败
class DatabaseFailure extends Failure {
  /// 数据库错误码
  final String? dbErrorCode;

  const DatabaseFailure({
    required String message,
    this.dbErrorCode,
    String? code,
    Map<String, dynamic>? extra,
  }) : super(message: message, code: code, extra: extra);
}

/// 业务逻辑失败
/// 
/// 业务规则验证相关的失败
class BusinessFailure extends Failure {
  /// 业务规则类型
  final String? ruleType;

  const BusinessFailure({
    required String message,
    this.ruleType,
    String? code,
    Map<String, dynamic>? extra,
  }) : super(message: message, code: code, extra: extra);
}

/// 未知失败
/// 
/// 未分类的失败类型
class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = '发生未知错误',
    String? code = 'UNKNOWN_ERROR',
    Map<String, dynamic>? extra,
  }) : super(message: message, code: code, extra: extra);
}

/// 超时失败
/// 
/// 操作超时相关的失败
class TimeoutFailure extends Failure {
  /// 超时时长（秒）
  final int? timeoutSeconds;

  const TimeoutFailure({
    String message = '操作超时，请重试',
    this.timeoutSeconds,
    String? code = 'TIMEOUT',
    Map<String, dynamic>? extra,
  }) : super(message: message, code: code, extra: extra);
}

/// 存储失败
/// 
/// 文件存储相关的失败
class StorageFailure extends Failure {
  /// 存储类型
  final String? storageType;

  const StorageFailure({
    required String message,
    this.storageType,
    String? code,
    Map<String, dynamic>? extra,
  }) : super(message: message, code: code, extra: extra);
}

/// 平台失败
/// 
/// 平台特定的失败
class PlatformFailure extends Failure {
  /// 平台类型
  final String platform;

  const PlatformFailure({
    required String message,
    required this.platform,
    String? code,
    Map<String, dynamic>? extra,
  }) : super(message: message, code: code, extra: extra);
}

/// 失败扩展方法
extension FailureExtension on Failure {
  /// 获取用户友好的错误消息
  String get userMessage {
    // 根据错误代码返回本地化的消息
    // TODO: 实现本地化逻辑
    return message;
  }
  
  /// 是否为网络相关错误
  bool get isNetworkError => this is NetworkFailure || this is TimeoutFailure;
  
  /// 是否为验证错误
  bool get isValidationError => this is ValidationFailure;
  
  /// 是否需要重试
  bool get canRetry {
    return this is NetworkFailure || 
           this is TimeoutFailure || 
           this is ServerFailure;
  }
}