import 'package:flutter/material.dart';

/// 底部导航栏组件
class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onIndexChanged;
  
  const BottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onIndexChanged,
      backgroundColor: const Color(0xFF0D2818),
      selectedItemColor: const Color(0xFFDC143C),
      unselectedItemColor: Colors.white.withOpacity(0.6),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: '统计',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: '设置',
        ),
      ],
    );
  }
}