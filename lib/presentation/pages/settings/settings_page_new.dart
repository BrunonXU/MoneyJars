/*
 * 设置页面 (settings_page_new.dart)
 * 
 * 功能说明：
 * - 应用设置管理
 * - 数据迁移入口
 * - 主题切换
 * - 关于页面
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'migration_page.dart';

/// 设置页面
class SettingsPageNew extends StatelessWidget {
  const SettingsPageNew({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: '外观',
          children: [
            _buildThemeToggle(context),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: '数据管理',
          children: [
            _buildMigrationTile(context),
            _buildExportTile(context),
            _buildBackupTile(context),
          ],
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: '关于',
          children: [
            _buildAboutTile(context),
            _buildVersionTile(),
          ],
        ),
      ],
    );
  }
  
  /// 构建设置区块
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A3D2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.white24),
          ...children,
        ],
      ),
    );
  }
  
  /// 构建主题切换项
  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color: Colors.white70,
          ),
          title: const Text(
            '深色模式',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            themeProvider.isDarkMode ? '已启用' : '已关闭',
            style: const TextStyle(color: Colors.white60),
          ),
          trailing: Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            activeColor: Colors.green,
          ),
        );
      },
    );
  }
  
  /// 构建数据迁移项
  Widget _buildMigrationTile(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.sync,
        color: Colors.white70,
      ),
      title: const Text(
        '数据迁移',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        '从旧版本迁移数据到新架构',
        style: TextStyle(color: Colors.white60),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white30,
        size: 16,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MigrationPage(),
          ),
        );
      },
    );
  }
  
  /// 构建导出数据项
  Widget _buildExportTile(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.file_download,
        color: Colors.white70,
      ),
      title: const Text(
        '导出数据',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        '导出数据为CSV或JSON格式',
        style: TextStyle(color: Colors.white60),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white30,
        size: 16,
      ),
      onTap: () {
        // TODO: 实现数据导出功能
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('导出功能即将推出'),
            backgroundColor: Colors.orange,
          ),
        );
      },
    );
  }
  
  /// 构建备份数据项
  Widget _buildBackupTile(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.backup,
        color: Colors.white70,
      ),
      title: const Text(
        '备份与恢复',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        '创建数据备份或恢复数据',
        style: TextStyle(color: Colors.white60),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white30,
        size: 16,
      ),
      onTap: () {
        // TODO: 实现备份功能
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('备份功能即将推出'),
            backgroundColor: Colors.orange,
          ),
        );
      },
    );
  }
  
  /// 构建关于项
  Widget _buildAboutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.info_outline,
        color: Colors.white70,
      ),
      title: const Text(
        '关于MoneyJars',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        '了解更多关于此应用',
        style: TextStyle(color: Colors.white60),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white30,
        size: 16,
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A3D2E),
            title: const Text(
              '关于MoneyJars',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'MoneyJars是一款创新的记账应用，'
              '采用独特的拖拽式交互设计，'
              '让记账变得简单有趣。\n\n'
              '特色功能：\n'
              '• 拖拽快速记账\n'
              '• 智能分类管理\n'
              '• 数据可视化统计\n'
              '• 多设备数据同步',
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
      },
    );
  }
  
  /// 构建版本信息项
  Widget _buildVersionTile() {
    return const ListTile(
      leading: Icon(
        Icons.code,
        color: Colors.white70,
      ),
      title: Text(
        '版本信息',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'v2.0.0 (新架构版本)',
        style: TextStyle(color: Colors.white60),
      ),
    );
  }
}