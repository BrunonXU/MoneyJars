/*
 * 罐头详情页面 (jar_detail_page.dart)
 * 
 * 功能说明：
 * - 显示收入/支出/综合罐头的详细统计信息
 * - 展示金额卡片和完整的交易记录列表
 * - 支持编辑、删除、搜索、筛选交易记录
 * - 按分类查看交易记录和时间筛选
 * 
 * 相关修改位置：
 * - P0增强：添加交易记录列表、编辑删除、搜索筛选功能
 * - 从 home_screen.dart 中拆分出来的详情页面功能
 * - 布局位置调整：优化页面布局和间距
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_constants.dart';
import '../models/transaction_record.dart';
import '../providers/transaction_provider.dart';
import '../widgets/common/error_widget.dart';
import '../widgets/common/loading_widget.dart';
import '../utils/responsive_layout.dart';

class JarDetailPage extends StatefulWidget {
  final TransactionType type;
  final TransactionProvider provider;
  final bool isComprehensive;

  const JarDetailPage({
    Key? key,
    required this.type,
    required this.provider,
    required this.isComprehensive,
  }) : super(key: key);

  @override
  State<JarDetailPage> createState() => _JarDetailPageState();
}

class _JarDetailPageState extends State<JarDetailPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  // 筛选状态
  String _searchQuery = '';
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  
  // UI状态
  bool _isLoading = false;
  String? _errorMessage;
  bool _showFilters = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }
  
  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // 设置外部背景色
      body: ResponsiveLayout.responsive(
        mobile: _buildMobileDetailLayout(),
        tablet: _buildTabletDetailLayout(),
        desktop: _buildDesktopDetailLayout(),
      ),
    );
  }
  
  // 移动端详情页布局
  Widget _buildMobileDetailLayout() {
    return Center(
      child: Container(
        width: 1.sw,
        height: 1.sh,
        margin: EdgeInsets.zero,
        constraints: BoxConstraints(
          maxWidth: 1.sw,
          maxHeight: 1.sh,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppConstants.backgroundGradient,
                  ),
                ),
                child: _buildBodyContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // 平板端详情页布局
  Widget _buildTabletDetailLayout() {
    final layout = ResponsiveLayout.getDetailLayout();
    
    return Center(
      child: Container(
        width: layout['width'],
        height: layout['height'],
        margin: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: AppConstants.backgroundGradient,
                    ),
                  ),
                  child: _buildBodyContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 桌面端详情页布局
  Widget _buildDesktopDetailLayout() {
    final layout = ResponsiveLayout.getDetailLayout();
    
    return Center(
      child: Container(
        width: layout['width'],
        height: layout['height'],
        margin: EdgeInsets.all(30.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: AppConstants.backgroundGradient,
                    ),
                  ),
                  child: _buildBodyContent(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建AppBar
  Widget _buildAppBar() {
    return Container(
      height: AppConstants.appBarHeight + 50, // 为TabBar增加高度
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppConstants.primaryGradient,
        ),
        boxShadow: AppConstants.shadowMedium,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 顶部工具栏
            Padding(
              padding: const EdgeInsets.only(
                top: AppConstants.spacingSmall,
                left: AppConstants.spacingMedium,
                right: AppConstants.spacingMedium,
              ),
              child: Row(
                children: [
                  // 返回按钮
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // 标题
                  Expanded(
                    child: Text(
                      widget.isComprehensive 
                          ? '综合统计' 
                          : (widget.type == TransactionType.income ? '收入详情' : '支出详情'),
                      style: AppConstants.titleStyle.copyWith(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 操作按钮
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear_all, color: Colors.white),
                    onPressed: _clearFilters,
                  ),
                ],
              ),
            ),
            // TabBar
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              tabs: const [
                Tab(icon: Icon(Icons.pie_chart), text: '统计'),
                Tab(icon: Icon(Icons.list), text: '明细'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          top: AppConstants.spacingLarge.h,
          left: AppConstants.spacingLarge.w,
          right: AppConstants.spacingLarge.w,
          bottom: AppConstants.spacingLarge.h,
        ),
        child: Column(
          children: [
            _buildAmountCard(),
            SizedBox(height: _showFilters ? AppConstants.spacingMedium.h : AppConstants.spacingLarge.h),
            if (_showFilters) _buildFiltersCard(),
            if (_showFilters) SizedBox(height: AppConstants.spacingMedium.h),
            Container(
              height: 450.h, // 响应式高度避免溢出
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCategoryStats(),
                  _buildTransactionsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final amount = widget.isComprehensive 
        ? widget.provider.netIncome 
        : (widget.type == TransactionType.income ? widget.provider.totalIncome : widget.provider.totalExpense);
    
    final color = widget.isComprehensive 
        ? (widget.provider.netIncome >= 0 ? AppConstants.comprehensivePositiveColor : AppConstants.comprehensiveNegativeColor)
        : (widget.type == TransactionType.income ? AppConstants.incomeColor : AppConstants.expenseColor);
    
    final recordCount = _getFilteredTransactions().length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppConstants.cardGradient,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: AppConstants.shadowLarge,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isComprehensive ? AppConstants.labelNetIncome : 
                (widget.type == TransactionType.income ? '总收入' : '总支出'),
                style: AppConstants.bodyStyle.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
              Text(
                '$recordCount 笔记录',
                style: AppConstants.captionStyle.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            '¥${amount.toStringAsFixed(2)}',
            style: AppConstants.headingStyle.copyWith(
              color: color,
              fontSize: 36,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats() {
    final stats = widget.isComprehensive 
        ? {...widget.provider.getCategoryStats(TransactionType.income), ...widget.provider.getCategoryStats(TransactionType.expense)}
        : widget.provider.getCategoryStats(widget.type);
    
    if (stats.isEmpty) {
      return EmptyStateWidget(
        message: AppConstants.hintNoData,
        description: '开始记录您的第一笔交易吧！',
        icon: Icons.account_balance_wallet_outlined,
      );
    }
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: AppConstants.shadowMedium,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLarge,
              vertical: AppConstants.spacingMedium,
            ),
            child: Text(
              widget.isComprehensive ? '分类统计' : '${widget.type == TransactionType.income ? '收入' : '支出'}分类',
              style: AppConstants.titleStyle.copyWith(
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLarge,
                vertical: AppConstants.spacingSmall,
              ),
              itemCount: stats.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppConstants.spacingSmall),
              itemBuilder: (context, index) {
                final category = stats.keys.elementAt(index);
                final amount = stats[category]!;
                final total = stats.values.reduce((a, b) => a + b);
                final percentage = (amount / total * 100).toInt();
                
                return _buildCategoryItem(category, amount, percentage);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, double amount, int percentage) {
    final color = AppConstants.categoryColors[category.hashCode % AppConstants.categoryColors.length];
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = _selectedCategory == category ? null : category;
        });
      },
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: _selectedCategory == category 
              ? color.withOpacity(0.1)
              : AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: _selectedCategory == category
              ? Border.all(color: color, width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMedium),
            Expanded(
              child: Text(
                category,
                style: AppConstants.bodyStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '¥${amount.toStringAsFixed(2)}',
                  style: AppConstants.bodyStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: AppConstants.captionStyle.copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // 筛选卡片
  Widget _buildFiltersCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLarge,
        vertical: AppConstants.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: AppConstants.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '筛选条件',
            style: AppConstants.titleStyle.copyWith(
              color: AppConstants.primaryColor,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          
          // 搜索框
          SizedBox(
            height: 45,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索描述或金额...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  borderSide: BorderSide(
                    color: AppConstants.dividerColor,
                    width: 1,
                  ),
                ),
                filled: true,
                fillColor: AppConstants.backgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingSmall,
                  vertical: AppConstants.spacingSmall,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: AppConstants.spacingSmall),
          
          // 日期范围选择
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range, size: 16),
                    label: Text(
                      _startDate != null 
                          ? DateFormat('MM/dd').format(_startDate!)
                          : '开始日期',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _selectStartDate(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range, size: 16),
                    label: Text(
                      _endDate != null 
                          ? DateFormat('MM/dd').format(_endDate!)
                          : '结束日期',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _selectEndDate(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 交易记录列表
  Widget _buildTransactionsList() {
    final transactions = _getFilteredTransactions();
    
    if (_isLoading) {
      return const LoadingWidget(message: '加载中...');
    }
    
    if (_errorMessage != null) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: () {
          setState(() {
            _errorMessage = null;
          });
        },
      );
    }
    
    if (transactions.isEmpty) {
      return EmptyStateWidget(
        message: '未找到交易记录',
        description: _hasActiveFilters() ? '尝试调整筛选条件' : '开始记录您的第一笔交易吧！',
        icon: Icons.receipt_long_outlined,
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
        boxShadow: AppConstants.shadowMedium,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '交易记录',
                  style: AppConstants.titleStyle.copyWith(
                    color: AppConstants.primaryColor,
                  ),
                ),
                Text(
                  '${transactions.length} 笔',
                  style: AppConstants.captionStyle,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLarge,
                vertical: AppConstants.spacingMedium,
              ),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const Divider(
                color: AppConstants.dividerColor,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionItem(transaction, index);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // 交易记录项
  Widget _buildTransactionItem(TransactionRecord transaction, int index) {
    final color = transaction.type == TransactionType.income
        ? AppConstants.incomeColor
        : AppConstants.expenseColor;
    
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppConstants.spacingLarge),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog(transaction);
      },
      onDismissed: (direction) {
        _deleteTransaction(transaction);
      },
      child: InkWell(
        onTap: () => _showEditTransactionDialog(transaction),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.spacingMedium,
            horizontal: AppConstants.spacingSmall,
          ),
          child: Row(
            children: [
              // 分类颜色指示器
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: AppConstants.categoryColors[
                      transaction.parentCategory.hashCode % AppConstants.categoryColors.length],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMedium),
              
              // 交易信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.description.isEmpty 
                                ? '${transaction.parentCategory} - ${transaction.subCategory}'
                                : transaction.description,
                            style: AppConstants.bodyStyle.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${transaction.type == TransactionType.income ? '+' : '-'}¥${transaction.amount.toStringAsFixed(2)}',
                          style: AppConstants.bodyStyle.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingXSmall),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingSmall,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.categoryColors[
                                transaction.parentCategory.hashCode % AppConstants.categoryColors.length].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                          ),
                          child: Text(
                            '${transaction.parentCategory} · ${transaction.subCategory}',
                            style: AppConstants.captionStyle.copyWith(
                              color: AppConstants.categoryColors[
                                  transaction.parentCategory.hashCode % AppConstants.categoryColors.length],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('MM/dd HH:mm').format(transaction.date),
                          style: AppConstants.captionStyle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 获取筛选后的交易记录
  List<TransactionRecord> _getFilteredTransactions() {
    var transactions = widget.isComprehensive
        ? widget.provider.transactions
        : widget.provider.transactions.where((t) => t.type == widget.type).toList();
    
    // 按时间排序（最新的在前）
    transactions.sort((a, b) => b.date.compareTo(a.date));
    
    // 应用筛选条件
    if (_searchQuery.isNotEmpty) {
      transactions = transactions.where((t) {
        return t.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               t.parentCategory.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               t.subCategory.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               t.amount.toString().contains(_searchQuery);
      }).toList();
    }
    
    if (_selectedCategory != null) {
      transactions = transactions.where((t) => t.parentCategory == _selectedCategory).toList();
    }
    
    if (_startDate != null) {
      transactions = transactions.where((t) => t.date.isAfter(_startDate!.subtract(const Duration(days: 1)))).toList();
    }
    
    if (_endDate != null) {
      transactions = transactions.where((t) => t.date.isBefore(_endDate!.add(const Duration(days: 1)))).toList();
    }
    
    return transactions;
  }
  
  // 是否有活动筛选
  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty || _selectedCategory != null || _startDate != null || _endDate != null;
  }
  
  // 选择开始日期
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }
  
  // 选择结束日期
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }
  
  // 删除交易记录
  Future<void> _deleteTransaction(TransactionRecord transaction) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      await widget.provider.deleteTransaction(transaction.id);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('交易记录已删除'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: '撤销',
              textColor: Colors.white,
              onPressed: () {
                // TODO: 实现撤销功能
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '删除失败: $e';
        });
      }
    }
  }
  
  // 显示删除确认对话框
  Future<bool?> _showDeleteConfirmDialog(TransactionRecord transaction) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这笔交易记录吗？\n\n${transaction.description.isEmpty ? '${transaction.parentCategory} - ${transaction.subCategory}' : transaction.description}\n¥${transaction.amount.toStringAsFixed(2)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  // 显示编辑交易对话框
  Future<void> _showEditTransactionDialog(TransactionRecord transaction) async {
    final TextEditingController amountController = TextEditingController(
      text: transaction.amount.toString(),
    );
    final TextEditingController descriptionController = TextEditingController(
      text: transaction.description,
    );
    
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑交易记录'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: '金额',
                  prefixText: '¥ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: AppConstants.spacingMedium),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => _saveEditedTransaction(
              transaction,
              amountController.text,
              descriptionController.text,
            ),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
  
  // 保存编辑的交易记录
  Future<void> _saveEditedTransaction(
    TransactionRecord transaction,
    String amountText,
    String description,
  ) async {
    try {
      final double? amount = double.tryParse(amountText);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请输入有效的金额'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final updatedTransaction = transaction.copyWith(
        amount: amount,
        description: description.trim(),
      );
      
      await widget.provider.updateTransaction(updatedTransaction);
      
      if (mounted) {
        Navigator.of(context).pop();
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('交易记录已更新'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('更新失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 