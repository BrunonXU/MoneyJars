import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import '../models/transaction_record.dart';

// 条件导入：Web平台使用专门的Web数据库服务
import 'database_service_stub.dart' if (dart.library.html) 'database_service_web.dart';

class DatabaseService {
  static Database? _database;
  static bool _isInitializing = false;
  
  /// 工厂方法：根据平台创建合适的数据库服务
  factory DatabaseService.create() {
    if (kIsWeb) {
      return WebDatabaseService();
    } else {
      return DatabaseService();
    }
  }
  
  /// 默认构造函数
  DatabaseService();
  
  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // 避免重复初始化
    if (_isInitializing) {
      while (_isInitializing) {
        await Future.delayed(Duration(milliseconds: 10));
      }
      return _database!;
    }
    
    _isInitializing = true;
    try {
      _database = await _initDatabase();
      return _database!;
    } finally {
      _isInitializing = false;
    }
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    // Web平台使用不同的数据库工厂
    if (kIsWeb) {
      // 使用专门的Web数据库工厂，避免警告
      return await databaseFactoryFfiWeb.openDatabase(
        'money_jars.db',
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: _createDatabase,
          onUpgrade: _upgradeDatabase,
        ),
      );
    } else {
      // 移动平台使用默认路径
      String path = join(await getDatabasesPath(), 'money_jars.db');
      return await openDatabase(
        path,
        version: 2,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
      );
    }
  }

  /// 创建数据库表
  Future<void> _createDatabase(Database db, int version) async {
    // 创建交易记录表
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        parentCategory TEXT NOT NULL,
        subCategory TEXT NOT NULL,
        category TEXT, -- 保持兼容性
        date TEXT NOT NULL,
        type INTEGER NOT NULL,
        isArchived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 创建自定义分类表
    await db.execute('''
      CREATE TABLE categories (
        name TEXT PRIMARY KEY,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL,
        type INTEGER NOT NULL,
        subCategories TEXT -- JSON格式存储子分类
      )
    ''');
  }

  /// 升级数据库
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 添加新字段
      await db.execute('ALTER TABLE transactions ADD COLUMN parentCategory TEXT');
      await db.execute('ALTER TABLE transactions ADD COLUMN subCategory TEXT');
      await db.execute('ALTER TABLE categories ADD COLUMN subCategories TEXT');
      
      // 迁移现有数据
      await _migrateOldData(db);
    }
  }

  /// 迁移旧数据
  Future<void> _migrateOldData(Database db) async {
    // 迁移交易记录
    final transactions = await db.query('transactions');
    for (final transaction in transactions) {
      if (transaction['parentCategory'] == null) {
        final category = transaction['category'] as String?;
        final parts = category?.split('-') ?? ['其他', '默认'];
        await db.update(
          'transactions',
          {
            'parentCategory': parts.isNotEmpty ? parts[0] : '其他',
            'subCategory': parts.length > 1 ? parts[1] : '默认',
          },
          where: 'id = ?',
          whereArgs: [transaction['id']],
        );
      }
    }
  }

  /// 初始化数据库
  Future<void> initDatabase() async {
    await database; // 确保数据库已初始化
  }

  /// 插入交易记录
  Future<void> insertTransaction(TransactionRecord transaction) async {
    final db = await database;
    await db.insert('transactions', transaction.toJson());
  }

  /// 获取所有交易记录
  Future<List<TransactionRecord>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions');
    return List.generate(maps.length, (i) => TransactionRecord.fromJson(maps[i]));
  }

  /// 更新交易记录
  Future<void> updateTransaction(TransactionRecord transaction) async {
    final db = await database;
    await db.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  /// 删除交易记录
  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 插入自定义分类
  Future<void> insertCustomCategory(Category category) async {
    final db = await database;
    final categoryData = category.toJson();
    categoryData['subCategories'] = jsonEncode(category.subCategories.map((e) => e.toJson()).toList());
    await db.insert('categories', categoryData);
  }

  /// 更新自定义分类
  Future<void> updateCustomCategory(Category category) async {
    final db = await database;
    final categoryData = category.toJson();
    categoryData['subCategories'] = jsonEncode(category.subCategories.map((e) => e.toJson()).toList());
    await db.update(
      'categories',
      categoryData,
      where: 'name = ? AND type = ?',
      whereArgs: [category.name, category.type.index],
    );
  }

  /// 获取自定义分类
  Future<List<Category>> getCustomCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      final map = Map<String, dynamic>.from(maps[i]);
      // 解析子分类
      if (map['subCategories'] != null) {
        final subCatsJson = jsonDecode(map['subCategories']) as List;
        map['subCategories'] = subCatsJson;
      } else {
        map['subCategories'] = [];
      }
      return Category.fromJson(map);
    });
  }

  /// 保存罐头设置
  Future<void> saveJarSettings(JarSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jar_settings', jsonEncode(settings.toJson()));
  }

  /// 获取罐头设置
  Future<JarSettings?> getJarSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('jar_settings');
    if (settingsJson != null) {
      return JarSettings.fromJson(jsonDecode(settingsJson));
    }
    return null;
  }

  /// 获取存钱目标 (兼容旧版本)
  Future<double> getSavingsGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('savings_goal') ?? 1000.0;
  }

  /// 更新存钱目标 (兼容旧版本)
  Future<void> updateSavingsGoal(double goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('savings_goal', goal);
  }

  /// 清空所有数据
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('categories');
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
} 