/*
 * 罐头卡片组件 (jar_card_widget.dart)
 * 
 * 功能说明：
 * - 展示单个罐头的信息和状态
 * - 包含目标进度、当前金额等
 * - 支持交互和动画效果
 * 
 * 视觉设计：
 * - 圆形进度环
 * - 罐头图标和动画
 * - 金额和目标显示
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/domain/entities/jar_settings.dart';

/// 罐头卡片组件
/// 
/// 展示单个罐头的状态和信息
class JarCardWidget extends StatefulWidget {
  /// 罐头类型
  final JarType jarType;
  
  /// 罐头设置
  final JarSettings jarSettings;
  
  /// 当前金额
  final double currentAmount;
  
  /// 点击回调
  final VoidCallback? onTap;
  
  /// 设置按钮点击回调
  final VoidCallback? onSettingsTap;
  
  /// 是否显示设置按钮
  final bool showSettings;
  
  /// 是否启用动画
  final bool enableAnimation;
  
  const JarCardWidget({
    Key? key,
    required this.jarType,
    required this.jarSettings,
    required this.currentAmount,
    this.onTap,
    this.onSettingsTap,
    this.showSettings = true,
    this.enableAnimation = true,
  }) : super(key: key);
  
  @override
  State<JarCardWidget> createState() => _JarCardWidgetState();
}

class _JarCardWidgetState extends State<JarCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'zh_CN',
    symbol: '¥',
    decimalDigits: 2,
  );
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _calculateProgress(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    if (widget.enableAnimation) {
      _animationController.forward();
    }
  }
  
  @override
  void didUpdateWidget(JarCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentAmount != widget.currentAmount ||
        oldWidget.jarSettings.targetAmount != widget.jarSettings.targetAmount) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: _calculateProgress(),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
      _animationController.forward(from: 0.0);
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// 计算进度
  double _calculateProgress() {
    if (widget.jarSettings.targetAmount <= 0) return 0.0;
    return (widget.currentAmount / widget.jarSettings.targetAmount).clamp(0.0, 1.0);
  }
  
  /// 获取罐头颜色
  Color _getJarColor() {
    if (widget.jarSettings.customColor != null) {
      return Color(widget.jarSettings.customColor!);
    }
    
    switch (widget.jarType) {
      case JarType.income:
        return Colors.green;
      case JarType.expense:
        return Colors.red;
      case JarType.comprehensive:
        return Colors.blue;
    }
  }
  
  /// 获取罐头图标
  String _getJarIcon() {
    return widget.jarSettings.customIcon ?? _getDefaultIcon();
  }
  
  /// 获取默认图标
  String _getDefaultIcon() {
    switch (widget.jarType) {
      case JarType.income:
        return '💰';
      case JarType.expense:
        return '💸';
      case JarType.comprehensive:
        return '🏦';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jarColor = _getJarColor();
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enableAnimation ? _scaleAnimation.value : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: jarColor.withOpacity(0.2),
                    blurRadius: 20.0,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 主内容
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 进度环和图标
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 背景进度环
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 12.0,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    jarColor.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              // 实际进度环
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: CircularProgressIndicator(
                                  value: widget.enableAnimation 
                                      ? _progressAnimation.value 
                                      : _calculateProgress(),
                                  strokeWidth: 12.0,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(jarColor),
                                ),
                              ),
                              // 中心内容
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 罐头图标
                                  Text(
                                    _getJarIcon(),
                                    style: const TextStyle(fontSize: 48),
                                  ),
                                  const SizedBox(height: 8),
                                  // 进度百分比
                                  Text(
                                    '${(_calculateProgress() * 100).toStringAsFixed(1)}%',
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: jarColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // 标题
                        Text(
                          widget.jarSettings.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // 当前金额
                        Text(
                          _currencyFormat.format(widget.currentAmount),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: jarColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // 目标金额
                        Text(
                          '目标: ${_currencyFormat.format(widget.jarSettings.targetAmount)}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                        
                        // 截止日期
                        if (widget.jarSettings.deadline != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '截止: ${DateFormat('yyyy-MM-dd').format(widget.jarSettings.deadline!)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                        
                        // 描述
                        if (widget.jarSettings.description != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            widget.jarSettings.description!,
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        // 提醒状态
                        if (widget.jarSettings.enableTargetReminder &&
                            _calculateProgress() >= widget.jarSettings.reminderThreshold) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.notifications_active,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '即将达成目标！',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // 设置按钮
                  if (widget.showSettings && widget.onSettingsTap != null)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: theme.iconTheme.color?.withOpacity(0.6),
                        ),
                        onPressed: widget.onSettingsTap,
                        tooltip: '罐头设置',
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}