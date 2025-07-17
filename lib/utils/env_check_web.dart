import 'dart:html' as html;
import 'env_check.dart';

/// Web平台专用环境检查
class WebEnvChecker {
  /// 执行Web环境检查
  static EnvCheckResult performWebChecks() {
    // 1. 检查 IndexedDB（可选，不阻断运行）
    // 某些移动端浏览器可能不支持IndexedDB
    if (html.window.indexedDB == null) {
      print('警告: IndexedDB 不支持，将使用localStorage作为替代');
    }
    
    // 2. 检查 localStorage/sessionStorage（基本要求）
    try {
      html.window.localStorage['__test__'] = '1';
      html.window.localStorage.remove('__test__');
      html.window.sessionStorage['__test__'] = '1';
      html.window.sessionStorage.remove('__test__');
    } catch (e) {
      // 这是基本要求，如果不支持则确实无法运行
      print('错误: localStorage/sessionStorage 不支持: $e');
      return EnvCheckResult(false, reason: 'localStorage/sessionStorage 不支持，请检查浏览器设置');
    }
    
    // 3. 检查 Service Worker (可选，部分浏览器可能不支持)
    // Edge某些版本可能不支持，改为警告而非阻断
    try {
      if (html.window.navigator.serviceWorker == null) {
        print('警告: Service Worker 不支持，但不影响基本功能');
      }
    } catch (e) {
      print('警告: Service Worker 检测失败: $e');
    }
    
    // 4. 检查主流浏览器 - 支持更多浏览器包括移动端
    final ua = html.window.navigator.userAgent.toLowerCase();
    final isSupportedBrowser = 
        // 桌面端浏览器
        ua.contains('chrome') || ua.contains('firefox') || ua.contains('safari') || 
        ua.contains('edg') || ua.contains('edge') ||
        // 移动端浏览器
        ua.contains('mobile') || ua.contains('android') || ua.contains('iphone') || 
        ua.contains('ipad') || ua.contains('ipod') ||
        // 微信浏览器
        ua.contains('micromessenger') || ua.contains('wechat') ||
        // QQ浏览器
        ua.contains('qq') || ua.contains('mqqbrowser') ||
        // UC浏览器
        ua.contains('ucbrowser') || ua.contains('ucweb') ||
        // 小米浏览器
        ua.contains('miuibrowser') ||
        // 华为浏览器
        ua.contains('huaweibrowser') ||
        // 360浏览器
        ua.contains('qihu') || ua.contains('360');
    
    if (!isSupportedBrowser) {
      // 输出调试信息但不阻断，因为可能是新浏览器
      print('警告: 未识别的浏览器类型，但将尝试继续运行: $ua');
    }
    
    // 5. 检查无痕/隐私模式（可选检测，不阻断运行）
    // 微信浏览器和某些移动端浏览器可能限制localStorage
    try {
      html.window.localStorage['__incognito_test__'] = '1';
      html.window.localStorage.remove('__incognito_test__');
    } catch (e) {
      // 不阻断运行，只是警告
      print('警告: localStorage受限，可能处于隐私模式或特殊浏览器环境: $e');
    }
    
    return EnvCheckResult(true);
  }
}