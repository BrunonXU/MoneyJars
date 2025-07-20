/*
 * 罐头设置实体 (jar_settings.dart)
 * 
 * 功能说明：
 * - 定义罐头的配置信息
 * - 包含目标金额、标题、截止日期等
 * - 支持未来扩展更多配置选项
 * 
 * 迁移说明：
 * - 从transaction_record_hive.dart提取JarSettings定义
 * - 移除Hive注解，成为纯领域实体
 * - 添加更多配置选项为未来扩展做准备
 */

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// 罐头类型枚举
enum JarType {
  /// 收入罐头
  income,
  /// 支出罐头
  expense,
  /// 综合罐头
  comprehensive,
}

/// 罐头设置实体
/// 
/// 管理每个罐头的配置信息
class JarSettings extends Equatable {
  /// 目标金额
  final double targetAmount;
  
  /// 罐头标题
  final String title;
  
  /// 更新时间
  final DateTime updatedAt;
  
  /// 截止日期（可选）
  final DateTime? deadline;
  
  /// 罐头类型
  final JarType jarType;
  
  /// 是否启用目标提醒
  final bool enableTargetReminder;
  
  /// 提醒阈值（达到目标的百分比时提醒）
  final double reminderThreshold;
  
  /// 自定义颜色（可选）
  final int? customColor;
  
  /// 自定义图标（可选）
  final String? customIcon;
  
  /// 描述信息
  final String? description;
  
  /// 是否在主页显示
  final bool showOnHome;
  
  /// 显示顺序
  final int displayOrder;
  
  /// 用户ID（为未来多用户预留）
  final String? userId;

  const JarSettings({
    required this.targetAmount,
    required this.title,
    required this.updatedAt,
    this.deadline,
    required this.jarType,
    this.enableTargetReminder = false,
    this.reminderThreshold = 0.8, // 默认达到80%时提醒
    this.customColor,
    this.customIcon,
    this.description,
    this.showOnHome = true,
    this.displayOrder = 0,
    this.userId,
  });

  /// 获取颜色值
  Color? get colorValue => customColor != null ? Color(customColor!) : null;
  
  /// 检查是否已过截止日期
  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!);
  }
  
  /// 获取剩余天数
  int? get remainingDays {
    if (deadline == null) return null;
    final difference = deadline!.difference(DateTime.now());
    return difference.inDays;
  }
  
  /// 计算完成进度
  double calculateProgress(double currentAmount) {
    if (targetAmount <= 0) return 0;
    final progress = currentAmount / targetAmount;
    return progress > 1 ? 1 : progress;
  }
  
  /// 检查是否需要提醒
  bool shouldRemind(double currentAmount) {
    if (!enableTargetReminder) return false;
    final progress = calculateProgress(currentAmount);
    return progress >= reminderThreshold && progress < 1;
  }
  
  /// 创建副本并修改部分字段
  JarSettings copyWith({
    double? targetAmount,
    String? title,
    DateTime? updatedAt,
    DateTime? deadline,
    JarType? jarType,
    bool? enableTargetReminder,
    double? reminderThreshold,
    int? customColor,
    String? customIcon,
    String? description,
    bool? showOnHome,
    int? displayOrder,
    String? userId,
  }) {
    return JarSettings(
      targetAmount: targetAmount ?? this.targetAmount,
      title: title ?? this.title,
      updatedAt: updatedAt ?? this.updatedAt,
      deadline: deadline ?? this.deadline,
      jarType: jarType ?? this.jarType,
      enableTargetReminder: enableTargetReminder ?? this.enableTargetReminder,
      reminderThreshold: reminderThreshold ?? this.reminderThreshold,
      customColor: customColor ?? this.customColor,
      customIcon: customIcon ?? this.customIcon,
      description: description ?? this.description,
      showOnHome: showOnHome ?? this.showOnHome,
      displayOrder: displayOrder ?? this.displayOrder,
      userId: userId ?? this.userId,
    );
  }
  
  /// 更新目标金额
  JarSettings updateTarget(double newTarget) {
    return copyWith(
      targetAmount: newTarget,
      updatedAt: DateTime.now(),
    );
  }
  
  /// 更新标题
  JarSettings updateTitle(String newTitle) {
    return copyWith(
      title: newTitle,
      updatedAt: DateTime.now(),
    );
  }
  
  /// 设置截止日期
  JarSettings setDeadline(DateTime? newDeadline) {
    return copyWith(
      deadline: newDeadline,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    targetAmount,
    title,
    updatedAt,
    deadline,
    jarType,
    enableTargetReminder,
    reminderThreshold,
    customColor,
    customIcon,
    description,
    showOnHome,
    displayOrder,
    userId,
  ];
}

/// 罐头统计信息
/// 
/// 用于展示罐头的统计数据
class JarStatistics {
  /// 罐头类型
  final JarType jarType;
  
  /// 当前金额
  final double currentAmount;
  
  /// 目标金额
  final double targetAmount;
  
  /// 完成进度（0-1）
  final double progress;
  
  /// 本月新增
  final double monthlyChange;
  
  /// 日均变化
  final double dailyAverage;
  
  /// 预计完成日期
  final DateTime? estimatedCompletionDate;

  const JarStatistics({
    required this.jarType,
    required this.currentAmount,
    required this.targetAmount,
    required this.progress,
    required this.monthlyChange,
    required this.dailyAverage,
    this.estimatedCompletionDate,
  });
}