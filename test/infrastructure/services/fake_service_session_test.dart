import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/infrastructure/services/fake_service_session.dart';

void main() {
  group('FakeServiceSession', () {
    late FakeServiceSession session;
    setUp(() {
      session = FakeServiceSession();
    });

    test('userStream emits null initially', () async {
      expect(session.currentUser, isNull);
      expectLater(session.userStream, emitsInOrder(<dynamic>[null]));
    });

    test('signInWithGoogle emits user and sets currentUser', () async {
      final List<UserModel?> emitted = <UserModel?>[];
      final StreamSubscription<UserModel?> sub = session.userStream.listen(
        emitted.add,
      );
      final UserModel? user = await session.signInWithGoogle();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(session.currentUser, isNotNull);
      expect(user, isNotNull);
      expect(user!.id, 'fake_user');
      expect(emitted.last, isNotNull);
      expect(emitted.last!.displayName, 'Fake User');
      await sub.cancel();
    });

    test('signOut emits null and clears currentUser', () async {
      await session.signInWithGoogle();
      final List<UserModel?> emitted = <UserModel?>[];
      final StreamSubscription<UserModel?> sub = session.userStream.listen(
        emitted.add,
      );
      await session.signOut();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(session.currentUser, isNull);
      expect(emitted.last, isNull);
      await sub.cancel();
    });
  });
}
