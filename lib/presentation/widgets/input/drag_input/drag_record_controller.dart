/*
 * 拖拽记录控制器 (drag_record_controller.dart)
 * 
 * 功能说明：
 * - 管理拖拽输入的状态和逻辑
 * - 处理动画控制
 * - 协调各个组件
 * 
 * 设计模式：
 * - 状态管理分离
 * - 动画控制集中管理
 */

import 'package:flutter/material.dart';
import '../../../../core/domain/entities/transaction.dart';

/// 拖拽记录控制器
/// 
/// 集中管理拖拽输入的状态和动画
class DragRecordController extends ChangeNotifier {
  /// 交易类型
  final TransactionType type;
  
  /// 金额
  final double amount;
  
  /// 描述
  final String description;
  
  /// 记录位置
  Offset _recordPosition = Offset.zero;
  
  /// 拖拽偏移量
  Offset? _dragOffset;
  
  /// 是否正在拖拽
  bool _isDragging = false;
  
  /// 是否显示子分类
  bool _isShowingSubCategories = false;
  
  /// 选中的父分类
  String? _selectedParentCategory;
  
  /// 悬停的分类
  String? _hoveredCategory;
  
  /// 是否可以创建新分类
  bool _canCreateNewCategory = false;
  
  /// 动画控制器
  late AnimationController fadeController;
  late AnimationController scaleController;
  late AnimationController transitionController;
  late AnimationController pulseController;
  late AnimationController returnController;
  
  /// 动画
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> transitionAnimation;
  late Animation<double> pulseAnimation;
  late Animation<Offset> returnAnimation;
  
  DragRecordController({
    required this.type,
    required this.amount,
    required this.description,
  });
  
  // Getters
  Offset get recordPosition => _recordPosition;
  Offset? get dragOffset => _dragOffset;
  bool get isDragging => _isDragging;
  bool get isShowingSubCategories => _isShowingSubCategories;
  String? get selectedParentCategory => _selectedParentCategory;
  String? get hoveredCategory => _hoveredCategory;
  bool get canCreateNewCategory => _canCreateNewCategory;
  
  /// 初始化动画控制器
  void initializeAnimations(TickerProvider vsync) {
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );
    
    scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );
    
    transitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );
    
    pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );
    
    returnController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );
    
    // 初始化动画
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: fadeController, curve: Curves.easeInOut),
    );
    
    scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.easeInOut),
    );
    
    transitionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: transitionController, curve: Curves.easeInOut),
    );
    
    pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );
    
    returnAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: returnController, curve: Curves.easeInOut),
    );
    
    // 启动初始动画
    fadeController.forward();
    pulseController.repeat(reverse: true);
  }
  
  /// 设置初始位置
  void setInitialPosition(Size screenSize) {
    _recordPosition = Offset(
      screenSize.width / 2,
      screenSize.height / 2,
    );
    notifyListeners();
  }
  
  /// 开始拖拽
  void startDrag(Offset localPosition) {
    _isDragging = true;
    _dragOffset = localPosition;
    scaleController.forward();
    notifyListeners();
  }
  
  /// 更新拖拽位置
  void updateDragPosition(Offset globalPosition) {
    if (_isDragging && _dragOffset != null) {
      _recordPosition = globalPosition - _dragOffset!;
      notifyListeners();
    }
  }
  
  /// 结束拖拽
  void endDrag() {
    _isDragging = false;
    _dragOffset = null;
    scaleController.reverse();
    notifyListeners();
  }
  
  /// 更新悬停分类
  void updateHoveredCategory(String? category) {
    if (_hoveredCategory != category) {
      _hoveredCategory = category;
      notifyListeners();
    }
  }
  
  /// 选择父分类
  void selectParentCategory(String category) {
    _selectedParentCategory = category;
    _isShowingSubCategories = true;
    transitionController.forward();
    notifyListeners();
  }
  
  /// 返回主分类
  void returnToMainCategories() {
    _isShowingSubCategories = false;
    _selectedParentCategory = null;
    transitionController.reverse();
    notifyListeners();
  }
  
  /// 设置是否可以创建新分类
  void setCanCreateNewCategory(bool canCreate) {
    if (_canCreateNewCategory != canCreate) {
      _canCreateNewCategory = canCreate;
      notifyListeners();
    }
  }
  
  /// 触发返回动画
  void triggerReturnAnimation(Size screenSize) {
    final centerPosition = Offset(
      screenSize.width / 2,
      screenSize.height / 2,
    );
    
    returnAnimation = Tween<Offset>(
      begin: _recordPosition,
      end: centerPosition,
    ).animate(
      CurvedAnimation(parent: returnController, curve: Curves.easeInOut),
    );
    
    returnController.forward(from: 0.0).then((_) {
      _recordPosition = centerPosition;
      notifyListeners();
    });
  }
  
  /// 释放资源
  @override
  void dispose() {
    fadeController.dispose();
    scaleController.dispose();
    transitionController.dispose();
    pulseController.dispose();
    returnController.dispose();
    super.dispose();
  }
}