import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/blocs/bloc_session.dart';
import 'package:ppdartw/domains/repositories/session_repository.dart';

class MockSessionRepository implements SessionRepository {
  final BlocGeneral<Either<ErrorItem, UserModel?>> _userStream =
      BlocGeneral<Either<ErrorItem, UserModel?>>(
        Right<ErrorItem, UserModel?>(null),
      );
  UserModel? _user;
  bool signedOut = false;

  @override
  Stream<Either<ErrorItem, UserModel?>> get userStream => _userStream.stream;

  @override
  UserModel? get currentUser => _user;

  @override
  Future<Either<ErrorItem, UserModel>> signInWithGoogle() async {
    _user = const UserModel(
      id: 'test',
      displayName: 'Test User',
      email: 'test@test.com',
      photoUrl: '',
      jwt: <String, dynamic>{},
    );
    _userStream.value = Right<ErrorItem, UserModel?>(_user);
    return Right<ErrorItem, UserModel>(_user!);
  }

  @override
  Future<Either<ErrorItem, void>> signOut() async {
    _user = null;
    _userStream.value = Right<ErrorItem, UserModel?>(null);
    signedOut = true;
    return Right<ErrorItem, void>(null);
  }
}

void main() {
  group('BlocSession', () {
    late BlocSession bloc;
    late MockSessionRepository repo;

    setUp(() {
      repo = MockSessionRepository();
      bloc = BlocSession(repo);
    });

    tearDown(() {
      bloc.dispose();
    });

    test('initial user is null', () {
      expect(bloc.user, isNull);
      expectLater(bloc.userStream, emitsInOrder(<dynamic>[null]));
    });

    test('signInWithGoogle sets user', () async {
      final Either<ErrorItem, UserModel> result = await bloc.signInWithGoogle();
      expect(result.isRight, true);
      expect(bloc.user, isNotNull);
      expect(bloc.user!.id, 'test');
      expectLater(bloc.userStream, emitsInOrder(<dynamic>[isA<UserModel>()]));
    });

    test('signOut clears user', () async {
      await bloc.signInWithGoogle();
      bloc.signOut();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(bloc.user, isNull);
      expect(repo.signedOut, true);
      expectLater(bloc.userStream, emitsInOrder(<dynamic>[null]));
    });
  });
}
