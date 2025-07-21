import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';
import 'constants/app_constants.dart';
// Loading widget import removed - not needed in main
import 'widgets/common/error_widget.dart';
import 'utils/env_check.dart';

void main() async {
  // 确保Flutter binding初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  final envResult = EnvChecker.check();
  if (!envResult.supported) {
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EnvNotSupportedPage(reason: envResult.reason),
    ));
  } else {
    runApp(const MoneyJarsApp());
  }
}

class MoneyJarsApp extends StatelessWidget {
  const MoneyJarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 设置状态栏样式 - 圣诞主题
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D2818),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: ScreenUtilInit(
        // 设计稿的设备尺寸(单位dp)
        designSize: const Size(375, 812), // iPhone 11 Pro 尺寸
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'MoneyJars',
            debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFDC143C),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
          scaffoldBackgroundColor: const Color(0xFF0D2818),
          cardColor: const Color(0xFF1A3D2E),
          dividerColor: const Color(0xFFFFD700),
          textTheme: TextTheme(
            headlineLarge: AppConstants.headingStyle,
            titleLarge: AppConstants.titleStyle,
            bodyLarge: AppConstants.bodyStyle,
            bodySmall: AppConstants.captionStyle,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A3D2E),
              foregroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                side: const BorderSide(color: Color(0xFFDC143C), width: 2),
              ),
              elevation: 0,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFDC143C)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: const BorderSide(color: Color(0xFFDC143C)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              borderSide: const BorderSide(color: Color(0xFFDC143C), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF1A3D2E),
            contentPadding: EdgeInsets.all(AppConstants.spacingLarge),
          ),
        ),
        home: const SplashScreen(),
          );
        },
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
        backgroundColor: const Color(0xFF0D2818),
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
      backgroundColor: const Color(0xFF0D2818),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D2818),
              Color(0xFF1A3D2E),
              Color(0xFF0D2818),
            ],
          ),
        ),
        child: AnimatedBuilder(
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
                                  color: const Color(0xFF1A3D2E),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                                  border: Border.all(
                                    color: const Color(0xFFDC143C),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFDC143C).withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFFFFD700).withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.park,
                                  size: 60,
                                  color: Color(0xFF228B22),
                                ),
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: AppConstants.spacingXLarge),
                        
                        // 应用名称 - 圣诞主题
                        Text(
                          'Christmas Jars',
                          style: AppConstants.headingStyle.copyWith(
                            fontSize: 36,
                            color: const Color(0xFFDC143C),
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFDC143C).withOpacity(0.8),
                                blurRadius: 10,
                              ),
                              Shadow(
                                color: const Color(0xFFFFD700).withOpacity(0.6),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppConstants.spacingMedium),
                        
                        // 副标题
                        Text(
                          '圣诞节记账，温馨节日',
                          style: AppConstants.bodyStyle.copyWith(
                            color: const Color(0xFFFFFFFF).withOpacity(0.7),
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
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFDC143C),
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
                      color: const Color(0xFFFFFFFF).withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
  }
} 