/*
 * 分类管理页面 (category_management_page.dart)
 * 
 * 功能说明：
 * - 管理收入和支出分类
 * - 添加、编辑、删除分类
 * - 设置分类图标和颜色
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/premium_color_scheme.dart';
import '../../models/transaction_record_hive.dart' as hive;
import '../../services/providers/transaction_provider.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({Key? key}) : super(key: key);

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCategoryList(hive.TransactionType.expense),
                        _buildCategoryList(hive.TransactionType.income),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewCategory,
        backgroundColor: PremiumColors.luxuryGold,
        child: Icon(Icons.add, color: Colors.black),
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
            color: PremiumColors.cardShadow.withValues(alpha: 0.3),
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
              // 中间标题
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      flex: 0,
                      child: Hero(
                        tag: 'app_icon',
                        child: Container(
                          width: (AppConstants.iconXLarge + 4).w,
                          height: (AppConstants.iconXLarge + 4).h,
                          constraints: BoxConstraints(
                            maxWidth: 40.w,
                            maxHeight: 40.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                            boxShadow: [
                              BoxShadow(
                                color: PremiumColors.cardShadow.withValues(alpha: 0.2),
                                blurRadius: 4.0,
                                offset: Offset(0, 1.0),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.category,
                            size: AppConstants.iconMedium.sp,
                            color: PremiumColors.deepWineRed,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppConstants.spacingMedium.w),
                    Flexible(
                      flex: 1,
                      child: Text(
                        'MoneyJars - 分类管理',
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
              SizedBox(width: 48.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: PremiumColors.luxuryGold,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey[600],
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.remove_circle_outline),
                SizedBox(width: 8.w),
                Text('支出分类'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline),
                SizedBox(width: 8.w),
                Text('收入分类'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(hive.TransactionType type) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final categories = provider.getCategories().where((c) => c.type == type).toList();
        
        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == hive.TransactionType.expense ? Icons.remove_circle_outline : Icons.add_circle_outline,
                  size: 80.sp,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16.h),
                Text(
                  '暂无${type == hive.TransactionType.expense ? '支出' : '收入'}分类',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '点击右下角按钮添加新分类',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryItem(category);
          },
        );
      },
    );
  }

  Widget _buildCategoryItem(hive.Category category) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: PremiumColors.cardShadow.withValues(alpha: 0.1),
            blurRadius: 4.0,
            offset: Offset(0, 2.0),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: _getCategoryColor(category).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(category),
            color: _getCategoryColor(category),
            size: 24.sp,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: PremiumColors.deepWineRed,
          ),
        ),
        subtitle: Text(
          category.type == hive.TransactionType.expense ? '支出分类' : '收入分类',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text('编辑'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20.sp, color: PremiumColors.errorRed),
                  SizedBox(width: 8.w),
                  Text('删除', style: TextStyle(color: PremiumColors.errorRed)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _editCategory(category);
            } else if (value == 'delete') {
              _deleteCategory(category);
            }
          },
        ),
      ),
    );
  }

  Color _getCategoryColor(hive.Category category) {
    final colors = PremiumColors.premiumCategoryColors;
    final index = category.name.hashCode % colors.length;
    return colors[index.abs()];
  }

  IconData _getCategoryIcon(hive.Category category) {
    // 根据分类名称返回对应图标
    final iconMap = {
      '餐饮': Icons.restaurant,
      '交通': Icons.directions_car,
      '购物': Icons.shopping_bag,
      '娱乐': Icons.movie,
      '住房': Icons.home,
      '医疗': Icons.medical_services,
      '教育': Icons.school,
      '旅行': Icons.flight,
      '工资': Icons.work,
      '投资': Icons.show_chart,
      '兼职': Icons.work_outline,
      '礼金': Icons.card_giftcard,
      '其他': Icons.more_horiz,
    };
    
    return iconMap[category.name] ?? Icons.category;
  }

  void _addNewCategory() {
    final type = _tabController.index == 0 ? hive.TransactionType.expense : hive.TransactionType.income;
    _showCategoryDialog(type: type);
  }

  void _editCategory(hive.Category category) {
    _showCategoryDialog(category: category);
  }

  void _deleteCategory(hive.Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('确定要删除分类"${category.name}"吗？\n\n注意：删除分类后，该分类下的所有交易记录将被移至"其他"分类。'),
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
      await provider.deleteCategory(category.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除分类"${category.name}"'),
            backgroundColor: PremiumColors.successEmerald,
          ),
        );
      }
    }
  }

  void _showCategoryDialog({hive.TransactionType? type, hive.Category? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    hive.TransactionType selectedType = type ?? category!.type;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEditing ? '编辑分类' : '添加分类'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '分类名称',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              SizedBox(height: 16.h),
              Text('分类类型', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<hive.TransactionType>(
                      title: Text('支出'),
                      value: hive.TransactionType.expense,
                      groupValue: selectedType,
                      onChanged: isEditing ? null : (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<hive.TransactionType>(
                      title: Text('收入'),
                      value: hive.TransactionType.income,
                      groupValue: selectedType,
                      onChanged: isEditing ? null : (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () => _saveCategory(
                nameController.text.trim(),
                selectedType,
                category,
              ),
              child: Text(isEditing ? '保存' : '添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCategory(String name, hive.TransactionType type, hive.Category? existingCategory) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请输入分类名称'),
          backgroundColor: PremiumColors.errorRed,
        ),
      );
      return;
    }

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    
    try {
      if (existingCategory != null) {
        // 编辑现有分类
        final updatedCategory = hive.Category.create(
          id: existingCategory.id,
          name: name,
          type: type,
          color: existingCategory.color,
          icon: existingCategory.icon,
          subCategories: existingCategory.subCategories,
        );
        await provider.updateCategory(updatedCategory);
      } else {
        // 添加新分类
        final newCategory = hive.Category.create(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          type: type,
          color: 0xFF9B59B6, // 默认颜色
          icon: 'category', // 默认图标
          subCategories: [], // 空的子分类列表
        );
        await provider.addCategory(newCategory);
      }
      
      Navigator.pop(context);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(existingCategory != null ? '分类已更新' : '分类已添加'),
            backgroundColor: PremiumColors.successEmerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败：$e'),
            backgroundColor: PremiumColors.errorRed,
          ),
        );
      }
    }
  }
}