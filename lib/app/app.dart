/*
 * 应用程序主配置文件 (app.dart)
 * 
 * 功能说明：
 * - 应用程序的主要配置和初始化
 * - 依赖注入设置
 * - 全局Provider配置
 * - 应用级别的错误处理
 * 
 * 迁移说明：
 * - 从原main.dart提取应用配置部分
 * - 保留MaterialApp配置
 * - 添加依赖注入容器
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/di/service_locator.dart';
import '../presentation/providers/transaction_provider_new.dart';
import '../presentation/providers/category_provider.dart';
import '../presentation/pages/splash/splash_page_new.dart';
import '../core/theme/app_theme.dart';
import '../core/routes/app_routes.dart';

/// MoneyJars应用程序主类
/// 
/// 负责应用的初始化和全局配置
class MoneyJarsApp extends StatelessWidget {
  const MoneyJarsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProviderNew(
            transactionRepository: serviceLocator.transactionRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(
            categoryRepository: serviceLocator.categoryRepository,
          ),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'MoneyJars',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const SplashPageNew(),
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}

/// 应用初始化
/// 
/// 在应用启动前执行的初始化操作
class AppInitializer {
  /// 初始化应用
  static Future<void> initialize() async {
    // 初始化依赖注入
    await initServiceLocator();
  }
  
  /// 配置依赖注入
  static void configureDependencies() {
    // 依赖注入已在 service_locator.dart 中配置
  }
}