/*
 * 罐头详情页面 - 高级版 (jar_detail_page_new.dart)
 * 
 * 设计特点：
 * - 高级配色方案：深酒红、深森林绿、奢华金
 * - 三种视图模式：饼状图、列表、折线图
 * - Material Design 3规范
 * - 企业级交互体验
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:html' as html;
import 'dart:convert';
import '../../config/premium_color_scheme.dart';
import '../../models/transaction_record_hive.dart';
import '../../services/providers/transaction_provider.dart';

// 视图模式枚举
enum ViewMode { pie, list, trend }

class JarDetailPageNew extends StatefulWidget {
  final TransactionType type;
  final bool isComprehensive;

  const JarDetailPageNew({
    Key? key,
    required this.type,
    this.isComprehensive = false,
  }) : super(key: key);

  @override
  State<JarDetailPageNew> createState() => _JarDetailPageNewState();
}

class _JarDetailPageNewState extends State<JarDetailPageNew> 
    with TickerProviderStateMixin {
  // 视图控制
  ViewMode _currentView = ViewMode.list;
  
  // 动画控制器
  late AnimationController _viewTransitionController;
  late AnimationController _fabAnimationController;
  
  // 搜索和筛选
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';
  
  // 高级筛选状态
  bool _isFilterActive = false;
  double? _minAmount;
  double? _maxAmount;
  DateTime? _startDate;
  DateTime? _endDate;
  Set<String> _selectedCategories = <String>{};
  TransactionType? _selectedType;
  
  // 时间范围选择
  String _timeRange = '本月'; // 本周、本月、三个月、一年
  
  // 批量操作
  bool _isSelectionMode = false;
  Set<String> _selectedItems = {};
  
  @override
  void initState() {
    super.initState();
    _viewTransitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _viewTransitionController.forward();
  }

  @override
  void dispose() {
    _viewTransitionController.dispose();
    _fabAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 获取罐头标题
  String get _jarTitle {
    if (widget.isComprehensive) return '综合罐头';
    return widget.type == TransactionType.income ? '收入罐头' : '支出罐头';
  }

  // 获取主题色
  Color get _themeColor {
    if (widget.isComprehensive) return PremiumColors.luxuryGold;
    return widget.type == TransactionType.income 
        ? PremiumColors.deepWineRed 
        : PremiumColors.deepForestGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // 明亮的灰白背景
      appBar: _buildSimpleAppBar(),
      body: Column(
        children: [
          _buildFilterIndicator(),
          _buildAnalysisCard(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _getViewWidget(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isSearching ? null : _buildBottomNavigation(),
      floatingActionButton: _buildFAB(),
    );
  }

  // 构建极简AppBar
  PreferredSizeWidget _buildSimpleAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: PremiumColors.darkCharcoal),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // App图标
          Container(
            margin: EdgeInsets.only(right: 8.w),
            child: Icon(
              Icons.savings,
              size: 22.w,
              color: _themeColor,
            ),
          ),
          Text(
            _jarTitle,
            style: TextStyle(
              color: PremiumColors.darkCharcoal,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        // 搜索按钮
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
            color: PremiumColors.darkCharcoal,
          ),
          onPressed: _toggleSearch,
        ),
      ],
      bottom: _isSearching ? _buildSearchBarAsBottom() : null,
    );
  }

  // 构建搜索栏作为AppBar的bottom
  PreferredSizeWidget _buildSearchBarAsBottom() {
    return PreferredSize(
      preferredSize: Size.fromHeight(60.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: PremiumColors.cardBorder, width: 1),
          ),
        ),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: PremiumColors.darkCharcoal),
          decoration: InputDecoration(
            hintText: '搜索描述或金额...',
            hintStyle: TextStyle(color: PremiumColors.smokeGrey),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _themeColor, width: 2),
            ),
            prefixIcon: Icon(Icons.search, color: PremiumColors.smokeGrey),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: PremiumColors.smokeGrey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
      ),
    );
  }

  // 构建底部导航栏
  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentView.index,
        onTap: (index) => _switchView(ViewMode.values[index]),
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: _themeColor,
        unselectedItemColor: PremiumColors.smokeGrey,
        selectedFontSize: 12.sp,
        unselectedFontSize: 12.sp,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_rounded),
            activeIcon: Icon(Icons.pie_chart_rounded),
            label: '分类',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            activeIcon: Icon(Icons.list_alt_rounded),
            label: '列表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_rounded),
            activeIcon: Icon(Icons.show_chart_rounded),
            label: '趋势',
          ),
        ],
      ),
    );
  }

  // 构建操作按钮组
  Widget _buildActionButtons() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: PremiumColors.smokeGrey, size: 20),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'export',
          child: Row(
            children: [
              Icon(Icons.download, color: PremiumColors.darkCharcoal, size: 18),
              SizedBox(width: 12.w),
              Text('导出数据', style: TextStyle(color: PremiumColors.darkCharcoal, fontSize: 14.sp)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'filter',
          child: Row(
            children: [
              Icon(Icons.filter_list, color: PremiumColors.darkCharcoal, size: 18),
              SizedBox(width: 12.w),
              Text('高级筛选', style: TextStyle(color: PremiumColors.darkCharcoal, fontSize: 14.sp)),
            ],
          ),
        ),
        if (_currentView == ViewMode.list)
          PopupMenuItem(
            value: 'batch',
            child: Row(
              children: [
                Icon(Icons.checklist, color: PremiumColors.darkCharcoal, size: 18),
                SizedBox(width: 12.w),
                Text('批量操作', style: TextStyle(color: PremiumColors.darkCharcoal, fontSize: 14.sp)),
              ],
            ),
          ),
      ],
      onSelected: _handleMenuAction,
    );
  }

  // 删除了未使用的SliverAppBar相关方法

  // 构建筛选状态指示器
  Widget _buildFilterIndicator() {
    if (!_isFilterActive) return SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: PremiumColors.deepWineRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PremiumColors.deepWineRed.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_alt,
            color: PremiumColors.deepWineRed,
            size: 14,
          ),
          SizedBox(width: 6.w),
          Text(
            '筛选已应用',
            style: TextStyle(
              color: PremiumColors.deepWineRed,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              setState(() {
                _minAmount = null;
                _maxAmount = null;
                _startDate = null;
                _endDate = null;
                _selectedCategories.clear();
                _selectedType = null;
                _isFilterActive = false;
              });
              _showSnackBar('筛选条件已清除');
            },
            child: Icon(
              Icons.close,
              color: PremiumColors.deepWineRed,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // 构建智能分析卡片 - 重新设计布局避免溢出
  Widget _buildAnalysisCard() {
    return Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final stats = _calculateStats(provider);
          
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _themeColor.withOpacity(0.15),
                  PremiumColors.darkCharcoal.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PremiumColors.cardBorder.withOpacity(0.6)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 第一行：AI标识 + 操作按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // AI标识区域
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: PremiumColors.luxuryGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: PremiumColors.luxuryGold.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.psychology_outlined,
                            color: PremiumColors.luxuryGold,
                            size: 14,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            'AI分析',
                            style: TextStyle(
                              color: PremiumColors.luxuryGold,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 高级功能按钮
                    _buildActionButtons(),
                  ],
                ),
                SizedBox(height: 12.h),
                // 第二行：统计信息
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildCompactStatItem(
                        '总额',
                        '¥${(stats['total'] ?? 0.0) >= 1000 ? '${((stats['total'] ?? 0.0) / 1000).toStringAsFixed(1)}k' : (stats['total'] ?? 0.0).toStringAsFixed(0)}',
                        _themeColor,
                      ),
                    ),
                    Container(
                      width: 1, 
                      height: 30.h, 
                      color: PremiumColors.cardBorder.withOpacity(0.5),
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    Expanded(
                      child: _buildCompactStatItem(
                        '变化',
                        '${stats['changePercent'] ?? 0}%',
                        stats['changePercent'] != null && stats['changePercent'] > 0
                            ? PremiumColors.successEmerald
                            : PremiumColors.errorRed,
                        showArrow: true,
                        isPositive: stats['changePercent'] != null && stats['changePercent'] > 0,
                      ),
                    ),
                    Container(
                      width: 1, 
                      height: 30.h, 
                      color: PremiumColors.cardBorder.withOpacity(0.5),
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    Expanded(
                      child: _buildCompactStatItem(
                        '笔数',
                        '${stats['count'] ?? 0}',
                        PremiumColors.luxuryGold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
  }

  // 构建紧凑统计项 - 优化布局防溢出
  Widget _buildCompactStatItem(String label, String value, Color color, 
      {bool showArrow = false, bool isPositive = true}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
            color: PremiumColors.silverGrey,
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showArrow)
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
                size: 12,
              ),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 构建统计项
  Widget _buildStatItem(String label, String value, Color color, 
      {bool showArrow = false, bool isPositive = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: PremiumColors.silverGrey,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            if (showArrow)
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: color,
                size: 16,
              ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 删除了原来的时间范围选择器，现在使用对话框

  // 删除了未使用的 _buildViewContent 方法

  // 获取当前视图组件
  Widget _getViewWidget() {
    switch (_currentView) {
      case ViewMode.pie:
        return _buildPieChartView();
      case ViewMode.list:
        return _buildListView();
      case ViewMode.trend:
        return _buildTrendView();
    }
  }

  // 构建饼状图视图
  Widget _buildPieChartView() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final categoryData = _getCategoryPieData(provider);
        
        if (categoryData.isEmpty) {
          return _buildEmptyState();
        }
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // 饼状图容器
              Container(
                height: 320.h,
                margin: EdgeInsets.only(bottom: 24.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 标题
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        '分类占比分析',
                        style: TextStyle(
                          color: PremiumColors.darkCharcoal,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // 饼状图
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        child: Row(
                          children: [
                            // 左侧饼图
                            Expanded(
                              flex: 3,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: PieChart(
                                  PieChartData(
                                    sections: categoryData.map((data) => PieChartSectionData(
                                      color: data['color'],
                                      value: data['amount'],
                                      title: data['percentage'] > 5 
                                          ? '${data['percentage'].toStringAsFixed(0)}%' 
                                          : '',
                                      radius: 50.w,
                                      titleStyle: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.5),
                                            offset: const Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    )).toList(),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 25.w,
                                    startDegreeOffset: -90,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            // 右侧图例
                            Expanded(
                              flex: 2,
                              child: _buildCompactLegend(categoryData),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 分类图例列表
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Text(
                        '分类详情',
                        style: TextStyle(
                          color: PremiumColors.darkCharcoal,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...categoryData.map((data) => _buildCategoryItem(data)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 构建紧凑型图例
  Widget _buildCompactLegend(List<Map<String, dynamic>> categoryData) {
    final displayData = categoryData.take(5).toList(); // 最多显示前5个，避免溢出
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ...displayData.map((data) => Container(
            margin: EdgeInsets.only(bottom: 6.h),
            child: Row(
              children: [
                // 颜色指示器
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    color: data['color'],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 6.w),
                // 分类名称和百分比
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data['category'],
                        style: TextStyle(
                          color: PremiumColors.darkCharcoal,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${data['percentage'].toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: PremiumColors.smokeGrey,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
          if (categoryData.length > 5)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                '+ ${categoryData.length - 5} more',
                style: TextStyle(
                  color: PremiumColors.smokeGrey,
                  fontSize: 9.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 构建最大分类标记
  Widget _buildLargestBadge() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _themeColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _themeColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.star,
        color: Colors.white,
        size: 16.w,
      ),
    );
  }

  // 构建分类项
  Widget _buildCategoryItem(Map<String, dynamic> data) {
    return Container(
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: data['isLargest'] 
            ? Border.all(color: _themeColor.withOpacity(0.3), width: 2)
            : null,
      ),
      child: Row(
        children: [
          // 颜色指示器
          Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: data['color'],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 12.w),
          
          // 分类信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data['category'],
                      style: TextStyle(
                        color: PremiumColors.darkCharcoal,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (data['isLargest'])
                      Icon(
                        Icons.star,
                        color: _themeColor,
                        size: 16.w,
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¥${data['amount'].toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _themeColor,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${data['percentage'].toStringAsFixed(1)}% · ${data['count']}笔',
                      style: TextStyle(
                        color: PremiumColors.smokeGrey,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建列表视图
  Widget _buildListView() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final records = _getFilteredRecords(provider);
        
        if (records.isEmpty) {
          return _buildEmptyState();
        }
        
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: records.length,
          itemBuilder: (context, index) => _buildTransactionCard(records[index]),
        );
      },
    );
  }

  // 构建趋势图视图
  Widget _buildTrendView() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final trendData = _getTrendChartData(provider);
        
        if (trendData.isEmpty) {
          return _buildEmptyState();
        }
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // 趋势图容器
              Container(
                height: 350.h,
                margin: EdgeInsets.only(bottom: 24.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 标题和控制区
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: PremiumColors.cardBorder, width: 1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '趋势分析',
                            style: TextStyle(
                              color: PremiumColors.darkCharcoal,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // 可点击的时间范围选择器
                          GestureDetector(
                            onTap: () => _showTimeRangeDialog(),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: PremiumColors.cardBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14.w,
                                    color: PremiumColors.smokeGrey,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    _timeRange,
                                    style: TextStyle(
                                      color: PremiumColors.darkCharcoal,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16.w,
                                    color: PremiumColors.smokeGrey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 折线图
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 24.h, 24.w, 16.h),
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: _getHorizontalInterval(trendData),
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: PremiumColors.cardBorder,
                                  strokeWidth: 1,
                                  dashArray: [5, 5],
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30.h,
                                  interval: _getDateInterval(trendData.length),
                                  getTitlesWidget: (value, meta) => _buildDateLabel(value, trendData),
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: _getHorizontalInterval(trendData),
                                  reservedSize: 45.w,
                                  getTitlesWidget: (value, meta) => _buildAmountLabel(value),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                bottom: BorderSide(color: PremiumColors.cardBorder, width: 1),
                                left: BorderSide(color: PremiumColors.cardBorder, width: 1),
                              ),
                            ),
                            minX: 0,
                            maxX: (trendData.length - 1).toDouble(),
                            minY: 0,
                            maxY: _getMaxY(trendData),
                            lineBarsData: _getLineBarsData(trendData),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (touchedSpot) => PremiumColors.darkCharcoal,
                                tooltipPadding: EdgeInsets.all(8.w),
                                getTooltipItems: (spots) => _getTooltipItems(spots, trendData),
                              ),
                              getTouchedSpotIndicator: (barData, spotIndexes) {
                                return spotIndexes.map((index) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: _themeColor.withOpacity(0.3),
                                      strokeWidth: 2,
                                      dashArray: [5, 5],
                                    ),
                                    FlDotData(
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 6,
                                          color: Colors.white,
                                          strokeWidth: 3,
                                          strokeColor: _themeColor,
                                        );
                                      },
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 统计概要卡片
              _buildTrendSummaryCard(trendData),
            ],
          ),
        );
      },
    );
  }

  // 构建交易卡片
  Widget _buildTransactionCard(TransactionRecord record) {
    final isSelected = _selectedItems.contains(record.id);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Material(
        color: isSelected 
            ? _themeColor.withOpacity(0.1) 
            : PremiumColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (_isSelectionMode) {
              setState(() {
                if (isSelected) {
                  _selectedItems.remove(record.id);
                } else {
                  _selectedItems.add(record.id);
                }
              });
            }
          },
          onLongPress: () => _enterSelectionMode(record.id),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _themeColor : PremiumColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // 选择框
                if (_isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value!) {
                          _selectedItems.add(record.id);
                        } else {
                          _selectedItems.remove(record.id);
                        }
                      });
                    },
                    activeColor: _themeColor,
                  ),
                // 分类图标
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: _themeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(record.parentCategory),
                    color: _themeColor,
                    size: 24.w,
                  ),
                ),
                SizedBox(width: 12.w),
                // 交易信息
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.description,
                        style: TextStyle(
                          color: PremiumColors.platinum,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${record.parentCategory} · ${DateFormat('MM月dd日 HH:mm').format(record.date)}',
                        style: TextStyle(
                          color: PremiumColors.silverGrey,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                // 金额
                Text(
                  '¥${record.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: _themeColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80.w,
            color: PremiumColors.smokeGrey,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无交易记录',
            style: TextStyle(
              color: PremiumColors.silverGrey,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '开始记录您的第一笔交易吧',
            style: TextStyle(
              color: PremiumColors.smokeGrey,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  // 构建浮动操作按钮
  Widget? _buildFAB() {
    if (_isSelectionMode) {
      return FloatingActionButton.extended(
        onPressed: _handleBatchAction,
        backgroundColor: _themeColor,
        label: Text(
          '删除 (${_selectedItems.length})',
          style: TextStyle(color: PremiumColors.platinum),
        ),
        icon: Icon(Icons.delete_outline, color: PremiumColors.platinum),
      );
    }
    
    return FloatingActionButton(
      onPressed: _addNewTransaction,
      backgroundColor: _themeColor,
      child: Icon(Icons.add, color: PremiumColors.platinum),
    );
  }

  // 辅助方法

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _switchView(ViewMode mode) {
    setState(() {
      _currentView = mode;
      _viewTransitionController.forward(from: 0);
    });
  }

  // 获取过滤后的交易记录 - 支持搜索和高级筛选
  List<TransactionRecord> _getFilteredTransactions(TransactionProvider provider) {
    List<TransactionRecord> allTransactions;
    
    // 根据页面类型获取对应的交易记录
    if (widget.isComprehensive) {
      allTransactions = provider.transactions; // 综合页面显示所有记录
    } else {
      allTransactions = widget.type == TransactionType.income 
          ? provider.incomeRecords 
          : provider.expenseRecords;
    }
    
    List<TransactionRecord> filteredTransactions = List.from(allTransactions);
    
    // 应用搜索筛选
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filteredTransactions = filteredTransactions.where((transaction) {
        return transaction.description.toLowerCase().contains(searchTerm) ||
               transaction.parentCategory.toLowerCase().contains(searchTerm) ||
               transaction.subCategory.toLowerCase().contains(searchTerm);
      }).toList();
    }
    
    // 应用高级筛选条件
    if (_isFilterActive) {
      filteredTransactions = filteredTransactions.where((transaction) {
        // 金额范围筛选
        if (_minAmount != null && transaction.amount < _minAmount!) {
          return false;
        }
        if (_maxAmount != null && transaction.amount > _maxAmount!) {
          return false;
        }
        
        // 日期范围筛选
        if (_startDate != null && transaction.date.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && transaction.date.isAfter(_endDate!.add(Duration(days: 1)))) {
          return false;
        }
        
        // 分类筛选
        if (_selectedCategories.isNotEmpty && 
            !_selectedCategories.contains(transaction.parentCategory)) {
          return false;
        }
        
        // 交易类型筛选（仅限综合页面）
        if (widget.isComprehensive && _selectedType != null && 
            transaction.type != _selectedType) {
          return false;
        }
        
        return true;
      }).toList();
    }
    
    return filteredTransactions;
  }

  // CSV导出功能 - 企业级数据导出
  Future<void> _exportToCSV() async {
    try {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      final transactions = _getFilteredTransactions(provider);
      
      if (transactions.isEmpty) {
        _showSnackBar('没有数据可以导出', isError: true);
        return;
      }

      // 构建CSV内容
      final csvContent = _buildCSVContent(transactions);
      
      // 生成文件名（包含交易类型和时间戳）
      final now = DateTime.now();
      final dateFormatter = DateFormat('yyyy-MM-dd_HH-mm');
      final typeName = widget.type == TransactionType.income ? '收入' : 
                      widget.isComprehensive ? '综合' : '支出';
      final fileName = '${typeName}记录_${dateFormatter.format(now)}.csv';
      
      // 创建Blob并触发下载
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      
      html.Url.revokeObjectUrl(url);
      
      _showSnackBar('数据导出成功：$fileName');
      
    } catch (e) {
      _showSnackBar('导出失败：${e.toString()}', isError: true);
    }
  }

  // 构建CSV内容
  String _buildCSVContent(List<TransactionRecord> transactions) {
    final buffer = StringBuffer();
    
    // CSV头部 - 企业级字段规范
    buffer.writeln('日期,时间,类型,主分类,子分类,金额,描述,余额变化,创建时间');
    
    // 数据行
    for (final transaction in transactions) {
      final date = DateFormat('yyyy-MM-dd').format(transaction.date);
      final time = DateFormat('HH:mm:ss').format(transaction.date);
      final type = transaction.type == TransactionType.income ? '收入' : '支出';
      final parentCategory = transaction.parentCategory;
      final subCategory = transaction.subCategory;
      final amount = transaction.amount.toStringAsFixed(2);
      final description = '"${transaction.description.replaceAll('"', '""')}"'; // CSV转义
      final balanceChange = transaction.type == TransactionType.income ? '+$amount' : '-$amount';
      final createdAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.createdAt);
      
      buffer.writeln('$date,$time,$type,$parentCategory,$subCategory,$amount,$description,$balanceChange,$createdAt');
    }
    
    return buffer.toString();
  }

  // 显示提示信息
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? PremiumColors.errorRed 
            : PremiumColors.successEmerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportToCSV();
        break;
      case 'filter':
        _showAdvancedFilterDialog();
        break;
      case 'batch':
        _enterSelectionMode(null);
        break;
    }
  }

  // 显示高级筛选对话框 - 企业级筛选体验
  Future<void> _showAdvancedFilterDialog() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    
    // 临时筛选状态
    double? tempMinAmount = _minAmount;
    double? tempMaxAmount = _maxAmount;
    DateTime? tempStartDate = _startDate;
    DateTime? tempEndDate = _endDate;
    Set<String> tempSelectedCategories = Set.from(_selectedCategories);
    TransactionType? tempSelectedType = _selectedType;
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.filter_list, color: PremiumColors.deepWineRed, size: 24),
              SizedBox(width: 12.w),
              Text(
                '高级筛选',
                style: TextStyle(
                  color: PremiumColors.darkCharcoal,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Container(
            width: 320.w,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 金额范围筛选
                  _buildFilterSection(
                    '金额范围',
                    Icons.attach_money,
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '最小金额',
                              prefixText: '¥',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              tempMinAmount = double.tryParse(value);
                            },
                            controller: TextEditingController(
                              text: tempMinAmount?.toString() ?? '',
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: '最大金额',
                              prefixText: '¥',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              tempMaxAmount = double.tryParse(value);
                            },
                            controller: TextEditingController(
                              text: tempMaxAmount?.toString() ?? '',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // 日期范围筛选
                  _buildFilterSection(
                    '日期范围',
                    Icons.date_range,
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: tempStartDate ?? DateTime.now().subtract(Duration(days: 30)),
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setDialogState(() => tempStartDate = date);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tempStartDate != null 
                                        ? DateFormat('yyyy-MM-dd').format(tempStartDate!)
                                        : '开始日期',
                                    style: TextStyle(color: PremiumColors.darkCharcoal),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: tempEndDate ?? DateTime.now(),
                                    firstDate: tempStartDate ?? DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) {
                                    setDialogState(() => tempEndDate = date);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tempEndDate != null 
                                        ? DateFormat('yyyy-MM-dd').format(tempEndDate!)
                                        : '结束日期',
                                    style: TextStyle(color: PremiumColors.darkCharcoal),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // 分类筛选
                  _buildFilterSection(
                    '分类筛选',
                    Icons.category,
                    _buildCategoryFilter(provider, tempSelectedCategories, setDialogState),
                  ),
                  
                  // 交易类型筛选（仅综合页面显示）
                  if (widget.isComprehensive) ...[
                    SizedBox(height: 24.h),
                    _buildFilterSection(
                      '交易类型',
                      Icons.swap_horiz,
                      Row(
                        children: [
                          _buildTypeChip('收入', TransactionType.income, tempSelectedType, (type) {
                            setDialogState(() {
                              tempSelectedType = tempSelectedType == type ? null : type;
                            });
                          }),
                          SizedBox(width: 12.w),
                          _buildTypeChip('支出', TransactionType.expense, tempSelectedType, (type) {
                            setDialogState(() {
                              tempSelectedType = tempSelectedType == type ? null : type;
                            });
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 清除所有筛选
                setDialogState(() {
                  tempMinAmount = null;
                  tempMaxAmount = null;
                  tempStartDate = null;
                  tempEndDate = null;
                  tempSelectedCategories.clear();
                  tempSelectedType = null;
                });
              },
              child: Text('清除', style: TextStyle(color: PremiumColors.smokeGrey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('取消', style: TextStyle(color: PremiumColors.smokeGrey)),
            ),
            ElevatedButton(
              onPressed: () {
                // 应用筛选
                setState(() {
                  _minAmount = tempMinAmount;
                  _maxAmount = tempMaxAmount;
                  _startDate = tempStartDate;
                  _endDate = tempEndDate;
                  _selectedCategories = tempSelectedCategories;
                  _selectedType = tempSelectedType;
                  _isFilterActive = _minAmount != null || _maxAmount != null ||
                      _startDate != null || _endDate != null ||
                      _selectedCategories.isNotEmpty || _selectedType != null;
                });
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PremiumColors.deepWineRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('应用', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    
    if (result == true) {
      _showSnackBar('筛选条件已应用');
    }
  }

  // 构建筛选区域
  Widget _buildFilterSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: PremiumColors.deepWineRed, size: 16),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                color: PremiumColors.darkCharcoal,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        content,
      ],
    );
  }

  // 构建分类筛选
  Widget _buildCategoryFilter(TransactionProvider provider, Set<String> selectedCategories, StateSetter setDialogState) {
    final categories = widget.isComprehensive 
        ? [...provider.getAllCategories(TransactionType.income), ...provider.getAllCategories(TransactionType.expense)]
        : provider.getAllCategories(widget.type);
    
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: categories.take(6).map((category) {
        final isSelected = selectedCategories.contains(category.name);
        return FilterChip(
          label: Text(
            '${category.icon} ${category.name}',
            style: TextStyle(
              color: isSelected ? Colors.white : PremiumColors.darkCharcoal,
              fontSize: 12.sp,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setDialogState(() {
              if (selected) {
                selectedCategories.add(category.name);
              } else {
                selectedCategories.remove(category.name);
              }
            });
          },
          backgroundColor: Colors.grey.shade200,
          selectedColor: PremiumColors.deepWineRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      }).toList(),
    );
  }

  // 构建交易类型筛选芯片
  Widget _buildTypeChip(String label, TransactionType type, TransactionType? selectedType, Function(TransactionType) onTap) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? PremiumColors.deepWineRed : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? PremiumColors.deepWineRed : Colors.grey.shade400,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : PremiumColors.darkCharcoal,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _enterSelectionMode(String? initialId) {
    setState(() {
      _isSelectionMode = true;
      if (initialId != null) {
        _selectedItems.add(initialId);
      }
    });
  }

  void _handleBatchAction() async {
    if (_selectedItems.isEmpty) return;
    
    // 确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除选中的 ${_selectedItems.length} 条记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: PremiumColors.errorRed,
            ),
            child: Text('删除'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      
      // 批量删除选中的记录
      for (String recordId in _selectedItems) {
        await provider.deleteTransaction(recordId);
      }
      
      // 清空选择状态
      setState(() {
        _selectedItems.clear();
        _isSelectionMode = false;
      });
      
      // 显示成功提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除 ${_selectedItems.length} 条记录'),
            backgroundColor: PremiumColors.successEmerald,
          ),
        );
      }
    }
  }

  void _addNewTransaction() {
    // TODO: 实现添加交易
  }

  List<TransactionRecord> _getFilteredRecords(TransactionProvider provider) {
    var records = provider.transactions;
    
    // 根据类型筛选
    if (!widget.isComprehensive) {
      records = records.where((r) => r.type == widget.type).toList();
    }
    
    // 搜索筛选
    if (_searchQuery.isNotEmpty) {
      records = records.where((r) => 
        r.description.contains(_searchQuery) ||
        r.amount.toString().contains(_searchQuery)
      ).toList();
    }
    
    return records;
  }

  Map<String, dynamic> _calculateStats(TransactionProvider provider) {
    final records = _getFilteredRecords(provider);
    
    return {
      'total': records.fold(0.0, (sum, r) => sum + r.amount),
      'count': records.length,
      'changePercent': 12.5, // TODO: 计算真实对比
    };
  }

  void _showTimeRangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.access_time, color: _themeColor, size: 20.w),
            SizedBox(width: 8.w),
            Text(
              '选择时间范围', 
              style: TextStyle(
                color: PremiumColors.darkCharcoal,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        contentPadding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['本周', '本月', '三个月', '一年'].map((range) => 
            Container(
              margin: EdgeInsets.only(bottom: 4.h),
              child: Material(
                color: _timeRange == range 
                    ? _themeColor.withOpacity(0.1) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    setState(() => _timeRange = range);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    child: Row(
                      children: [
                        Icon(
                          _timeRange == range ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: _timeRange == range ? _themeColor : PremiumColors.smokeGrey,
                          size: 20.w,
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          range, 
                          style: TextStyle(
                            color: _timeRange == range ? _themeColor : PremiumColors.darkCharcoal,
                            fontSize: 14.sp,
                            fontWeight: _timeRange == range ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        if (_timeRange == range) ...[
                          Spacer(),
                          Icon(
                            Icons.check,
                            color: _themeColor,
                            size: 18.w,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ).toList(),
        ),
      ),
    );
  }

  // 获取分类饼状图数据
  List<Map<String, dynamic>> _getCategoryPieData(TransactionProvider provider) {
    final records = _getFilteredRecords(provider);
    if (records.isEmpty) return [];
    
    // 按分类聚合数据
    final Map<String, Map<String, dynamic>> categoryStats = {};
    double totalAmount = 0;
    
    for (final record in records) {
      final category = record.parentCategory;
      totalAmount += record.amount;
      
      if (categoryStats.containsKey(category)) {
        categoryStats[category]!['amount'] += record.amount;
        categoryStats[category]!['count'] += 1;
      } else {
        categoryStats[category] = {
          'amount': record.amount,
          'count': 1,
        };
      }
    }
    
    // 转换为图表数据并排序
    final List<Map<String, dynamic>> pieData = [];
    int colorIndex = 0;
    
    categoryStats.forEach((category, stats) {
      final percentage = (stats['amount'] / totalAmount) * 100;
      pieData.add({
        'category': category,
        'amount': stats['amount'],
        'count': stats['count'],
        'percentage': percentage,
        'color': _getCategoryColor(colorIndex),
        'isLargest': false, // 稍后设置
      });
      colorIndex++;
    });
    
    // 按金额排序
    pieData.sort((a, b) => b['amount'].compareTo(a['amount']));
    
    // 标记最大分类
    if (pieData.isNotEmpty) {
      pieData[0]['isLargest'] = true;
    }
    
    return pieData;
  }

  // 获取分类颜色 - 高对比度配色方案
  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFF3B82F6), // 蓝色
      const Color(0xFFEF4444), // 红色
      const Color(0xFF10B981), // 绿色
      const Color(0xFFF59E0B), // 黄色
      const Color(0xFF8B5CF6), // 紫色
      const Color(0xFFEC4899), // 粉色
      const Color(0xFF06B6D4), // 青色
      const Color(0xFFF97316), // 橙色
      const Color(0xFF84CC16), // 青柠色
      const Color(0xFF6366F1), // 靛蓝色
      const Color(0xFFE11D48), // 玫瑰色
      const Color(0xFF059669), // 翡翠绿
      // 备用颜色
      PremiumColors.deepWineRed,
      PremiumColors.deepForestGreen,
      PremiumColors.luxuryGold,
      ...PremiumColors.premiumCategoryColors,
    ];
    return colors[index % colors.length];
  }

  // 获取趋势图数据
  List<Map<String, dynamic>> _getTrendChartData(TransactionProvider provider) {
    final records = _getFilteredRecords(provider);
    if (records.isEmpty) return [];
    
    // 按日期分组统计
    final Map<String, double> dailyTotals = {};
    final now = DateTime.now();
    final startDate = _getStartDate(now);
    
    // 初始化日期范围内的所有日期
    for (int i = 0; i <= now.difference(startDate).inDays; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = DateFormat('MM-dd').format(date);
      dailyTotals[dateKey] = 0;
    }
    
    // 统计每日金额
    for (final record in records) {
      if (record.date.isAfter(startDate.subtract(const Duration(days: 1)))) {
        final dateKey = DateFormat('MM-dd').format(record.date);
        dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + 
            (record.type == TransactionType.income ? record.amount : -record.amount);
      }
    }
    
    // 转换为列表并累计
    final List<Map<String, dynamic>> trendData = [];
    double cumulativeAmount = 0;
    int index = 0;
    
    dailyTotals.forEach((date, amount) {
      cumulativeAmount += amount;
      trendData.add({
        'date': date,
        'amount': amount,
        'cumulative': cumulativeAmount,
        'index': index++,
      });
    });
    
    return trendData;
  }

  // 获取开始日期
  DateTime _getStartDate(DateTime now) {
    switch (_timeRange) {
      case '本周':
        return now.subtract(Duration(days: 7));
      case '本月':
        return DateTime(now.year, now.month, 1);
      case '三个月':
        return now.subtract(Duration(days: 90));
      case '一年':
        return now.subtract(Duration(days: 365));
      default:
        return now.subtract(Duration(days: 30));
    }
  }

  // 获取Y轴间隔
  double _getHorizontalInterval(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 100;
    
    final maxValue = _getMaxY(data);
    if (maxValue <= 1000) return 200;
    if (maxValue <= 5000) return 1000;
    if (maxValue <= 10000) return 2000;
    return 5000;
  }

  // 获取X轴日期间隔
  double _getDateInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 31) return 5;
    if (dataLength <= 90) return 15;
    return 30;
  }

  // 构建日期标签
  Widget _buildDateLabel(double value, List<Map<String, dynamic>> data) {
    if (value.toInt() >= data.length || value < 0) {
      return SizedBox.shrink();
    }
    
    final dateStr = data[value.toInt()]['date'] as String;
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      child: Text(
        dateStr,
        style: TextStyle(
          color: PremiumColors.smokeGrey,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  // 构建金额标签
  Widget _buildAmountLabel(double value) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Text(
        value >= 10000 ? '${(value / 10000).toStringAsFixed(1)}w' : value.toStringAsFixed(0),
        style: TextStyle(
          color: PremiumColors.smokeGrey,
          fontSize: 10.sp,
        ),
      ),
    );
  }

  // 获取Y轴最大值
  double _getMaxY(List<Map<String, dynamic>> data) {
    double maxValue = 0;
    for (final item in data) {
      final cumulative = item['cumulative'] as double;
      if (cumulative > maxValue) maxValue = cumulative;
    }
    // 增加20%的边距
    return maxValue * 1.2;
  }

  // 获取折线数据
  List<LineChartBarData> _getLineBarsData(List<Map<String, dynamic>> data) {
    return [
      LineChartBarData(
        spots: data.map((item) {
          return FlSpot(
            item['index'].toDouble(),
            item['cumulative'] as double,
          );
        }).toList(),
        isCurved: true,
        curveSmoothness: 0.3,
        color: _themeColor,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: data.length <= 31,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: Colors.white,
              strokeWidth: 2,
              strokeColor: _themeColor,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: _themeColor.withOpacity(0.1),
          gradient: LinearGradient(
            colors: [
              _themeColor.withOpacity(0.2),
              _themeColor.withOpacity(0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ];
  }

  // 获取提示项
  List<LineTooltipItem> _getTooltipItems(
    List<LineBarSpot> spots,
    List<Map<String, dynamic>> data,
  ) {
    return spots.map((spot) {
      final index = spot.x.toInt();
      if (index >= data.length) return null;
      
      final item = data[index];
      final date = item['date'] as String;
      final dailyAmount = item['amount'] as double;
      final cumulative = item['cumulative'] as double;
      
      return LineTooltipItem(
        '$date\n',
        TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w400,
        ),
        children: [
          TextSpan(
            text: '当日: ¥${dailyAmount.toStringAsFixed(2)}\n',
            style: TextStyle(
              color: dailyAmount >= 0 
                  ? PremiumColors.successEmerald 
                  : PremiumColors.errorRed,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(
            text: '累计: ¥${cumulative.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }).whereType<LineTooltipItem>().toList();
  }

  // 构建趋势摘要卡片
  Widget _buildTrendSummaryCard(List<Map<String, dynamic>> data) {
    final firstValue = data.first['cumulative'] as double;
    final lastValue = data.last['cumulative'] as double;
    final change = lastValue - firstValue;
    
    // 计算日均
    final dailyAverage = change / data.length;
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '期间统计',
            style: TextStyle(
              color: PremiumColors.darkCharcoal,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  '期初余额',
                  '¥${firstValue.toStringAsFixed(2)}',
                  PremiumColors.smokeGrey,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: PremiumColors.cardBorder,
              ),
              Expanded(
                child: _buildSummaryItem(
                  '期末余额',
                  '¥${lastValue.toStringAsFixed(2)}',
                  _themeColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  '净变化',
                  '${change >= 0 ? '+' : ''}¥${change.toStringAsFixed(2)}',
                  change >= 0 ? PremiumColors.successEmerald : PremiumColors.errorRed,
                  showArrow: true,
                  isPositive: change >= 0,
                ),
              ),
              Container(
                width: 1,
                height: 40.h,
                color: PremiumColors.cardBorder,
              ),
              Expanded(
                child: _buildSummaryItem(
                  '日均',
                  '${dailyAverage >= 0 ? '+' : ''}¥${dailyAverage.toStringAsFixed(2)}',
                  PremiumColors.infoNavy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建摘要项
  Widget _buildSummaryItem(String label, String value, Color color, 
      {bool showArrow = false, bool isPositive = true}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: PremiumColors.smokeGrey,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showArrow) 
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: color,
                  size: 16.w,
                ),
              if (showArrow) SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    // TODO: 根据分类返回对应图标
    return Icons.category;
  }
}