import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/transaction_record.dart';
import '../providers/transaction_provider.dart';

class JarSettingsDialog extends StatefulWidget {
  const JarSettingsDialog({Key? key}) : super(key: key);

  @override
  State<JarSettingsDialog> createState() => _JarSettingsDialogState();
}

class _JarSettingsDialogState extends State<JarSettingsDialog> {
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    _titleController.text = provider.jarSettings.title;
    _targetAmountController.text = provider.jarSettings.targetAmount.toString();
    _selectedDeadline = provider.jarSettings.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('罐头设置'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题输入
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '罐头标题',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入罐头标题';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // 目标金额输入
            TextFormField(
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: '目标金额',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: '¥ ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入目标金额';
                }
                if (double.tryParse(value) == null) {
                  return '请输入有效金额';
                }
                if (double.parse(value) <= 0) {
                  return '目标金额必须大于0';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // 截止日期选择
            InkWell(
              onTap: _selectDeadline,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '截止日期 (可选)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDeadline != null
                      ? '${_selectedDeadline!.year}-${_selectedDeadline!.month.toString().padLeft(2, '0')}-${_selectedDeadline!.day.toString().padLeft(2, '0')}'
                      : '点击选择截止日期',
                  style: TextStyle(
                    color: _selectedDeadline != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 清除截止日期按钮
            if (_selectedDeadline != null)
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDeadline = null;
                  });
                },
                child: const Text('清除截止日期'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveSettings,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (date != null) {
      setState(() {
        _selectedDeadline = date;
      });
    }
  }

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      
      final newSettings = JarSettings(
        title: _titleController.text.trim(),
        targetAmount: double.parse(_targetAmountController.text),
        deadline: _selectedDeadline,
      );
      
      try {
        await provider.updateJarSettings(newSettings);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('设置已保存'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 