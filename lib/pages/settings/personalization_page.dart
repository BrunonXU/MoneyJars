/*
 * 个性化页面 (personalization_page.dart)
 * 
 * 功能说明：
 * - 个性化设置和主题配置
 * - 保持顶部MoneyJars导航栏
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/constants.dart';
import '../../config/premium_color_scheme.dart';

class PersonalizationPage extends StatelessWidget {
  const PersonalizationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildAppBar(context),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[50]!,
                    Colors.white,
                  ],
                ),
              ),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: AppConstants.appBarHeight + 6,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: PremiumColors.cardShadow.withOpacity(0.3),
            blurRadius: 8.0,
            offset: Offset(0, 2.0),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: AppConstants.spacingSmall.h),
          child: Row(
            children: [
              // 返回按钮
              Padding(
                padding: EdgeInsets.only(left: AppConstants.spacingMedium.w),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: PremiumColors.deepWineRed),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              // 中间标题 - 防溢出设计
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hero图标 - 响应式尺寸
                    Flexible(
                      flex: 0,
                      child: Hero(
                        tag: 'app_icon',
                        child: Container(
                          width: (AppConstants.iconXLarge + 4).w,
                          height: (AppConstants.iconXLarge + 4).h,
                          constraints: BoxConstraints(
                            maxWidth: 40.w, // 防止过大导致溢出
                            maxHeight: 40.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                            boxShadow: [
                              BoxShadow(
                                color: PremiumColors.cardShadow.withOpacity(0.2),
                                blurRadius: 4.0,
                                offset: Offset(0, 1.0),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.more_horiz,
                            size: AppConstants.iconMedium.sp,
                            color: PremiumColors.deepWineRed,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppConstants.spacingMedium.w),
                    // 标题文字 - 防溢出处理
                    Flexible(
                      flex: 1,
                      child: Text(
                        'MoneyJars - 个性化',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: PremiumColors.deepWineRed,
                          fontSize: AppConstants.fontSizeXLarge.sp,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              // 右侧占位 - 响应式宽度
              SizedBox(width: 48.w), // 减少占位宽度
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.more_horiz,
            size: 80.sp,
            color: PremiumColors.deepWineRed,
          ),
          SizedBox(height: 20.h),
          Text(
            '个性化设置',
            style: AppConstants.headingStyle.copyWith(
              fontSize: 24.sp,
              color: PremiumColors.deepWineRed,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '个性化功能开发中...',
            style: AppConstants.bodyStyle.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}