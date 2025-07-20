import 'package:flutter/material.dart';

/// 设置页面
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2818),
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: '常规设置',
            children: [
              _buildSettingItem(
                icon: Icons.palette_outlined,
                title: '主题',
                subtitle: '暗色主题',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.language_outlined,
                title: '语言',
                subtitle: '简体中文',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: '数据管理',
            children: [
              _buildSettingItem(
                icon: Icons.backup_outlined,
                title: '备份数据',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.restore_outlined,
                title: '恢复数据',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.delete_outline,
                title: '清空数据',
                onTap: () {},
                textColor: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: '关于',
            children: [
              _buildSettingItem(
                icon: Icons.info_outline,
                title: '版本',
                subtitle: 'v2.0.0',
                onTap: () {},
              ),
              _buildSettingItem(
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A3D2E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: textColor ?? Colors.white.withOpacity(0.8),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor ?? Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}