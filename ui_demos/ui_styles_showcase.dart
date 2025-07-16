/*
 * UI Styles Showcase Demo
 * UI风格展示演示
 * 
 * 展示四种不同的UI风格：
 * 1. 玻璃形态 (Glassmorphism)
 * 2. 神经形态 (Neumorphism)
 * 3. 深色霓虹 (Neon Dark)
 * 4. 现代渐变 (Gradient Modern)
 * 
 * 使用方法：
 * 1. 将此文件复制到您的Flutter项目中
 * 2. 导入所需的demo文件
 * 3. 在main.dart中运行UIStylesShowcase
 */

import 'package:flutter/material.dart';
import 'glassmorphism_demo.dart';
import 'neumorphism_demo.dart';
import 'neon_dark_demo.dart';
import 'gradient_modern_demo.dart';

void main() {
  runApp(UIStylesShowcaseApp());
}

class UIStylesShowcaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI Styles Showcase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: UIStylesShowcase(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UIStylesShowcase extends StatefulWidget {
  @override
  _UIStylesShowcaseState createState() => _UIStylesShowcaseState();
}

class _UIStylesShowcaseState extends State<UIStylesShowcase> {
  int _selectedIndex = 0;

  final List<UIStyle> _styles = [
    UIStyle(
      name: 'Glassmorphism',
      description: '玻璃形态风格\n半透明、模糊效果',
      icon: Icons.blur_on,
      color: Color(0xFF667EEA),
      widget: GlassmorphismDemo(),
    ),
    UIStyle(
      name: 'Neumorphism',
      description: '神经形态风格\n柔和阴影、3D效果',
      icon: Icons.view_in_ar,
      color: Color(0xFF6C63FF),
      widget: NeumorphismDemo(),
    ),
    UIStyle(
      name: 'Neon Dark',
      description: '深色霓虹风格\n科技感、发光效果',
      icon: Icons.flash_on,
      color: Color(0xFF00D4FF),
      widget: NeonDarkDemo(),
    ),
    UIStyle(
      name: 'Gradient Modern',
      description: '现代渐变风格\n彩虹色彩、动态效果',
      icon: Icons.gradient,
      color: Color(0xFFFF416C),
      widget: GradientModernDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'UI Styles Showcase',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _styles[_selectedIndex].color,
        elevation: 0,
        centerTitle: true,
      ),
      body: Row(
        children: [
          // 左侧导航
          Container(
            width: 300,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _styles[_selectedIndex].color.withOpacity(0.1),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _styles[_selectedIndex].icon,
                        size: 48,
                        color: _styles[_selectedIndex].color,
                      ),
                      SizedBox(height: 12),
                      Text(
                        _styles[_selectedIndex].name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _styles[_selectedIndex].color,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _styles[_selectedIndex].description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _styles.length,
                    itemBuilder: (context, index) {
                      final style = _styles[index];
                      final isSelected = index == _selectedIndex;
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? style.color.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected 
                              ? Border.all(color: style.color, width: 2)
                              : null,
                        ),
                        child: ListTile(
                          leading: Icon(
                            style.icon,
                            color: isSelected ? style.color : Colors.grey,
                          ),
                          title: Text(
                            style.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? style.color : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            style.description.split('\n')[0],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '推荐动画库',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildAnimationChip('Rive'),
                          _buildAnimationChip('Lottie'),
                          _buildAnimationChip('Animate'),
                          _buildAnimationChip('Shimmer'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 右侧预览
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: ClipRect(
                child: _styles[_selectedIndex].widget,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationChip(String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}

class UIStyle {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final Widget widget;

  UIStyle({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.widget,
  });
}