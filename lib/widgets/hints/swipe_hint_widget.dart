import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/constants.dart';

/// 💡 滑动提示组件
/// 
/// 这个组件负责显示MoneyJars应用的滑动提示，包括：
/// - 支出页面的向下滑动提示
/// - 收入页面的向上滑动提示
/// - 15%更大的提示框尺寸
/// - 平滑的呼吸动画效果
/// 
/// 设计特点：
/// - 半透明背景提示框
/// - 动态箭头图标指示
/// - 响应式尺寸适配
/// - 自动呼吸动画
class SwipeHintWidget extends StatefulWidget {
  /// 提示文字内容
  final String hintText;
  
  /// 箭头图标方向
  final IconData arrowIcon;
  
  /// 提示框位置（顶部或底部）
  final bool isTop;

  const SwipeHintWidget({
    Key? key,
    required this.hintText,
    required this.arrowIcon,
    this.isTop = false,
  }) : super(key: key);

  @override
  State<SwipeHintWidget> createState() => _SwipeHintWidgetState();
}

class _SwipeHintWidgetState extends State<SwipeHintWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  /// 🎬 初始化呼吸动画
  /// 
  /// 创建周期性的透明度变化动画，产生呼吸效果
  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2), // 动画周期：2秒
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.3, // 最小透明度：30%
      end: 0.8, // 最大透明度：80%
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // 平滑曲线：缓入缓出
    ));

    // 开始循环动画
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return _buildHintContainer();
      },
    );
  }

  /// 🎨 构建提示容器
  /// 
  /// 包含半透明背景、圆角边框和提示内容
  Widget _buildHintContainer() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w, // 水平内边距：16逻辑像素
        vertical: 8.h, // 垂直内边距：8逻辑像素
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(_opacityAnimation.value), // 动态透明度背景
        borderRadius: BorderRadius.circular(20.r), // 圆角半径：20逻辑像素
      ),
      child: _buildHintContent(),
    );
  }

  /// 📝 构建提示内容
  /// 
  /// 包含箭头图标和提示文字
  Widget _buildHintContent() {
    return Row(
      mainAxisSize: MainAxisSize.min, // 最小尺寸：紧凑布局
      children: [
        // 📍 箭头图标：指示滑动方向
        Icon(
          widget.arrowIcon,
          color: Colors.white, // 图标颜色：白色
          size: 16.r, // 图标尺寸：16逻辑像素
        ),
        
        SizedBox(width: 8.w), // 间距：图标与文字之间
        
        // 💬 提示文字
        Text(
          widget.hintText,
          style: TextStyle(
            color: Colors.white, // 文字颜色：白色
            fontSize: 12.sp, // 字体大小：12逻辑像素
            fontWeight: FontWeight.w500, // 字体粗细：中等
          ),
        ),
      ],
    );
  }
}

/// 🎯 滑动提示工厂类
/// 
/// 提供快速创建常用滑动提示的静态方法
class SwipeHintFactory {
  /// 创建向下滑动提示（支出页面使用）
  static Widget createDownHint() {
    return SwipeHintWidget(
      hintText: '下滑查看综合',
      arrowIcon: Icons.keyboard_arrow_down,
      isTop: false,
    );
  }

  /// 创建向上滑动提示（收入页面使用）
  static Widget createUpHint() {
    return SwipeHintWidget(
      hintText: '上滑查看综合',
      arrowIcon: Icons.keyboard_arrow_up,
      isTop: true,
    );
  }
}