/*
 * 应用程序入口 (main.dart) - 新架构版本
 * 
 * 功能说明：
 * - 应用程序的启动入口
 * - 初始化必要的服务
 * - 错误处理和崩溃报告
 * 
 * 迁移说明：
 * - 简化main.dart，将配置移到app/app.dart
 * - 添加全局错误处理
 * - 支持不同的运行环境
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'app/app.dart';

/// 应用程序入口
/// 
/// 初始化应用并启动
void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 设置错误处理
  _setupErrorHandling();
  
  // 设置系统UI
  _setupSystemUI();
  
  // 初始化应用
  await _initializeApp();
  
  // 启动应用
  runApp(const MoneyJarsApp());
}

/// 设置全局错误处理
void _setupErrorHandling() {
  // Flutter框架错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    // 在开发环境打印错误
    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      // 在生产环境记录错误
      _logError(details.exception, details.stack);
    }
  };
  
  // Dart错误处理
  PlatformDispatcher.instance.onError = (error, stack) {
    _logError(error, stack);
    return true; // 阻止应用崩溃
  };
}

/// 设置系统UI样式
void _setupSystemUI() {
  // 设置状态栏样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF0D2818),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // 设置屏幕方向（仅支持竖屏）
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

/// 初始化应用
/// 
/// 执行应用启动前的所有初始化操作
Future<void> _initializeApp() async {
  try {
    // 初始化应用配置
    await AppInitializer.initialize();
    
    // 配置依赖注入
    AppInitializer.configureDependencies();
    
    // 加载必要的资源
    await _loadResources();
    
  } catch (error, stack) {
    // 初始化失败处理
    _logError(error, stack);
    // 可以显示错误页面或使用默认配置继续
  }
}

/// 加载应用资源
Future<void> _loadResources() async {
  // TODO: 预加载图片资源
  // TODO: 加载本地化资源
  // TODO: 初始化主题
}

/// 记录错误
/// 
/// 在生产环境中记录错误信息
void _logError(Object error, StackTrace? stack) {
  // TODO: 集成崩溃报告服务（如Sentry、Firebase Crashlytics）
  debugPrint('Error: $error');
  if (stack != null) {
    debugPrint('Stack trace:\n$stack');
  }
}

