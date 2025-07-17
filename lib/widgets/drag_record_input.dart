/*
 * 拖拽记录输入组件 (drag_record_input.dart)
 * 
 * 功能说明：
 * - 提供拖拽式交易记录输入界面
 * - 支持分类选择和新分类创建
 * - 包含背景模糊和动画效果
 * 
 * 相关修改位置：
 * - 修改4：拖拽取消动画 - 回归中心动画和圆心遮挡处理 (第648-688行区域)
 * - 修改5：拖拽定位精度 - 精确角度计算算法 (第689-703行区域)
 * - 使用独立的enhanced_pie_chart.dart组件进行图表绘制
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/transaction_record_hive.dart';
import '../providers/transaction_provider.dart';
import '../constants/app_constants.dart';
import 'enhanced_pie_chart.dart';

class DragRecordInput extends StatefulWidget {
  final TransactionType type;
  final double amount;
  final String description;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const DragRecordInput({
    Key? key,
    required this.type,
    required this.amount,
    required this.description,
    required this.onComplete,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<DragRecordInput> createState() => _DragRecordInputState();
}

class _DragRecordInputState extends State<DragRecordInput>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _transitionController;
  late AnimationController _pulseController;
  late AnimationController _returnController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _transitionAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _returnAnimation;

  Offset _recordPosition = Offset.zero;
  bool _isDragging = false;
  bool _isShowingSubCategories = false;
  String? _selectedParentCategory;
  String? _hoveredCategory;
  bool _canCreateNewCategory = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializePosition();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppConstants.animationSlow,  // 600ms 丝滑过渡
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: AppConstants.animationMedium,  // 400ms 缩放动画
      vsync: this,
    );
    
    _transitionController = AnimationController(
      duration: AppConstants.animationSlow,  // 600ms 分类切换
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),  // 更慢的脉冲动画
      vsync: this,
    );

    _returnController = AnimationController(
      duration: AppConstants.animationSlow,  // 600ms 回归动画
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: AppConstants.curveSmooth),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _scaleController, curve: AppConstants.curveSmooth),
    );
    
    _transitionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: AppConstants.curveSmooth),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: AppConstants.curveSmooth),
    );

    _returnAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _returnController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _initializePosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _recordPosition = Offset(
          screenSize.width / 2,
          screenSize.height - 150,
        );
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _transitionController.dispose();
    _pulseController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            // 背景遮罩
            _buildBackgroundOverlay(),
            
            // 环状图分类区域
            _buildCategoryChart(provider),
            
            // 可拖拽的记录单元
            _buildDraggableRecord(),
            
            // 操作按钮
            _buildActionButtons(),
            
            // 提示信息
            _buildHintText(),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundOverlay() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppConstants.primaryGradient[0].withOpacity((_isDragging ? 0.1 : 0.3) * _fadeAnimation.value),
                AppConstants.primaryGradient[1].withOpacity((_isDragging ? 0.2 : 0.5) * _fadeAnimation.value),
                Colors.black.withOpacity((_isDragging ? 0.4 : 0.7) * _fadeAnimation.value),
              ],
            ),
          ),
          child: Stack(
            children: [
              // 背景模糊效果 - 初始就有，拖拽时消失
              if (!_isDragging)
                BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: 15.0 * _fadeAnimation.value,
                    sigmaY: 15.0 * _fadeAnimation.value,
                  ),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChart(TransactionProvider provider) {
    return AnimatedBuilder(
      animation: _transitionAnimation,
      builder: (context, child) {
        if (!_isShowingSubCategories) {
          return _buildMainCategoryChart(provider);
        } else {
          return _buildSubCategoryChart(provider);
        }
      },
    );
  }

  Widget _buildMainCategoryChart(TransactionProvider provider) {
    final categories = provider.getAllCategories(widget.type);
    final categoryNames = categories.map((c) => c.name).toList();
    final stats = provider.getCategoryStats(widget.type);
    final totalAmount = stats.values.fold(0.0, (sum, value) => sum + value);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 标题
          _buildChartTitle('选择分类', totalAmount),
          
          const SizedBox(height: AppConstants.spacingXLarge),
          
          // 环状图
          Container(
            width: AppConstants.pieChartSize,
            height: AppConstants.pieChartSize,
            child: CustomPaint(
              painter: EnhancedPieChartPainter(
                categories: categoryNames,
                stats: stats,
                type: widget.type,
                hoveredCategory: _hoveredCategory,
                totalAmount: totalAmount,
                canCreateNew: _canCreateNewCategory,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryChart(TransactionProvider provider) {
    if (_selectedParentCategory == null) return Container();
    
    final subCategories = provider.getSubCategories(_selectedParentCategory!, widget.type);
    final subCategoryNames = subCategories.map((s) => s.name).toList();
    final stats = provider.getSubCategoryStats(_selectedParentCategory!, widget.type);
    final totalAmount = stats.values.fold(0.0, (sum, value) => sum + value);

    return AnimatedBuilder(
      animation: _transitionAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _transitionAnimation.value,
          child: Opacity(
            opacity: _transitionAnimation.value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 标题
                  _buildChartTitle(_selectedParentCategory!, totalAmount),
                  
                  const SizedBox(height: AppConstants.spacingXLarge),
                  
                  // 子分类环状图
                  Container(
                    width: AppConstants.pieChartSize,
                    height: AppConstants.pieChartSize,
                    child: CustomPaint(
                      painter: EnhancedSubCategoryPieChartPainter(
                        subCategories: subCategoryNames,
                        stats: stats,
                        parentCategory: _selectedParentCategory!,
                        type: widget.type,
                        hoveredCategory: _hoveredCategory,
                        totalAmount: totalAmount,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChartTitle(String title, double amount) {
    return Column(
      children: [
        Text(
          title,
          style: AppConstants.headingStyle.copyWith(
            color: AppConstants.cardColor,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        if (amount > 0)
          Text(
            '总计: ¥${amount.toStringAsFixed(2)}',
            style: AppConstants.bodyStyle.copyWith(
              color: AppConstants.cardColor.withOpacity(0.8),
            ),
          ),
      ],
    );
  }

  Widget _buildDraggableRecord() {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _pulseAnimation, _returnAnimation]),
      builder: (context, child) {
        final currentPosition = _returnController.isAnimating 
            ? _returnAnimation.value 
            : _recordPosition;
        
        return Positioned(
          left: currentPosition.dx - AppConstants.dragRecordSize / 2,
          top: currentPosition.dy - AppConstants.dragRecordSize / 2,
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Transform.scale(
              scale: _scaleAnimation.value * _pulseAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 外层光芒效果
                  if (_isDragging) ...[
                    Container(
                      width: AppConstants.dragRecordSize * 1.8,
                      height: AppConstants.dragRecordSize * 1.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.7, 1.0],
                        ),
                      ),
                    ),
                    Container(
                      width: AppConstants.dragRecordSize * 1.4,
                      height: AppConstants.dragRecordSize * 1.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                  // 主要圆点
                  Container(
                    width: AppConstants.dragRecordSize,
                    height: AppConstants.dragRecordSize,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.8),
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.6),
                          blurRadius: _isDragging ? 25 : 15,
                          offset: const Offset(0, 0),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getRecordIcon(),
                          color: _getRecordColor(),
                          size: AppConstants.iconMedium,
                        ),
                        const SizedBox(height: AppConstants.spacingXSmall),
                        Text(
                          '¥${widget.amount.toStringAsFixed(0)}',
                          style: AppConstants.captionStyle.copyWith(
                            color: _getRecordColor(),
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      top: 50,
      right: 20,
      child: Row(
        children: [
          if (_isShowingSubCategories)
            _buildActionButton(
              icon: Icons.arrow_back,
              onPressed: _goBackToMainCategories,
              tooltip: AppConstants.buttonBack,
            ),
          const SizedBox(width: AppConstants.spacingMedium),
          _buildActionButton(
            icon: Icons.close,
            onPressed: widget.onCancel,
            tooltip: AppConstants.buttonCancel,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppConstants.cardColor.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: AppConstants.shadowMedium,
        ),
        child: IconButton(
          icon: Icon(icon, color: AppConstants.primaryColor),
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildHintText() {
    String hintText = AppConstants.hintDragToCategory;
    if (_canCreateNewCategory) {
      hintText = AppConstants.hintDragToCreateCategory;
    }
    
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _isDragging ? 1.0 : 0.7,
        duration: AppConstants.animationFast,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLarge),
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppConstants.cardGradient,
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
            boxShadow: AppConstants.shadowMedium,
            border: Border.all(
              color: AppConstants.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            hintText,
            style: AppConstants.bodyStyle.copyWith(
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
    _scaleController.forward();
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _recordPosition = details.globalPosition;
    });
    _checkHover();
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    _scaleController.reverse();
    _handleDrop();
  }

  void _checkHover() {
    final center = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );
    
    final distance = (_recordPosition - center).distance;
    
    if (distance > AppConstants.pieChartRadius + 60) {
      // 在环外，可以创建新分类
      setState(() {
        _hoveredCategory = null;
        _canCreateNewCategory = true;
      });
    } else if (distance > AppConstants.pieChartCenterRadius && distance <= AppConstants.pieChartRadius + 40) {
      // 在环状图区域内（包括悬停扩展区域）
      final angle = math.atan2(
        _recordPosition.dy - center.dy,
        _recordPosition.dx - center.dx,
      );
      
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      
      if (_isShowingSubCategories) {
        final subCategories = provider.getSubCategories(_selectedParentCategory!, widget.type);
        final categoryNames = subCategories.map((s) => s.name).toList();
        
        if (categoryNames.isNotEmpty) {
          final categoryIndex = _calculateCategoryIndex(angle, categoryNames.length);
          // 添加范围检查
          if (categoryIndex >= 0 && categoryIndex < categoryNames.length) {
            setState(() {
              _hoveredCategory = categoryNames[categoryIndex];
              _canCreateNewCategory = false;
            });
          }
        }
      } else {
        final categories = provider.getAllCategories(widget.type);
        final categoryNames = categories.map((c) => c.name).toList();
        
        if (categoryNames.isNotEmpty) {
          final categoryIndex = _calculateCategoryIndex(angle, categoryNames.length);
          // 添加范围检查
          if (categoryIndex >= 0 && categoryIndex < categoryNames.length) {
            setState(() {
              _hoveredCategory = categoryNames[categoryIndex];
              _canCreateNewCategory = false;
            });
          }
        }
      }
    } else {
      // 在中心区域
      setState(() {
        _hoveredCategory = null;
        _canCreateNewCategory = false;
      });
    }
  }

  void _handleDrop() {
    if (_hoveredCategory != null) {
      if (_isShowingSubCategories) {
        // 在子分类中，直接完成记录
        _completeRecord(_selectedParentCategory!, _hoveredCategory!);
      } else {
        // 在主分类中，检查是否有子分类
        final provider = Provider.of<TransactionProvider>(context, listen: false);
        final subCategories = provider.getSubCategories(_hoveredCategory!, widget.type);
        
        if (subCategories.isNotEmpty) {
          // 有子分类，跳转到子分类选择
          _showSubCategories(_hoveredCategory!);
        } else {
          // 没有子分类，直接完成记录
          _completeRecord(_hoveredCategory!, null);
        }
      }
    } else if (_canCreateNewCategory) {
      _showCreateCategoryDialog();
    }
    
    // 重置状态
    setState(() {
      _hoveredCategory = null;
      _canCreateNewCategory = false;
    });
  }

  void _showSubCategories(String parentCategory) {
    setState(() {
      _selectedParentCategory = parentCategory;
      _isShowingSubCategories = true;
    });
    _transitionController.forward();
    HapticFeedback.selectionClick();
  }

  void _goBackToMainCategories() {
    _transitionController.reverse().then((_) {
      setState(() {
        _isShowingSubCategories = false;
        _selectedParentCategory = null;
      });
    });
    HapticFeedback.selectionClick();
  }

  void _completeRecord(String parentCategory, String? subCategory) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    
    final record = TransactionRecord.create(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: widget.amount,
      type: widget.type,
      parentCategory: parentCategory,
      subCategory: subCategory ?? 'default',
      description: widget.description,
      date: DateTime.now(),
      isArchived: true,
    );
    
    provider.addTransaction(record);
    
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppConstants.successTransactionSaved),
        backgroundColor: AppConstants.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
    
    widget.onComplete();
  }

  void _showCreateCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateCategoryDialog(
        type: widget.type,
        onCategoryCreated: (category) {
          // 创建大类后，进入子分类选择
          _showSubCategories(category);
        },
      ),
    ).then((result) {
      // 如果对话框被取消，触发回归动画
      if (result == null) {
        _animateReturnToCenter();
      }
    });
  }

  void _animateReturnToCenter() {
    final screenSize = MediaQuery.of(context).size;
    final centerPosition = Offset(
      screenSize.width / 2,
      screenSize.height - 150,
    );
    
    _returnAnimation = Tween<Offset>(
      begin: _recordPosition,
      end: centerPosition,
    ).animate(CurvedAnimation(
      parent: _returnController,
      curve: Curves.easeInOut,
    ));

    _returnController.forward().then((_) {
      setState(() {
        _recordPosition = centerPosition;
      });
      _returnController.reset();
    });
  }

  int _calculateCategoryIndex(double angle, int categoryCount) {
    // 绘制时从-π/2开始，需要与此保持一致
    // 将角度标准化到[0, 2π]范围
    double normalizedAngle = (angle + math.pi / 2 + 2 * math.pi) % (2 * math.pi);
    
    // 计算角度步长
    final angleStep = 2 * math.pi / categoryCount;
    
    // 计算最接近的分类索引
    // 由于我们从-π/2开始绘制，第一个分类在顶部
    int categoryIndex = (normalizedAngle / angleStep).round() % categoryCount;
    
    // 确保索引在有效范围内
    if (categoryIndex < 0) categoryIndex += categoryCount;
    if (categoryIndex >= categoryCount) categoryIndex -= categoryCount;
    
    return categoryIndex;
  }

  Color _getRecordColor() {
    return widget.type == TransactionType.income
        ? AppConstants.incomeColor
        : AppConstants.expenseColor;
  }

  IconData _getRecordIcon() {
    return widget.type == TransactionType.income
        ? Icons.add_circle
        : Icons.remove_circle;
  }
}

// 增强的饼状图绘制器
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

  void _drawCategorySegments(Canvas canvas, Offset center, double radius, double innerRadius) {
    final paint = Paint()..style = PaintingStyle.fill;
    
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

// 子分类饼状图绘制器
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

// 创建分类对话框
class CreateCategoryDialog extends StatefulWidget {
  final TransactionType type;
  final Function(String) onCategoryCreated;

  const CreateCategoryDialog({
    Key? key,
    required this.type,
    required this.onCategoryCreated,
  }) : super(key: key);

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '创建新分类',
        style: AppConstants.titleStyle.copyWith(
          color: AppConstants.primaryColor,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: '输入分类名称',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                borderSide: BorderSide(color: AppConstants.primaryColor),
              ),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppConstants.buttonCancel,
            style: AppConstants.bodyStyle.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createCategory,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: AppConstants.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppConstants.cardColor),
                  ),
                )
              : Text(AppConstants.buttonCreate),
        ),
      ],
    );
  }

  void _createCategory() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      
      // 创建新的分类
      final category = Category.create(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        color: AppConstants.categoryColors[0].value,
        icon: Icons.category.codePoint.toString(),
        type: widget.type,
        subCategories: [
          SubCategory.create(
            name: 'default',
            icon: Icons.category.codePoint.toString(),
          ),
        ],
      );
      
      await provider.addCustomCategory(category);
      
      widget.onCategoryCreated(name);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.errorCategorySave),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 