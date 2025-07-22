/*
 * 增强3D环状图组件 (enhanced_pie_chart.dart)
 * 
 * 功能说明：
 * - 提供3D立体效果的环状图显示
 * - 支持主分类和子分类的层级显示
 * - 具备拖拽交互和创建新分类功能
 * 
 * 相关修改位置：
 * - 修改6：环状图视觉增强 - 3D效果和高亮显示的核心实现
 * - 从 drag_record_input.dart 中拆分出来的图表组件
 * - 颜色优化：使用色轮等距分布的12种鲜艳颜色
 */

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_constants.dart';
import '../models/transaction_record_hive.dart';

// 主分类环状图绘制器
class EnhancedPieChartPainter extends CustomPainter {
  final List<String> categories;
  final Map<String, double> stats;
  final TransactionType type;
  final String? hoveredCategory;
  final double totalAmount;
  final bool canCreateNew;

  EnhancedPieChartPainter({
    required this.categories,
    required this.stats,
    required this.type,
    required this.hoveredCategory,
    required this.totalAmount,
    required this.canCreateNew,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = AppConstants.pieChartRadius;
    final innerRadius = AppConstants.pieChartCenterRadius;
    
    if (categories.isEmpty) {
      _drawEmptyChart(canvas, center, radius);
      return;
    }
    
    // 绘制分类扇形
    _drawCategorySegments(canvas, center, radius, innerRadius);
    
    // 绘制中心圆
    _drawCenterCircle(canvas, center, innerRadius);
    
    // 绘制创建新分类提示
    if (canCreateNew) {
      _drawCreateNewHint(canvas, center, radius);
    }
  }

  void _drawEmptyChart(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppConstants.textSecondaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawCircle(center, radius, paint);
    
    // 绘制提示文本
    final textPainter = TextPainter(
      text: TextSpan(
        text: '拖拽到此处\n创建分类',
        style: AppConstants.bodyStyle.copyWith(
          color: AppConstants.cardColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  // 修改6：环状图视觉增强 - 3D分类扇形绘制
  void _drawCategorySegments(Canvas canvas, Offset center, double radius, double innerRadius) {
    double startAngle = -math.pi / 2;
    final angleStep = 2 * math.pi / categories.length;
    
    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final isHovered = category == hoveredCategory;
      final currentRadius = isHovered ? radius + 25 : radius; // 增大悬停效果
      
      // 获取分类颜色
      final baseColor = AppConstants.categoryColors[i % AppConstants.categoryColors.length];
      
      if (canCreateNew) {
        // 环外状态：所有类别变成深灰色
        _draw3DSegment(canvas, center, currentRadius, innerRadius, startAngle, angleStep, 
            Colors.black.withOpacity(0.15), false);
      } else {
        // 正常状态 - 绘制3D效果
        final segmentColor = isHovered ? baseColor : baseColor.withOpacity(0.9);
        _draw3DSegment(canvas, center, currentRadius, innerRadius, startAngle, angleStep, 
            segmentColor, isHovered);
      }
      
      // 绘制分类标签
      _drawCategoryLabel(canvas, center, category, startAngle + angleStep / 2, currentRadius, 
          canCreateNew ? Colors.grey.withOpacity(0.3) : baseColor);
      
      startAngle += angleStep;
    }
  }

  // 修改6：环状图视觉增强 - 3D扇形绘制核心方法
  void _draw3DSegment(Canvas canvas, Offset center, double radius, double innerRadius, 
      double startAngle, double angleStep, Color color, bool isHighlighted) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // 底部阴影
    canvas.save();
    canvas.translate(3, 6); // 阴影偏移
    paint.color = Colors.black.withOpacity(0.2);
    final shadowRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(shadowRect, startAngle, angleStep, true, paint);
    
    // 清除内圆阴影
    paint.color = Colors.transparent;
    paint.blendMode = BlendMode.clear;
    canvas.drawCircle(center, innerRadius, paint);
    paint.blendMode = BlendMode.srcOver;
    canvas.restore();
    
    // 主体渐变
    final gradient = RadialGradient(
      center: Alignment.topLeft,
      radius: 1.5,
      colors: [
        color.withOpacity(isHighlighted ? 1.0 : 0.9),
        color.withOpacity(isHighlighted ? 0.8 : 0.6),
        color.withOpacity(isHighlighted ? 0.6 : 0.4),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    paint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: radius),
    );
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, angleStep, true, paint);
    
    // 清除内圆
    paint.shader = null;
    paint.color = Colors.transparent;
    paint.blendMode = BlendMode.clear;
    canvas.drawCircle(center, innerRadius, paint);
    paint.blendMode = BlendMode.srcOver;
    
    // 高光效果
    if (isHighlighted) {
      paint.color = Colors.white.withOpacity(0.3);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      canvas.drawArc(rect, startAngle, angleStep, false, paint);
      
      // 内侧高光
      paint.strokeWidth = 2;
      paint.color = Colors.white.withOpacity(0.5);
      final innerHighlightRect = Rect.fromCircle(center: center, radius: radius * 0.85);
      canvas.drawArc(innerHighlightRect, startAngle, angleStep, false, paint);
    }
    
    paint.style = PaintingStyle.fill;
  }

  void _drawCategoryLabel(Canvas canvas, Offset center, String category, double angle, double radius, Color color) {
    final labelRadius = radius * 0.7;
    final labelPosition = Offset(
      center.dx + labelRadius * math.cos(angle),
      center.dy + labelRadius * math.sin(angle),
    );
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: category,
        style: AppConstants.captionStyle.copyWith(
          color: AppConstants.cardColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      labelPosition - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  // 修改4：拖拽取消动画 - 中心圆显示黑色背景遮挡数字
  void _drawCenterCircle(Canvas canvas, Offset center, double innerRadius) {
    final paint = Paint();
    
    // 如果在创建新分类状态，中心圆使用黑色遮挡背景数字
    if (canCreateNew) {
      paint.color = Colors.black.withOpacity(0.9);
    } else {
      paint.color = AppConstants.cardColor.withOpacity(0.9);
    }
    paint.style = PaintingStyle.fill;
    
    canvas.drawCircle(center, innerRadius, paint);
    
    // 绘制边框
    paint.color = AppConstants.primaryColor.withOpacity(0.3);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, innerRadius, paint);
    
    // 绘制中心文本
    String centerText;
    Color textColor;
    
    if (canCreateNew) {
      centerText = '创建新分类';
      textColor = AppConstants.cardColor; // 白色文字在黑色背景上
    } else if (hoveredCategory != null && stats.containsKey(hoveredCategory)) {
      centerText = '¥${stats[hoveredCategory]!.toStringAsFixed(0)}';
      textColor = AppConstants.primaryColor;
    } else if (totalAmount > 0) {
      centerText = '¥${totalAmount.toStringAsFixed(0)}';
      textColor = AppConstants.primaryColor;
    } else {
      centerText = '选择分类';
      textColor = AppConstants.primaryColor;
    }
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: centerText,
        style: AppConstants.titleStyle.copyWith(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawCreateNewHint(Canvas canvas, Offset center, double radius) {
    final paint = Paint();
    
    // 环外白色高亮呼吸灯效果
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final breathe = 0.7 + 0.3 * math.sin(time * 3.0); // 呼吸频率
    
    // 绘制多层呼吸光环
    for (int i = 0; i < 3; i++) {
      final ringRadius = radius + 40 + (i * 15);
      final opacity = (breathe * (1.0 - i * 0.3)).clamp(0.0, 1.0);
      
      paint.color = Colors.white.withOpacity(opacity * 0.8);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 6 - (i * 2);
      canvas.drawCircle(center, ringRadius, paint);
    }
    
    // 中心白色圆形
    paint.color = Colors.white.withOpacity(breathe * 0.9);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 25, paint);
    
    // 文字
    final textPainter = TextPainter(
      text: TextSpan(
        text: '创建新分类',
        style: AppConstants.bodyStyle.copyWith(
          color: AppConstants.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! EnhancedPieChartPainter ||
        oldDelegate.hoveredCategory != hoveredCategory ||
        oldDelegate.canCreateNew != canCreateNew ||
        canCreateNew; // 在创建新分类状态时持续重绘呼吸效果
  }
}

// 子分类环状图绘制器
class EnhancedSubCategoryPieChartPainter extends CustomPainter {
  final List<String> subCategories;
  final Map<String, double> stats;
  final String parentCategory;
  final TransactionType type;
  final String? hoveredCategory;
  final double totalAmount;

  EnhancedSubCategoryPieChartPainter({
    required this.subCategories,
    required this.stats,
    required this.parentCategory,
    required this.type,
    required this.hoveredCategory,
    required this.totalAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = AppConstants.pieChartRadius;
    final innerRadius = AppConstants.pieChartCenterRadius;
    
    if (subCategories.isEmpty) {
      _drawEmptySubChart(canvas, center, radius);
      return;
    }
    
    // 绘制子分类扇形
    _drawSubCategorySegments(canvas, center, radius, innerRadius);
    
    // 绘制中心圆
    _drawCenterCircle(canvas, center, innerRadius);
  }

  void _drawEmptySubChart(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppConstants.textSecondaryColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawCircle(center, radius, paint);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: '暂无子分类',
        style: AppConstants.bodyStyle.copyWith(
          color: AppConstants.cardColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  // 修改6：环状图视觉增强 - 子分类3D绘制
  void _drawSubCategorySegments(Canvas canvas, Offset center, double radius, double innerRadius) {
    double startAngle = -math.pi / 2;
    final angleStep = 2 * math.pi / subCategories.length;
    
    for (int i = 0; i < subCategories.length; i++) {
      final subCategory = subCategories[i];
      final isHovered = subCategory == hoveredCategory;
      final currentRadius = isHovered ? radius + 25 : radius;
      
      // 获取子分类颜色（使用更亮的色调）
      final baseColor = AppConstants.categoryColors[(i + 2) % AppConstants.categoryColors.length];
      final color = Color.lerp(baseColor, Colors.white, 0.2)!;
      
      // 绘制3D子分类扇形
      _draw3DSegment(canvas, center, currentRadius, innerRadius, startAngle, angleStep, 
          color, isHovered);
      
      // 绘制子分类标签
      _drawSubCategoryLabel(canvas, center, subCategory, startAngle + angleStep / 2, currentRadius, color);
      
      startAngle += angleStep;
    }
  }

  void _drawSubCategoryLabel(Canvas canvas, Offset center, String subCategory, double angle, double radius, Color color) {
    final labelRadius = radius * 0.7;
    final labelPosition = Offset(
      center.dx + labelRadius * math.cos(angle),
      center.dy + labelRadius * math.sin(angle),
    );
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: subCategory,
        style: AppConstants.captionStyle.copyWith(
          color: AppConstants.cardColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      labelPosition - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  void _drawCenterCircle(Canvas canvas, Offset center, double innerRadius) {
    final paint = Paint()
      ..color = AppConstants.cardColor.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, innerRadius, paint);
    
    // 绘制边框
    paint.color = AppConstants.primaryColor.withOpacity(0.3);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, innerRadius, paint);
    
    // 绘制中心文本 - 显示当前悬停子分类的金额
    String centerText = parentCategory;
    if (hoveredCategory != null && stats.containsKey(hoveredCategory)) {
      centerText = '¥${stats[hoveredCategory]!.toStringAsFixed(0)}';
    } else if (totalAmount > 0) {
      centerText = '¥${totalAmount.toStringAsFixed(0)}';
    }
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: centerText,
        style: AppConstants.titleStyle.copyWith(
          color: AppConstants.primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  // 修改6：环状图视觉增强 - 子分类3D绘制方法
  void _draw3DSegment(Canvas canvas, Offset center, double radius, double innerRadius, 
      double startAngle, double angleStep, Color color, bool isHighlighted) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // 底部阴影
    canvas.save();
    canvas.translate(3, 6); // 阴影偏移
    paint.color = Colors.black.withOpacity(0.2);
    final shadowRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(shadowRect, startAngle, angleStep, true, paint);
    
    // 清除内圆阴影
    paint.color = Colors.transparent;
    paint.blendMode = BlendMode.clear;
    canvas.drawCircle(center, innerRadius, paint);
    paint.blendMode = BlendMode.srcOver;
    canvas.restore();
    
    // 主体渐变
    final gradient = RadialGradient(
      center: Alignment.topLeft,
      radius: 1.5,
      colors: [
        color.withOpacity(isHighlighted ? 1.0 : 0.9),
        color.withOpacity(isHighlighted ? 0.8 : 0.6),
        color.withOpacity(isHighlighted ? 0.6 : 0.4),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
    
    paint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: radius),
    );
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, angleStep, true, paint);
    
    // 清除内圆
    paint.shader = null;
    paint.color = Colors.transparent;
    paint.blendMode = BlendMode.clear;
    canvas.drawCircle(center, innerRadius, paint);
    paint.blendMode = BlendMode.srcOver;
    
    // 高光效果
    if (isHighlighted) {
      paint.color = Colors.white.withOpacity(0.3);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      canvas.drawArc(rect, startAngle, angleStep, false, paint);
      
      // 内侧高光
      paint.strokeWidth = 2;
      paint.color = Colors.white.withOpacity(0.5);
      final innerHighlightRect = Rect.fromCircle(center: center, radius: radius * 0.85);
      canvas.drawArc(innerHighlightRect, startAngle, angleStep, false, paint);
    }
    
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! EnhancedSubCategoryPieChartPainter ||
        oldDelegate.hoveredCategory != hoveredCategory;
  }
} 