import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/constants.dart';

/// 📱 顶部导航栏组件
/// 
/// 这个组件负责显示MoneyJars应用的顶部导航栏，包括：
/// - 左侧设置按钮（暂时隐藏）
/// - 中间应用标题和图标
/// - 右侧占位区域（保持布局平衡）
/// 
/// 设计特点：
/// - 使用Hero动画的应用图标
/// - 响应式设计，适配不同屏幕尺寸
/// - 遵循Material Design规范
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent, // 透明背景：让背景图片透过
      elevation: 0, // 无阴影：保持扁平设计
      automaticallyImplyLeading: false, // 禁用默认返回按钮
      title: _buildAppBarContent(),
    );
  }

  /// 🎨 构建导航栏内容
  /// 
  /// 包含三个主要部分：
  /// 1. 左侧设置按钮容器（暂时隐藏）
  /// 2. 中间标题区域（应用图标 + 标题文字）
  /// 3. 右侧占位区域（保持布局平衡）
  Widget _buildAppBarContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐：左右分布
      children: [
        // 🔧 左侧设置按钮容器（暂时隐藏，保持布局结构）
        SizedBox(width: 60.w), // 占位空白：与右侧保持平衡
        
        // 🏠 中间标题区域：应用图标 + 标题文字
        _buildCenterTitle(),
        
        // 📍 右侧占位区域：保持布局平衡
        SizedBox(width: 60.w), // 占位空白：与左侧保持平衡
      ],
    );
  }

  /// 🏠 构建中间标题区域
  /// 
  /// 包含Hero动画的应用图标和MoneyJars标题文字
  /// 使用Hero动画可以在页面切换时提供平滑的过渡效果
  Widget _buildCenterTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min, // 最小尺寸：紧凑布局
      children: [
        // 🎭 Hero动画应用图标容器
        Hero(
          tag: 'app_icon', // Hero标签：用于页面切换动画
          child: Container(
            width: AppConstants.iconMedium, // 图标宽度：中等尺寸
            height: AppConstants.iconMedium, // 图标高度：中等尺寸
            decoration: BoxDecoration(
              color: Colors.white, // 背景颜色：白色
              borderRadius: BorderRadius.circular(8.r), // 圆角：8逻辑像素
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1), // 阴影颜色：10%透明黑色
                  blurRadius: 4.r, // 模糊半径：4逻辑像素
                  offset: Offset(0, 2.h), // 阴影偏移：向下2逻辑像素
                ),
              ],
            ),
            child: Icon(
              Icons.savings, // 储蓄罐图标：与应用主题匹配
              color: AppConstants.primaryColor, // 图标颜色：主题色
              size: AppConstants.iconSmall, // 图标尺寸：小号
            ),
          ),
        ),
        
        // 📏 间距：图标与文字之间的空白
        SizedBox(width: AppConstants.spacingMedium),
        
        // 📝 MoneyJars标题文字
        Text(
          'MoneyJars', // 应用名称
          style: TextStyle(
            fontSize: AppConstants.fontSizeXLarge, // 字体大小：特大号
            fontWeight: FontWeight.bold, // 字体粗细：粗体
            color: AppConstants.primaryColor, // 文字颜色：主题色
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight); // 标准导航栏高度
}