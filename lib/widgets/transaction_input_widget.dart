import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_record_hive.dart';

class TransactionInputWidget extends StatefulWidget {
  final TransactionType type;
  final VoidCallback onCancel;
  final Function(double amount, String description, String category) onSubmit;

  const TransactionInputWidget({
    super.key,
    required this.type,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  State<TransactionInputWidget> createState() => _TransactionInputWidgetState();
}

class _TransactionInputWidgetState extends State<TransactionInputWidget>
    with SingleTickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  String _selectedCategory = '';
  bool _isAmountValid = false;
  bool _isDescriptionValid = false;

  @override
  void initState() {
    super.initState();
    
    // 设置默认分类
    _selectedCategory = widget.type == TransactionType.income ? '工资' : '餐饮';
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    
    // 监听输入变化
    _amountController.addListener(_validateAmount);
    _descriptionController.addListener(_validateDescription);

    // 自动聚焦到金额输入
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  void _validateAmount() {
    setState(() {
      _isAmountValid = _amountController.text.isNotEmpty && 
                     double.tryParse(_amountController.text) != null &&
                     double.parse(_amountController.text) > 0;
    });
  }

  void _validateDescription() {
    setState(() {
      _isDescriptionValid = _descriptionController.text.trim().isNotEmpty;
    });
  }

  bool get _canSubmit => _isAmountValid && _isDescriptionValid;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitTransaction() {
    if (!_canSubmit) return;

    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text.trim();
    
    widget.onSubmit(amount, description, _selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onCancel(),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // 防止点击输入区域时关闭
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 标题
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.type == TransactionType.income ? '记录收入' : '记录支出',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: widget.onCancel,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // 金额输入
                      _buildAmountInput(),
                      const SizedBox(height: 16),
                      
                      // 描述输入
                      _buildDescriptionInput(),
                      const SizedBox(height: 16),
                      
                      // 分类选择
                      _buildCategorySelector(),
                      const SizedBox(height: 24),
                      
                      // 提交按钮
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '金额',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isAmountValid ? Colors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              hintText: '0.00',
              prefixIcon: Icon(
                Icons.attach_money,
                color: widget.type == TransactionType.income ? Colors.green : Colors.red,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            onSubmitted: (_) => _descriptionFocusNode.requestFocus(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '备注',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isDescriptionValid ? Colors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextField(
            controller: _descriptionController,
            focusNode: _descriptionFocusNode,
            decoration: const InputDecoration(
              hintText: '请输入备注信息...',
              prefixIcon: Icon(Icons.edit_note),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: (_) => _submitTransaction(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = widget.type == TransactionType.income 
        ? DefaultCategories.incomeCategories 
        : DefaultCategories.expenseCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category.name;
              
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category.name;
                    });
                  },
                  child: Container(
                    width: 70,
                    decoration: BoxDecoration(
                      color: isSelected ? Color(category.color) : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected 
                          ? Border.all(color: Color(category.color), width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          category.icon,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _canSubmit ? _submitTransaction : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.type == TransactionType.income ? Colors.green : Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: _canSubmit ? 5 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.type == TransactionType.income ? Icons.add : Icons.remove,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              widget.type == TransactionType.income ? '添加收入' : '添加支出',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 