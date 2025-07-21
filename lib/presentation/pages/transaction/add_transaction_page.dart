import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/domain/entities/transaction.dart' as domain;
import '../../providers/transaction_provider_new.dart';
import '../../providers/category_provider.dart';

/// 添加交易页面
class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  domain.TransactionType _selectedType = domain.TransactionType.expense;
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  DateTime _selectedDate = DateTime.now();
  
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      appBar: AppBar(
        title: const Text('添加交易'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 交易类型选择
            _buildTypeSelector(),
            const SizedBox(height: 20),
            
            // 金额输入
            _buildAmountField(),
            const SizedBox(height: 20),
            
            // 描述输入
            _buildDescriptionField(),
            const SizedBox(height: 20),
            
            // 分类选择
            _buildCategorySelector(),
            const SizedBox(height: 20),
            
            // 日期选择
            _buildDateSelector(),
            const SizedBox(height: 40),
            
            // 保存按钮
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<domain.TransactionType>(
            title: const Text('支出', style: TextStyle(color: Colors.white)),
            value: domain.TransactionType.expense,
            groupValue: _selectedType,
            activeColor: const Color(0xFFDC143C),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                _selectedCategoryId = null;
                _selectedCategoryName = null;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<domain.TransactionType>(
            title: const Text('收入', style: TextStyle(color: Colors.white)),
            value: domain.TransactionType.income,
            groupValue: _selectedType,
            activeColor: const Color(0xFFFFD700),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                _selectedCategoryId = null;
                _selectedCategoryName = null;
              });
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: '金额',
        prefixText: '¥ ',
        labelStyle: TextStyle(color: Colors.white70),
        prefixStyle: TextStyle(color: Colors.white),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入金额';
        }
        if (double.tryParse(value) == null) {
          return '请输入有效的金额';
        }
        return null;
      },
    );
  }
  
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: '描述',
        labelStyle: TextStyle(color: Colors.white70),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请输入描述';
        }
        return null;
      },
    );
  }
  
  Widget _buildCategorySelector() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = _selectedType == domain.TransactionType.income
            ? categoryProvider.incomeCategories
            : categoryProvider.expenseCategories;
            
        return DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          decoration: const InputDecoration(
            labelText: '分类',
            labelStyle: TextStyle(color: Colors.white70),
          ),
          dropdownColor: const Color(0xFF1A3D2E),
          style: const TextStyle(color: Colors.white),
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category.id,
              child: Row(
                children: [
                  Icon(
                    Icons.category,
                    color: Color(category.color),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            final category = categories.firstWhere((c) => c.id == value);
            setState(() {
              _selectedCategoryId = value;
              _selectedCategoryName = category.name;
            });
          },
          validator: (value) {
            if (value == null) {
              return '请选择分类';
            }
            return null;
          },
        );
      },
    );
  }
  
  Widget _buildDateSelector() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          locale: const Locale('zh', 'CN'),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '日期',
          labelStyle: TextStyle(color: Colors.white70),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.calendar_today, color: Colors.white70),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveTransaction,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text('保存', style: TextStyle(fontSize: 18)),
    );
  }
  
  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text;
    
    final transaction = domain.Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      description: description,
      parentCategoryId: _selectedCategoryId!,
      parentCategoryName: _selectedCategoryName!,
      type: _selectedType,
      date: _selectedDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: 'default_user',
      tags: [],
      attachments: [],
    );
    
    try {
      final provider = context.read<TransactionProviderNew>();
      await provider.addTransaction(transaction);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('交易已保存')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }
}