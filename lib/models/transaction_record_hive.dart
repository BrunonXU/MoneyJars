import 'package:hive/hive.dart';

part 'transaction_record_hive.g.dart';

/// 🏪 交易类型枚举
@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,    // 收入

  @HiveField(1)
  expense,   // 支出
}

/// 💰 交易记录模型 - Hive版本
/// 
/// 使用Hive进行本地数据存储，支持：
/// - 高性能的读写操作
/// - 类型安全的数据序列化
/// - 跨平台兼容性
/// - 简单的查询和过滤
@HiveType(typeId: 1)
class TransactionRecord extends HiveObject {
  /// 交易记录唯一标识符
  @HiveField(0)
  late String id;

  /// 交易金额
  @HiveField(1)
  late double amount;

  /// 交易描述
  @HiveField(2)
  late String description;

  /// 父级分类名称
  @HiveField(3)
  late String parentCategory;

  /// 子分类名称
  @HiveField(4)
  late String subCategory;

  /// 交易类型（收入/支出）
  @HiveField(5)
  late TransactionType type;

  /// 交易日期
  @HiveField(6)
  late DateTime date;

  /// 是否已归档
  @HiveField(7, defaultValue: false)
  late bool isArchived;

  /// 创建时间
  @HiveField(8)
  late DateTime createdAt;

  /// 最后更新时间
  @HiveField(9)
  late DateTime updatedAt;

  /// 默认构造函数
  TransactionRecord();

  /// 便捷构造函数
  TransactionRecord.create({
    required this.id,
    required this.amount,
    required this.description,
    required this.parentCategory,
    required this.subCategory,
    required this.type,
    required this.date,
    this.isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    this.createdAt = createdAt ?? now;
    this.updatedAt = updatedAt ?? now;
  }

  /// 从JSON创建（用于Web localStorage）
  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    final record = TransactionRecord();
    record.id = json['id'] as String;
    record.amount = (json['amount'] as num).toDouble();
    record.description = json['description'] as String;
    record.parentCategory = json['parentCategory'] as String;
    record.subCategory = json['subCategory'] as String;
    record.type = TransactionType.values[json['type'] as int];
    record.date = DateTime.fromMillisecondsSinceEpoch(json['date'] as int);
    record.isArchived = json['isArchived'] as bool? ?? false;
    record.createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int);
    record.updatedAt = DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int);
    return record;
  }

  /// 转换为JSON（用于Web localStorage）
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'parentCategory': parentCategory,
      'subCategory': subCategory,
      'type': type.index,
      'date': date.millisecondsSinceEpoch,
      'isArchived': isArchived,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// 创建副本
  TransactionRecord copyWith({
    String? id,
    double? amount,
    String? description,
    String? parentCategory,
    String? subCategory,
    TransactionType? type,
    DateTime? date,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionRecord.create(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      parentCategory: parentCategory ?? this.parentCategory,
      subCategory: subCategory ?? this.subCategory,
      type: type ?? this.type,
      date: date ?? this.date,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TransactionRecord(id: $id, amount: $amount, description: $description, type: $type, date: $date)';
  }
}

/// 🏷️ 自定义分类模型
@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late TransactionType type;

  @HiveField(3)
  late int color;

  @HiveField(4)
  late String icon;

  @HiveField(5)
  late List<SubCategory> subCategories;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  late DateTime updatedAt;

  Category();

  Category.create({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.icon,
    required this.subCategories,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    this.createdAt = createdAt ?? now;
    this.updatedAt = updatedAt ?? now;
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    final category = Category();
    category.id = json['id'] as String;
    category.name = json['name'] as String;
    category.type = TransactionType.values[json['type'] as int];
    category.color = json['color'] as int;
    category.icon = json['icon'] as String;
    category.subCategories = (json['subCategories'] as List)
        .map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
        .toList();
    category.createdAt = DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int);
    category.updatedAt = DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int);
    return category;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'color': color,
      'icon': icon,
      'subCategories': subCategories.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }
}

/// 🏷️ 子分类模型
@HiveType(typeId: 3)
class SubCategory extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String icon;

  SubCategory();

  SubCategory.create({
    required this.name,
    required this.icon,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory.create(
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
    };
  }
}

/// ⚙️ 罐头设置模型
@HiveType(typeId: 4)
class JarSettings extends HiveObject {
  @HiveField(0)
  late double targetAmount;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late DateTime updatedAt;

  @HiveField(3)
  DateTime? deadline;

  JarSettings();

  JarSettings.create({
    required this.targetAmount,
    required this.title,
    DateTime? updatedAt,
    this.deadline,
  }) {
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  factory JarSettings.fromJson(Map<String, dynamic> json) {
    return JarSettings.create(
      targetAmount: (json['targetAmount'] as num).toDouble(),
      title: json['title'] as String,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
      deadline: json['deadline'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['deadline'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetAmount': targetAmount,
      'title': title,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'deadline': deadline?.millisecondsSinceEpoch,
    };
  }
}

/// 预定义的分类
class DefaultCategories {
  static final List<Category> incomeCategories = [
    Category.create(
      id: 'income_salary',
      name: '工资',
      color: 0xFF81C784,
      icon: '💼',
      type: TransactionType.income,
      subCategories: [
        SubCategory.create(name: '基本工资', icon: '💰'),
        SubCategory.create(name: '奖金', icon: '⭐'),
        SubCategory.create(name: '加班费', icon: '⏰'),
      ],
    ),
    Category.create(
      id: 'income_parttime',
      name: '兼职',
      color: 0xFF64B5F6,
      icon: '💼',
      type: TransactionType.income,
      subCategories: [
        SubCategory.create(name: '自由职业', icon: '💻'),
        SubCategory.create(name: '临时工', icon: '🔧'),
        SubCategory.create(name: '咨询', icon: '🧠'),
      ],
    ),
    Category.create(
      id: 'income_investment',
      name: '投资',
      color: 0xFF4DB6AC,
      icon: '📈',
      type: TransactionType.income,
      subCategories: [
        SubCategory.create(name: '股票', icon: '📊'),
        SubCategory.create(name: '基金', icon: '🥧'),
        SubCategory.create(name: '理财', icon: '💾'),
      ],
    ),
    Category.create(
      id: 'income_other',
      name: '其他',
      color: 0xFF90A4AE,
      icon: '⋯',
      type: TransactionType.income,
      subCategories: [
        SubCategory.create(name: '礼金', icon: '🎁'),
        SubCategory.create(name: '退款', icon: '↩️'),
        SubCategory.create(name: '意外收入', icon: '💰'),
      ],
    ),
  ];

  static final List<Category> expenseCategories = [
    Category.create(
      id: 'expense_food',
      name: '餐饮',
      color: 0xFFFFAB91,
      icon: '🍽️',
      type: TransactionType.expense,
      subCategories: [
        SubCategory.create(name: '早餐', icon: '🥐'),
        SubCategory.create(name: '午餐', icon: '🍱'),
        SubCategory.create(name: '晚餐', icon: '🍽️'),
        SubCategory.create(name: '零食', icon: '🍪'),
        SubCategory.create(name: '饮料', icon: '🥤'),
      ],
    ),
    Category.create(
      id: 'expense_transport',
      name: '交通',
      color: 0xFF90CAF9,
      icon: '🚗',
      type: TransactionType.expense,
      subCategories: [
        SubCategory.create(name: '公交', icon: '🚌'),
        SubCategory.create(name: '地铁', icon: '🚇'),
        SubCategory.create(name: '打车', icon: '🚕'),
        SubCategory.create(name: '油费', icon: '⛽'),
      ],
    ),
    Category.create(
      id: 'expense_shopping',
      name: '购物',
      color: 0xFFCE93D8,
      icon: '🛍️',
      type: TransactionType.expense,
      subCategories: [
        SubCategory.create(name: '服装', icon: '👕'),
        SubCategory.create(name: '日用品', icon: '🛒'),
        SubCategory.create(name: '电子产品', icon: '📱'),
        SubCategory.create(name: '化妆品', icon: '💄'),
      ],
    ),
    Category.create(
      id: 'expense_entertainment',
      name: '娱乐',
      color: 0xFFF48FB1,
      icon: '🎬',
      type: TransactionType.expense,
      subCategories: [
        SubCategory.create(name: '电影', icon: '🎬'),
        SubCategory.create(name: '游戏', icon: '🎮'),
        SubCategory.create(name: '旅游', icon: '✈️'),
        SubCategory.create(name: '运动', icon: '⚽'),
      ],
    ),
    Category.create(
      id: 'expense_medical',
      name: '医疗',
      color: 0xFFEF9A9A,
      icon: '🏥',
      type: TransactionType.expense,
      subCategories: [
        SubCategory.create(name: '挂号费', icon: '📋'),
        SubCategory.create(name: '药费', icon: '💊'),
        SubCategory.create(name: '检查费', icon: '🔬'),
        SubCategory.create(name: '住院费', icon: '🏨'),
      ],
    ),
    Category.create(
      id: 'expense_other',
      name: '其他',
      color: 0xFFBCAAA4,
      icon: '⋯',
      type: TransactionType.expense,
      subCategories: [
        SubCategory.create(name: '转账', icon: '💸'),
        SubCategory.create(name: '手续费', icon: '🧾'),
        SubCategory.create(name: '杂费', icon: '📦'),
      ],
    ),
  ];
}