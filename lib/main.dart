import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';
import 'constants/app_constants.dart';
import 'widgets/common/loading_widget.dart';
import 'widgets/common/error_widget.dart';

void main() {
  runApp(const MoneyJarsApp());
}

class MoneyJarsApp extends StatelessWidget {
  const MoneyJarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppConstants.backgroundColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: MaterialApp(
        title: 'MoneyJars',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConstants.primaryColor,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
          scaffoldBackgroundColor: AppConstants.backgroundColor,
          cardColor: AppConstants.cardColor,
          dividerColor: AppConstants.dividerColor,
          textTheme: const TextTheme(
            headlineLarge: AppConstants.headingStyle,
            titleLarge: AppConstants.titleStyle,
            bodyLarge: AppConstants.bodyStyle,
            bodySmall: AppConstants.captionStyle,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: AppConstants.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              elevation: 0,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppConstants.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: AppConstants.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
            ),
            filled: true,
            fillColor: AppConstants.backgroundColor,
            contentPadding: const EdgeInsets.all(AppConstants.spacingLarge),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: AppConstants.curveDefault),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: AppConstants.curveElastic),
      ),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: AppConstants.curveDefault),
      ),
    );
    
    _controller.forward();
  }

  Future<void> _initializeApp() async {
    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      
      // 添加超时机制
      await provider.initializeData().timeout(
        AppConstants.databaseTimeout,
        onTimeout: () {
          throw Exception('初始化超时，请检查网络连接');
        },
      );
      
      // 等待动画完成
      await _controller.forward();
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: AppConstants.animationMedium,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: AppErrorWidget(
          message: AppConstants.errorInitialization,
          details: _errorMessage,
          onRetry: () {
            setState(() {
              _hasError = false;
              _errorMessage = null;
            });
            _initializeApp();
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 主要内容
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      children: [
                        // MoneyJars 图标
                        Hero(
                          tag: 'app_icon',
                          child: RotationTransition(
                            turns: _rotationAnimation,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor,
                                borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppConstants.primaryColor.withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.savings,
                                size: 60,
                                color: AppConstants.cardColor,
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: AppConstants.spacingXLarge),
                        
                        // 应用名称
                        Text(
                          'MoneyJars',
                          style: AppConstants.headingStyle.copyWith(
                            fontSize: 36,
                            color: AppConstants.primaryColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: AppConstants.spacingMedium),
                        
                        // 副标题
                        Text(
                          '智能记账，精彩生活',
                          style: AppConstants.bodyStyle.copyWith(
                            color: AppConstants.textSecondaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.spacingXXLarge),
                
                // 加载指示器
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstants.primaryColor.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.spacingLarge),
                
                // 加载文本
                Opacity(
                  opacity: _fadeAnimation.value,
                  child: Text(
                    '正在初始化...',
                    style: AppConstants.captionStyle.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 