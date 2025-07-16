/*
 * 响应式布局工具类 (responsive_layout.dart)
 * 
 * 功能说明：
 * - 智能识别设备类型和屏幕尺寸
 * - 提供不同设备的布局策略
 * - 支持移动端、平板、桌面端的自适应设计
 * 
 * 设备分类：
 * - 移动端：< 600px - 垂直布局，原始手机体验
 * - 平板端：600px - 1200px - 水平布局，充分利用屏幕
 * - 桌面端：> 1200px - 网格布局，多栏显示
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;

enum DeviceType {
  mobile,    // 手机
  tablet,    // 平板
  desktop,   // 桌面
}

class ResponsiveLayout {
  static DeviceType getDeviceType() {
    final screenWidth = ScreenUtil().screenWidth;
    
    if (screenWidth < 600) {
      return DeviceType.mobile;
    } else if (screenWidth < 1200) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  static bool get isMobile => getDeviceType() == DeviceType.mobile;
  static bool get isTablet => getDeviceType() == DeviceType.tablet;
  static bool get isDesktop => getDeviceType() == DeviceType.desktop;
  
  // 计算最佳缩放比例
  static double getOptimalScale(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final deviceType = getDeviceType();
    
    // 基准尺寸 (设计稿)
    const baseWidth = 375.0;
    const baseHeight = 812.0;
    
    switch (deviceType) {
      case DeviceType.mobile:
        // 移动端：充分利用屏幕，但保持比例
        double scaleX = screenSize.width / baseWidth;
        double scaleY = screenSize.height / baseHeight;
        return math.min(scaleX, scaleY);
        
      case DeviceType.tablet:
        // 平板端：适当放大，保持良好的可读性
        double scaleX = screenSize.width / baseWidth;
        double scaleY = screenSize.height / baseHeight;
        double scale = math.min(scaleX, scaleY);
        return math.max(scale * 0.8, 1.2); // 至少1.2倍，最多80%屏幕
        
      case DeviceType.desktop:
        // 桌面端：固定较大的缩放比例
        double scaleX = screenSize.width / baseWidth;
        double scaleY = screenSize.height / baseHeight;
        double scale = math.min(scaleX, scaleY);
        return math.max(scale * 0.6, 1.8); // 至少1.8倍，最多60%屏幕
    }
  }
  
  // 获取主容器的布局参数
  static Map<String, dynamic> getMainContainerLayout(BuildContext context) {
    final deviceType = getDeviceType();
    final screenSize = MediaQuery.of(context).size;
    final scale = getOptimalScale(context);
    
    // 基准尺寸
    const baseWidth = 375.0;
    const baseHeight = 812.0;
    
    // 计算缩放后的尺寸
    final scaledWidth = baseWidth * scale;
    final scaledHeight = baseHeight * scale;
    
    switch (deviceType) {
      case DeviceType.mobile:
        // 移动端：充分利用屏幕，无边框
        return {
          'width': screenSize.width,
          'height': screenSize.height,
          'margin': EdgeInsets.zero,
          'padding': EdgeInsets.zero,
          'showBorder': false,
          'borderRadius': 0.0,
          'scale': scale,
        };
        
      case DeviceType.tablet:
        // 平板端：居中显示，带边框
        return {
          'width': scaledWidth,
          'height': scaledHeight,
          'margin': EdgeInsets.symmetric(
            horizontal: math.max(0, (screenSize.width - scaledWidth) / 2),
            vertical: math.max(0, (screenSize.height - scaledHeight) / 2),
          ),
          'padding': EdgeInsets.zero,
          'showBorder': true,
          'borderRadius': 16.0,
          'scale': scale,
        };
        
      case DeviceType.desktop:
        // 桌面端：居中显示，带边框和阴影
        return {
          'width': scaledWidth,
          'height': scaledHeight,
          'margin': EdgeInsets.symmetric(
            horizontal: math.max(0, (screenSize.width - scaledWidth) / 2),
            vertical: math.max(0, (screenSize.height - scaledHeight) / 2),
          ),
          'padding': EdgeInsets.zero,
          'showBorder': true,
          'borderRadius': 20.0,
          'scale': scale,
        };
    }
  }
  
  // 获取罐头布局参数
  static Map<String, dynamic> getJarLayout() {
    final deviceType = getDeviceType();
    
    switch (deviceType) {
      case DeviceType.mobile:
        // 移动端：垂直布局，单个罐头显示
        return {
          'orientation': 'vertical',
          'jarWidth': 300.w,
          'jarHeight': 400.h,
          'spacing': 20.h,
          'showNavigation': true,
          'navigationStyle': 'dots',
        };
        
      case DeviceType.tablet:
        // 平板端：水平布局，显示多个罐头
        return {
          'orientation': 'horizontal',
          'jarWidth': 200.w,
          'jarHeight': 300.h,
          'spacing': 30.w,
          'showNavigation': false,
          'navigationStyle': 'tabs',
        };
        
      case DeviceType.desktop:
        // 桌面端：网格布局，显示所有罐头
        return {
          'orientation': 'grid',
          'jarWidth': 220.w,
          'jarHeight': 280.h,
          'spacing': 40.w,
          'showNavigation': false,
          'navigationStyle': 'sidebar',
        };
    }
  }
  
  // 获取详情页布局参数
  static Map<String, dynamic> getDetailLayout() {
    final deviceType = getDeviceType();
    
    switch (deviceType) {
      case DeviceType.mobile:
        // 移动端：全屏弹窗
        return {
          'showAsDialog': false,
          'width': 1.sw,
          'height': 1.sh,
          'padding': EdgeInsets.all(16.w),
          'showCloseButton': false,
        };
        
      case DeviceType.tablet:
        // 平板端：大对话框
        return {
          'showAsDialog': true,
          'width': 600.w,
          'height': 500.h,
          'padding': EdgeInsets.all(20.w),
          'showCloseButton': true,
        };
        
      case DeviceType.desktop:
        // 桌面端：侧边栏或分割视图
        return {
          'showAsDialog': false,
          'width': 400.w,
          'height': 1.sh,
          'padding': EdgeInsets.all(24.w),
          'showCloseButton': true,
        };
    }
  }
  
  // 获取字体大小缩放系数
  static double get fontScale {
    final deviceType = getDeviceType();
    
    switch (deviceType) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.2;
      case DeviceType.desktop:
        return 1.1;
    }
  }
  
  // 获取间距缩放系数
  static double get spacingScale {
    final deviceType = getDeviceType();
    
    switch (deviceType) {
      case DeviceType.mobile:
        return 1.0;
      case DeviceType.tablet:
        return 1.3;
      case DeviceType.desktop:
        return 1.5;
    }
  }
  
  // 响应式Widget构建器
  static Widget responsive({
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = getDeviceType();
        
        switch (deviceType) {
          case DeviceType.mobile:
            return mobile;
          case DeviceType.tablet:
            return tablet ?? mobile;
          case DeviceType.desktop:
            return desktop ?? tablet ?? mobile;
        }
      },
    );
  }
}