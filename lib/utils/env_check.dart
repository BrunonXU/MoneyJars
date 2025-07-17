import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 条件导入：Web平台导入实际实现，其他平台导入存根
import 'env_check_stub.dart' if (dart.library.html) 'env_check_web.dart';

/// 检查环境是否支持 MoneyJars Web 运行
class EnvCheckResult {
  final bool supported;
  final String? reason;
  EnvCheckResult(this.supported, {this.reason});
}

class EnvChecker {
  /// 检查所有关键特性
  static EnvCheckResult check() {
    // 非Web平台直接返回支持
    if (!kIsWeb) {
      return EnvCheckResult(true);
    }
    
    // Web平台进行详细检查
    return _checkWebEnvironment();
  }
  
  /// Web平台环境检查
  static EnvCheckResult _checkWebEnvironment() {
    try {
      // 使用条件导入的Web检查器
      return WebEnvChecker.performWebChecks();
    } catch (e) {
      return EnvCheckResult(false, reason: 'Web环境检查失败: $e');
    }
  }
}

/// 不支持环境时的提示页
class EnvNotSupportedPage extends StatelessWidget {
  final String? reason;
  const EnvNotSupportedPage({Key? key, this.reason}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181F1B),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 80),
              const SizedBox(height: 32),
              const Text(
                '当前浏览器或环境不支持 MoneyJars Web 版',
                style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                '建议使用最新版 Chrome、Edge、Firefox、Safari，并关闭无痕/隐私模式。',
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              if (reason != null) ...[
                const SizedBox(height: 12),
                Text(
                  '检测原因：$reason',
                  style: const TextStyle(fontSize: 14, color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              const Divider(color: Colors.white24),
              const SizedBox(height: 12),
              const Text(
                'Your browser or environment is not supported.\nPlease use the latest Chrome, Edge, Firefox, or Safari, and disable incognito/private mode.',
                style: TextStyle(fontSize: 13, color: Colors.white54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              const Text(
                '如需协助请联系 Bruno 先生：xza23520168352024@163.com',
                style: TextStyle(fontSize: 14, color: Colors.orangeAccent),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 