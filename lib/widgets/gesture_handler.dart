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
  
  // 手势阈值配置
  static const double _swipeThreshold = 80.0; // 增加阈值要求更明显的滑动
  
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
      
      if (currentPage == 0 && _accumulatedDelta > _swipeThreshold) {
        // 支出罐头，向下滑动进入输入模式
        onExpenseSwipe?.call();
        reset();
      } else if (currentPage == 2 && _accumulatedDelta < -_swipeThreshold) {
        // 收入罐头，向上滑动进入输入模式
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