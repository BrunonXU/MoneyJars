import 'package:flutter/material.dart';

/// 交易类型枚举
enum TransactionType {
  income,  // 收入
  expense, // 支出
}

/// 交易记录模型
class TransactionRecord {
  final String id;
  final double amount;
  final String description;
  final String parentCategory; // 大类别
  final String subCategory;    // 小类别
  final DateTime date;
  final TransactionType type;
  final bool isArchived; // 是否已归档

  TransactionRecord({
    required this.id,
    required this.amount,
    required this.description,
    required this.parentCategory,
    required this.subCategory,
    required this.date,
    required this.type,
    this.isArchived = false,
  });

  // 兼容旧版本的category字段
  String get category => '$parentCategory-$subCategory';

  /// 从JSON创建对象
  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    try {
      // 处理旧版本数据
      String parentCat = json['parentCategory'] ?? '';
      String subCat = json['subCategory'] ?? '';
      
      // 如果是旧版本数据，从category字段解析
      if (parentCat.isEmpty && json['category'] != null) {
        final parts = json['category'].toString().split('-');
        parentCat = parts.isNotEmpty ? parts[0] : '其他';
        subCat = parts.length > 1 ? parts[1] : '默认';
      }
      
      return TransactionRecord(
        id: json['id'] ?? '',
        amount: (json['amount'] ?? 0.0).toDouble(),
        description: json['description'] ?? '',
        parentCategory: parentCat.isEmpty ? '其他' : parentCat,
        subCategory: subCat.isEmpty ? '默认' : subCat,
        date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
        type: TransactionType.values[json['type'] ?? 0],
        isArchived: (json['isArchived'] ?? 0) == 1,
      );
    } catch (e) {
      return TransactionRecord(
        id: json['id'] ?? '',
        amount: 0.0,
        description: '解析错误',
        parentCategory: '其他',
        subCategory: '默认',
        date: DateTime.now(),
        type: TransactionType.expense,
        isArchived: false,
      );
    }
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'parentCategory': parentCategory,
      'subCategory': subCategory,
      'category': category, // 保持兼容性
      'date': date.toIso8601String(),
      'type': type.index,
      'isArchived': isArchived ? 1 : 0,
    };
  }

  /// 创建副本
  TransactionRecord copyWith({
    String? id,
    double? amount,
    String? description,
    String? parentCategory,
    String? subCategory,
    DateTime? date,
    TransactionType? type,
    bool? isArchived,
  }) {
    return TransactionRecord(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      parentCategory: parentCategory ?? this.parentCategory,
      subCategory: subCategory ?? this.subCategory,
      date: date ?? this.date,
      type: type ?? this.type,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

/// 子分类模型
class SubCategory {
  final String name;
  final Color color;
  final IconData icon;

  SubCategory({
    required this.name,
    required this.color,
    required this.icon,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    try {
      return SubCategory(
        name: json['name'] ?? '',
        color: Color(json['color'] ?? Colors.grey.value),
        icon: _getIconFromCodePoint(json['icon']),
      );
    } catch (e) {
      return SubCategory(
        name: json['name'] ?? '未知',
        color: Colors.grey,
        icon: Icons.error,
      );
    }
  }

  static IconData _getIconFromCodePoint(dynamic codePoint) {
    if (codePoint == null) return Icons.error;
    if (codePoint is int) {
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    }
    return Icons.error;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
    };
  }
}

/// 分类模型 - 现在是大类别
class Category {
  final String name;
  final Color color;
  final IconData icon;
  final TransactionType type;
  final List<SubCategory> subCategories;

  Category({
    required this.name,
    required this.color,
    required this.icon,
    required this.type,
    required this.subCategories,
  });

  /// 从JSON创建对象
  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      final subCatsJson = json['subCategories'] as List<dynamic>? ?? [];
      final subCats = subCatsJson.map((e) => SubCategory.fromJson(e)).toList();
      
      return Category(
        name: json['name'] ?? '',
        color: Color(json['color'] ?? Colors.grey.value),
        icon: SubCategory._getIconFromCodePoint(json['icon']),
        type: TransactionType.values[json['type'] ?? 0],
        subCategories: subCats,
      );
    } catch (e) {
      return Category(
        name: json['name'] ?? '未知',
        color: Colors.grey,
        icon: Icons.error,
        type: TransactionType.expense,
        subCategories: [],
      );
    }
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
      'type': type.index,
      'subCategories': subCategories.map((e) => e.toJson()).toList(),
    };
  }
}

/// 罐头设置模型
class JarSettings {
  final double targetAmount; // 目标金额（上限）
  final String title;        // 罐头标题
  final DateTime? deadline;  // 截止日期（可选）

  JarSettings({
    required this.targetAmount,
    required this.title,
    this.deadline,
  });

  factory JarSettings.fromJson(Map<String, dynamic> json) {
    return JarSettings(
      targetAmount: (json['targetAmount'] ?? 0.0).toDouble(),
      title: json['title'] ?? '我的罐头',
      deadline: json['deadline'] != null 
          ? DateTime.tryParse(json['deadline'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetAmount': targetAmount,
      'title': title,
      'deadline': deadline?.toIso8601String(),
    };
  }

  JarSettings copyWith({
    double? targetAmount,
    String? title,
    DateTime? deadline,
  }) {
    return JarSettings(
      targetAmount: targetAmount ?? this.targetAmount,
      title: title ?? this.title,
      deadline: deadline ?? this.deadline,
    );
  }
}

/// 预定义的分类
class DefaultCategories {
  static final List<Category> incomeCategories = [
    Category(
      name: '工资',
      color: const Color(0xFF81C784), // 淡蓝色调
      icon: Icons.work,
      type: TransactionType.income,
      subCategories: [
        SubCategory(name: '基本工资', color: const Color(0xFF66BB6A), icon: Icons.account_balance_wallet),
        SubCategory(name: '奖金', color: const Color(0xFF4CAF50), icon: Icons.star),
        SubCategory(name: '加班费', color: const Color(0xFF388E3C), icon: Icons.access_time),
      ],
    ),
    Category(
      name: '兼职',
      color: const Color(0xFF64B5F6),
      icon: Icons.business_center,
      type: TransactionType.income,
      subCategories: [
        SubCategory(name: '自由职业', color: const Color(0xFF42A5F5), icon: Icons.laptop),
        SubCategory(name: '临时工', color: const Color(0xFF2196F3), icon: Icons.build),
        SubCategory(name: '咨询', color: const Color(0xFF1976D2), icon: Icons.psychology),
      ],
    ),
    Category(
      name: '投资',
      color: const Color(0xFF4DB6AC),
      icon: Icons.trending_up,
      type: TransactionType.income,
      subCategories: [
        SubCategory(name: '股票', color: const Color(0xFF26A69A), icon: Icons.show_chart),
        SubCategory(name: '基金', color: const Color(0xFF009688), icon: Icons.pie_chart),
        SubCategory(name: '理财', color: const Color(0xFF00695C), icon: Icons.savings),
      ],
    ),
    Category(
      name: '其他',
      color: const Color(0xFF90A4AE),
      icon: Icons.more_horiz,
      type: TransactionType.income,
      subCategories: [
        SubCategory(name: '礼金', color: const Color(0xFF78909C), icon: Icons.card_giftcard),
        SubCategory(name: '退款', color: const Color(0xFF607D8B), icon: Icons.replay),
        SubCategory(name: '意外收入', color: const Color(0xFF455A64), icon: Icons.attach_money),
      ],
    ),
  ];

  static final List<Category> expenseCategories = [
    Category(
      name: '餐饮',
      color: const Color(0xFFFFAB91), // 淡红色调
      icon: Icons.restaurant,
      type: TransactionType.expense,
      subCategories: [
        SubCategory(name: '早餐', color: const Color(0xFFFF8A65), icon: Icons.breakfast_dining),
        SubCategory(name: '午餐', color: const Color(0xFFFF7043), icon: Icons.lunch_dining),
        SubCategory(name: '晚餐', color: const Color(0xFFFF5722), icon: Icons.dinner_dining),
        SubCategory(name: '零食', color: const Color(0xFFE64A19), icon: Icons.cookie),
        SubCategory(name: '饮料', color: const Color(0xFFD84315), icon: Icons.local_drink),
      ],
    ),
    Category(
      name: '交通',
      color: const Color(0xFF90CAF9),
      icon: Icons.directions_car,
      type: TransactionType.expense,
      subCategories: [
        SubCategory(name: '公交', color: const Color(0xFF64B5F6), icon: Icons.directions_bus),
        SubCategory(name: '地铁', color: const Color(0xFF42A5F5), icon: Icons.subway),
        SubCategory(name: '打车', color: const Color(0xFF2196F3), icon: Icons.local_taxi),
        SubCategory(name: '油费', color: const Color(0xFF1976D2), icon: Icons.local_gas_station),
      ],
    ),
    Category(
      name: '购物',
      color: const Color(0xFFCE93D8),
      icon: Icons.shopping_bag,
      type: TransactionType.expense,
      subCategories: [
        SubCategory(name: '服装', color: const Color(0xFFBA68C8), icon: Icons.checkroom),
        SubCategory(name: '日用品', color: const Color(0xFFAB47BC), icon: Icons.shopping_cart),
        SubCategory(name: '电子产品', color: const Color(0xFF9C27B0), icon: Icons.phone_android),
        SubCategory(name: '化妆品', color: const Color(0xFF8E24AA), icon: Icons.face_retouching_natural),
      ],
    ),
    Category(
      name: '娱乐',
      color: const Color(0xFFF48FB1),
      icon: Icons.movie,
      type: TransactionType.expense,
      subCategories: [
        SubCategory(name: '电影', color: const Color(0xFFF06292), icon: Icons.movie_creation),
        SubCategory(name: '游戏', color: const Color(0xFFEC407A), icon: Icons.games),
        SubCategory(name: '旅游', color: const Color(0xFFE91E63), icon: Icons.flight),
        SubCategory(name: '运动', color: const Color(0xFFAD1457), icon: Icons.sports),
      ],
    ),
    Category(
      name: '医疗',
      color: const Color(0xFFEF9A9A),
      icon: Icons.local_hospital,
      type: TransactionType.expense,
      subCategories: [
        SubCategory(name: '挂号费', color: const Color(0xFFE57373), icon: Icons.assignment),
        SubCategory(name: '药费', color: const Color(0xFFEF5350), icon: Icons.medication),
        SubCategory(name: '检查费', color: const Color(0xFFF44336), icon: Icons.medical_services),
        SubCategory(name: '住院费', color: const Color(0xFFD32F2F), icon: Icons.hotel),
      ],
    ),
    Category(
      name: '其他',
      color: const Color(0xFFBCAAA4),
      icon: Icons.more_horiz,
      type: TransactionType.expense,
      subCategories: [
        SubCategory(name: '转账', color: const Color(0xFFA1887F), icon: Icons.send),
        SubCategory(name: '手续费', color: const Color(0xFF8D6E63), icon: Icons.receipt),
        SubCategory(name: '杂费', color: const Color(0xFF5D4037), icon: Icons.category),
      ],
    ),
  ];
} 