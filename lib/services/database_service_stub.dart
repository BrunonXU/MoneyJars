import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart' hide Category;
import '../models/transaction_record.dart';
import '../services/database_service.dart';

/// 非Web平台存根实现
class WebDatabaseService extends DatabaseService {
  // 在非Web平台，直接使用父类的默认实现
}