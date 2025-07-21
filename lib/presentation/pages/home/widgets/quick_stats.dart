import 'package:flutter/material.dart';

/// 快速统计组件
class QuickStats extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final double netIncome;
  
  const QuickStats({
    Key? key,
    required this.totalIncome,
    required this.totalExpense,
    required this.netIncome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A3D2E),
            const Color(0xFF0D2818).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '本月净收入',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¥${netIncome.toStringAsFixed(2)}',
            style: TextStyle(
              color: netIncome >= 0 ? const Color(0xFFFFD700) : const Color(0xFFDC143C),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: '收入',
                value: totalIncome,
                color: const Color(0xFFFFD700),
                icon: Icons.arrow_upward,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              _StatItem(
                label: '支出',
                value: totalExpense,
                color: const Color(0xFFDC143C),
                icon: Icons.arrow_downward,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  
  const _StatItem({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '¥${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}