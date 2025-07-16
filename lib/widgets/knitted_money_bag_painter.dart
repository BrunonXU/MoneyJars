/*
 * 针织风格钱袋绘制器 (knitted_money_bag_painter.dart)
 * 
 * 功能说明：
 * - 基于用户设计的针织风格钱袋
 * - 动态浮动金币效果
 * - 圣诞节装饰元素
 * - 针织纹理背景
 */

import 'package:flutter/material.dart';
import 'dart:math' as math;

class KnittedMoneyBagPainter extends CustomPainter {
  final double progress;
  final Color bagColor;
  final Color backgroundPattern;
  final double coinAnimation;
  final double currentAmount;
  final bool isIncome;

  KnittedMoneyBagPainter({
    required this.progress,
    required this.bagColor,
    required this.backgroundPattern,
    required this.coinAnimation,
    required this.currentAmount,
    required this.isIncome,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // 绘制针织纹理背景
    _drawKnittedBackground(canvas, size, paint);
    
    // 绘制圣诞装饰边框
    _drawChristmasPatternBorder(canvas, size, paint);
    
    // 绘制钱袋主体
    _drawMoneyBag(canvas, size, paint);
    
    // 绘制浮动金币
    _drawFloatingCoins(canvas, size, paint);
    
    // 绘制圣诞装饰
    _drawChristmasDecorations(canvas, size, paint);
  }

  void _drawKnittedBackground(Canvas canvas, Size size, Paint paint) {
    // 创建针织纹理效果
    paint.color = backgroundPattern;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // 绘制针织纹理点
    paint.color = backgroundPattern.withOpacity(0.7);
    final patternSize = 8.0;
    
    for (double x = 0; x < size.width; x += patternSize) {
      for (double y = 0; y < size.height; y += patternSize) {
        // 创建V字形针织纹理
        final offset = (x / patternSize).floor() % 2 == 0 ? 0.0 : patternSize / 2;
        canvas.drawCircle(
          Offset(x + patternSize / 2, y + offset + patternSize / 2),
          1.5,
          paint,
        );
      }
    }
  }

  void _drawChristmasPatternBorder(Canvas canvas, Size size, Paint paint) {
    final borderHeight = 40.0;
    final patternColor = Colors.white.withOpacity(0.9);
    
    // 顶部边框
    _drawPatternBorder(canvas, Rect.fromLTWH(0, 0, size.width, borderHeight), paint, patternColor);
    
    // 底部边框
    _drawPatternBorder(canvas, Rect.fromLTWH(0, size.height - borderHeight, size.width, borderHeight), paint, patternColor);
  }

  void _drawPatternBorder(Canvas canvas, Rect rect, Paint paint, Color color) {
    paint.color = color;
    
    // 绘制鹿角图案
    final patternWidth = 20.0;
    final patternHeight = 15.0;
    
    for (double x = 0; x < rect.width; x += patternWidth * 2) {
      final centerX = x + patternWidth;
      final centerY = rect.top + rect.height / 2;
      
      // 绘制简化的鹿角图案
      _drawDeerAntler(canvas, Offset(centerX, centerY), patternHeight, paint);
    }
  }

  void _drawDeerAntler(Canvas canvas, Offset center, double height, Paint paint) {
    final path = Path();
    
    // 主干
    path.moveTo(center.dx, center.dy + height / 2);
    path.lineTo(center.dx, center.dy - height / 2);
    
    // 分叉
    path.moveTo(center.dx - height / 4, center.dy - height / 4);
    path.lineTo(center.dx, center.dy - height / 2);
    path.lineTo(center.dx + height / 4, center.dy - height / 4);
    
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
  }

  void _drawMoneyBag(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final bagWidth = size.width * 0.4;
    final bagHeight = size.height * 0.45;
    
    // 钱袋主体颜色
    final bagMainColor = Color(0xFFDEB887); // 麻袋色
    
    // 绘制钱袋主体
    final bagRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, centerY + bagHeight * 0.1),
        width: bagWidth,
        height: bagHeight,
      ),
      Radius.circular(bagWidth * 0.1),
    );
    
    // 钱袋渐变
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        bagMainColor.withOpacity(0.9),
        bagMainColor.withOpacity(0.7),
        bagMainColor.withOpacity(0.5),
      ],
    ).createShader(bagRect.outerRect);
    
    canvas.drawRRect(bagRect, paint);
    
    // 绘制钱袋纹理
    paint.shader = null;
    paint.color = bagMainColor.withOpacity(0.3);
    _drawBagTexture(canvas, bagRect.outerRect, paint);
    
    // 绘制钱袋口
    _drawBagOpening(canvas, centerX, centerY - bagHeight * 0.35, bagWidth, paint);
    
    // 绘制拉绳
    _drawDrawString(canvas, centerX, centerY - bagHeight * 0.3, bagWidth, paint);
    
    // 绘制美元符号
    _drawDollarSign(canvas, Offset(centerX, centerY + bagHeight * 0.05), paint);
  }

  void _drawBagTexture(Canvas canvas, Rect bagRect, Paint paint) {
    final textureSpacing = 8.0;
    
    for (double x = bagRect.left; x < bagRect.right; x += textureSpacing) {
      for (double y = bagRect.top; y < bagRect.bottom; y += textureSpacing) {
        // 创建编织纹理
        if ((x / textureSpacing).floor() % 2 == (y / textureSpacing).floor() % 2) {
          canvas.drawLine(
            Offset(x, y),
            Offset(x + textureSpacing * 0.7, y + textureSpacing * 0.7),
            paint..strokeWidth = 1,
          );
        }
      }
    }
  }

  void _drawBagOpening(Canvas canvas, double centerX, double centerY, double bagWidth, Paint paint) {
    final openingWidth = bagWidth * 0.8;
    final openingHeight = 15.0;
    
    // 钱袋开口
    paint.color = const Color(0xFF8B4513); // 深褐色
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: openingWidth,
          height: openingHeight,
        ),
        Radius.circular(openingHeight / 2),
      ),
      paint,
    );
    
    // 开口内部阴影
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY + 2),
          width: openingWidth * 0.9,
          height: openingHeight * 0.7,
        ),
        Radius.circular(openingHeight / 2),
      ),
      paint,
    );
  }

  void _drawDrawString(Canvas canvas, double centerX, double centerY, double bagWidth, Paint paint) {
    final stringColor = const Color(0xFF654321);
    paint.color = stringColor;
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;
    
    // 左侧绳子
    final leftStringPath = Path();
    leftStringPath.moveTo(centerX - bagWidth * 0.3, centerY);
    leftStringPath.quadraticBezierTo(
      centerX - bagWidth * 0.2, centerY - 15,
      centerX - bagWidth * 0.1, centerY - 10,
    );
    canvas.drawPath(leftStringPath, paint);
    
    // 右侧绳子
    final rightStringPath = Path();
    rightStringPath.moveTo(centerX + bagWidth * 0.3, centerY);
    rightStringPath.quadraticBezierTo(
      centerX + bagWidth * 0.2, centerY - 15,
      centerX + bagWidth * 0.1, centerY - 10,
    );
    canvas.drawPath(rightStringPath, paint);
    
    paint.style = PaintingStyle.fill;
  }

  void _drawDollarSign(Canvas canvas, Offset center, Paint paint) {
    paint.color = const Color(0xFF228B22); // 绿色美元符号
    paint.strokeWidth = 4;
    paint.style = PaintingStyle.stroke;
    
    final dollarPath = Path();
    final radius = 12.0;
    
    // S形曲线
    dollarPath.moveTo(center.dx + radius * 0.5, center.dy - radius * 0.8);
    dollarPath.quadraticBezierTo(
      center.dx - radius * 0.5, center.dy - radius * 0.4,
      center.dx + radius * 0.3, center.dy,
    );
    dollarPath.quadraticBezierTo(
      center.dx + radius * 0.8, center.dy + radius * 0.4,
      center.dx - radius * 0.5, center.dy + radius * 0.8,
    );
    
    canvas.drawPath(dollarPath, paint);
    
    // 垂直线
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );
    
    paint.style = PaintingStyle.fill;
  }

  void _drawFloatingCoins(Canvas canvas, Size size, Paint paint) {
    final coinCount = (currentAmount / 50).ceil().clamp(3, 8);
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    for (int i = 0; i < coinCount; i++) {
      final angle = (i * math.pi * 2 / coinCount) + (coinAnimation * math.pi);
      final radius = 60 + math.sin(coinAnimation * math.pi + i) * 20;
      
      final coinX = centerX + math.cos(angle) * radius;
      final coinY = centerY + math.sin(angle) * radius * 0.6 + 
                    math.sin(coinAnimation * math.pi * 2 + i * 0.5) * 10;
      
      _drawAnimatedCoin(canvas, Offset(coinX, coinY), paint, i);
    }
  }

  void _drawAnimatedCoin(Canvas canvas, Offset center, Paint paint, int index) {
    final coinRadius = 10.0;
    final rotation = coinAnimation * math.pi * 2 + index * 0.5;
    
    // 金币渐变
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFFFFD700), // 金色
        const Color(0xFFFFB300), // 深金色
        const Color(0xFFFF8F00), // 边缘金色
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
    
    // 美元符号
    paint.color = const Color(0xFF8B4513);
    paint.style = PaintingStyle.fill;
    _drawMiniDollarSign(canvas, center, paint, rotation);
  }

  void _drawMiniDollarSign(Canvas canvas, Offset center, Paint paint, double rotation) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    
    paint.strokeWidth = 1.5;
    paint.style = PaintingStyle.stroke;
    
    // 简化的美元符号
    final path = Path();
    path.moveTo(2, -5);
    path.quadraticBezierTo(-2, -2, 2, 0);
    path.quadraticBezierTo(4, 2, -2, 5);
    
    canvas.drawPath(path, paint);
    canvas.drawLine(const Offset(0, -6), const Offset(0, 6), paint);
    
    canvas.restore();
    paint.style = PaintingStyle.fill;
  }

  void _drawChristmasDecorations(Canvas canvas, Size size, Paint paint) {
    // 绘制冬青叶
    _drawHollyLeaves(canvas, size, paint);
    
    // 绘制雪花
    _drawSnowflakes(canvas, size, paint);
  }

  void _drawHollyLeaves(Canvas canvas, Size size, Paint paint) {
    final hollyPositions = [
      Offset(size.width * 0.15, size.height * 0.2),
      Offset(size.width * 0.85, size.height * 0.2),
      Offset(size.width * 0.15, size.height * 0.8),
      Offset(size.width * 0.85, size.height * 0.8),
    ];
    
    for (final pos in hollyPositions) {
      _drawHollyLeaf(canvas, pos, paint);
    }
  }

  void _drawHollyLeaf(Canvas canvas, Offset center, Paint paint) {
    // 绿色冬青叶
    paint.color = const Color(0xFF228B22);
    
    final leafPath = Path();
    leafPath.moveTo(center.dx, center.dy - 10);
    leafPath.quadraticBezierTo(center.dx + 5, center.dy - 5, center.dx + 8, center.dy);
    leafPath.quadraticBezierTo(center.dx + 3, center.dy + 3, center.dx + 6, center.dy + 8);
    leafPath.quadraticBezierTo(center.dx, center.dy + 5, center.dx - 6, center.dy + 8);
    leafPath.quadraticBezierTo(center.dx - 3, center.dy + 3, center.dx - 8, center.dy);
    leafPath.quadraticBezierTo(center.dx - 5, center.dy - 5, center.dx, center.dy - 10);
    
    canvas.drawPath(leafPath, paint);
    
    // 红色浆果
    paint.color = const Color(0xFFDC143C);
    canvas.drawCircle(Offset(center.dx + 2, center.dy), 2, paint);
    canvas.drawCircle(Offset(center.dx - 2, center.dy + 2), 2, paint);
  }

  void _drawSnowflakes(Canvas canvas, Size size, Paint paint) {
    paint.color = Colors.white.withOpacity(0.8);
    
    for (int i = 0; i < 12; i++) {
      final x = (i * 137.5 + coinAnimation * 50) % size.width;
      final y = (i * 200 + coinAnimation * 100) % size.height;
      
      _drawSnowflake(canvas, Offset(x, y), paint);
    }
  }

  void _drawSnowflake(Canvas canvas, Offset center, Paint paint) {
    final size = 3.0;
    paint.strokeWidth = 1;
    paint.style = PaintingStyle.stroke;
    
    // 六角雪花
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final endX = center.dx + math.cos(angle) * size;
      final endY = center.dy + math.sin(angle) * size;
      
      canvas.drawLine(center, Offset(endX, endY), paint);
    }
    
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! KnittedMoneyBagPainter ||
        oldDelegate.progress != progress ||
        oldDelegate.coinAnimation != coinAnimation ||
        oldDelegate.currentAmount != currentAmount;
  }
}