/*
 * 应用路由配置 (app_routes.dart)
 * 
 * 功能说明：
 * - 定义所有页面路由路径
 * - 配置路由参数
 * - 管理路由跳转逻辑
 * 
 * 路由命名规范：
 * - 使用小写字母和下划线
 * - 层级用斜杠分隔
 * - 例如：/jars/detail, /settings/jar_config
 */

/// 路由路径常量定义
class AppRoutes {
  // 防止实例化
  AppRoutes._();
  
  /// 根路由
  static const String root = '/';
  
  /// 罐头相关路由
  static const String jarsHome = '/jars';
  static const String jarDetail = '/jars/detail';
  static const String jarSettings = '/jars/settings';
  
  /// 交易输入路由
  static const String transactionInput = '/transaction/input';
  static const String transactionEdit = '/transaction/edit';
  
  /// 统计分析路由
  static const String statistics = '/statistics';
  static const String statisticsDetail = '/statistics/detail';
  static const String monthlyReport = '/statistics/monthly';
  
  /// 设置相关路由
  static const String settings = '/settings';
  static const String categorySettings = '/settings/categories';
  static const String themeSettings = '/settings/theme';
  static const String backupRestore = '/settings/backup';
  
  /// 帮助相关路由
  static const String help = '/help';
  static const String tutorial = '/help/tutorial';
  static const String about = '/help/about';
  
  /// 个性化路由
  static const String personalization = '/personalization';
}

/// 路由参数键定义
class RouteParams {
  // 防止实例化
  RouteParams._();
  
  /// 罐头类型参数
  static const String jarType = 'jarType';
  
  /// 交易ID参数
  static const String transactionId = 'transactionId';
  
  /// 日期范围参数
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';
  
  /// 分类参数
  static const String categoryId = 'categoryId';
  static const String categoryType = 'categoryType';
}

/// 路由生成器
class RouteGenerator {
  /// 生成路由
  /// 
  /// [settings] - 路由设置，包含路由名称和参数
  /// 返回对应的页面路由
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // TODO: 实现路由生成逻辑
    // 根据settings.name返回对应的PageRoute
    
    switch (settings.name) {
      case AppRoutes.root:
        // return MaterialPageRoute(builder: (_) => JarsHomePage());
        break;
      
      case AppRoutes.jarDetail:
        // final args = settings.arguments as Map<String, dynamic>;
        // return MaterialPageRoute(
        //   builder: (_) => JarDetailPage(
        //     type: args[RouteParams.jarType],
        //   ),
        // );
        break;
      
      // 更多路由配置...
      
      default:
        // return MaterialPageRoute(builder: (_) => ErrorPage());
    }
    
    // 临时返回，待实现
    throw UnimplementedError('Route ${settings.name} not implemented');
  }
}