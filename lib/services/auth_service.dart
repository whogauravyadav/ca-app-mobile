import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/app_config.dart';
import '../models/models.dart';
import 'api_client.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(apiClientProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

class AuthService {
  AuthService(this._api, this._prefs);

  final ApiClient _api;
  final SharedPreferences _prefs;

  String? get token => _prefs.getString(AppConfig.tokenKey);

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  UserModel? getCachedUser() {
    final raw = _prefs.getString(AppConfig.userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistSession(String token, UserModel user) async {
    await _prefs.setString(AppConfig.tokenKey, token);
    await _prefs.setString(AppConfig.userKey, jsonEncode(user.toJson()));
  }

  Future<void> clearSession() async {
    await _prefs.remove(AppConfig.tokenKey);
    await _prefs.remove(AppConfig.userKey);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post('/login', data: {
      'email': email,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _persistSession(data['token'] as String, user);
    return user;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _api.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    final data = res.data as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _persistSession(data['token'] as String, user);
    return user;
  }

  Future<UserModel> fetchProfile() async {
    final res = await _api.get('/profile');
    final data = res.data as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _prefs.setString(AppConfig.userKey, jsonEncode(user.toJson()));
    return user;
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } catch (_) {
      // Still clear local session
    }
    await clearSession();
  }

  // Content APIs
  Future<List<CategoryModel>> getCategories() async {
    final res = await _api.get('/categories');
    final list = (res.data['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ArticleModel>> getArticles({
    String? category,
    String? search,
    bool today = false,
    int page = 1,
  }) async {
    final res = await _api.get('/articles', queryParameters: {
      if (category != null && category.isNotEmpty) 'category': category,
      if (search != null && search.isNotEmpty) 'search': search,
      if (today) 'today': 1,
      'page': page,
    });
    final list = (res.data['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ArticleModel> getArticle(String slug) async {
    final res = await _api.get('/articles/$slug');
    return ArticleModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<QuizSummary>> getQuizzes() async {
    final res = await _api.get('/quizzes');
    final list = (res.data['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => QuizSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<QuizDetail> getQuiz(int id) async {
    final res = await _api.get('/quizzes/$id');
    return QuizDetail.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<QuizResult> submitQuiz(
    int id,
    List<Map<String, dynamic>> answers,
  ) async {
    final res = await _api.post('/quizzes/$id/submit', data: {
      'answers': answers,
    });
    return QuizResult.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<BookmarkModel>> getBookmarks() async {
    final res = await _api.get('/bookmarks');
    final list = (res.data['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => BookmarkModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addBookmark(int articleId) async {
    await _api.post('/bookmarks', data: {'article_id': articleId});
  }

  Future<void> removeBookmark(int articleId) async {
    await _api.delete('/bookmarks/$articleId');
  }

  Future<List<PlanModel>> getPlans() async {
    final res = await _api.get('/plans');
    final list = (res.data['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => PlanModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> activateSubscription(int planId) async {
    final res = await _api.post('/subscription/activate', data: {
      'plan_id': planId,
      'payment_ref': 'stub-${DateTime.now().millisecondsSinceEpoch}',
    });
    final user =
        UserModel.fromJson(res.data['data']['user'] as Map<String, dynamic>);
    await _prefs.setString(AppConfig.userKey, jsonEncode(user.toJson()));
    return user;
  }
}
