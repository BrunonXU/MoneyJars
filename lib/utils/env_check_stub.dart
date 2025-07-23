import 'env_check.dart';

/// Stub implementation for conditional imports
class WebEnvChecker {
  static bool get isSupported => throw UnsupportedError(
      'WebEnvChecker is not available on this platform');
  
  static EnvCheckResult performWebChecks() => throw UnsupportedError(
      'WebEnvChecker is not available on this platform');
}