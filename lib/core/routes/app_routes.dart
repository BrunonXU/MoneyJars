import 'package:flutter/material.dart';
import '../../presentation/pages/splash/splash_page_new.dart';
import '../../presentation/pages/home/home_page_new.dart';
import '../../presentation/pages/statistics/statistics_page.dart';
import '../../presentation/pages/settings/settings_page.dart';

/// 应用路由配置
class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
  static const String addTransaction = '/add-transaction';
  static const String categoryManagement = '/category-management';
  
  /// 路由生成器
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPageNew(),
        );
        
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePageNew(),
        );
        
      case statistics:
        return MaterialPageRoute(
          builder: (_) => const StatisticsPage(),
        );
        
      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('页面未找到: ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  /// 页面转场动画
  static PageRouteBuilder fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}