import 'env_check.dart';

/// 非Web平台存根实现
class WebEnvChecker {
  /// 非Web平台始终返回支持
  static EnvCheckResult performWebChecks() {
    return EnvCheckResult(true);
  }
}