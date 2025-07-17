import 'storage_service.dart';

/// 平台无关的存储服务实现选择器
StorageService createStorageService() {
  throw UnsupportedError('Platform not supported');
}