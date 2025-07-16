/*
 * Neumorphism UI Demo
 * 神经形态主义UI风格演示
 * 
 * 特点：
 * - 柔和阴影和高光
 * - 低对比度同色系
 * - 3D浮雕效果
 * - 温和现代感
 */

import 'package:flutter/material.dart';

class NeumorphismDemo extends StatelessWidget {
  // 神经形态配色
  static const Color backgroundColor = Color(0xFFF0F0F3);
  static const Color shadowLight = Color(0xFFFFFFFF);
  static const Color shadowDark = Color(0xFFD1D9E6);
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color textColor = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 神经形态罐头
            NeumorphicContainer(
              width: 200,
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeumorphicIcon(
                    icon: Icons.savings,
                    size: 60,
                    color: primaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '收入罐头',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '¥12,345.67',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 40),
            
            // 神经形态按钮
            NeumorphicButton(
              onPressed: () {},
              child: Text(
                '添加记录',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            SizedBox(height: 32),
            
            // 神经形态输入框
            NeumorphicTextField(
              hintText: '输入金额',
            ),
          ],
        ),
      ),
    );
  }
}

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final bool isPressed;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.width = 100,
    this.height = 100,
    this.isPressed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: NeumorphismDemo.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isPressed
            ? [
                // 内阴影效果
                BoxShadow(
                  color: NeumorphismDemo.shadowDark,
                  offset: Offset(2, 2),
                  blurRadius: 5,
                  inset: true,
                ),
                BoxShadow(
                  color: NeumorphismDemo.shadowLight,
                  offset: Offset(-2, -2),
                  blurRadius: 5,
                  inset: true,
                ),
              ]
            : [
                // 外阴影效果
                BoxShadow(
                  color: NeumorphismDemo.shadowDark,
                  offset: Offset(6, 6),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: NeumorphismDemo.shadowLight,
                  offset: Offset(-6, -6),
                  blurRadius: 12,
                ),
              ],
      ),
      child: child,
    );
  }
}

class NeumorphicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const NeumorphicButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: NeumorphismDemo.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isPressed
              ? [
                  BoxShadow(
                    color: NeumorphismDemo.shadowDark,
                    offset: Offset(2, 2),
                    blurRadius: 5,
                  ),
                ]
              : [
                  BoxShadow(
                    color: NeumorphismDemo.shadowDark,
                    offset: Offset(4, 4),
                    blurRadius: 8,
                  ),
                  BoxShadow(
                    color: NeumorphismDemo.shadowLight,
                    offset: Offset(-4, -4),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: widget.child,
      ),
    );
  }
}

class NeumorphicIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const NeumorphicIcon({
    Key? key,
    required this.icon,
    this.size = 24,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: NeumorphismDemo.backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: NeumorphismDemo.shadowDark,
            offset: Offset(2, 2),
            blurRadius: 4,
          ),
          BoxShadow(
            color: NeumorphismDemo.shadowLight,
            offset: Offset(-2, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
}

class NeumorphicTextField extends StatelessWidget {
  final String hintText;

  const NeumorphicTextField({
    Key? key,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: NeumorphismDemo.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          // 内阴影效果
          BoxShadow(
            color: NeumorphismDemo.shadowDark,
            offset: Offset(2, 2),
            blurRadius: 4,
            inset: true,
          ),
          BoxShadow(
            color: NeumorphismDemo.shadowLight,
            offset: Offset(-2, -2),
            blurRadius: 4,
            inset: true,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: NeumorphismDemo.textColor),
          border: InputBorder.none,
        ),
        style: TextStyle(color: NeumorphismDemo.primaryColor),
      ),
    );
  }
}