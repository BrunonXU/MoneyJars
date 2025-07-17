import 'dart:html' as html;
import 'package:flutter/material.dart';

/// 检查环境是否支持 MoneyJars Web 运行
class EnvCheckResult {
  final bool supported;
  final String? reason;
  EnvCheckResult(this.supported, {this.reason});
}

class EnvChecker {
  /// 检查所有关键特性
  static EnvCheckResult check() {
    // 1. 检查 IndexedDB
    if (!html.window.indexedDB.supported) {
      return EnvCheckResult(false, reason: 'IndexedDB 不支持');
    }
    // 2. 检查 localStorage/sessionStorage
    try {
      html.window.localStorage['__test__'] = '1';
      html.window.localStorage.remove('__test__');
      html.window.sessionStorage['__test__'] = '1';
      html.window.sessionStorage.remove('__test__');
    } catch (e) {
      return EnvCheckResult(false, reason: 'localStorage/sessionStorage 不支持');
    }
    // 3. 检查 Service Worker
    // 不能直接用 supported，改为判断 serviceWorker 是否为 null
    if (html.window.navigator.serviceWorker == null) {
      return EnvCheckResult(false, reason: 'Service Worker 不支持');
    }
    // 4. 检查主流浏览器
    final ua = html.window.navigator.userAgent.toLowerCase();
    final isSupportedBrowser =
        ua.contains('chrome') || ua.contains('firefox') || ua.contains('safari') || ua.contains('edg');
    if (!isSupportedBrowser) {
      return EnvCheckResult(false, reason: '非主流浏览器');
    }
    // 5. 检查无痕/隐私模式（部分浏览器可检测）
    // 这里只能做简单检测，无法100%准确
    try {
      html.window.localStorage['__incognito_test__'] = '1';
      html.window.localStorage.remove('__incognito_test__');
    } catch (e) {
      return EnvCheckResult(false, reason: '可能处于无痕/隐私模式');
    }
    return EnvCheckResult(true);
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