/*
 * 分类饼图组件 (category_pie_chart.dart)
 * 
 * 功能说明：
 * - 绘制分类饼图
 * - 支持3D效果和动画
 * - 处理悬停和选择状态
 * 
 * 视觉设计：
 * - 3D立体饼图
 * - 动态高亮效果
 * - 呼吸灯动画
 */

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/domain/entities/category.dart';
import '../../../../core/domain/entities/transaction.dart';

/// 分类饼图组件
class CategoryPieChart extends StatelessWidget {
  /// 分类列表
  final List<Category> categories;
  
  /// 统计数据
  final Map<String, double> stats;
  
  /// 交易类型
  final TransactionType type;
  
  /// 悬停的分类
  final String? hoveredCategory;
  
  /// 是否可以创建新分类
  final bool canCreateNew;
  
  /// 总金额
  final double totalAmount;
  
  /// 是否显示子分类
  final bool isSubCategory;
  
  /// 父分类名称（子分类时使用）
  final String? parentCategory;
  
  /// 图表半径
  final double radius;
  
  /// 中心圆半径
  final double innerRadius;
  
  /// 3D深度
  final double depth;
  
  const CategoryPieChart({
    Key? key,
    required this.categories,
    required this.stats,
    required this.type,
    this.hoveredCategory,
    this.canCreateNew = false,
    this.totalAmount = 0,
    this.isSubCategory = false,
    this.parentCategory,
    this.radius = 180,
    this.innerRadius = 80,
    this.depth = 30,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(radius * 2 + 100, radius * 2 + 100),
      painter: _CategoryPieChartPainter(
        categories: categories,
        stats: stats,
        type: type,
        hoveredCategory: hoveredCategory,
        canCreateNew: canCreateNew,
        totalAmount: totalAmount,
        isSubCategory: isSubCategory,
        parentCategory: parentCategory,
        radius: radius,
        innerRadius: innerRadius,
        depth: depth,
      ),
    );
  }
}

/// 分类饼图绘制器
class _CategoryPieChartPainter extends CustomPainter {
  final List<Category> categories;
  final Map<String, double> stats;
  final TransactionType type;
  final String? hoveredCategory;
  final bool canCreateNew;
  final double totalAmount;
  final bool isSubCategory;
  final String? parentCategory;
  final double radius;
  final double innerRadius;
  final double depth;
  
  _CategoryPieChartPainter({
    required this.categories,
    required this.stats,
    required this.type,
    required this.hoveredCategory,
    required this.canCreateNew,
    required this.totalAmount,
    required this.isSubCategory,
    required this.parentCategory,
    required this.radius,
    required this.innerRadius,
    required this.depth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    if (categories.isEmpty) {
      _drawEmptyChart(canvas, center);
      return;
    }
    
    // 绘制3D饼图
    _draw3DPieChart(canvas, center);
    
    // 绘制中心圆
    _drawCenterCircle(canvas, center);
    
    // 如果可以创建新分类，绘制提示
    if (canCreateNew) {
      _drawCreateNewHint(canvas, center);
    }
  }
  
  /// 绘制空图表
  void _drawEmptyChart(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    canvas.drawCircle(center, radius, paint);
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: isSubCategory ? '暂无子分类' : '暂无分类',
        style: TextStyle(
          color: Colors.grey[600],
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
  
  /// 绘制3D饼图
  void _draw3DPieChart(Canvas canvas, Offset center) {
    final categoryCount = categories.length;
    final anglePerCategory = (2 * math.pi) / categoryCount;
    var currentAngle = -math.pi / 2;
    
    // 绘制侧面（3D效果）
    for (int i = 0; i < categoryCount; i++) {
      final category = categories[i];
      final startAngle = currentAngle;
      final endAngle = startAngle + anglePerCategory;
      
      _draw3DSide(
        canvas,
        center,
        startAngle,
        endAngle,
        _getCategoryColor(category, i),
      );
      
      currentAngle = endAngle;
    }
    
    // 绘制顶面
    currentAngle = -math.pi / 2;
    for (int i = 0; i < categoryCount; i++) {
      final category = categories[i];
      final startAngle = currentAngle;
      final endAngle = startAngle + anglePerCategory;
      final isHovered = hoveredCategory == category.name;
      
      _drawTopSegment(
        canvas,
        center,
        startAngle,
        endAngle,
        _getCategoryColor(category, i),
        isHovered,
      );
      
      // 绘制标签
      _drawLabel(
        canvas,
        center,
        category.name,
        (startAngle + endAngle) / 2,
        isHovered,
      );
      
      currentAngle = endAngle;
    }
  }
  
  /// 绘制3D侧面
  void _draw3DSide(
    Canvas canvas,
    Offset center,
    double startAngle,
    double endAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    // 外圆弧侧面
    final outerPath = Path();
    const steps = 20;
    final angleStep = (endAngle - startAngle) / steps;
    
    for (int i = 0; i < steps; i++) {
      final angle1 = startAngle + angleStep * i;
      final angle2 = startAngle + angleStep * (i + 1);
      
      final x1 = center.dx + radius * math.cos(angle1);
      final y1 = center.dy + radius * math.sin(angle1);
      final x2 = center.dx + radius * math.cos(angle2);
      final y2 = center.dy + radius * math.sin(angle2);
      
      outerPath.moveTo(x1, y1);
      outerPath.lineTo(x2, y2);
      outerPath.lineTo(x2, y2 + depth);
      outerPath.lineTo(x1, y1 + depth);
      outerPath.close();
      
      canvas.drawPath(outerPath, paint);
      outerPath.reset();
    }
    
    // 绘制径向侧面
    _drawRadialSides(canvas, center, startAngle, endAngle, color);
  }
  
  /// 绘制径向侧面
  void _drawRadialSides(
    Canvas canvas,
    Offset center,
    double startAngle,
    double endAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    // 起始径向面
    final startPath = Path();
    final startX = center.dx + radius * math.cos(startAngle);
    final startY = center.dy + radius * math.sin(startAngle);
    final innerStartX = center.dx + innerRadius * math.cos(startAngle);
    final innerStartY = center.dy + innerRadius * math.sin(startAngle);
    
    startPath.moveTo(innerStartX, innerStartY);
    startPath.lineTo(startX, startY);
    startPath.lineTo(startX, startY + depth);
    startPath.lineTo(innerStartX, innerStartY + depth);
    startPath.close();
    
    canvas.drawPath(startPath, paint);
    
    // 结束径向面
    final endPath = Path();
    final endX = center.dx + radius * math.cos(endAngle);
    final endY = center.dy + radius * math.sin(endAngle);
    final innerEndX = center.dx + innerRadius * math.cos(endAngle);
    final innerEndY = center.dy + innerRadius * math.sin(endAngle);
    
    endPath.moveTo(innerEndX, innerEndY);
    endPath.lineTo(endX, endY);
    endPath.lineTo(endX, endY + depth);
    endPath.lineTo(innerEndX, innerEndY + depth);
    endPath.close();
    
    canvas.drawPath(endPath, paint);
  }
  
  /// 绘制顶部扇形
  void _drawTopSegment(
    Canvas canvas,
    Offset center,
    double startAngle,
    double endAngle,
    Color color,
    bool isHovered,
  ) {
    final paint = Paint()
      ..color = isHovered ? color : color.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      endAngle - startAngle,
      false,
    );
    path.arcTo(
      Rect.fromCircle(center: center, radius: innerRadius),
      endAngle,
      startAngle - endAngle,
      false,
    );
    path.close();
    
    // 悬停时的阴影效果
    if (isHovered) {
      canvas.drawShadow(path, Colors.black, 10, true);
    }
    
    canvas.drawPath(path, paint);
  }
  
  /// 绘制标签
  void _drawLabel(
    Canvas canvas,
    Offset center,
    String label,
    double angle,
    bool isHovered,
  ) {
    final labelRadius = radius * 0.7;
    final labelPosition = Offset(
      center.dx + labelRadius * math.cos(angle),
      center.dy + labelRadius * math.sin(angle),
    );
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.black,
          fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
          fontSize: isHovered ? 18 : 16,
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
  
  /// 绘制中心圆
  void _drawCenterCircle(Canvas canvas, Offset center) {
    final paint = Paint();
    
    // 背景
    paint.color = canCreateNew 
        ? Colors.black.withOpacity(0.9)
        : Theme.of(canvas.size as BuildContext).cardColor.withOpacity(0.9);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, innerRadius, paint);
    
    // 边框
    paint.color = Theme.of(canvas.size as BuildContext).primaryColor.withOpacity(0.3);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, innerRadius, paint);
    
    // 中心文本
    String centerText;
    Color textColor;
    
    if (canCreateNew) {
      centerText = '创建新分类';
      textColor = Colors.white;
    } else if (hoveredCategory != null && stats.containsKey(hoveredCategory)) {
      centerText = '¥${stats[hoveredCategory]!.toStringAsFixed(0)}';
      textColor = Theme.of(canvas.size as BuildContext).primaryColor;
    } else if (totalAmount > 0) {
      centerText = '¥${totalAmount.toStringAsFixed(0)}';
      textColor = Theme.of(canvas.size as BuildContext).primaryColor;
    } else {
      centerText = isSubCategory ? '选择子分类' : '选择分类';
      textColor = Theme.of(canvas.size as BuildContext).primaryColor;
    }
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: centerText,
        style: TextStyle(
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
  
  /// 绘制创建新分类提示
  void _drawCreateNewHint(Canvas canvas, Offset center) {
    final paint = Paint();
    
    // 呼吸灯效果
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final breathe = 0.7 + 0.3 * math.sin(time * 3.0);
    
    // 多层光环
    for (int i = 0; i < 3; i++) {
      final ringRadius = radius + 40 + (i * 15);
      final opacity = (breathe * (1.0 - i * 0.3)).clamp(0.0, 1.0);
      
      paint.color = Colors.white.withOpacity(opacity * 0.8);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 6 - (i * 2);
      canvas.drawCircle(center, ringRadius, paint);
    }
    
    // 中心高亮
    paint.color = Colors.white.withOpacity(breathe * 0.9);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 25, paint);
  }
  
  /// 获取分类颜色
  Color _getCategoryColor(Category category, int index) {
    if (category.color != null) {
      return Color(category.color!);
    }
    
    // 默认颜色方案
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];
    
    return colors[index % colors.length];
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _CategoryPieChartPainter ||
        oldDelegate.hoveredCategory != hoveredCategory ||
        oldDelegate.canCreateNew != canCreateNew ||
        canCreateNew; // 持续重绘呼吸效果
  }
}