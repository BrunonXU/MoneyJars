/*
 * 如何使用页面 (help_page.dart)
 * 
 * 功能说明：
 * - 应用使用指南和帮助文档
 * - 保持顶部MoneyJars导航栏
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/constants.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({Key? key}) : super(key: key);

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
                  colors: AppConstants.backgroundGradient,
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
        color: AppConstants.backgroundColor,
        boxShadow: AppConstants.shadowMedium,
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
                  icon: Icon(Icons.arrow_back, color: AppConstants.primaryColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              // 中间标题
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'app_icon',
                      child: Container(
                        width: (AppConstants.iconXLarge + 4).w,
                        height: (AppConstants.iconXLarge + 4).h,
                        decoration: BoxDecoration(
                          color: AppConstants.backgroundColor,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                          boxShadow: AppConstants.shadowMedium,
                        ),
                        child: Icon(
                          Icons.help_outline,
                          size: AppConstants.iconMedium.sp,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: AppConstants.spacingMedium.w),
                    Text(
                      'MoneyJars - 如何使用',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                        fontSize: AppConstants.fontSizeXLarge.sp,
                      ),
                    ),
                  ],
                ),
              ),
              // 右侧占位，保持平衡
              SizedBox(width: 60.w),
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
            Icons.help_outline,
            size: 80.sp,
            color: AppConstants.primaryColor,
          ),
          SizedBox(height: 20.h),
          Text(
            '如何使用',
            style: AppConstants.headingStyle.copyWith(
              fontSize: 24.sp,
              color: AppConstants.primaryColor,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '使用指南开发中...',
            style: AppConstants.bodyStyle.copyWith(
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}