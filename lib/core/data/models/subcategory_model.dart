import 'package:hive/hive.dart';
import '../../domain/entities/category.dart';

part 'subcategory_model.g.dart';

/// 子分类数据模型
@HiveType(typeId: 3)
class SubCategoryModel extends HiveObject {
  @HiveField(0)
  final String name;
  
  @HiveField(1)
  final String icon;
  
  @HiveField(2)
  final int usageCount;
  
  @HiveField(3)
  final bool isEnabled;

  SubCategoryModel({
    required this.name,
    required this.icon,
    this.usageCount = 0,
    this.isEnabled = true,
  });

  /// 转换为领域实体
  SubCategory toEntity() {
    return SubCategory(
      name: name,
      icon: icon,
      usageCount: usageCount,
      isEnabled: isEnabled,
    );
  }

  /// 从领域实体创建
  factory SubCategoryModel.fromEntity(SubCategory entity) {
    return SubCategoryModel(
      name: entity.name,
      icon: entity.icon,
      usageCount: entity.usageCount,
      isEnabled: entity.isEnabled,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'usageCount': usageCount,
      'isEnabled': isEnabled,
    };
  }

  /// 从JSON创建
  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      name: json['name'],
      icon: json['icon'],
      usageCount: json['usageCount'] ?? 0,
      isEnabled: json['isEnabled'] ?? true,
    );
  }
}