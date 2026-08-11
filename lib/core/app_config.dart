/// ═══════════════════════════════════════════════════════════════════════════
/// APP CONFIG — change API / branding here only
/// ═══════════════════════════════════════════════════════════════════════════
///
/// When switching environments, edit [apiRoot] (and optionally [apiPrefix]).
/// Everything else (Dio base URL, assets, app name) reads from this file.
class AppConfig {
  AppConfig._();

  // ── Change this when the API host changes ────────────────────────────────
  /// Production API host (no trailing slash).
  static const String apiRoot = 'https://ca.risebix.com';

  /// Local / emulator alternatives (uncomment one and comment apiRoot above):
  // static const String apiRoot = 'http://10.0.2.2:4402';      // Android emulator
  // static const String apiRoot = 'http://192.168.0.105:8701'; // LAN Docker
  // static const String apiRoot = 'http://127.0.0.1:4402';     // desktop

  /// Path prefix for the mobile API (Laravel routes under /api/mobile).
  static const String apiPrefix = '/api/mobile';

  /// Full base URL used by Dio — do not hardcode elsewhere.
  static String get apiBaseUrl => '$apiRoot$apiPrefix';

  // ── Branding ─────────────────────────────────────────────────────────────
  static const String appName = 'Daily Current Affairs';
  static const String appTagline = 'Govt Exams';
  static const String logoAsset = 'assets/images/app_logo.png';
  static const String iconAsset = 'assets/images/app_icon.png';

  // ── Timeouts / storage keys ──────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';
  static const String onboardingKey = 'onboarding_done';
}
