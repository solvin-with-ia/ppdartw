import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/blocs/bloc_game.dart';
import 'package:ppdartw/blocs/bloc_session.dart';
import 'package:ppdartw/domains/models/game_model.dart';
import 'package:ppdartw/domains/repositories/session_repository.dart';

class DummyUserModel extends UserModel {
  const DummyUserModel()
    : super(
        id: 'dummy',
        displayName: 'Dummy',
        email: 'dummy@test.com',
        photoUrl: 'https://dummy.com/avatar.png',
        jwt: const <String, dynamic>{},
      );
}

class DummyBlocSession extends BlocSession {
  DummyBlocSession() : super(DummySessionRepository());
  @override
  UserModel? get user => const DummyUserModel();
}

class DummySessionRepository implements SessionRepository {
  @override
  Future<Either<ErrorItem, UserModel>> signInWithGoogle() async =>
      Right<ErrorItem, UserModel>(const DummyUserModel());

  @override
  Future<Either<ErrorItem, void>> signOut() async =>
      Right<ErrorItem, void>(null);

  @override
  Stream<Either<ErrorItem, UserModel>> get userStream =>
      const Stream<Either<ErrorItem, UserModel>>.empty();

  @override
  UserModel? get currentUser => const DummyUserModel();
}

void main() {
  group('BlocGame', () {
    late BlocGame blocGame;
    late BlocSession blocSession;

    setUp(() {
      blocSession = DummyBlocSession();
      blocGame = BlocGame(blocSession);
    });

    test('Estado inicial es GameModel.empty()', () {
      expect(blocGame.currentGame, isA<GameModel>());
      expect(blocGame.currentGame!.isNew, isTrue);
    });

    test('createGame crea un nuevo GameModel con el admin logueado', () {
      blocGame.createGame(name: 'Partida Test');
      final GameModel game = blocGame.currentGame!;
      expect(game.name, 'Partida Test');
      expect(game.admin.id, 'dummy');
      expect(game.isNew, isFalse); // Dependiendo de la lógica
    });

    test('updateGameName actualiza el nombre de la partida', () {
      blocGame.createGame(name: 'Partida Test');
      blocGame.updateGameName('Nuevo Nombre');
      expect(blocGame.currentGame!.name, 'Nuevo Nombre');
    });

    test('dispose no lanza errores', () {
      expect(() => blocGame.dispose(), returnsNormally);
    });
  });
}
