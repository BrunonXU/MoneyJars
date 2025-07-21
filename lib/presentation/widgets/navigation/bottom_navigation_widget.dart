/*
 * 底部导航栏组件 (bottom_navigation_widget.dart)
 * 
 * 功能说明：
 * - 提供应用主要功能导航
 * - 包含快速记账入口
 * - 支持自定义样式和动画
 * 
 * 设计特点：
 * - Material 3设计风格
 * - 中央凸起的FAB按钮
 * - 流畅的切换动画
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 底部导航栏组件
class BottomNavigationWidget extends StatefulWidget {
  /// 当前选中的索引
  final int currentIndex;
  
  /// 索引改变回调
  final ValueChanged<int> onIndexChanged;
  
  /// 添加记录回调
  final VoidCallback onAddRecord;
  
  /// 是否显示记账按钮
  final bool showAddButton;
  
  /// 导航项配置
  final List<BottomNavItem> items;
  
  const BottomNavigationWidget({
    Key? key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.onAddRecord,
    this.showAddButton = true,
    List<BottomNavItem>? items,
  }) : items = items ?? const [
          BottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: '首页',
          ),
          BottomNavItem(
            icon: Icons.pie_chart_outline,
            activeIcon: Icons.pie_chart,
            label: '统计',
          ),
          BottomNavItem(
            icon: Icons.category_outlined,
            activeIcon: Icons.category,
            label: '分类',
          ),
          BottomNavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: '设置',
          ),
        ],
        super(key: key);
  
  @override
  State<BottomNavigationWidget> createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Stack(
            children: [
              // 导航栏背景
              _buildNavigationBar(theme),
              
              // 中央记账按钮
              if (widget.showAddButton)
                _buildCenterFAB(theme),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 构建导航栏
  Widget _buildNavigationBar(ThemeData theme) {
    return Row(
      children: [
        // 左侧导航项
        ...widget.items.take(2).map((item) => Expanded(
          child: _NavItem(
            item: item,
            isSelected: widget.items.indexOf(item) == widget.currentIndex,
            onTap: () => _handleNavTap(widget.items.indexOf(item)),
          ),
        )),
        
        // 中间占位
        if (widget.showAddButton)
          const SizedBox(width: 80),
        
        // 右侧导航项
        ...widget.items.skip(2).take(2).map((item) => Expanded(
          child: _NavItem(
            item: item,
            isSelected: widget.items.indexOf(item) == widget.currentIndex,
            onTap: () => _handleNavTap(widget.items.indexOf(item)),
          ),
        )),
      ],
    );
  }
  
  /// 构建中央FAB按钮
  Widget _buildCenterFAB(ThemeData theme) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTapDown: (_) => _fabAnimationController.forward(),
          onTapUp: (_) {
            _fabAnimationController.reverse();
            _showAddOptions();
          },
          onTapCancel: () => _fabAnimationController.reverse(),
          child: AnimatedBuilder(
            animation: _fabScaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _fabScaleAnimation.value,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  /// 处理导航点击
  void _handleNavTap(int index) {
    if (index != widget.currentIndex) {
      HapticFeedback.lightImpact();
      widget.onIndexChanged(index);
    }
  }
  
  /// 显示添加选项
  void _showAddOptions() {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddOptionsSheet(
        onOptionSelected: (type) {
          Navigator.of(context).pop();
          widget.onAddRecord();
        },
      ),
    );
  }
}

/// 导航项组件
class _NavItem extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.primaryColor
        : theme.textTheme.bodySmall?.color?.withOpacity(0.6);
    
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              key: ValueKey(isSelected),
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// 添加选项底部弹窗
class _AddOptionsSheet extends StatelessWidget {
  final Function(AddOptionType) onOptionSelected;
  
  const _AddOptionsSheet({
    required this.onOptionSelected,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          Text(
            '选择记账类型',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          
          // 选项
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AddOption(
                icon: Icons.arrow_downward,
                label: '收入',
                color: Colors.green,
                onTap: () => onOptionSelected(AddOptionType.income),
              ),
              _AddOption(
                icon: Icons.arrow_upward,
                label: '支出',
                color: Colors.red,
                onTap: () => onOptionSelected(AddOptionType.expense),
              ),
              _AddOption(
                icon: Icons.sync_alt,
                label: '转账',
                color: Colors.blue,
                onTap: () => onOptionSelected(AddOptionType.transfer),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// 添加选项组件
class _AddOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _AddOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 底部导航项配置
class BottomNavItem {
  /// 图标
  final IconData icon;
  
  /// 激活状态图标
  final IconData activeIcon;
  
  /// 标签
  final String label;
  
  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// 添加选项类型
enum AddOptionType {
  income,
  expense,
  transfer,
}