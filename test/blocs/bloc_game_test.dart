import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/blocs/bloc_game.dart';
import 'package:ppdartw/blocs/bloc_session.dart';
import 'package:ppdartw/domains/models/game_model.dart';
import 'package:ppdartw/domains/repositories/game_repository.dart';
import 'package:ppdartw/domains/repositories/session_repository.dart';
import 'package:ppdartw/domains/usecases/game/create_game_usecase.dart';
import 'package:ppdartw/domains/usecases/session/get_user_stream_usecase.dart';
import 'package:ppdartw/domains/usecases/session/sign_in_with_google_usecase.dart';
import 'package:ppdartw/domains/usecases/session/sign_out_usecase.dart';

class MockGameRepository implements GameRepository {
  @override
  Future<Either<ErrorItem, void>> saveGame(GameModel game) async =>
      Right<ErrorItem, void>(null);
  @override
  Stream<Either<ErrorItem, GameModel?>> gameStream(String gameId) =>
      const Stream<Either<ErrorItem, GameModel?>>.empty();
  @override
  Stream<Either<ErrorItem, List<GameModel>>> gamesStream() =>
      const Stream<Either<ErrorItem, List<GameModel>>>.empty();
  @override
  Future<Either<ErrorItem, GameModel>> readGame(String gameId) async =>
      Right<ErrorItem, GameModel>(GameModel.empty());
}

class DummyCreateGameUsecase extends CreateGameUsecase {
  DummyCreateGameUsecase() : super(MockGameRepository());
  @override
  Future<Either<ErrorItem, void>> call(GameModel game) async =>
      Right<ErrorItem, void>(null);
}

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

class DummySignInWithGoogleUsecase {
  Future<Either<ErrorItem, UserModel>> call() async =>
      Right<ErrorItem, UserModel>(const DummyUserModel());
}

class DummySignOutUsecase {
  Future<Either<ErrorItem, void>> call() async => Right<ErrorItem, void>(null);
}

class DummyGetUserStreamUsecase {
  Stream<Either<ErrorItem, UserModel?>> call() =>
      const Stream<Either<ErrorItem, UserModel?>>.empty();
}

class DummyBlocSession extends BlocSession {
  DummyBlocSession()
    : super(
        signInWithGoogleUsecase: SignInWithGoogleUsecase(
          DummySessionRepository(),
        ),
        signOutUsecase: SignOutUsecase(DummySessionRepository()),
        getUserStreamUsecase: GetUserStreamUsecase(DummySessionRepository()),
      );

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
    late CreateGameUsecase createGameUsecase;

    setUp(() {
      blocSession = DummyBlocSession();
      createGameUsecase = DummyCreateGameUsecase();
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
      );
    });

    test('Estado inicial es GameModel.empty()', () {
      expect(blocGame.currentGame, isA<GameModel>());
      expect(blocGame.currentGame!.isNew, isTrue);
    });

    test('createGame crea un nuevo GameModel con el admin logueado', () async {
      await blocGame.createGame(name: 'Partida Test');
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
