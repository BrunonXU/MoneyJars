/*
 * 交易数据模型 (transaction_model.dart)
 * 
 * 功能说明：
 * - 用于数据存储和传输的模型
 * - 支持Hive数据库和JSON序列化
 * - 与领域实体Transaction相互转换
 * 
 * 迁移说明：
 * - 基于现有的TransactionRecord结构
 * - 保持向后兼容性
 * - 添加新字段支持未来扩展
 */

import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

/// 交易数据模型
/// 
/// 用于Hive存储的交易记录模型
@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  /// 交易记录唯一标识符
  @HiveField(0)
  late String id;

  /// 交易金额
  @HiveField(1)
  late double amount;

  /// 交易描述
  @HiveField(2)
  late String description;

  /// 父级分类ID
  @HiveField(3)
  late String parentCategoryId;
  
  /// 父级分类名称
  @HiveField(4)
  late String parentCategoryName;

  /// 子分类ID（可选）
  @HiveField(5)
  String? subCategoryId;
  
  /// 子分类名称（可选）
  @HiveField(6)
  String? subCategoryName;

  /// 交易类型（收入/支出）
  @HiveField(7)
  late int typeIndex; // 使用int存储枚举

  /// 交易日期
  @HiveField(8)
  late DateTime date;

  /// 是否已归档
  @HiveField(9, defaultValue: false)
  late bool isArchived;

  /// 创建时间
  @HiveField(10)
  late DateTime createdAt;

  /// 最后更新时间
  @HiveField(11)
  late DateTime updatedAt;
  
  /// 备注（新增字段）
  @HiveField(12)
  String? notes;
  
  /// 标签列表（新增字段）
  @HiveField(13)
  List<String>? tags;
  
  /// 用户ID（新增字段，为多用户预留）
  @HiveField(14)
  String? userId;
  
  /// 设备ID（新增字段，用于同步）
  @HiveField(15)
  String? deviceId;
  
  /// 同步时间（新增字段）
  @HiveField(16)
  DateTime? syncedAt;
  
  /// 扩展数据（新增字段，JSON字符串）
  @HiveField(17)
  String? metadata;

  /// 默认构造函数
  TransactionModel();

  /// 从领域实体创建数据模型
  factory TransactionModel.fromEntity(Transaction entity) {
    final model = TransactionModel()
      ..id = entity.id
      ..amount = entity.amount
      ..description = entity.description
      ..parentCategoryId = entity.parentCategoryId
      ..parentCategoryName = entity.parentCategoryName
      ..subCategoryId = entity.subCategoryId
      ..subCategoryName = entity.subCategoryName
      ..typeIndex = entity.type.index
      ..date = entity.date
      ..isArchived = entity.isArchived
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt ?? entity.createdAt
      ..notes = entity.notes
      ..tags = entity.tags.isNotEmpty ? entity.tags : null
      ..userId = null // 暂时为null，未来实现
      ..deviceId = null // 暂时为null，未来实现
      ..syncedAt = null // 暂时为null，未来实现
      ..metadata = null; // 暂时为null，未来实现
    
    return model;
  }

  /// 转换为领域实体
  Transaction toEntity() {
    return Transaction(
      id: id,
      amount: amount,
      description: description,
      parentCategoryId: parentCategoryId,
      parentCategoryName: parentCategoryName,
      subCategoryId: subCategoryId,
      subCategoryName: subCategoryName,
      type: TransactionType.values[typeIndex],
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isArchived: isArchived,
      notes: notes,
      tags: tags ?? [],
    );
  }

  /// 从JSON创建（用于Web localStorage）
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final model = TransactionModel()
      ..id = json['id'] as String
      ..amount = (json['amount'] as num).toDouble()
      ..description = json['description'] as String
      ..parentCategoryId = json['parentCategoryId'] as String? ?? json['parentCategory'] as String // 兼容旧字段名
      ..parentCategoryName = json['parentCategoryName'] as String? ?? json['parentCategory'] as String
      ..subCategoryId = json['subCategoryId'] as String?
      ..subCategoryName = json['subCategoryName'] as String? ?? json['subCategory'] as String?
      ..typeIndex = json['typeIndex'] as int? ?? json['type'] as int // 兼容旧字段名
      ..date = DateTime.fromMillisecondsSinceEpoch(json['date'] as int)
      ..isArchived = json['isArchived'] as bool? ?? false
      ..createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int)
      ..updatedAt = DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
      ..notes = json['notes'] as String?
      ..tags = (json['tags'] as List<dynamic>?)?.cast<String>()
      ..userId = json['userId'] as String?
      ..deviceId = json['deviceId'] as String?
      ..syncedAt = json['syncedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['syncedAt'] as int)
          : null
      ..metadata = json['metadata'] as String?;
    
    return model;
  }

  /// 转换为JSON（用于Web localStorage）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'parentCategoryId': parentCategoryId,
      'parentCategoryName': parentCategoryName,
      'parentCategory': parentCategoryName, // 保持向后兼容
      'subCategoryId': subCategoryId,
      'subCategoryName': subCategoryName,
      'subCategory': subCategoryName, // 保持向后兼容
      'typeIndex': typeIndex,
      'type': typeIndex, // 保持向后兼容
      'date': date.millisecondsSinceEpoch,
      'isArchived': isArchived,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'notes': notes,
      'tags': tags,
      'userId': userId,
      'deviceId': deviceId,
      'syncedAt': syncedAt?.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  /// 从旧版TransactionRecord迁移
  /// 用于数据迁移的兼容性方法
  factory TransactionModel.fromLegacyRecord(Map<String, dynamic> legacy) {
    return TransactionModel.fromJson({
      'id': legacy['id'],
      'amount': legacy['amount'],
      'description': legacy['description'],
      'parentCategory': legacy['parentCategory'],
      'subCategory': legacy['subCategory'],
      'type': legacy['type'],
      'date': legacy['date'],
      'isArchived': legacy['isArchived'] ?? false,
      'createdAt': legacy['createdAt'],
      'updatedAt': legacy['updatedAt'],
    });
  }
}