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
import '../utils/modern_ui_styles.dart';

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
  Offset? _dragOffset; // 手指相对于白点中心的偏移量
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
        // 白色圆点出现在整个屏幕的中心
        _recordPosition = Offset(
          screenSize.width / 2,
          screenSize.height / 2,
        );
      });
      
      // 启动呼吸动画
      _pulseController.repeat(reverse: true);
      _fadeController.forward();
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
            // 背景遮罩 - 毛玻璃效果遮挡一切
            _buildBackgroundOverlay(),
            
            // 环状图分类区域
            _buildCategoryChart(provider),
            
            // 操作按钮
            _buildActionButtons(),
            
            // 提示信息
            _buildHintText(),
            
            // 可拖拽的记录单元 - 最高层，永远可见
            _buildDraggableRecord(),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundOverlay() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // 全屏毛玻璃蒙版 - 遮挡所有背景内容
            BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 25.0 * _fadeAnimation.value,
                sigmaY: 25.0 * _fadeAnimation.value,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3 * _fadeAnimation.value),
                      Colors.black.withOpacity(0.5 * _fadeAnimation.value),
                      Colors.black.withOpacity(0.7 * _fadeAnimation.value),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
      // 计算手指相对于白点中心的偏移量
      _dragOffset = details.globalPosition - _recordPosition;
    });
    _scaleController.forward();
    _pulseController.stop(); // 停止呼吸动画
    HapticFeedback.lightImpact();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      // 白点位置 = 手指位置 - 初始偏移量，确保平滑跟随
      if (_dragOffset != null) {
        _recordPosition = details.globalPosition - _dragOffset!;
      }
    });
    _checkHover(); // 实时检测悬停分类
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    _scaleController.reverse();
    _pulseController.repeat(reverse: true); // 恢复呼吸动画
    _handleDrop();
  }

  void _checkHover() {
    final center = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height / 2,
    );
    
    final distance = (_recordPosition - center).distance;
    
    if (distance > AppConstants.pieChartRadius + 30) { // 减少识别范围，提高精度
      // 在环外，可以创建新分类
      setState(() {
        _hoveredCategory = null;
        _canCreateNewCategory = true;
      });
    } else if (distance > AppConstants.pieChartCenterRadius && distance <= AppConstants.pieChartRadius + 20) { // 更精确的识别范围
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
      
      // 简单2D白色块
      _draw2DSegment(canvas, center, currentRadius, innerRadius, startAngle, angleStep, isHovered);
      
      // 绘制分类标签 - 黑色字体
      _drawCategoryLabel(canvas, center, category, startAngle + angleStep / 2, currentRadius, 
          Colors.black); // 始终黑色字体
      
      startAngle += angleStep;
    }
  }

  void _draw3DSegment(Canvas canvas, Offset center, double radius, double innerRadius, 
      double startAngle, double angleStep, Color color, bool isHighlighted) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // 3D芝士蛋糕效果：绘制垂直厚度
    const double depth = 12.0; // 3D厚度
    
    // 1. 底部阴影（更深的阴影模拟立体效果）
    canvas.save();
    canvas.translate(4, 8); // 更明显的阴影偏移
    paint.color = Colors.black.withOpacity(0.4);
    final shadowRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(shadowRect, startAngle, angleStep, true, paint);
    
    // 清除内圆阴影
    paint.color = Colors.transparent;
    paint.blendMode = BlendMode.clear;
    canvas.drawCircle(center, innerRadius, paint);
    paint.blendMode = BlendMode.srcOver;
    canvas.restore();
    
    // 2. 绘制侧面（垂直边缘）
    _draw3DSides(canvas, center, radius, innerRadius, startAngle, angleStep, color, depth);
    
    // 3. 顶面渐变（芝士蛋糕的顶层效果）
    final topGradient = RadialGradient(
      center: Alignment(-0.3, -0.3), // 光源从左上角照射
      radius: 1.2,
      colors: [
        Color.lerp(color, Colors.white, 0.4)!, // 高光区域
        color, // 中间色调
        Color.lerp(color, Colors.black, 0.2)!, // 阴影区域
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    
    paint.shader = topGradient.createShader(
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
    
    // 4. 高光效果（增强立体感）
    if (isHighlighted) {
      // 外边缘高光
      paint.color = Colors.white.withOpacity(0.6);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 4;
      canvas.drawArc(rect, startAngle, angleStep, false, paint);
      
      // 内侧柔和高光
      paint.strokeWidth = 2;
      paint.color = Colors.white.withOpacity(0.3);
      final innerHighlightRect = Rect.fromCircle(center: center, radius: radius * 0.9);
      canvas.drawArc(innerHighlightRect, startAngle, angleStep, false, paint);
      
      // 顶面额外光泽
      paint.style = PaintingStyle.fill;
      paint.color = Colors.white.withOpacity(0.2);
      final highlightRect = Rect.fromCircle(center: center, radius: radius * 0.7);
      canvas.drawArc(highlightRect, startAngle, angleStep, true, paint);
    }
    
    paint.style = PaintingStyle.fill;
  }

  /// 绘制简单2D白色扇形
  void _draw2DSegment(Canvas canvas, Offset center, double radius, double innerRadius, 
      double startAngle, double angleStep, bool isHighlighted) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // 纯白色填充
    paint.color = Colors.white;
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, angleStep, true, paint);
    
    // 清除内圆
    paint.color = Colors.transparent;
    paint.blendMode = BlendMode.clear;
    canvas.drawCircle(center, innerRadius, paint);
    paint.blendMode = BlendMode.srcOver;
    
    // 悬停时的边框高光
    if (isHighlighted) {
      paint.color = Colors.black.withOpacity(0.3);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawArc(rect, startAngle, angleStep, false, paint);
    }
    
    paint.style = PaintingStyle.fill;
  }
  
  /// 绘制3D侧面，营造芝士蛋糕的厚度效果
  void _draw3DSides(Canvas canvas, Offset center, double radius, double innerRadius, 
      double startAngle, double angleStep, Color color, double depth) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // 计算扇形的起点和终点
    final startX = center.dx + radius * math.cos(startAngle);
    final startY = center.dy + radius * math.sin(startAngle);
    final endAngle = startAngle + angleStep;
    final endX = center.dx + radius * math.cos(endAngle);
    final endY = center.dy + radius * math.sin(endAngle);
    
    // 内圆的对应点
    final innerStartX = center.dx + innerRadius * math.cos(startAngle);
    final innerStartY = center.dy + innerRadius * math.sin(startAngle);
    final innerEndX = center.dx + innerRadius * math.cos(endAngle);
    final innerEndY = center.dy + innerRadius * math.sin(endAngle);
    
    // 侧面颜色（比顶面暗一些）
    final sideColor = Color.lerp(color, Colors.black, 0.3)!;
    
    // 绘制外弧的侧面
    final outerPath = Path();
    outerPath.moveTo(startX, startY);
    outerPath.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, angleStep, false
    );
    outerPath.lineTo(endX, endY + depth);
    outerPath.arcTo(
      Rect.fromCircle(center: Offset(center.dx, center.dy + depth), radius: radius),
      endAngle, -angleStep, false
    );
    outerPath.close();
    
    paint.color = sideColor;
    canvas.drawPath(outerPath, paint);
    
    // 绘制径向侧面（如果可见）
    if (angleStep < math.pi) { // 只在扇形小于半圆时绘制径向侧面
      // 起始径向面
      final startRadialPath = Path();
      startRadialPath.moveTo(innerStartX, innerStartY);
      startRadialPath.lineTo(startX, startY);
      startRadialPath.lineTo(startX, startY + depth);
      startRadialPath.lineTo(innerStartX, innerStartY + depth);
      startRadialPath.close();
      
      paint.color = Color.lerp(sideColor, Colors.black, 0.2)!;
      canvas.drawPath(startRadialPath, paint);
      
      // 结束径向面
      final endRadialPath = Path();
      endRadialPath.moveTo(innerEndX, innerEndY);
      endRadialPath.lineTo(endX, endY);
      endRadialPath.lineTo(endX, endY + depth);
      endRadialPath.lineTo(innerEndX, innerEndY + depth);
      endRadialPath.close();
      
      canvas.drawPath(endRadialPath, paint);
    }
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
          color: color, // 使用传入的颜色，现在是黑色
          fontWeight: FontWeight.bold,
          fontSize: (AppConstants.captionStyle.fontSize ?? 12) * 1.4, // 字体放大40%
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
      
      // 简单2D白色块
      _draw2DSegment(canvas, center, currentRadius, innerRadius, startAngle, angleStep, isHovered);
      
      // 绘制子分类标签 - 黑色字体
      _drawSubCategoryLabel(canvas, center, subCategory, startAngle + angleStep / 2, currentRadius, Colors.black);
      
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
          color: color, // 使用传入的颜色，现在是黑色
          fontWeight: FontWeight.bold,
          fontSize: 11 * 1.4, // 字体放大40%
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

  /// 绘制简单2D白色扇形（子分类版本）
  void _draw2DSegment(Canvas canvas, Offset center, double radius, double innerRadius, 
      double startAngle, double angleStep, bool isHighlighted) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // 纯白色填充
    paint.color = Colors.white;
    
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, angleStep, true, paint);
    
    // 清除内圆
    paint.color = Colors.transparent;
    paint.blendMode = BlendMode.clear;
    canvas.drawCircle(center, innerRadius, paint);
    paint.blendMode = BlendMode.srcOver;
    
    // 悬停时的边框高光
    if (isHighlighted) {
      paint.color = Colors.black.withOpacity(0.3);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawArc(rect, startAngle, angleStep, false, paint);
    }
    
    paint.style = PaintingStyle.fill;
  }

  void _draw3DSegment(Canvas canvas, Offset center, double radius, double innerRadius, 
      double startAngle, double angleStep, Color color, bool isHighlighted) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // 3D芝士蛋糕效果：绘制垂直厚度
    const double depth = 12.0; // 3D厚度
    
    // 1. 底部阴影（更深的阴影模拟立体效果）
    canvas.save();
    canvas.translate(4, 8); // 更明显的阴影偏移
    paint.color = Colors.black.withOpacity(0.4);
    final shadowRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(shadowRect, startAngle, angleStep, true, paint);
    
    // 清除内圆阴影
    paint.color = Colors.transparent;
    paint.blendMode = BlendMode.clear;
    canvas.drawCircle(center, innerRadius, paint);
    paint.blendMode = BlendMode.srcOver;
    canvas.restore();
    
    // 2. 绘制侧面（垂直边缘）
    _draw3DSides(canvas, center, radius, innerRadius, startAngle, angleStep, color, depth);
    
    // 3. 顶面渐变（芝士蛋糕的顶层效果）
    final topGradient = RadialGradient(
      center: Alignment(-0.3, -0.3), // 光源从左上角照射
      radius: 1.2,
      colors: [
        Color.lerp(color, Colors.white, 0.4)!, // 高光区域
        color, // 中间色调
        Color.lerp(color, Colors.black, 0.2)!, // 阴影区域
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    
    paint.shader = topGradient.createShader(
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
    
    // 4. 高光效果（增强立体感）
    if (isHighlighted) {
      // 外边缘高光
      paint.color = Colors.white.withOpacity(0.6);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 4;
      canvas.drawArc(rect, startAngle, angleStep, false, paint);
      
      // 内侧柔和高光
      paint.strokeWidth = 2;
      paint.color = Colors.white.withOpacity(0.3);
      final innerHighlightRect = Rect.fromCircle(center: center, radius: radius * 0.9);
      canvas.drawArc(innerHighlightRect, startAngle, angleStep, false, paint);
      
      // 顶面额外光泽
      paint.style = PaintingStyle.fill;
      paint.color = Colors.white.withOpacity(0.2);
      final highlightRect = Rect.fromCircle(center: center, radius: radius * 0.7);
      canvas.drawArc(highlightRect, startAngle, angleStep, true, paint);
    }
    
    paint.style = PaintingStyle.fill;
  }
  
  /// 绘制3D侧面，营造芝士蛋糕的厚度效果（子分类版本）
  void _draw3DSides(Canvas canvas, Offset center, double radius, double innerRadius, 
      double startAngle, double angleStep, Color color, double depth) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // 计算扇形的起点和终点
    final startX = center.dx + radius * math.cos(startAngle);
    final startY = center.dy + radius * math.sin(startAngle);
    final endAngle = startAngle + angleStep;
    final endX = center.dx + radius * math.cos(endAngle);
    final endY = center.dy + radius * math.sin(endAngle);
    
    // 内圆的对应点
    final innerStartX = center.dx + innerRadius * math.cos(startAngle);
    final innerStartY = center.dy + innerRadius * math.sin(startAngle);
    final innerEndX = center.dx + innerRadius * math.cos(endAngle);
    final innerEndY = center.dy + innerRadius * math.sin(endAngle);
    
    // 侧面颜色（比顶面暗一些）
    final sideColor = Color.lerp(color, Colors.black, 0.3)!;
    
    // 绘制外弧的侧面
    final outerPath = Path();
    outerPath.moveTo(startX, startY);
    outerPath.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, angleStep, false
    );
    outerPath.lineTo(endX, endY + depth);
    outerPath.arcTo(
      Rect.fromCircle(center: Offset(center.dx, center.dy + depth), radius: radius),
      endAngle, -angleStep, false
    );
    outerPath.close();
    
    paint.color = sideColor;
    canvas.drawPath(outerPath, paint);
    
    // 绘制径向侧面（如果可见）
    if (angleStep < math.pi) { // 只在扇形小于半圆时绘制径向侧面
      // 起始径向面
      final startRadialPath = Path();
      startRadialPath.moveTo(innerStartX, innerStartY);
      startRadialPath.lineTo(startX, startY);
      startRadialPath.lineTo(startX, startY + depth);
      startRadialPath.lineTo(innerStartX, innerStartY + depth);
      startRadialPath.close();
      
      paint.color = Color.lerp(sideColor, Colors.black, 0.2)!;
      canvas.drawPath(startRadialPath, paint);
      
      // 结束径向面
      final endRadialPath = Path();
      endRadialPath.moveTo(innerEndX, innerEndY);
      endRadialPath.lineTo(endX, endY);
      endRadialPath.lineTo(endX, endY + depth);
      endRadialPath.lineTo(innerEndX, innerEndY + depth);
      endRadialPath.close();
      
      canvas.drawPath(endRadialPath, paint);
    }
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

class _CreateCategoryDialogState extends State<CreateCategoryDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _controller = TextEditingController();
  bool _isLoading = false;
  
  String _selectedIcon = '📝';
  Color _selectedColor = Colors.blue;
  
  // 预设图标
  final List<String> _incomeIcons = [
    '💰', '💵', '💴', '💶', '💷', '💸', '💳', '🏦',
    '📈', '💹', '🎯', '🏆', '🎁', '🎉', '🎊', '✨',
  ];
  
  final List<String> _expenseIcons = [
    '🛍️', '🍔', '🚗', '🏠', '✈️', '🎬', '🎮', '📚',
    '💊', '👔', '💄', '🎓', '🏥', '⚡', '📱', '🎯',
  ];
  
  // 预设颜色
  final List<Color> _presetColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 根据类型选择默认图标
    _selectedIcon = widget.type == TransactionType.income
        ? _incomeIcons.first
        : _expenseIcons.first;
    
    // 根据类型选择默认颜色
    _selectedColor = widget.type == TransactionType.income
        ? AppConstants.incomeColor
        : AppConstants.expenseColor;
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: ModernUIStyles.cardBackgroundColor,
      child: Container(
        width: 400,
        height: 600,
        decoration: ModernUIStyles.elevatedCardDecoration,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 标题
            Text(
              '创建新分类',
              style: ModernUIStyles.headingStyle.copyWith(
                fontSize: 20,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 预览
            _buildPreview(),
            
            const SizedBox(height: 20),
            
            // 标签页
            TabBar(
              controller: _tabController,
              indicatorColor: ModernUIStyles.accentColor,
              labelColor: Colors.white,
              tabs: const [
                Tab(text: '名称'),
                Tab(text: '图标'),
                Tab(text: '颜色'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 标签页内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNameTab(),
                  _buildIconTab(),
                  _buildColorTab(),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ModernUIStyles.secondaryButtonStyle,
                  child: const Text('取消'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createCategory,
                  style: ModernUIStyles.primaryButtonStyle,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('创建'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建预览
  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernUIStyles.cardBackgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernUIStyles.accentColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _selectedColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _selectedIcon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 名称
          Text(
            _controller.text.isEmpty
                ? '分类名称'
                : _controller.text,
            style: ModernUIStyles.subheadingStyle.copyWith(
              color: _controller.text.isEmpty
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建名称标签页
  Widget _buildNameTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '请输入分类名称',
            style: ModernUIStyles.bodyStyle,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 20,
            style: const TextStyle(color: Colors.white),
            decoration: ModernUIStyles.inputDecoration(
              '例如：' + (widget.type == TransactionType.income ? '工资、投资' : '饮食、交通'),
            ).copyWith(
              counterStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Text(
            '名称应简洁明了，便于识别',
            style: ModernUIStyles.captionStyle,
          ),
        ],
      ),
    );
  }
  
  /// 构建图标标签页
  Widget _buildIconTab() {
    final icons = widget.type == TransactionType.income
        ? _incomeIcons
        : _expenseIcons;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择一个图标',
            style: ModernUIStyles.bodyStyle,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                final icon = icons[index];
                final isSelected = icon == _selectedIcon;
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ModernUIStyles.accentColor.withOpacity(0.2)
                          : ModernUIStyles.cardBackgroundColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? ModernUIStyles.accentColor
                            : ModernUIStyles.accentColor.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建颜色标签页
  Widget _buildColorTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择分类颜色',
            style: ModernUIStyles.bodyStyle,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _presetColors.length,
              itemBuilder: (context, index) {
                final color = _presetColors[index];
                final isSelected = color == _selectedColor;
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
        color: _selectedColor.value,
        icon: _selectedIcon,
        type: widget.type,
        subCategories: [
          SubCategory.create(
            name: 'default',
            icon: _selectedIcon,
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