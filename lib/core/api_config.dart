/// API base URL for the Laravel mobile API.
///
/// Android emulator → host machine loopback: `10.0.2.2`
/// iOS simulator / desktop / web → `127.0.0.1`
/// Physical device → use your machine's LAN IP, e.g. `http://192.168.1.10:4402/api/mobile`
class ApiConfig {
  ApiConfig._();

  /// Switch this for non-emulator platforms.
  static const String baseUrl = 'http://10.0.2.2:4402/api/mobile';

  // static const String baseUrl = 'http://127.0.0.1:4402/api/mobile';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';
  static const String onboardingKey = 'onboarding_done';
  static const String themeModeKey = 'theme_mode';
}
