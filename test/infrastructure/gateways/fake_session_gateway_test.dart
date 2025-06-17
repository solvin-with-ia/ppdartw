import 'package:flutter_test/flutter_test.dart';
import 'package:ppdartw/infrastructure/gateways/fake_session_gateway.dart';
import 'package:ppdartw/infrastructure/services/fake_service_session.dart';

void main() {
  group('FakeSessionGateway', () {
    late FakeSessionGateway gateway;
    setUp(() {
      gateway = FakeSessionGateway(FakeServiceSession());
    });

    test('userStream emits null initially', () async {
      expectLater(gateway.userStream, emitsInOrder(<dynamic>[null]));
    });

    test('signInWithGoogle emits user and sets currentUser', () async {
      final emitted = <Map<String, dynamic>?>[];
      final sub = gateway.userStream.listen(emitted.add);
      final user = await gateway.signInWithGoogle();
      await Future.delayed(const Duration(milliseconds: 10));
      expect(gateway.currentUser, isNotNull);
      expect(user, isNotNull);
      expect(user!['id'], 'fake_user');
      expect(emitted.last, isNotNull);
      expect(emitted.last!['displayName'], 'Fake User');
      await sub.cancel();
    });

    test('signOut emits null and clears currentUser', () async {
      await gateway.signInWithGoogle();
      final emitted = <Map<String, dynamic>?>[];
      final sub = gateway.userStream.listen(emitted.add);
      await gateway.signOut();
      await Future.delayed(const Duration(milliseconds: 10));
      expect(gateway.currentUser, isNull);
      expect(emitted.last, isNull);
      await sub.cancel();
    });
  });
}
