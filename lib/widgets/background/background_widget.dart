import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 🎨 动态背景图片组件
/// 
/// 这个组件负责管理MoneyJars应用的动态背景系统，包括：
/// - 三个罐头页面的背景图片切换
/// - 背景图片的平滑过渡效果  
/// - 背景图片的适配和居中显示
/// 
/// 背景图片对应关系：
/// - 支出页面(page=0)：绿色针织背景 (green_knitted_jar.png)
/// - 综合页面(page=1)：小猪背景 (festive_piggy_bank.png)
/// - 收入页面(page=2)：红色针织背景 (red_knitted_jar.png)
class BackgroundWidget extends StatelessWidget {
  /// 页面控制器，用于获取当前页面滚动进度
  final PageController pageController;
  
  const BackgroundWidget({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        return _buildDynamicBackground();
      },
    );
  }

  /// 🎨 构建动态背景图片系统
  /// 
  /// 根据当前页面索引显示对应背景，背景图片随PageView滚动而平滑过渡
  /// 
  /// 背景切换逻辑：
  /// - page < 0.5: 支出页面区域，显示绿色针织背景
  /// - 0.5 <= page <= 1.5: 综合页面区域，显示小猪背景
  /// - page > 1.5: 收入页面区域，显示红色针织背景
  /// 
  /// 过渡效果：
  /// - 0.5 < page < 1.0: 支出→综合过渡，小猪背景渐入
  /// - 1.0 < page < 1.5: 综合→收入过渡，红色针织背景渐入
  Widget _buildDynamicBackground() {
    double page = 1.0; // 默认页面：1.0=综合页面(小猪背景)
    
    if (pageController.hasClients && pageController.page != null) {
      page = pageController.page!; // 获取当前页面：实时滚动进度(0.0-2.0)
    }
    
    // 🎨 动态背景选择：根据页面滑动进度智能切换背景图片和背景色
    String backgroundImage; // 背景图片路径：动态选择的背景图片文件
    Color backgroundColor; // 背景颜色：与背景图片主色调匹配的填充色
    
    if (page < 0.5) {
      // 📍 支出页面区域 (0.0 - 0.5)：绿色针织背景占主导
      backgroundImage = 'assets/images/green_knitted_jar.png';
      backgroundColor = const Color(0xFF104812); // 深绿色：与绿色针织背景匹配
    } else if (page <= 1.5) {
      // 📍 综合页面区域 (0.5 - 1.5)：小猪背景占主导
      backgroundImage = 'assets/images/festive_piggy_bank.png';
      backgroundColor = const Color.fromARGB(255, 255, 255, 255); // 白色：与小猪背景匹配
    } else {
      // 📍 收入页面区域 (1.5 - 2.0)：红色针织背景占主导
      backgroundImage = 'assets/images/red_knitted_jar.png';
      backgroundColor = const Color(0xFF66120D); // 深红色：与红色针织背景匹配
    }
    
    return Stack(
      children: [
        // 🖼️ 主要背景层：固定位置的背景图片，宽度与屏幕完全吻合
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor, // 背景颜色：与图片主色调匹配，填充白边区域
            image: DecorationImage(
              image: AssetImage(backgroundImage), // 背景图片：动态选择的背景图片文件
              fit: BoxFit.fitWidth, // 填充模式：宽度完全匹配，高度可能裁剪
              alignment: Alignment.center, // 对齐方式：居中对齐
            ),
          ),
        ),
        
        // 🌅 过渡背景层1：支出→综合页面过渡 (0.5 < page < 1.0)
        if (page > 0.5 && page < 1.0)
          Opacity(
            opacity: (page - 0.5) * 2, // 渐变透明度：page=0.5时opacity=0，page=1.0时opacity=1
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255), // 白色：与小猪背景匹配
                image: DecorationImage(
                  image: AssetImage('assets/images/festive_piggy_bank.png'), // 小猪背景：渐入效果
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        
        // 🌅 过渡背景层2：综合→收入页面过渡 (1.0 < page < 1.5)
        if (page > 1.0 && page < 1.5)
          Opacity(
            opacity: (page - 1.0) * 2, // 渐变透明度：page=1.0时opacity=0，page=1.5时opacity=1
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFB71C1C), // 深红色：与红色针织背景匹配
                image: DecorationImage(
                  image: AssetImage('assets/images/red_knitted_jar.png'), // 红色针织背景：渐入效果
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}