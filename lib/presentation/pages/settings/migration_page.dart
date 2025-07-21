/*
 * 数据迁移页面 (migration_page.dart)
 * 
 * 功能说明：
 * - 提供用户友好的迁移界面
 * - 显示迁移进度和结果
 * - 支持备份和恢复
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/storage_service.dart';
import '../../../core/data/datasources/local/hive_datasource.dart';
import '../../../tools/migration/data_migration_tool.dart';
import '../../../core/di/service_locator.dart';

/// 数据迁移页面
class MigrationPage extends StatefulWidget {
  const MigrationPage({Key? key}) : super(key: key);

  @override
  State<MigrationPage> createState() => _MigrationPageState();
}

class _MigrationPageState extends State<MigrationPage> {
  bool _isMigrating = false;
  double _progress = 0.0;
  String _progressMessage = '';
  MigrationResult? _result;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3D2E),
        title: const Text('数据迁移'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            if (!_isMigrating && _result == null) _buildActionButtons(),
            if (_isMigrating) _buildProgressIndicator(),
            if (_result != null) _buildResultCard(),
          ],
        ),
      ),
    );
  }
  
  /// 构建信息卡片
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3D2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '数据迁移说明',
                style: TextStyle(
                  color: Colors.blue[400],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '此功能将帮助您将旧版本的数据迁移到新架构：',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          _buildInfoItem('• 所有分类和子分类'),
          _buildInfoItem('• 所有交易记录'),
          _buildInfoItem('• 应用设置和偏好'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.orange[400],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '建议在迁移前备份现有数据',
                    style: TextStyle(
                      color: Colors.orange[400],
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建信息项
  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 14,
        ),
      ),
    );
  }
  
  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _startMigration,
          icon: const Icon(Icons.sync),
          label: const Text('开始迁移'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _checkDataStatus,
          icon: const Icon(Icons.assessment),
          label: const Text('检查数据状态'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
  
  /// 构建进度指示器
  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3D2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          const Text(
            '正在迁移数据...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          const SizedBox(height: 12),
          Text(
            '${(_progress * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _progressMessage,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建结果卡片
  Widget _buildResultCard() {
    final result = _result!;
    final isSuccess = result.success;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3D2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? Colors.green : Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            isSuccess ? '迁移成功！' : '迁移失败',
            style: TextStyle(
              color: isSuccess ? Colors.green : Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              result.summary,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),
          if (result.errors.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '错误详情：',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...result.errors.map((error) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          '• $error',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _result = null;
                _progress = 0.0;
                _progressMessage = '';
              });
            },
            child: const Text('完成'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 开始迁移
  Future<void> _startMigration() async {
    setState(() {
      _isMigrating = true;
      _progress = 0.0;
      _progressMessage = '正在准备迁移...';
    });
    
    try {
      // 获取旧存储和新存储实例
      // 注意：需要使用StorageServiceAdapter而不是抽象的StorageService
      // 暂时跳过实际迁移，因为需要具体的旧版本实现
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('数据迁移功能正在开发中'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        _isMigrating = false;
      });
      return;
      
    } catch (e) {
      setState(() {
        _isMigrating = false;
        _result = MigrationResult()
          ..success = false
          ..errors = ['迁移过程中发生错误：$e'];
      });
    }
  }
  
  /// 检查数据状态
  Future<void> _checkDataStatus() async {
    try {
      // 暂时显示模拟数据
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A3D2E),
            title: const Text(
              '数据状态',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              '旧版本数据：\n'
              '- 分类：检测中...\n'
              '- 交易记录：检测中...\n\n'
              '新架构数据：\n'
              '- 请在迁移后查看\n\n'
              '注：实际迁移功能正在开发中',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
      return;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('检查数据状态失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}