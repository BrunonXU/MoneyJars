/*
 * Neon Dark UI Demo
 * 深色霓虹UI风格演示
 * 
 * 特点：
 * - 深色背景
 * - 霓虹色高光
 * - 科技感十足
 * - 未来主义风格
 */

import 'package:flutter/material.dart';

class NeonDarkDemo extends StatelessWidget {
  // 深色霓虹配色
  static const Color darkBackground = Color(0xFF0A0E27);
  static const Color cardBackground = Color(0xFF1A1F3A);
  static const Color primaryNeon = Color(0xFF00D4FF);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonPink = Color(0xFFFF10F0);
  static const Color neonOrange = Color(0xFFFF4500);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              darkBackground,
              Color(0xFF1A1F3A),
              darkBackground,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 霓虹罐头
              NeonContainer(
                glowColor: primaryNeon,
                child: Column(
                  children: [
                    NeonIcon(
                      icon: Icons.savings,
                      size: 60,
                      glowColor: neonGreen,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '收入罐头',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    NeonText(
                      text: '¥12,345.67',
                      color: neonGreen,
                      fontSize: 32,
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 32),
              
              // 霓虹按钮
              NeonButton(
                onPressed: () {},
                glowColor: neonPink,
                child: Text(
                  '添加记录',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              SizedBox(height: 32),
              
              // 霓虹进度条
              NeonProgressBar(
                progress: 0.7,
                glowColor: neonOrange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NeonContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double borderRadius;

  const NeonContainer({
    Key? key,
    required this.child,
    required this.glowColor,
    this.borderRadius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: NeonDarkDemo.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: glowColor,
          width: 2,
        ),
        boxShadow: [
          // 外发光效果
          BoxShadow(
            color: glowColor.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          // 内发光效果
          BoxShadow(
            color: glowColor.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: -5,
          ),
        ],
      ),
      child: child,
    );
  }
}

class NeonButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color glowColor;

  const NeonButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.glowColor,
  }) : super(key: key);

  @override
  _NeonButtonState createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: NeonDarkDemo.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.glowColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withOpacity(_glowAnimation.value * 0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class NeonIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color glowColor;

  const NeonIcon({
    Key? key,
    required this.icon,
    this.size = 24,
    required this.glowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeonDarkDemo.cardBackground,
        shape: BoxShape.circle,
        border: Border.all(
          color: glowColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size,
        color: glowColor,
      ),
    );
  }
}

class NeonText extends StatefulWidget {
  final String text;
  final Color color;
  final double fontSize;

  const NeonText({
    Key? key,
    required this.text,
    required this.color,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  _NeonTextState createState() => _NeonTextState();
}

class _NeonTextState extends State<NeonText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Text(
          widget.text,
          style: TextStyle(
            color: widget.color,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: widget.color.withOpacity(_glowAnimation.value),
                blurRadius: 10,
              ),
              Shadow(
                color: widget.color.withOpacity(_glowAnimation.value * 0.5),
                blurRadius: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}

class NeonProgressBar extends StatefulWidget {
  final double progress;
  final Color glowColor;

  const NeonProgressBar({
    Key? key,
    required this.progress,
    required this.glowColor,
  }) : super(key: key);

  @override
  _NeonProgressBarState createState() => _NeonProgressBarState();
}

class _NeonProgressBarState extends State<NeonProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 8,
      decoration: BoxDecoration(
        color: NeonDarkDemo.cardBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: widget.glowColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Stack(
            children: [
              Container(
                width: 200 * _progressAnimation.value,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.glowColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}