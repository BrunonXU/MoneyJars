/*
 * 手势处理组件 (gesture_handler.dart)
 * 
 * 功能说明：
 * - 处理主屏幕的滑动手势检测
 * - 管理拖拽状态和累积距离计算
 * - 提供精确的手势识别和回调机制
 * 
 * 相关修改位置：
 * - 修改1：滑动手感问题 - 累积距离检测和手势处理的核心实现
 * - 从 home_screen.dart 中拆分出来的手势处理逻辑
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 回调函数类型
typedef SwipeCallback = void Function();

class GestureHandler {
  // 修改1：滑动手感问题 - 手势状态管理
  double _accumulatedDelta = 0.0;
  bool _isDragging = false;
  Offset? _startPosition;
  
  // 手势阈值配置 - 降低阈值提高滑动灵敏度
  static const double _swipeThreshold = 40.0; // 优化后的灵敏阈值，提升手感
  
  void reset() {
    _accumulatedDelta = 0.0;
    _isDragging = false;
    _startPosition = null;
  }
  
  bool get isDragging => _isDragging;
  double get accumulatedDelta => _accumulatedDelta;
  
  // 修改1：滑动手感问题 - 拖拽开始处理
  void handlePanStart(DragStartDetails details, {required bool isInputMode}) {
    if (!isInputMode) {
      _isDragging = true;
      _accumulatedDelta = 0.0;
      _startPosition = details.globalPosition;
    }
  }
  
  // 修改1：滑动手感问题 - 拖拽更新处理，使用累积距离检测
  // 关键修复：任何页面都可以滑动触发记录模式
  void handlePanUpdate(
    DragUpdateDetails details, {
    required bool isInputMode,
    required int currentPage,
    SwipeCallback? onExpenseSwipe,
    SwipeCallback? onIncomeSwipe,
  }) {
    if (!isInputMode && _isDragging) {
      final delta = details.delta.dy;
      _accumulatedDelta += delta;
      
      // 修复：任何页面都支持向下滑动进入支出记录
      if (_accumulatedDelta > _swipeThreshold) {
        onExpenseSwipe?.call();
        reset();
      }
      // 修复：任何页面都支持向上滑动进入收入记录  
      else if (_accumulatedDelta < -_swipeThreshold) {
        onIncomeSwipe?.call();
        reset();
      }
    }
  }
  
  // 修改1：滑动手感问题 - 拖拽结束处理
  void handlePanEnd(DragEndDetails details) {
    reset();
  }
  
  // 触觉反馈辅助方法
  static void provideLightFeedback() {
    HapticFeedback.lightImpact();
  }
  
  static void provideSelectionFeedback() {
    HapticFeedback.selectionClick();
  }
  
  static void provideMediumFeedback() {
    HapticFeedback.mediumImpact();
  }
  
  static void provideHeavyFeedback() {
    HapticFeedback.heavyImpact();
  }
}

// 手势检测Widget包装器
class SwipeDetector extends StatelessWidget {
  final Widget child;
  final GestureHandler gestureHandler;
  final bool isInputMode;
  final int currentPage;
  final VoidCallback? onExpenseSwipe;
  final VoidCallback? onIncomeSwipe;
  final VoidCallback? onTap;

  const SwipeDetector({
    Key? key,
    required this.child,
    required this.gestureHandler,
    required this.isInputMode,
    required this.currentPage,
    this.onExpenseSwipe,
    this.onIncomeSwipe,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => gestureHandler.handlePanStart(
        details,
        isInputMode: isInputMode,
      ),
      onPanUpdate: (details) => gestureHandler.handlePanUpdate(
        details,
        isInputMode: isInputMode,
        currentPage: currentPage,
        onExpenseSwipe: onExpenseSwipe,
        onIncomeSwipe: onIncomeSwipe,
      ),
      onPanEnd: gestureHandler.handlePanEnd,
      onTap: onTap,
      child: child,
    );
  }
} 