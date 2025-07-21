import 'package:flutter/material.dart';
import '../../transaction/add_transaction_page.dart';
import '../../../widgets/input/drag_input/drag_record_input_new.dart';
import '../../../widgets/input/quick_amount_input.dart';
import '../../../../core/domain/entities/transaction.dart';

/// 主页操作按钮组件
class ActionButtons extends StatelessWidget {
  final VoidCallback? onAddTransaction;
  
  const ActionButtons({
    Key? key,
    this.onAddTransaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onAddTransaction ?? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('添加交易'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC143C),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _showDragRecordInput(context);
              },
              icon: const Icon(Icons.touch_app),
              label: const Text('拖拽记账'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3D2E),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// 显示拖拽记账输入
  void _showDragRecordInput(BuildContext context) {
    // 先显示快速金额输入
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QuickAmountInput(
        onAmountConfirmed: (amount, description) {
          Navigator.pop(context);
          // 显示类型选择对话框
          _showTypeSelectionDialog(context, amount, description);
        },
      ),
    );
  }
  
  /// 显示类型选择对话框
  void _showTypeSelectionDialog(BuildContext context, double amount, String description) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A3D2E),
        title: const Text(
          '选择类型',
          style: TextStyle(color: Colors.white),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _TypeButton(
              label: '支出',
              color: const Color(0xFFDC143C),
              icon: Icons.remove_circle,
              onTap: () {
                Navigator.pop(context);
                _showDragInput(context, TransactionType.expense, amount, description);
              },
            ),
            _TypeButton(
              label: '收入',
              color: const Color(0xFFFFD700),
              icon: Icons.add_circle,
              onTap: () {
                Navigator.pop(context);
                _showDragInput(context, TransactionType.income, amount, description);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// 显示拖拽输入界面
  void _showDragInput(
    BuildContext context,
    TransactionType type,
    double amount,
    String description,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => DragRecordInputNew(
          type: type,
          amount: amount,
          description: description,
          onComplete: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('交易已保存'),
                backgroundColor: Colors.green,
              ),
            );
          },
          onCancel: () {
            Navigator.pop(context);
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}

/// 类型选择按钮
class _TypeButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  
  const _TypeButton({
    Key? key,
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}