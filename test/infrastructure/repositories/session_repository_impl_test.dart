import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/infrastructure/gateways/session_gateway_impl.dart';
import 'package:ppdartw/infrastructure/repositories/session_repository_impl.dart';
import 'package:ppdartw/infrastructure/services/fake_service_session.dart';

void main() {
  group('SessionRepositoryImpl', () {
    late SessionRepositoryImpl repo;
    setUp(() {
      repo = SessionRepositoryImpl(SessionGatewayImpl(FakeServiceSession()));
    });

    test('userStream emits null initially', () async {
      expectLater(repo.userStream, emits(isA<Either<ErrorItem, UserModel?>>()));
    });

    test('signInWithGoogle emits user and sets currentUser', () async {
      final List<Either<ErrorItem, UserModel?>> emitted =
          <Either<ErrorItem, UserModel?>>[];
      final StreamSubscription<Either<ErrorItem, UserModel?>> sub = repo
          .userStream
          .listen(emitted.add);
      final Either<ErrorItem, UserModel> result = await repo.signInWithGoogle();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(result.isRight, true);
      result.fold(
        (ErrorItem l) => fail('Should be right'),
        (UserModel r) => expect(r.id, 'fake_user'),
      );
      expect(repo.currentUser, isNotNull);
      expect(emitted.last.isRight, true);
      emitted.last.fold(
        (ErrorItem l) => fail('Should be right'),
        (UserModel? r) => expect(r?.id, 'fake_user'),
      );
      await sub.cancel();
    });

    test('signOut emits null and clears currentUser', () async {
      await repo.signInWithGoogle();
      final List<Either<ErrorItem, UserModel?>> emitted =
          <Either<ErrorItem, UserModel?>>[];
      final StreamSubscription<Either<ErrorItem, UserModel?>> sub = repo
          .userStream
          .listen(emitted.add);
      final Either<ErrorItem, void> result = await repo.signOut();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(result.isRight, true);
      expect(repo.currentUser, isNull);
      expect(emitted.last.isRight, true);
      emitted.last.fold(
        (ErrorItem l) => fail('Should be right'),
        (UserModel? r) => expect(r, isNull),
      );
      await sub.cancel();
    });
  });
}
