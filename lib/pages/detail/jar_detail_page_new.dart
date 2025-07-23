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
        if (_currentView == ViewMode.trend)
          PopupMenuItem(
            value: 'timeRange',
            child: Row(
              children: [
                Icon(Icons.date_range, color: PremiumColors.darkCharcoal, size: 18),
                SizedBox(width: 12.w),
                Text('时间范围', style: TextStyle(color: PremiumColors.darkCharcoal, fontSize: 14.sp)),
              ],
            ),
          ),
      ],
      onSelected: _handleMenuAction,
    );
  }

  // 删除了未使用的SliverAppBar相关方法

  // 构建智能分析卡片
  Widget _buildAnalysisCard() {
    return Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final stats = _calculateStats(provider);
          
          return Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _themeColor.withOpacity(0.2),
                  PremiumColors.darkCharcoal,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: PremiumColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '智能分析',
                      style: TextStyle(
                        color: PremiumColors.darkCharcoal,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // 高级功能按钮
                    _buildActionButtons(),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '本期总额',
                        '¥${stats['total']?.toStringAsFixed(2) ?? '0.00'}',
                        _themeColor,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildStatItem(
                        '对比上期',
                        '${stats['changePercent'] ?? 0}%',
                        stats['changePercent'] != null && stats['changePercent'] > 0
                            ? PremiumColors.successEmerald
                            : PremiumColors.errorRed,
                        showArrow: true,
                        isPositive: stats['changePercent'] != null && stats['changePercent'] > 0,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _buildStatItem(
                        '交易笔数',
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
    return Center(
      child: Text(
        '趋势图视图开发中...',
        style: TextStyle(color: PremiumColors.darkCharcoal),
      ),
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

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        // TODO: 实现导出功能
        break;
      case 'filter':
        // TODO: 实现高级筛选
        break;
      case 'batch':
        _enterSelectionMode(null);
        break;
      case 'timeRange':
        _showTimeRangeDialog();
        break;
    }
  }

  void _enterSelectionMode(String? initialId) {
    setState(() {
      _isSelectionMode = true;
      if (initialId != null) {
        _selectedItems.add(initialId);
      }
    });
  }

  void _handleBatchAction() {
    // TODO: 实现批量删除
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
        title: Text('选择时间范围', style: TextStyle(color: PremiumColors.darkCharcoal)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['本周', '本月', '三个月', '一年'].map((range) => 
            ListTile(
              title: Text(range, style: TextStyle(color: PremiumColors.darkCharcoal)),
              leading: Radio<String>(
                value: range,
                groupValue: _timeRange,
                onChanged: (value) {
                  setState(() => _timeRange = value!);
                  Navigator.pop(context);
                },
                activeColor: _themeColor,
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

  IconData _getCategoryIcon(String category) {
    // TODO: 根据分类返回对应图标
    return Icons.category;
  }
}