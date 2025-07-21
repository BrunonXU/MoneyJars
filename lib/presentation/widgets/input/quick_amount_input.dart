import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 快速金额输入组件
class QuickAmountInput extends StatefulWidget {
  final Function(double amount, String description) onAmountConfirmed;
  
  const QuickAmountInput({
    Key? key,
    required this.onAmountConfirmed,
  }) : super(key: key);

  @override
  State<QuickAmountInput> createState() => _QuickAmountInputState();
}

class _QuickAmountInputState extends State<QuickAmountInput> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocusNode = FocusNode();
  bool _isValid = false;
  
  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validateInput);
    // 自动聚焦到金额输入框
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }
  
  void _validateInput() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    setState(() {
      _isValid = amount > 0;
    });
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A3D2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动指示器
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // 标题
          const Text(
            '输入金额',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // 金额输入
          TextField(
            controller: _amountController,
            focusNode: _amountFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              prefixText: '¥ ',
              prefixStyle: const TextStyle(
                color: Colors.white70,
                fontSize: 24,
              ),
              hintText: '0.00',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 36,
              ),
              border: InputBorder.none,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFDC143C),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // 描述输入
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '备注（可选）',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 确认按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isValid ? _confirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC143C),
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '下一步',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _confirm() {
    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text.trim();
    widget.onAmountConfirmed(
      amount,
      description.isEmpty ? '记账' : description,
    );
  }
}