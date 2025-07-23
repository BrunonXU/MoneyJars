import 'storage_service.dart';

/// Stub implementation for conditional imports
/// This file is used when neither dart:io nor dart:html is available
StorageService createStorageService() => throw UnsupportedError(
    'Cannot create storage service on this platform');