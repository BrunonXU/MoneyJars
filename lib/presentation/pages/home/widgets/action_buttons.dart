import 'package:flutter/material.dart';
import '../../transaction/add_transaction_page.dart';

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
                // TODO: 实现拖拽输入功能
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('拖拽输入功能即将上线'),
                  ),
                );
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
}