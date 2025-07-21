/*
 * 简化版主入口 (main_simple.dart)
 * 
 * 功能说明：
 * - 用于测试新架构的最小可运行版本
 * - 移除所有复杂依赖，确保能够启动
 */

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化Hive
  await Hive.initFlutter();
  
  runApp(const SimpleApp());
}

class SimpleApp extends StatelessWidget {
  const SimpleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyJars 新架构测试',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0D2818),
      ),
      home: const SimpleHomePage(),
    );
  }
}

class SimpleHomePage extends StatefulWidget {
  const SimpleHomePage({Key? key}) : super(key: key);

  @override
  State<SimpleHomePage> createState() => _SimpleHomePageState();
}

class _SimpleHomePageState extends State<SimpleHomePage> {
  final List<Map<String, dynamic>> _transactions = [];
  
  void _addTransaction() {
    setState(() {
      _transactions.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'amount': 100.0,
        'description': '测试交易 ${_transactions.length + 1}',
        'type': 'expense',
        'date': DateTime.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoneyJars 新架构测试'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 统计卡片
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3D2E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  '新架构测试版',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  '交易数量: ${_transactions.length}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          
          // 添加按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _addTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC143C),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('添加测试交易'),
            ),
          ),
          
          // 交易列表
          Expanded(
            child: _transactions.isEmpty
                ? const Center(
                    child: Text(
                      '暂无交易记录',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      return Card(
                        color: const Color(0xFF1A3D2E),
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            tx['description'],
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '¥${tx['amount']}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Icon(
                            Icons.remove_circle,
                            color: Colors.red.withOpacity(0.7),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0D2818),
        selectedItemColor: const Color(0xFFDC143C),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '统计'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}