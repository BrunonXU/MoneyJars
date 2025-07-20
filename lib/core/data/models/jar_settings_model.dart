/*
 * 罐头设置数据模型 (jar_settings_model.dart)
 * 
 * 功能说明：
 * - 用于数据存储和传输的罐头设置模型
 * - 支持Hive数据库和JSON序列化
 * - 与领域实体JarSettings相互转换
 * 
 * 迁移说明：
 * - 基于现有的JarSettings结构
 * - 保持向后兼容性
 * - 添加新配置选项支持未来扩展
 */

import 'package:hive/hive.dart';
import '../../domain/entities/jar_settings.dart';

part 'jar_settings_model.g.dart';

/// 罐头设置数据模型
@HiveType(typeId: 4)
class JarSettingsModel extends HiveObject {
  @HiveField(0)
  late double targetAmount;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late DateTime updatedAt;

  @HiveField(3)
  DateTime? deadline;
  
  @HiveField(4)
  late int jarTypeIndex; // JarType枚举的索引
  
  @HiveField(5, defaultValue: false)
  late bool enableTargetReminder;
  
  @HiveField(6, defaultValue: 0.8)
  late double reminderThreshold;
  
  @HiveField(7)
  int? customColor;
  
  @HiveField(8)
  String? customIcon;
  
  @HiveField(9)
  String? description;
  
  @HiveField(10, defaultValue: true)
  late bool showOnHome;
  
  @HiveField(11, defaultValue: 0)
  late int displayOrder;
  
  @HiveField(12)
  String? userId;

  JarSettingsModel();

  /// 从领域实体创建数据模型
  factory JarSettingsModel.fromEntity(JarSettings entity) {
    final model = JarSettingsModel()
      ..targetAmount = entity.targetAmount
      ..title = entity.title
      ..updatedAt = entity.updatedAt
      ..deadline = entity.deadline
      ..jarTypeIndex = entity.jarType.index
      ..enableTargetReminder = entity.enableTargetReminder
      ..reminderThreshold = entity.reminderThreshold
      ..customColor = entity.customColor
      ..customIcon = entity.customIcon
      ..description = entity.description
      ..showOnHome = entity.showOnHome
      ..displayOrder = entity.displayOrder
      ..userId = entity.userId;
    
    return model;
  }

  /// 转换为领域实体
  JarSettings toEntity() {
    return JarSettings(
      targetAmount: targetAmount,
      title: title,
      updatedAt: updatedAt,
      deadline: deadline,
      jarType: JarType.values[jarTypeIndex],
      enableTargetReminder: enableTargetReminder,
      reminderThreshold: reminderThreshold,
      customColor: customColor,
      customIcon: customIcon,
      description: description,
      showOnHome: showOnHome,
      displayOrder: displayOrder,
      userId: userId,
    );
  }

  /// 从JSON创建
  factory JarSettingsModel.fromJson(Map<String, dynamic> json) {
    final jarTypeIndex = json['jarTypeIndex'] as int? ?? 
                        _inferJarTypeFromTitle(json['title'] as String);
    
    return JarSettingsModel()
      ..targetAmount = (json['targetAmount'] as num).toDouble()
      ..title = json['title'] as String
      ..updatedAt = DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
      ..deadline = json['deadline'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['deadline'] as int)
          : null
      ..jarTypeIndex = jarTypeIndex
      ..enableTargetReminder = json['enableTargetReminder'] as bool? ?? false
      ..reminderThreshold = (json['reminderThreshold'] as num?)?.toDouble() ?? 0.8
      ..customColor = json['customColor'] as int?
      ..customIcon = json['customIcon'] as String?
      ..description = json['description'] as String?
      ..showOnHome = json['showOnHome'] as bool? ?? true
      ..displayOrder = json['displayOrder'] as int? ?? 0
      ..userId = json['userId'] as String?;
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'targetAmount': targetAmount,
      'title': title,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'deadline': deadline?.millisecondsSinceEpoch,
      'jarTypeIndex': jarTypeIndex,
      'enableTargetReminder': enableTargetReminder,
      'reminderThreshold': reminderThreshold,
      'customColor': customColor,
      'customIcon': customIcon,
      'description': description,
      'showOnHome': showOnHome,
      'displayOrder': displayOrder,
      'userId': userId,
    };
  }

  /// 从标题推断罐头类型（向后兼容）
  static int _inferJarTypeFromTitle(String title) {
    if (title.contains('收入')) {
      return JarType.income.index;
    } else if (title.contains('支出')) {
      return JarType.expense.index;
    } else {
      return JarType.comprehensive.index;
    }
  }

  /// 创建默认的罐头设置
  static List<JarSettingsModel> createDefaultSettings() {
    final now = DateTime.now();
    return [
      // 收入罐头设置
      JarSettingsModel()
        ..targetAmount = 10000.0
        ..title = '收入目标'
        ..updatedAt = now
        ..jarTypeIndex = JarType.income.index
        ..enableTargetReminder = false
        ..reminderThreshold = 0.8
        ..showOnHome = true
        ..displayOrder = 0,
      
      // 支出罐头设置
      JarSettingsModel()
        ..targetAmount = 5000.0
        ..title = '支出预算'
        ..updatedAt = now
        ..jarTypeIndex = JarType.expense.index
        ..enableTargetReminder = true
        ..reminderThreshold = 0.9
        ..showOnHome = true
        ..displayOrder = 1,
      
      // 综合罐头设置
      JarSettingsModel()
        ..targetAmount = 5000.0
        ..title = '储蓄目标'
        ..updatedAt = now
        ..jarTypeIndex = JarType.comprehensive.index
        ..enableTargetReminder = false
        ..reminderThreshold = 0.8
        ..showOnHome = true
        ..displayOrder = 2,
    ];
  }
}