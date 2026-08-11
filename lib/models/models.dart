class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.exams = const [],
    this.examLabels = const [],
    this.role = 'student',
    this.subscriptionStatus = 'free',
    this.subscriptionExpiresAt,
    this.streakCount = 0,
    this.avatarUrl,
    this.isAdFree = false,
  });

  final int id;
  final String name;
  final String email;
  final String? phone;
  final List<String> exams;
  final List<String> examLabels;
  final String role;
  final String subscriptionStatus;
  final String? subscriptionExpiresAt;
  final int streakCount;
  final String? avatarUrl;
  final bool isAdFree;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final examsRaw = json['exams'];
    final labelsRaw = json['exam_labels'];
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      exams: examsRaw is List
          ? examsRaw.map((e) => e.toString()).toList()
          : const [],
      examLabels: labelsRaw is List
          ? labelsRaw.map((e) => e.toString()).toList()
          : const [],
      role: json['role'] as String? ?? 'student',
      subscriptionStatus: json['subscription_status'] as String? ?? 'free',
      subscriptionExpiresAt: json['subscription_expires_at'] as String?,
      streakCount: json['streak_count'] as int? ?? 0,
      avatarUrl: json['avatar_url'] as String?,
      isAdFree: json['is_ad_free'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'exams': exams,
        'exam_labels': examLabels,
        'role': role,
        'subscription_status': subscriptionStatus,
        'subscription_expires_at': subscriptionExpiresAt,
        'streak_count': streakCount,
        'avatar_url': avatarUrl,
        'is_ad_free': isAdFree,
      };

  UserModel copyWith({
    String? name,
    String? phone,
    List<String>? exams,
    List<String>? examLabels,
    String? subscriptionStatus,
    String? subscriptionExpiresAt,
    int? streakCount,
    String? avatarUrl,
    bool? isAdFree,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      exams: exams ?? this.exams,
      examLabels: examLabels ?? this.examLabels,
      role: role,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      streakCount: streakCount ?? this.streakCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAdFree: isAdFree ?? this.isAdFree,
    );
  }
}

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.color,
  });

  final int id;
  final String name;
  final String slug;
  final String? icon;
  final String? color;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }
}

class ArticleModel {
  const ArticleModel({
    required this.id,
    required this.title,
    required this.slug,
    this.summary,
    this.body,
    this.featuredImage,
    this.readTimeMin = 3,
    this.publishedAt,
    this.isPremiumEarly = false,
    this.category,
    this.locked = false,
    this.isBookmarked = false,
    this.quizzes = const [],
  });

  final int id;
  final String title;
  final String slug;
  final String? summary;
  final String? body;
  final String? featuredImage;
  final int readTimeMin;
  final String? publishedAt;
  final bool isPremiumEarly;
  final CategoryModel? category;
  final bool locked;
  final bool isBookmarked;
  final List<Map<String, dynamic>> quizzes;

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      summary: json['summary'] as String?,
      body: json['body'] as String?,
      featuredImage: json['featured_image'] as String?,
      readTimeMin: json['read_time_min'] as int? ?? 3,
      publishedAt: json['published_at'] as String?,
      isPremiumEarly: json['is_premium_early'] as bool? ?? false,
      category: json['category'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      locked: json['locked'] as bool? ?? false,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      quizzes: (json['quizzes'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
    );
  }

  ArticleModel copyWith({bool? isBookmarked}) {
    return ArticleModel(
      id: id,
      title: title,
      slug: slug,
      summary: summary,
      body: body,
      featuredImage: featuredImage,
      readTimeMin: readTimeMin,
      publishedAt: publishedAt,
      isPremiumEarly: isPremiumEarly,
      category: category,
      locked: locked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      quizzes: quizzes,
    );
  }
}

class QuizSummary {
  const QuizSummary({
    required this.id,
    required this.title,
    this.description,
    this.timeLimitSec,
    this.questionsCount = 0,
    this.category,
  });

  final int id;
  final String title;
  final String? description;
  final int? timeLimitSec;
  final int questionsCount;
  final CategoryModel? category;

  factory QuizSummary.fromJson(Map<String, dynamic> json) {
    return QuizSummary(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      timeLimitSec: json['time_limit_sec'] as int?,
      questionsCount: json['questions_count'] as int? ?? 0,
      category: json['category'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
    );
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    this.sortOrder = 0,
  });

  final int id;
  final String question;
  final List<String> options;
  final int sortOrder;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final opts = json['options'];
    List<String> options;
    if (opts is List) {
      options = opts.map((e) => e.toString()).toList();
    } else {
      options = const [];
    }
    return QuizQuestion(
      id: json['id'] as int,
      question: json['question'] as String? ?? '',
      options: options,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}

class QuizDetail {
  const QuizDetail({
    required this.id,
    required this.title,
    this.description,
    this.timeLimitSec,
    this.category,
    this.questions = const [],
  });

  final int id;
  final String title;
  final String? description;
  final int? timeLimitSec;
  final CategoryModel? category;
  final List<QuizQuestion> questions;

  factory QuizDetail.fromJson(Map<String, dynamic> json) {
    return QuizDetail(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      timeLimitSec: json['time_limit_sec'] as int?,
      category: json['category'] is Map<String, dynamic>
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class QuizResult {
  const QuizResult({
    required this.attemptId,
    required this.score,
    required this.total,
    required this.percent,
    this.results = const [],
  });

  final int attemptId;
  final int score;
  final int total;
  final int percent;
  final List<Map<String, dynamic>> results;

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      attemptId: json['attempt_id'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      percent: json['percent'] as int? ?? 0,
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          const [],
    );
  }
}

class PlanModel {
  const PlanModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.priceInr,
    required this.durationDays,
    this.features = const [],
  });

  final int id;
  final String name;
  final String slug;
  final num priceInr;
  final int durationDays;
  final List<String> features;

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final raw = json['features'];
    List<String> features = const [];
    if (raw is List) {
      features = raw.map((e) => e.toString()).toList();
    } else if (raw is Map) {
      features = raw.values.map((e) => e.toString()).toList();
    }
    return PlanModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      priceInr: json['price_inr'] as num? ?? 0,
      durationDays: json['duration_days'] as int? ?? 30,
      features: features,
    );
  }
}

class BookmarkModel {
  const BookmarkModel({
    required this.id,
    this.article,
    this.createdAt,
  });

  final int id;
  final ArticleModel? article;
  final String? createdAt;

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as int,
      article: json['article'] is Map<String, dynamic>
          ? ArticleModel.fromJson(json['article'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
    );
  }
}

class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data = const {},
    this.isRead = false,
    this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String type;
  final Map<String, dynamic> data;
  final bool isRead;
  final String? createdAt;

  String? get route {
    final r = data['route'];
    if (r is String && r.isNotEmpty) return r;
    if (type == 'article' && data['slug'] != null) {
      return '/article/${data['slug']}';
    }
    if (type == 'quiz' && data['quiz_id'] != null) {
      return '/quiz/${data['quiz_id']}';
    }
    return null;
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return AppNotificationModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'custom',
      data: rawData is Map<String, dynamic>
          ? rawData
          : <String, dynamic>{},
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );
  }

  AppNotificationModel copyWith({bool? isRead}) {
    return AppNotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
