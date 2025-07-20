/*
 * 新分类创建对话框 (new_category_dialog.dart)
 * 
 * 功能说明：
 * - 创建新的交易分类
 * - 支持父分类和子分类
 * - 图标和颜色选择
 * 
 * 交互设计：
 * - 分步骤创建
 * - 实时预览
 * - 验证输入
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/domain/entities/category.dart';
import '../../../../core/domain/entities/transaction.dart';
import '../../../providers/category_provider.dart';

/// 新分类创建对话框
class NewCategoryDialog extends StatefulWidget {
  /// 交易类型
  final TransactionType transactionType;
  
  /// 父分类（创建子分类时使用）
  final Category? parentCategory;
  
  /// 是否创建子分类
  final bool isSubCategory;
  
  const NewCategoryDialog({
    Key? key,
    required this.transactionType,
    this.parentCategory,
    this.isSubCategory = false,
  }) : super(key: key);
  
  @override
  State<NewCategoryDialog> createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewCategoryDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _nameController = TextEditingController();
  
  String _selectedIcon = '📝';
  Color _selectedColor = Colors.blue;
  bool _isCreating = false;
  String? _errorMessage;
  
  // 预设图标
  final List<String> _incomeIcons = [
    '💰', '💵', '💴', '💶', '💷', '💸', '💳', '🏦',
    '📈', '💹', '🎯', '🏆', '🎁', '🎉', '🎊', '✨',
  ];
  
  final List<String> _expenseIcons = [
    '🛍️', '🍔', '🚗', '🏠', '✈️', '🎬', '🎮', '📚',
    '💊', '👔', '💄', '🎓', '🏥', '⚡', '📱', '🎯',
  ];
  
  // 预设颜色
  final List<Color> _presetColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 根据类型选择默认图标
    _selectedIcon = widget.transactionType == TransactionType.income
        ? _incomeIcons.first
        : _expenseIcons.first;
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 400,
        height: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 标题
            Text(
              widget.isSubCategory ? '创建子分类' : '创建新分类',
              style: theme.textTheme.headlineSmall,
            ),
            
            if (widget.parentCategory != null) ...[
              const SizedBox(height: 8),
              Text(
                '父分类：${widget.parentCategory!.name}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // 预览
            _buildPreview(),
            
            const SizedBox(height: 20),
            
            // 标签页
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '名称'),
                Tab(text: '图标'),
                Tab(text: '颜色'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 标签页内容
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildNameTab(),
                  _buildIconTab(),
                  _buildColorTab(),
                ],
              ),
            ),
            
            // 错误提示
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isCreating ? null : _createCategory,
                  child: _isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('创建'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// 构建预览
  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _selectedColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _selectedIcon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 名称
          Text(
            _nameController.text.isEmpty
                ? (widget.isSubCategory ? '子分类名称' : '分类名称')
                : _nameController.text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _nameController.text.isEmpty
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : null,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建名称标签页
  Widget _buildNameTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '请输入${widget.isSubCategory ? '子' : ''}分类名称',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            autofocus: true,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: '例如：${_getSampleName()}',
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Text(
            '名称应简洁明了，便于识别',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
  
  /// 构建图标标签页
  Widget _buildIconTab() {
    final icons = widget.transactionType == TransactionType.income
        ? _incomeIcons
        : _expenseIcons;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择一个图标',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                final icon = icons[index];
                final isSelected = icon == _selectedIcon;
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withOpacity(0.2)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).dividerColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建颜色标签页
  Widget _buildColorTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择分类颜色',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _presetColors.length,
              itemBuilder: (context, index) {
                final color = _presetColors[index];
                final isSelected = color == _selectedColor;
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.onPrimary,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// 获取示例名称
  String _getSampleName() {
    if (widget.isSubCategory) {
      switch (widget.parentCategory?.name) {
        case '工资收入':
          return '基本工资、奖金';
        case '饮食':
          return '早餐、午餐';
        default:
          return '子分类名称';
      }
    } else {
      return widget.transactionType == TransactionType.income
          ? '工资、投资'
          : '饮食、交通';
    }
  }
  
  /// 创建分类
  Future<void> _createCategory() async {
    // 验证输入
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = '请输入分类名称';
      });
      return;
    }
    
    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });
    
    try {
      final categoryProvider = context.read<CategoryProvider>();
      
      if (widget.isSubCategory && widget.parentCategory != null) {
        // 创建子分类
        final subCategory = SubCategory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          icon: _selectedIcon,
        );
        
        await categoryProvider.addSubCategory(
          widget.parentCategory!.id,
          subCategory,
        );
      } else {
        // 创建主分类
        final category = Category(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor.value,
          type: widget.transactionType == TransactionType.income
              ? CategoryType.income
              : CategoryType.expense,
          isSystem: false,
          isEnabled: true,
          subCategories: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: null,
          usageCount: 0,
        );
        
        await categoryProvider.addCategory(category);
      }
      
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = '创建失败：$e';
        _isCreating = false;
      });
    }
  }
}