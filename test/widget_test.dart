import 'package:flutter_test/flutter_test.dart';

import 'package:current_affairs_app/models/models.dart';

void main() {
  test('UserModel parses API payload', () {
    final user = UserModel.fromJson({
      'id': 1,
      'name': 'Student',
      'email': 'student@currentaffairs.app',
      'role': 'student',
      'subscription_status': 'free',
      'subscription_expires_at': null,
      'streak_count': 3,
      'avatar_url': null,
      'is_ad_free': false,
    });

    expect(user.name, 'Student');
    expect(user.streakCount, 3);
    expect(user.isAdFree, isFalse);
  });
}
