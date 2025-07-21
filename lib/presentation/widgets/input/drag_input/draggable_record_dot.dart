/*
 * 可拖拽记录点组件 (draggable_record_dot.dart)
 * 
 * 功能说明：
 * - 可拖拽的白色圆点
 * - 显示金额和描述
 * - 支持缩放和脉冲动画
 * 
 * 交互设计：
 * - 长按开始拖拽
 * - 拖拽时放大
 * - 呼吸灯效果
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

/// 可拖拽记录点组件
class DraggableRecordDot extends StatelessWidget {
  /// 当前位置
  final Offset position;
  
  /// 金额
  final double amount;
  
  /// 描述
  final String description;
  
  /// 是否正在拖拽
  final bool isDragging;
  
  /// 缩放动画值
  final double scaleValue;
  
  /// 脉冲动画值
  final double pulseValue;
  
  /// 透明度动画值
  final double opacityValue;
  
  /// 拖拽开始回调
  final Function(Offset) onDragStart;
  
  /// 拖拽更新回调
  final Function(Offset) onDragUpdate;
  
  /// 拖拽结束回调
  final VoidCallback onDragEnd;
  
  /// 圆点大小
  final double size;
  
  /// 货币格式化
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'zh_CN',
    symbol: '¥',
    decimalDigits: 2,
  );
  
  DraggableRecordDot({
    Key? key,
    required this.position,
    required this.amount,
    required this.description,
    required this.isDragging,
    required this.scaleValue,
    required this.pulseValue,
    required this.opacityValue,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    this.size = 80,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveScale = scaleValue * pulseValue;
    
    return Positioned(
      left: position.dx - (size * effectiveScale / 2),
      top: position.dy - (size * effectiveScale / 2),
      child: GestureDetector(
        onPanStart: (details) => onDragStart(details.localPosition),
        onPanUpdate: (details) => onDragUpdate(details.globalPosition),
        onPanEnd: (_) => onDragEnd(),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: opacityValue,
          child: Transform.scale(
            scale: effectiveScale,
            child: Container(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 背景光晕
                  if (isDragging) _buildGlow(),
                  
                  // 主圆点
                  _buildMainDot(theme),
                  
                  // 内容
                  _buildContent(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// 构建光晕效果
  Widget _buildGlow() {
    return Container(
      width: size * 1.5,
      height: size * 1.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 40,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
  
  /// 构建主圆点
  Widget _buildMainDot(ThemeData theme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
          if (isDragging)
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
        ],
      ),
    );
  }
  
  /// 构建内容
  Widget _buildContent(ThemeData theme) {
    return ClipOval(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: size - 4,
          height: size - 4,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 金额
              Text(
                _formatAmount(),
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: isDragging ? 14 : 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // 描述
              if (description.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// 格式化金额
  String _formatAmount() {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}万';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}千';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}

/// 拖拽轨迹指示器
class DragTrailIndicator extends StatelessWidget {
  /// 起始位置
  final Offset startPosition;
  
  /// 当前位置
  final Offset currentPosition;
  
  /// 是否显示
  final bool isVisible;
  
  const DragTrailIndicator({
    Key? key,
    required this.startPosition,
    required this.currentPosition,
    required this.isVisible,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _TrailPainter(
        startPosition: startPosition,
        currentPosition: currentPosition,
      ),
    );
  }
}

/// 轨迹绘制器
class _TrailPainter extends CustomPainter {
  final Offset startPosition;
  final Offset currentPosition;
  
  _TrailPainter({
    required this.startPosition,
    required this.currentPosition,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // 绘制虚线
    final path = Path();
    path.moveTo(startPosition.dx, startPosition.dy);
    
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final distance = (currentPosition - startPosition).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();
    
    final dx = (currentPosition.dx - startPosition.dx) / distance;
    final dy = (currentPosition.dy - startPosition.dy) / distance;
    
    for (int i = 0; i < dashCount; i++) {
      final startX = startPosition.dx + (dx * i * (dashWidth + dashSpace));
      final startY = startPosition.dy + (dy * i * (dashWidth + dashSpace));
      final endX = startX + (dx * dashWidth);
      final endY = startY + (dy * dashWidth);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
    
    // 绘制箭头
    final arrowSize = 10.0;
    final angle = math.atan2(
      currentPosition.dy - startPosition.dy,
      currentPosition.dx - startPosition.dx,
    );
    
    final arrowPath = Path();
    arrowPath.moveTo(currentPosition.dx, currentPosition.dy);
    arrowPath.lineTo(
      currentPosition.dx - arrowSize * math.cos(angle - math.pi / 6),
      currentPosition.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    arrowPath.moveTo(currentPosition.dx, currentPosition.dy);
    arrowPath.lineTo(
      currentPosition.dx - arrowSize * math.cos(angle + math.pi / 6),
      currentPosition.dy - arrowSize * math.sin(angle + math.pi / 6),
    );
    
    canvas.drawPath(arrowPath, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _TrailPainter ||
        oldDelegate.startPosition != startPosition ||
        oldDelegate.currentPosition != currentPosition;
  }
}