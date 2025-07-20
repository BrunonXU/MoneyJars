import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider_new.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/bottom_navigation.dart';
import 'widgets/transaction_list.dart';
import 'widgets/quick_stats.dart';
import 'widgets/action_buttons.dart';

/// 新架构主页
class HomePageNew extends StatefulWidget {
  const HomePageNew({Key? key}) : super(key: key);

  @override
  State<HomePageNew> createState() => _HomePageNewState();
}

class _HomePageNewState extends State<HomePageNew> {
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      appBar: AppBar(
        title: const Text('MoneyJars'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomePage(),
          _buildStatisticsPage(),
          _buildSettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
  
  Widget _buildHomePage() {
    return Consumer2<TransactionProviderNew, CategoryProvider>(
      builder: (context, transactionProvider, categoryProvider, child) {
        if (transactionProvider.isLoading || categoryProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (transactionProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  transactionProvider.errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    transactionProvider.loadTransactions();
                  },
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }
        
        return Column(
          children: [
            // 快速统计
            QuickStats(
              totalIncome: transactionProvider.totalIncome,
              totalExpense: transactionProvider.totalExpense,
              netIncome: transactionProvider.netIncome,
            ),
            
            // 操作按钮
            const ActionButtons(),
            
            // 交易列表
            Expanded(
              child: TransactionList(
                transactions: transactionProvider.transactions,
                onTransactionTap: (transaction) {
                  // TODO: 打开交易详情
                },
                onTransactionDelete: (transaction) async {
                  await transactionProvider.deleteTransaction(transaction.id);
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildStatisticsPage() {
    // TODO: 使用新的统计页面
    return const Center(
      child: Text(
        '统计页面',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
  
  Widget _buildSettingsPage() {
    // TODO: 使用新的设置页面
    return const Center(
      child: Text(
        '设置页面',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}