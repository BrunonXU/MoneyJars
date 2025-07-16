/*
 * 主界面内容扩展 (home_screen_content.dart)
 * 
 * 功能说明：
 * - 为home_screen.dart提供不同设备的内容布局
 * - 平板端：水平显示多个罐头
 * - 桌面端：网格显示所有罐头
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_record.dart';
import '../widgets/money_jar_widget.dart';
import '../constants/app_constants.dart';
import '../utils/responsive_layout.dart';
import '../screens/jar_detail_page.dart';

// 扩展home_screen.dart的内容方法
extension HomeScreenContent on State {
  // 平板端内容 - 水平显示多个罐头
  Widget buildTabletContent() {
    final jarLayout = ResponsiveLayout.getJarLayout();
    
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // 标题区域
              Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Text(
                  'MoneyJars',
                  style: AppConstants.headingStyle.copyWith(
                    fontSize: 28.sp,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),
              
              // 罐头水平显示
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 收入罐头
                    Expanded(
                      child: _buildJarCard(
                        context,
                        provider,
                        TransactionType.income,
                        '收入罐头',
                        jarLayout,
                      ),
                    ),
                    
                    SizedBox(width: jarLayout['spacing']),
                    
                    // 支出罐头
                    Expanded(
                      child: _buildJarCard(
                        context,
                        provider,
                        TransactionType.expense,
                        '支出罐头',
                        jarLayout,
                      ),
                    ),
                    
                    SizedBox(width: jarLayout['spacing']),
                    
                    // 综合罐头
                    Expanded(
                      child: _buildJarCard(
                        context,
                        provider,
                        null, // 综合罐头
                        '综合统计',
                        jarLayout,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 底部统计信息
              _buildStatsSummary(provider),
            ],
          ),
        );
      },
    );
  }
  
  // 桌面端内容 - 网格显示所有罐头
  Widget buildDesktopContent() {
    final jarLayout = ResponsiveLayout.getJarLayout();
    
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              // 标题和工具栏
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MoneyJars',
                    style: AppConstants.headingStyle.copyWith(
                      fontSize: 32.sp,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.settings, size: 24.sp),
                        onPressed: () {
                          // 打开设置
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.analytics, size: 24.sp),
                        onPressed: () {
                          // 打开统计
                        },
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 32.h),
              
              // 罐头网格显示
              Expanded(
                child: Row(
                  children: [
                    // 左侧罐头区域
                    Expanded(
                      flex: 2,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: jarLayout['spacing'],
                        mainAxisSpacing: jarLayout['spacing'],
                        childAspectRatio: 0.8,
                        children: [
                          _buildJarCard(
                            context,
                            provider,
                            TransactionType.income,
                            '收入罐头',
                            jarLayout,
                          ),
                          _buildJarCard(
                            context,
                            provider,
                            TransactionType.expense,
                            '支出罐头',
                            jarLayout,
                          ),
                          _buildJarCard(
                            context,
                            provider,
                            null,
                            '综合统计',
                            jarLayout,
                          ),
                          _buildQuickActions(), // 快速操作
                        ],
                      ),
                    ),
                    
                    SizedBox(width: 32.w),
                    
                    // 右侧信息面板
                    Expanded(
                      flex: 1,
                      child: _buildInfoPanel(provider),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  // 构建罐头卡片
  Widget _buildJarCard(
    BuildContext context,
    TransactionProvider provider,
    TransactionType? type,
    String title,
    Map<String, dynamic> jarLayout,
  ) {
    final amount = type == null
        ? provider.netIncome
        : (type == TransactionType.income ? provider.totalIncome : provider.totalExpense);
    
    final color = type == null
        ? (provider.netIncome >= 0 ? AppConstants.comprehensivePositiveColor : AppConstants.comprehensiveNegativeColor)
        : (type == TransactionType.income ? AppConstants.incomeColor : AppConstants.expenseColor);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JarDetailPage(
              type: type ?? TransactionType.income,
              provider: provider,
              isComprehensive: type == null,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppConstants.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusXLarge.r),
          boxShadow: AppConstants.shadowMedium,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 罐头图标/图片
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                type == TransactionType.income ? Icons.trending_up :
                type == TransactionType.expense ? Icons.trending_down : Icons.analytics,
                size: 40.sp,
                color: color,
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // 标题
            Text(
              title,
              style: AppConstants.titleStyle.copyWith(
                fontSize: 16.sp,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // 金额
            Text(
              '¥${amount.toStringAsFixed(2)}',
              style: AppConstants.bodyStyle.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 构建统计摘要
  Widget _buildStatsSummary(TransactionProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge.r),
        boxShadow: AppConstants.shadowSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('总收入', provider.totalIncome, AppConstants.incomeColor),
          _buildStatItem('总支出', provider.totalExpense, AppConstants.expenseColor),
          _buildStatItem('净收入', provider.netIncome, provider.netIncome >= 0 ? AppConstants.comprehensivePositiveColor : AppConstants.comprehensiveNegativeColor),
        ],
      ),
    );
  }
  
  // 构建统计项目
  Widget _buildStatItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppConstants.captionStyle.copyWith(
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: AppConstants.bodyStyle.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  // 构建快速操作
  Widget _buildQuickActions() {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge.r),
        boxShadow: AppConstants.shadowMedium,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add,
            size: 40.sp,
            color: AppConstants.primaryColor,
          ),
          SizedBox(height: 16.h),
          Text(
            '快速记录',
            style: AppConstants.titleStyle.copyWith(
              fontSize: 16.sp,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  // 构建信息面板
  Widget _buildInfoPanel(TransactionProvider provider) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge.r),
        boxShadow: AppConstants.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日概览',
            style: AppConstants.titleStyle.copyWith(
              fontSize: 18.sp,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          SizedBox(height: 20.h),
          
          _buildInfoItem('今日收入', provider.todayIncome, AppConstants.incomeColor),
          SizedBox(height: 12.h),
          _buildInfoItem('今日支出', provider.todayExpense, AppConstants.expenseColor),
          SizedBox(height: 12.h),
          _buildInfoItem('今日净额', provider.todayIncome - provider.todayExpense, provider.todayIncome - provider.todayExpense >= 0 ? AppConstants.comprehensivePositiveColor : AppConstants.comprehensiveNegativeColor),
          
          SizedBox(height: 20.h),
          
          Text(
            '快速操作',
            style: AppConstants.titleStyle.copyWith(
              fontSize: 18.sp,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          _buildActionButton('记录收入', Icons.add, AppConstants.incomeColor),
          SizedBox(height: 8.h),
          _buildActionButton('记录支出', Icons.remove, AppConstants.expenseColor),
          SizedBox(height: 8.h),
          _buildActionButton('查看统计', Icons.analytics, AppConstants.primaryColor),
        ],
      ),
    );
  }
  
  // 构建信息项目
  Widget _buildInfoItem(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppConstants.bodyStyle.copyWith(
            fontSize: 14.sp,
          ),
        ),
        Text(
          '¥${amount.toStringAsFixed(2)}',
          style: AppConstants.bodyStyle.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  // 构建操作按钮
  Widget _buildActionButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 16.sp),
      label: Text(label, style: TextStyle(fontSize: 14.sp)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        minimumSize: Size(double.infinity, 40.h),
      ),
    );
  }
}

// 扩展TransactionProvider以添加今日统计
extension TodayStats on TransactionProvider {
  double get todayIncome {
    final today = DateTime.now();
    return transactions
        .where((t) => t.type == TransactionType.income &&
            t.date.day == today.day &&
            t.date.month == today.month &&
            t.date.year == today.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  
  double get todayExpense {
    final today = DateTime.now();
    return transactions
        .where((t) => t.type == TransactionType.expense &&
            t.date.day == today.day &&
            t.date.month == today.month &&
            t.date.year == today.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}