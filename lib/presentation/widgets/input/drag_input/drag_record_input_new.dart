/*
 * 拖拽记录输入组件（重构版） (drag_record_input_new.dart)
 * 
 * 功能说明：
 * - 整合所有拖拽输入相关组件
 * - 使用新的架构和Provider
 * - 模块化设计，易于维护
 * 
 * 主要改进：
 * - 组件拆分，职责单一
 * - 状态管理集中
 * - 动画控制优化
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

import '../../../../core/domain/entities/transaction.dart';
import '../../../../core/domain/entities/category.dart';
import '../../../providers/transaction_provider_new.dart';
import '../../../providers/category_provider.dart';

import 'drag_record_controller.dart';
import 'category_pie_chart.dart';
import 'draggable_record_dot.dart';
import 'new_category_dialog.dart';

/// 拖拽记录输入组件（重构版）
class DragRecordInputNew extends StatefulWidget {
  /// 交易类型
  final TransactionType type;
  
  /// 金额
  final double amount;
  
  /// 描述
  final String description;
  
  /// 完成回调
  final VoidCallback onComplete;
  
  /// 取消回调
  final VoidCallback onCancel;
  
  const DragRecordInputNew({
    Key? key,
    required this.type,
    required this.amount,
    required this.description,
    required this.onComplete,
    required this.onCancel,
  }) : super(key: key);
  
  @override
  State<DragRecordInputNew> createState() => _DragRecordInputNewState();
}

class _DragRecordInputNewState extends State<DragRecordInputNew>
    with TickerProviderStateMixin {
  late DragRecordController _controller;
  
  @override
  void initState() {
    super.initState();
    
    // 初始化控制器
    _controller = DragRecordController(
      type: widget.type,
      amount: widget.amount,
      description: widget.description,
    );
    
    // 初始化动画
    _controller.initializeAnimations(this);
    
    // 设置初始位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      _controller.setInitialPosition(screenSize);
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer2<CategoryProvider, DragRecordController>(
        builder: (context, categoryProvider, controller, child) {
          // 获取分类数据
          final categories = widget.type == TransactionType.income
              ? categoryProvider.enabledIncomeCategories
              : categoryProvider.enabledExpenseCategories;
          
          return Stack(
            children: [
              // 背景遮罩
              _BackgroundOverlay(
                fadeAnimation: controller.fadeAnimation,
              ),
              
              // 分类图表
              _CategoryChartArea(
                categories: categories,
                controller: controller,
                onCategorySelected: _handleCategorySelected,
                onSubCategorySelected: _handleSubCategorySelected,
              ),
              
              // 操作按钮
              _ActionButtons(
                fadeAnimation: controller.fadeAnimation,
                onCancel: widget.onCancel,
                onBack: controller.isShowingSubCategories
                    ? () => controller.returnToMainCategories()
                    : null,
              ),
              
              // 提示文字
              _HintText(
                fadeAnimation: controller.fadeAnimation,
                isShowingSubCategories: controller.isShowingSubCategories,
                selectedParentCategory: controller.selectedParentCategory,
              ),
              
              // 可拖拽记录点
              AnimatedBuilder(
                animation: Listenable.merge([
                  controller.scaleAnimation,
                  controller.pulseAnimation,
                  controller.fadeAnimation,
                  controller.returnAnimation,
                ]),
                builder: (context, child) {
                  final position = controller.returnController.isAnimating
                      ? controller.returnAnimation.value
                      : controller.recordPosition;
                  
                  return DraggableRecordDot(
                    position: position,
                    amount: widget.amount,
                    description: widget.description,
                    isDragging: controller.isDragging,
                    scaleValue: controller.scaleAnimation.value,
                    pulseValue: controller.pulseAnimation.value,
                    opacityValue: controller.fadeAnimation.value,
                    onDragStart: (localPosition) {
                      controller.startDrag(localPosition);
                    },
                    onDragUpdate: (globalPosition) {
                      controller.updateDragPosition(globalPosition);
                      _checkCategoryHover(globalPosition);
                    },
                    onDragEnd: () {
                      controller.endDrag();
                      _handleDragEnd();
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// 检查分类悬停
  void _checkCategoryHover(Offset position) {
    final screenSize = MediaQuery.of(context).size;
    final center = Offset(screenSize.width / 2, screenSize.height / 2);
    
    // 计算与中心的距离
    final distance = (position - center).distance;
    
    // 计算角度
    final angle = math.atan2(
      position.dy - center.dy,
      position.dx - center.dx,
    );
    
    // 检查是否在圆环范围内
    if (distance >= 80 && distance <= 180) {
      // 根据角度确定悬停的分类
      // TODO: 实现分类检测逻辑
      _controller.updateHoveredCategory(null);
    } else if (distance > 220) {
      // 检查是否可以创建新分类
      _controller.setCanCreateNewCategory(true);
    } else {
      _controller.updateHoveredCategory(null);
      _controller.setCanCreateNewCategory(false);
    }
  }
  
  /// 处理拖拽结束
  void _handleDragEnd() {
    if (_controller.canCreateNewCategory) {
      _showNewCategoryDialog();
    } else if (_controller.hoveredCategory != null) {
      if (_controller.isShowingSubCategories) {
        _handleSubCategorySelected(_controller.hoveredCategory!);
      } else {
        _handleCategorySelected(_controller.hoveredCategory!);
      }
    } else {
      // 返回中心动画
      _controller.triggerReturnAnimation(MediaQuery.of(context).size);
    }
  }
  
  /// 处理分类选择
  void _handleCategorySelected(String categoryName) {
    final categoryProvider = context.read<CategoryProvider>();
    final category = categoryProvider.getCategoryByName(
      categoryName,
      widget.type == TransactionType.income
          ? CategoryType.income
          : CategoryType.expense,
    );
    
    if (category != null && category.subCategories.isNotEmpty) {
      // 显示子分类
      _controller.selectParentCategory(categoryName);
    } else {
      // 直接完成
      _completeTransaction(categoryName, null);
    }
  }
  
  /// 处理子分类选择
  void _handleSubCategorySelected(String subCategoryName) {
    _completeTransaction(
      _controller.selectedParentCategory!,
      subCategoryName,
    );
  }
  
  /// 完成交易创建
  Future<void> _completeTransaction(
    String parentCategory,
    String? subCategory,
  ) async {
    final transactionProvider = context.read<TransactionProviderNew>();
    final categoryProvider = context.read<CategoryProvider>();
    
    // 获取分类信息
    final category = categoryProvider.getCategoryByName(
      parentCategory,
      widget.type == TransactionType.income
          ? CategoryType.income
          : CategoryType.expense,
    );
    
    if (category == null) return;
    
    // 创建交易
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: widget.amount,
      description: widget.description,
      parentCategoryId: category.id,
      parentCategoryName: category.name,
      subCategoryId: subCategory,
      subCategoryName: subCategory,
      date: DateTime.now(),
      createTime: DateTime.now(),
      type: widget.type,
      isArchived: false,
      updatedAt: DateTime.now(),
      notes: null,
      tags: [],
      attachments: [],
      location: null,
      userId: null,
      deviceId: null,
      syncedAt: null,
      metadata: {},
    );
    
    try {
      await transactionProvider.addTransaction(transaction);
      widget.onComplete();
    } catch (e) {
      // 错误处理
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('添加失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// 显示新分类创建对话框
  void _showNewCategoryDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => NewCategoryDialog(
        transactionType: widget.type,
        parentCategory: _controller.isShowingSubCategories
            ? context.read<CategoryProvider>().getCategoryByName(
                _controller.selectedParentCategory!,
                widget.type == TransactionType.income
                    ? CategoryType.income
                    : CategoryType.expense,
              )
            : null,
        isSubCategory: _controller.isShowingSubCategories,
      ),
    );
    
    if (result == true) {
      // 刷新分类数据
      await context.read<CategoryProvider>().loadCategories();
    }
    
    // 返回中心
    _controller.triggerReturnAnimation(MediaQuery.of(context).size);
  }
}

/// 背景遮罩组件
class _BackgroundOverlay extends StatelessWidget {
  final Animation<double> fadeAnimation;
  
  const _BackgroundOverlay({
    required this.fadeAnimation,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: 25.0 * fadeAnimation.value,
            sigmaY: 25.0 * fadeAnimation.value,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3 * fadeAnimation.value),
                  Colors.black.withOpacity(0.5 * fadeAnimation.value),
                  Colors.black.withOpacity(0.7 * fadeAnimation.value),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 分类图表区域
class _CategoryChartArea extends StatelessWidget {
  final List<Category> categories;
  final DragRecordController controller;
  final Function(String) onCategorySelected;
  final Function(String) onSubCategorySelected;
  
  const _CategoryChartArea({
    required this.categories,
    required this.controller,
    required this.onCategorySelected,
    required this.onSubCategorySelected,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        controller.fadeAnimation,
        controller.transitionAnimation,
      ]),
      builder: (context, child) {
        final screenSize = MediaQuery.of(context).size;
        
        return Positioned.fill(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: controller.isShowingSubCategories
                  ? _buildSubCategoryChart(screenSize)
                  : _buildMainCategoryChart(screenSize),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildMainCategoryChart(Size screenSize) {
    return Opacity(
      opacity: controller.fadeAnimation.value,
      child: CategoryPieChart(
        categories: categories,
        stats: {}, // TODO: 传入实际统计数据
        type: controller.type,
        hoveredCategory: controller.hoveredCategory,
        canCreateNew: controller.canCreateNewCategory,
        totalAmount: 0,
      ),
    );
  }
  
  Widget _buildSubCategoryChart(Size screenSize) {
    final parentCategory = categories.firstWhere(
      (cat) => cat.name == controller.selectedParentCategory,
    );
    
    return Opacity(
      opacity: controller.transitionAnimation.value,
      child: CategoryPieChart(
        categories: parentCategory.subCategories
            .map((sub) => Category(
                  id: sub.id,
                  name: sub.name,
                  icon: sub.icon,
                  color: parentCategory.color,
                  type: parentCategory.type,
                  isSystem: false,
                  isEnabled: true,
                  subCategories: [],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  userId: null,
                  usageCount: 0,
                ))
            .toList(),
        stats: {}, // TODO: 传入实际统计数据
        type: controller.type,
        hoveredCategory: controller.hoveredCategory,
        canCreateNew: false,
        totalAmount: 0,
        isSubCategory: true,
        parentCategory: controller.selectedParentCategory,
      ),
    );
  }
}

/// 操作按钮组件
class _ActionButtons extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final VoidCallback onCancel;
  final VoidCallback? onBack;
  
  const _ActionButtons({
    required this.fadeAnimation,
    required this.onCancel,
    this.onBack,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Opacity(
            opacity: fadeAnimation.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 返回/取消按钮
                IconButton(
                  onPressed: onBack ?? onCancel,
                  icon: Icon(
                    onBack != null ? Icons.arrow_back : Icons.close,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                  ),
                ),
                
                // 帮助按钮
                IconButton(
                  onPressed: () {
                    // TODO: 显示帮助信息
                  },
                  icon: const Icon(
                    Icons.help_outline,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 提示文字组件
class _HintText extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final bool isShowingSubCategories;
  final String? selectedParentCategory;
  
  const _HintText({
    required this.fadeAnimation,
    required this.isShowingSubCategories,
    this.selectedParentCategory,
  });
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 100,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: fadeAnimation.value * 0.8,
            child: Column(
              children: [
                Text(
                  isShowingSubCategories
                      ? '选择子分类 - $selectedParentCategory'
                      : '拖动到分类区域',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isShowingSubCategories
                      ? '拖动到子分类完成记录'
                      : '拖动到圆环外创建新分类',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}