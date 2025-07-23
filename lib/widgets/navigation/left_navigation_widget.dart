import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/constants.dart';

/// 🧭 左侧导航栏组件
/// 
/// 这个组件负责显示MoneyJars应用的左侧导航栏，包括：
/// - 4个功能页面快速入口按钮
/// - 设置、帮助、统计、个性化页面导航
/// - 圆角白色背景容器和阴影效果
/// 
/// 设计特点：
/// - 相对背景图片居中定位
/// - 长度延长20%的设计
/// - 平滑的页面切换动画
/// - 响应式图标尺寸
class LeftNavigationWidget extends StatelessWidget {
  /// 导航到设置页面回调
  final VoidCallback onSettingsTap;
  
  /// 导航到帮助页面回调
  final VoidCallback onHelpTap;
  
  /// 导航到统计页面回调
  final VoidCallback onStatisticsTap;
  
  /// 导航到个性化页面回调
  final VoidCallback onPersonalizationTap;

  const LeftNavigationWidget({
    Key? key,
    required this.onSettingsTap,
    required this.onHelpTap,
    required this.onStatisticsTap,
    required this.onPersonalizationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 2.w, // 左侧位置：几乎贴左边缘，只留2px白边
      top: MediaQuery.of(context).size.height * 0.32, // 垂直位置：调整为32%避免溢出
      child: _buildNavigationContainer(),
    );
  }

  /// 🎨 构建导航容器
  /// 
  /// 包含白色背景、圆角边框、阴影效果和4个功能按钮
  Widget _buildNavigationContainer() {
    return Container(
      width: 48.w, // 容器宽度：48逻辑像素(原42增大15%)
      padding: EdgeInsets.symmetric(vertical: 16.h), // 垂直内边距：减少为16逻辑像素避免溢出
      decoration: BoxDecoration(
        color: Colors.white, // 背景颜色：白色
        borderRadius: BorderRadius.circular(24.r), // 圆角半径：24逻辑像素(原21增大15%)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // 阴影颜色：10%透明黑色
            blurRadius: 8.r, // 模糊半径：8逻辑像素(原7增大15%)
            offset: Offset(0, 1.6.h), // 阴影偏移：向下1.6逻辑像素(原1.4增大15%)
          ),
        ],
      ),
      child: _buildNavigationButtons(),
    );
  }

  /// 🔘 构建导航按钮列表
  /// 
  /// 包含4个功能按钮，每个按钮都有对应的页面导航功能
  Widget _buildNavigationButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min, // 最小尺寸：紧凑布局
      children: [
        // 🔧 设置按钮：导航到设置页面
        _buildNavigationButton(
          icon: Icons.settings, // 设置图标
          onTap: onSettingsTap, // 点击回调
          tooltip: '设置', // 悬停提示
        ),
        
        SizedBox(height: 8.h), // 按钮间距：8逻辑像素
        
        // ❓ 帮助按钮：导航到帮助页面
        _buildNavigationButton(
          icon: Icons.help_outline, // 帮助图标
          onTap: onHelpTap, // 点击回调
          tooltip: '帮助', // 悬停提示
        ),
        
        SizedBox(height: 8.h), // 按钮间距：8逻辑像素
        
        // 📊 统计按钮：导航到统计页面
        _buildNavigationButton(
          icon: Icons.bar_chart, // 统计图标
          onTap: onStatisticsTap, // 点击回调
          tooltip: '统计', // 悬停提示
        ),
        
        SizedBox(height: 8.h), // 按钮间距：8逻辑像素
        
        // 🎨 个性化按钮：导航到个性化页面
        _buildNavigationButton(
          icon: Icons.more_horiz, // 更多选项图标
          onTap: onPersonalizationTap, // 点击回调
          tooltip: '个性化', // 悬停提示
        ),
      ],
    );
  }

  /// 🔘 构建单个导航按钮
  /// 
  /// 统一的按钮样式和交互效果
  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip, // 悬停提示文字
      child: InkWell(
        onTap: onTap, // 点击回调
        borderRadius: BorderRadius.circular(8.r), // 圆角点击区域
        child: Container(
          width: 32.w, // 按钮宽度：32逻辑像素
          height: 32.h, // 按钮高度：32逻辑像素
          alignment: Alignment.center, // 居中对齐
          child: Icon(
            icon, // 图标
            size: 20.r, // 图标尺寸：20逻辑像素
            color: AppConstants.primaryColor, // 图标颜色：主题色
          ),
        ),
      ),
    );
  }
}