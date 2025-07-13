/*
 * 罐头组件 (money_jar_widget.dart)
 * 
 * 功能说明：
 * - 绘制3D立体效果的金钱罐头
 * - 包含动态金币动画和进度显示
 * - 支持点击交互和触觉反馈
 * 
 * 相关修改位置：
 * - 修改2：布局位置调整 - 罐头标题位置优化 (第129行区域)
 * - 修改3：罐头点击动画 - 点击检测和弹性动画 (第268-327行区域)
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/transaction_record.dart';
import '../constants/app_constants.dart';

class MoneyJarWidget extends StatefulWidget {
  final double currentAmount;
  final double targetAmount;
  final Color color;
  final TransactionType type;
  final String title;
  final bool isComprehensive;
  final VoidCallback? onJarTap;

  const MoneyJarWidget({
    super.key,
    required this.currentAmount,
    required this.targetAmount,
    required this.color,
    required this.type,
    required this.title,
    this.isComprehensive = false,
    this.onJarTap,
  });

  @override
  State<MoneyJarWidget> createState() => _MoneyJarWidgetState();
}

class _MoneyJarWidgetState extends State<MoneyJarWidget>
    with TickerProviderStateMixin {
  late AnimationController _coinAnimationController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _tapAnimationController;
  late Animation<double> _coinAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _tapAnimation;

  double _previousAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _previousAmount = widget.currentAmount;
  }

  void _initializeAnimations() {
    _coinAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: AppConstants.animationSlow,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _tapAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _coinAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _coinAnimationController,
        curve: AppConstants.curveDefault,
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: AppConstants.curveElastic,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: AppConstants.curveDefault,
      ),
    );

    _tapAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _tapAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _coinAnimationController.repeat();
    _progressController.forward();
  }

  @override
  void didUpdateWidget(MoneyJarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检测金额变化并触发动画
    if (oldWidget.currentAmount != widget.currentAmount) {
      _triggerAmountChangeAnimation();
      _previousAmount = widget.currentAmount;
    }
  }

  void _triggerAmountChangeAnimation() {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  @override
  void dispose() {
    _coinAnimationController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    _tapAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.targetAmount > 0 
        ? (widget.currentAmount.abs() / widget.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // 背景渐变
          _buildBackground(),
          
          // 标题 - 固定在顶部
          Positioned(
            top: MediaQuery.of(context).padding.top + AppConstants.spacingLarge,
            left: 0,
            right: 0,
            child: Center(child: _buildTitle()),
          ),
          
          // 主要内容 - 罐头和金额信息
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 罐头容器
                  _buildJarContainer(progress),
                  
                  const SizedBox(height: AppConstants.spacingMedium),
                  
                  // 金额和进度信息
                  _buildAmountInfo(progress),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.color.withOpacity(0.08),
            widget.color.withOpacity(0.03),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.95 + (_pulseAnimation.value - 1.0) * 0.05, // 减小脉冲幅度
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingXLarge,
              vertical: AppConstants.spacingMedium,
            ),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
              border: Border.all(
                color: widget.color.withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                ...AppConstants.shadowMedium,
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingSmall),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getJarIcon(),
                    color: widget.color,
                    size: AppConstants.iconMedium,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                Text(
                  widget.title,
                  style: AppConstants.titleStyle.copyWith(
                    color: widget.color,
                    fontSize: AppConstants.fontSizeXLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.isComprehensive) ...[
                  const SizedBox(width: AppConstants.spacingMedium),
                  _buildComprehensiveIndicator(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComprehensiveIndicator() {
    final isPositive = widget.currentAmount >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingSmall,
        vertical: AppConstants.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.green : Colors.red,
            size: AppConstants.iconSmall,
          ),
          const SizedBox(width: AppConstants.spacingXSmall),
          Text(
            isPositive ? AppConstants.labelSurplus : AppConstants.labelDeficit,
            style: AppConstants.captionStyle.copyWith(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJarContainer(double progress) {
    return GestureDetector(
      onTap: () {
        if (widget.onJarTap != null) {
          _triggerTapAnimation();
          widget.onJarTap!();
        }
      },
      child: Container(
        width: AppConstants.jarWidth,
        height: AppConstants.jarHeight,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _coinAnimation,
            _progressAnimation,
            _pulseAnimation,
            _tapAnimation,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value * _tapAnimation.value,
              child: CustomPaint(
                painter: EnhancedJarPainter(
                  progress: progress * _progressAnimation.value,
                  color: widget.color,
                  coinAnimation: _coinAnimation.value,
                  currentAmount: widget.currentAmount.abs(),
                  isComprehensive: widget.isComprehensive,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _triggerTapAnimation() {
    _tapAnimationController.forward().then((_) {
      _tapAnimationController.reverse();
    });
    HapticFeedback.mediumImpact();
  }

  Widget _buildAmountInfo(double progress) {
    return Column(
      children: [
        // 当前金额
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Text(
                '¥${widget.currentAmount.toStringAsFixed(2)}',
                style: AppConstants.headingStyle.copyWith(
                  color: widget.color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        
        const SizedBox(height: AppConstants.spacingSmall),
        
        // 进度条
        if (widget.targetAmount > 0) ...[
          Container(
            width: 200,
            height: AppConstants.jarProgressHeight,
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppConstants.jarProgressHeight / 2),
            ),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    Container(
                      width: 200 * progress * _progressAnimation.value,
                      height: AppConstants.jarProgressHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.color,
                            widget.color.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.jarProgressHeight / 2),
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          const SizedBox(height: AppConstants.spacingSmall),
          
          // 百分比
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(progress * 100).toInt()}%',
                style: AppConstants.bodyStyle.copyWith(
                  color: widget.color.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Text(
                '/ ¥${widget.targetAmount.toStringAsFixed(0)}',
                style: AppConstants.captionStyle.copyWith(
                  color: widget.color.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  IconData _getJarIcon() {
    if (widget.isComprehensive) {
      return Icons.account_balance_wallet;
    }
    return widget.type == TransactionType.income 
        ? Icons.savings 
        : Icons.shopping_cart;
  }
}

class EnhancedJarPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double coinAnimation;
  final double currentAmount;
  final bool isComprehensive;

  EnhancedJarPainter({
    required this.progress,
    required this.color,
    required this.coinAnimation,
    required this.currentAmount,
    required this.isComprehensive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 绘制罐头主体
    _drawJarBody(canvas, size, paint);
    
    // 绘制金币
    _drawEnhancedCoins(canvas, size, paint);
    
    // 绘制罐头盖子
    _drawJarLid(canvas, size, paint);
    
    // 绘制高光和阴影效果
    _drawLightingEffects(canvas, size, paint);
    
    // 绘制进度指示器
    _drawProgressIndicator(canvas, size, paint);
  }

  void _drawJarBody(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final jarWidth = size.width * 0.75;
    final jarHeight = size.height * 0.65;
    final jarTop = size.height * 0.18;
    
    // 创建罐头主体路径
    final path = Path();
    path.moveTo(centerX - jarWidth / 2, jarTop + 20);
    path.quadraticBezierTo(centerX - jarWidth / 2 - 5, jarTop + 40, centerX - jarWidth / 2, jarTop + 60);
    path.lineTo(centerX - jarWidth / 2, jarTop + jarHeight - 20);
    path.quadraticBezierTo(centerX - jarWidth / 2, jarTop + jarHeight, centerX - jarWidth / 2 + 20, jarTop + jarHeight);
    path.lineTo(centerX + jarWidth / 2 - 20, jarTop + jarHeight);
    path.quadraticBezierTo(centerX + jarWidth / 2, jarTop + jarHeight, centerX + jarWidth / 2, jarTop + jarHeight - 20);
    path.lineTo(centerX + jarWidth / 2, jarTop + 60);
    path.quadraticBezierTo(centerX + jarWidth / 2 + 5, jarTop + 40, centerX + jarWidth / 2, jarTop + 20);
    path.close();

    // 3D阴影效果 - 底部阴影
    final shadowPath = Path.from(path);
    shadowPath.transform(Matrix4.translationValues(8, 12, 0).storage);
    paint.shader = null;
    paint.style = PaintingStyle.fill;
    paint.color = Colors.black.withOpacity(0.15);
    canvas.drawPath(shadowPath, paint);

    // 主体3D渐变 - 增强立体感
    final jar3DGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withOpacity(0.4),   // 顶部高光
        color.withOpacity(0.85),         // 主体颜色
        color.withOpacity(0.6),          // 中间过渡
        Colors.black.withOpacity(0.1),   // 底部阴影
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    
    paint.shader = jar3DGradient.createShader(
      Rect.fromLTWH(centerX - jarWidth / 2, jarTop, jarWidth, jarHeight),
    );
    canvas.drawPath(path, paint);
    
    // 玻璃反光效果
    final reflectionPath = Path();
    reflectionPath.moveTo(centerX - jarWidth / 3, jarTop + 30);
    reflectionPath.quadraticBezierTo(centerX - jarWidth / 4, jarTop + 80, centerX - jarWidth / 3.5, jarTop + 140);
    reflectionPath.lineTo(centerX - jarWidth / 2.5, jarTop + 140);
    reflectionPath.quadraticBezierTo(centerX - jarWidth / 3.5, jarTop + 80, centerX - jarWidth / 2.8, jarTop + 30);
    reflectionPath.close();
    
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.6),
        Colors.white.withOpacity(0.2),
        Colors.transparent,
      ],
    ).createShader(reflectionPath.getBounds());
    canvas.drawPath(reflectionPath, paint);
    
    // 边框高光
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.color = color.withOpacity(0.8);
    paint.strokeWidth = 3;
    canvas.drawPath(path, paint);
    
    // 内侧边框
    paint.color = Colors.white.withOpacity(0.3);
    paint.strokeWidth = 1;
    canvas.drawPath(path, paint);
  }

  void _drawEnhancedCoins(Canvas canvas, Size size, Paint paint) {
    // 修改：确保金币始终显示
    final displayAmount = math.max(currentAmount.abs(), 50.0); // 至少显示相当于50元的金币
    
    final centerX = size.width / 2;
    final jarWidth = size.width * 0.75;
    final jarHeight = size.height * 0.65;
    final jarTop = size.height * 0.18;
    final jarBottom = jarTop + jarHeight;
    
    // 根据金额和进度计算金币
    final coinCount = (displayAmount / 20).ceil().clamp(3, AppConstants.maxCoinCount); // 至少3个金币
    final fillHeight = math.max(jarHeight * progress, jarHeight * 0.4); // 至少显示40%的高度
    
    paint.style = PaintingStyle.fill;
    
    for (int i = 0; i < coinCount; i++) {
      final layer = i ~/ AppConstants.coinsPerLayer;
      final indexInLayer = i % AppConstants.coinsPerLayer;
      
      // 计算金币位置
      final layerY = jarBottom - 20 - (layer * AppConstants.coinLayerSpacing);
      // 修复显示条件 - 确保金币在填充高度内显示
      if (layerY > jarBottom - fillHeight) {
        final angle = (indexInLayer * math.pi * 2 / AppConstants.coinsPerLayer) + 
                     (coinAnimation * math.pi * 0.5 + i * 0.3);
        final radiusVariation = 0.8 + 0.2 * math.sin(coinAnimation * math.pi * 2 + i * 0.5);
        final radius = (jarWidth / 2 - 25) * 0.4 * radiusVariation;
        
        final coinX = centerX + radius * math.cos(angle);
        final coinY = layerY + 3 * math.sin(coinAnimation * math.pi * 2 + i * 0.7);
        
        _drawEnhancedCoin(canvas, Offset(coinX, coinY), AppConstants.coinSize, paint, i);
      }
    }
  }

  void _drawEnhancedCoin(Canvas canvas, Offset center, double radius, Paint paint, int index) {
    // 金币主体渐变
    final coinGradient = RadialGradient(
      colors: AppConstants.coinGradient,
      stops: const [0.0, 0.7, 1.0],
    );
    
    paint.shader = coinGradient.createShader(
      Rect.fromCircle(center: center, radius: radius),
    );
    canvas.drawCircle(center, radius, paint);
    
    // 金币边框
    paint.shader = null;
    paint.color = AppConstants.coinGradient[2];
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawCircle(center, radius, paint);
    
    // 金币内部细节
    paint.style = PaintingStyle.fill;
    paint.color = AppConstants.coinGradient[2].withOpacity(0.6);
    canvas.drawCircle(center, radius * 0.6, paint);
    
    // 金币高光
    paint.color = Colors.white.withOpacity(0.8);
    canvas.drawCircle(center + const Offset(-2, -2), radius * 0.3, paint);
  }

  void _drawJarLid(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final jarWidth = size.width * 0.75;
    final jarTop = size.height * 0.18;
    final lidHeight = 25.0;
    
    // 盖子主体
    final lidRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(centerX - jarWidth / 2 - 5, jarTop - lidHeight, jarWidth + 10, lidHeight + 10),
      const Radius.circular(8),
    );
    
    final lidGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.grey[300]!,
        Colors.grey[400]!,
        Colors.grey[500]!,
      ],
    );
    
    paint.shader = lidGradient.createShader(lidRect.outerRect);
    canvas.drawRRect(lidRect, paint);
    
    // 盖子边框
    paint.shader = null;
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.grey[600]!;
    paint.strokeWidth = 1;
    canvas.drawRRect(lidRect, paint);
    
    // 盖子把手
    paint.style = PaintingStyle.fill;
    paint.color = Colors.grey[400]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - 15, jarTop - lidHeight - 8, 30, 12),
        const Radius.circular(6),
      ),
      paint,
    );
  }

  void _drawLightingEffects(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final jarWidth = size.width * 0.75;
    final jarHeight = size.height * 0.65;
    final jarTop = size.height * 0.18;
    
    // 左侧高光
    paint.style = PaintingStyle.fill;
    paint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withOpacity(0.4),
        Colors.white.withOpacity(0.1),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 1.0],
    ).createShader(
      Rect.fromLTWH(centerX - jarWidth / 2, jarTop + 20, jarWidth * 0.3, jarHeight - 40),
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX - jarWidth / 2 + 5, jarTop + 30, jarWidth * 0.15, jarHeight - 60),
        const Radius.circular(20),
      ),
      paint,
    );
    
    // 右侧阴影
    paint.shader = LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        color.withOpacity(0.2),
        Colors.transparent,
      ],
    ).createShader(
      Rect.fromLTWH(centerX + jarWidth / 2 - jarWidth * 0.2, jarTop + 20, jarWidth * 0.2, jarHeight - 40),
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(centerX + jarWidth / 2 - 15, jarTop + 30, 10, jarHeight - 60),
        const Radius.circular(20),
      ),
      paint,
    );
  }

  void _drawProgressIndicator(Canvas canvas, Size size, Paint paint) {
    if (progress <= 0) return;
    
    final centerX = size.width / 2;
    final jarWidth = size.width * 0.75;
    final jarHeight = size.height * 0.65;
    final jarTop = size.height * 0.18;
    final jarBottom = jarTop + jarHeight;
    
    // 进度填充效果
    final fillHeight = jarHeight * progress;
    final fillTop = jarBottom - fillHeight;
    
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withOpacity(0.1),
        color.withOpacity(0.2),
      ],
    ).createShader(
      Rect.fromLTWH(centerX - jarWidth / 2, fillTop, jarWidth, fillHeight),
    );
    
    final fillPath = Path();
    fillPath.moveTo(centerX - jarWidth / 2, fillTop);
    fillPath.lineTo(centerX + jarWidth / 2, fillTop);
    fillPath.lineTo(centerX + jarWidth / 2, jarBottom - 20);
    fillPath.quadraticBezierTo(centerX + jarWidth / 2, jarBottom, centerX + jarWidth / 2 - 20, jarBottom);
    fillPath.lineTo(centerX - jarWidth / 2 + 20, jarBottom);
    fillPath.quadraticBezierTo(centerX - jarWidth / 2, jarBottom, centerX - jarWidth / 2, jarBottom - 20);
    fillPath.close();
    
    canvas.drawPath(fillPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! EnhancedJarPainter ||
        oldDelegate.progress != progress ||
        oldDelegate.coinAnimation != coinAnimation ||
        oldDelegate.currentAmount != currentAmount;
  }
} 