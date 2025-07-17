import 'package:flutter/foundation.dart';
import '../models/transaction_record_hive.dart' hide Category;
import '../models/transaction_record_hive.dart' as hive;

// 导入所有实现
import 'storage_service_web.dart';
import 'storage_service_mobile.dart';

/// 📦 抽象存储服务接口
/// 
/// 定义统一的数据存储接口，支持：
/// - Web平台：localStorage + JSON序列化
/// - 移动端：Hive高性能本地数据库
abstract class StorageService {
  /// 初始化存储服务
  Future<void> initialize();

  /// 释放资源
  Future<void> dispose();

  // ===== 交易记录操作 =====
  
  /// 获取所有交易记录
  Future<List<hive.TransactionRecord>> getTransactions();

  /// 根据ID获取交易记录
  Future<hive.TransactionRecord?> getTransaction(String id);

  /// 添加交易记录
  Future<void> addTransaction(hive.TransactionRecord transaction);

  /// 更新交易记录
  Future<void> updateTransaction(hive.TransactionRecord transaction);

  /// 删除交易记录
  Future<void> deleteTransaction(String id);

  /// 批量删除交易记录
  Future<void> deleteTransactions(List<String> ids);

  /// 清空所有交易记录
  Future<void> clearTransactions();

  // ===== 自定义分类操作 =====
  
  /// 获取所有自定义分类
  Future<List<hive.Category>> getCustomCategories();

  /// 添加自定义分类
  Future<void> addCustomCategory(hive.Category category);

  /// 更新自定义分类
  Future<void> updateCustomCategory(hive.Category category);

  /// 删除自定义分类
  Future<void> deleteCustomCategory(String id);

  // ===== 罐头设置操作 =====
  
  /// 获取罐头设置
  Future<hive.JarSettings?> getJarSettings();

  /// 保存罐头设置
  Future<void> saveJarSettings(hive.JarSettings settings);

  // ===== 数据导入导出 =====
  
  /// 导出所有数据
  Future<Map<String, dynamic>> exportAllData();

  /// 导入数据
  Future<void> importData(Map<String, dynamic> data);
}

/// 🏭 存储服务工厂
/// 
/// 根据平台自动选择合适的存储实现：
/// - kIsWeb: WebStorageService (localStorage)
/// - 其他平台: HiveStorageService (Hive)
class StorageServiceFactory {
  static StorageService? _instance;

  /// 获取存储服务实例（单例模式）
  static StorageService getInstance() {
    if (_instance != null) return _instance!;

    if (kIsWeb) {
      _instance = WebStorageService();
    } else {
      _instance = HiveStorageService();
    }

    return _instance!;
  }

  /// 重置实例（主要用于测试）
  static void resetInstance() {
    _instance = null;
  }
}