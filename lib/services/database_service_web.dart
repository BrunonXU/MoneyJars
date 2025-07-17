import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' hide Category;
import '../models/transaction_record.dart';
import '../services/database_service.dart';

/// Web平台专用数据库服务
class WebDatabaseService extends DatabaseService {
  static Database? _webDatabase;
  static bool _isWebInitializing = false;

  @override
  Future<Database> get database async {
    if (_webDatabase != null) return _webDatabase!;
    
    // 避免重复初始化
    if (_isWebInitializing) {
      while (_isWebInitializing) {
        await Future.delayed(Duration(milliseconds: 10));
      }
      return _webDatabase!;
    }
    
    _isWebInitializing = true;
    try {
      _webDatabase = await _initWebDatabase();
      return _webDatabase!;
    } finally {
      _isWebInitializing = false;
    }
  }

  /// 初始化Web数据库
  Future<Database> _initWebDatabase() async {
    try {
      // 使用专门的Web数据库工厂，避免全局工厂设置
      final webFactory = databaseFactoryFfiWeb;
      
      return await webFactory.openDatabase(
        'money_jars.db',
        options: OpenDatabaseOptions(
          version: 2,
          onCreate: (db, version) async {
            await _createWebDatabase(db, version);
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            await _upgradeWebDatabase(db, oldVersion, newVersion);
          },
        ),
      );
    } catch (e) {
      debugPrint('Web数据库初始化失败: $e');
      rethrow;
    }
  }

  /// 创建Web数据库表
  Future<void> _createWebDatabase(Database db, int version) async {
    // 创建交易记录表
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        parentCategory TEXT NOT NULL,
        subCategory TEXT NOT NULL,
        type TEXT NOT NULL,
        date INTEGER NOT NULL,
        isArchived INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // 创建自定义分类表
    await db.execute('''
      CREATE TABLE custom_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // 创建罐头设置表
    await db.execute('''
      CREATE TABLE jar_settings (
        id INTEGER PRIMARY KEY,
        targetAmount REAL NOT NULL,
        title TEXT NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // 插入默认罐头设置
    await db.insert('jar_settings', {
      'id': 1,
      'targetAmount': 1000.0,
      'title': '我的储蓄罐',
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 升级Web数据库
  Future<void> _upgradeWebDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 添加 isArchived 字段到 transactions 表
      await db.execute('ALTER TABLE transactions ADD COLUMN isArchived INTEGER NOT NULL DEFAULT 0');
    }
  }
}