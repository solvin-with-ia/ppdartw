import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ppdartw/domain/gateways/session_gateway.dart';
import 'package:ppdartw/infrastructure/gateways/session_gateway_impl.dart';
import 'package:ppdartw/infrastructure/services/fake_service_session.dart';

void main() {
  group('FakeSessionGateway', () {
    late SessionGateway gateway;
    setUp(() {
      gateway = SessionGatewayImpl(FakeServiceSession());
    });

    test('userStream emits null initially', () async {
      expectLater(gateway.userStream, emitsInOrder(<dynamic>[null]));
    });

    test('signInWithGoogle emits user and sets currentUser', () async {
      final List<Map<String, dynamic>?> emitted = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub = gateway.userStream
          .listen(emitted.add);
      final Map<String, dynamic>? user = await gateway.signInWithGoogle();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(gateway.currentUser, isNotNull);
      expect(user, isNotNull);
      expect(user!['id'], 'fake_user');
      expect(emitted.last, isNotNull);
      expect(emitted.last!['displayName'], 'Fake User');
      await sub.cancel();
    });

    test('signOut emits null and clears currentUser', () async {
      await gateway.signInWithGoogle();
      final List<Map<String, dynamic>?> emitted = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub = gateway.userStream
          .listen(emitted.add);
      await gateway.signOut();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(gateway.currentUser, isNull);
      expect(emitted.last, isNull);
      await sub.cancel();
    });
  });
}
