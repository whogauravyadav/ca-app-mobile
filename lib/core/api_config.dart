/// Compatibility shim — prefer [AppConfig] in `app_config.dart`.
///
/// Change the API URL only in: lib/core/app_config.dart
import 'app_config.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl => AppConfig.apiBaseUrl;
  static Duration get connectTimeout => AppConfig.connectTimeout;
  static Duration get receiveTimeout => AppConfig.receiveTimeout;
  static const String tokenKey = AppConfig.tokenKey;
  static const String userKey = AppConfig.userKey;
  static const String onboardingKey = AppConfig.onboardingKey;
  static const String themeModeKey = AppConfig.themeModeKey;
}
