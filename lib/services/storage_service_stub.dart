import 'storage_service.dart';
import 'storage_service_adapter.dart';

/// 平台无关的存储服务实现选择器
StorageService createStorageService() {
  // 使用新架构的适配器
  return RepositoryStorageAdapter();
}