/*
 * 用户设计的罐头组件 (user_design_jar_widget.dart)
 * 
 * 功能说明：
 * - 直接使用用户提供的PNG设计图片
 * - 保持原始针织纹理和设计完整性
 * - 在用户设计基础上添加动画效果
 * - 完全尊重用户的创意设计
 */

import 'package:flutter/material.dart';
import 'dart:math' as math;

class UserDesignJarWidget extends StatefulWidget {
  final double currentAmount;
  final double targetAmount;
  final bool isIncome;
  final VoidCallback? onTap;
  final bool isComprehensive;

  const UserDesignJarWidget({
    Key? key,
    required this.currentAmount,
    required this.targetAmount,
    required this.isIncome,
    this.onTap,
    this.isComprehensive = false,
  }) : super(key: key);

  @override
  State<UserDesignJarWidget> createState() => _UserDesignJarWidgetState();
}

class _UserDesignJarWidgetState extends State<UserDesignJarWidget>
    with TickerProviderStateMixin {
  late AnimationController _coinAnimationController;
  late AnimationController _pulseController;
  late Animation<double> _coinAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _coinAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _coinAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _coinAnimationController, curve: Curves.linear),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _coinAnimationController.repeat();
  }

  @override
  void dispose() {
    _coinAnimationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerPulse() {
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _triggerPulse();
        widget.onTap?.call();
      },
      child: Container(
        width: 280,
        height: 400,
        child: AnimatedBuilder(
          animation: Listenable.merge([_coinAnimation, _pulseAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Stack(
                children: [
                  // 用户的原始设计图片
                  Container(
                    width: 280,
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        widget.isComprehensive 
                            ? 'assets/images/festive_piggy_bank.png'  // 使用节日小猪图像
                            : widget.isIncome 
                                ? 'assets/images/red_knitted_jar.png'
                                : 'assets/images/green_knitted_jar.png',
                        fit: BoxFit.cover,
                        width: 280,
                        height: 400,
                      ),
                    ),
                  ),
                  
                  // 浮动的金币动画层 - 在用户设计上方
                  if (widget.currentAmount > 0)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: FloatingCoinsPainter(
                          coinAnimation: _coinAnimation.value,
                          currentAmount: widget.currentAmount,
                          isIncome: widget.isIncome,
                        ),
                      ),
                    ),
                  
                  // 金额显示层
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '¥${widget.currentAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
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

class FloatingCoinsPainter extends CustomPainter {
  final double coinAnimation;
  final double currentAmount;
  final bool isIncome;

  FloatingCoinsPainter({
    required this.coinAnimation,
    required this.currentAmount,
    required this.isIncome,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // 根据金额计算金币数量
    final coinCount = (currentAmount / 100).ceil().clamp(3, 5);  // 减少上限为5
    
    // 金币围绕钱袋位置旋转
    final centerX = size.width / 2;
    final centerY = size.height * 0.45; // 钱袋位置
    
    for (int i = 0; i < coinCount; i++) {
      final angle = (i * math.pi * 2 / coinCount) + (coinAnimation * math.pi);
      final radius = 60 + math.sin(coinAnimation * math.pi + i) * 20;
      
      final coinX = centerX + math.cos(angle) * radius;
      final coinY = centerY + math.sin(angle) * radius * 0.6 + 
                    math.sin(coinAnimation * math.pi * 2 + i * 0.5) * 10;
      
      _drawFloatingCoin(canvas, Offset(coinX, coinY), paint, i);
    }
  }

  void _drawFloatingCoin(Canvas canvas, Offset center, Paint paint, int index) {
    final coinRadius = 12.0;
    final rotation = coinAnimation * math.pi * 2 + index * 0.5;
    
    // 金币主体 - 金色渐变
    paint.shader = RadialGradient(
      colors: const [
        Color(0xFFFFD700), // 金色
        Color(0xFFFFB300), // 深金色
        Color(0xFFFF8F00), // 边缘金色
      ],
      stops: const [0.0, 0.7, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: coinRadius));
    
    canvas.drawCircle(center, coinRadius, paint);
    
    // 金币边框
    paint.shader = null;
    paint.color = const Color(0xFFFF8F00);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, coinRadius, paint);
    
    // 金币上的美元符号
    paint.color = const Color(0xFF8B4513);
    paint.style = PaintingStyle.fill;
    _drawDollarSign(canvas, center, paint, rotation);
  }

  void _drawDollarSign(Canvas canvas, Offset center, Paint paint, double rotation) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    
    // 美元符号的S形曲线
    final path = Path();
    path.moveTo(3, -6);
    path.quadraticBezierTo(-3, -3, 3, 0);
    path.quadraticBezierTo(6, 3, -3, 6);
    
    canvas.drawPath(path, paint);
    
    // 美元符号的垂直线
    canvas.drawLine(const Offset(0, -8), const Offset(0, 8), paint);
    
    canvas.restore();
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! FloatingCoinsPainter ||
        oldDelegate.coinAnimation != coinAnimation ||
        oldDelegate.currentAmount != currentAmount;
  }
}