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
    return Center(
      child: Text(
        '饼状图视图开发中...',
        style: TextStyle(color: PremiumColors.darkCharcoal),
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

  IconData _getCategoryIcon(String category) {
    // TODO: 根据分类返回对应图标
    return Icons.category;
  }
}