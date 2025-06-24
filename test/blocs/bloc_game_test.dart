import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/blocs/bloc_game.dart';
import 'package:ppdartw/blocs/bloc_modal.dart';
import 'package:ppdartw/blocs/bloc_navigator.dart';
import 'package:ppdartw/blocs/bloc_session.dart';
import 'package:ppdartw/domain/models/card_model.dart';
import 'package:ppdartw/domain/models/game_model.dart';
import 'package:ppdartw/domain/models/vote_model.dart';
import 'package:ppdartw/domain/repositories/game_repository.dart';
import 'package:ppdartw/domain/repositories/session_repository.dart';
import 'package:ppdartw/domain/usecases/game/create_game_usecase.dart';
import 'package:ppdartw/domain/usecases/game/get_game_stream_usecase.dart';
import 'package:ppdartw/domain/usecases/session/get_user_stream_usecase.dart';
import 'package:ppdartw/domain/usecases/session/sign_in_with_google_usecase.dart';
import 'package:ppdartw/domain/usecases/session/sign_out_usecase.dart';

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

// Fakes/mocks simples para pruebas
// Fakes mínimos para los usecases requeridos por BlocSession
class FakeSignInWithGoogleUsecase implements SignInWithGoogleUsecase {
  @override
  Future<Either<ErrorItem, UserModel>> call() async =>
      Right<ErrorItem, UserModel>(const DummyUserModel());

  @override
  SessionRepository get repository => throw UnimplementedError();
}

class FakeSignOutUsecase implements SignOutUsecase {
  @override
  Future<Either<ErrorItem, void>> call() async => Right<ErrorItem, void>(null);

  @override
  SessionRepository get repository => throw UnimplementedError();
}

class FakeGetUserStreamUsecase implements GetUserStreamUsecase {
  @override
  Stream<Either<ErrorItem, UserModel?>> call() =>
      Stream<Either<ErrorItem, UserModel?>>.value(
        Right<ErrorItem, UserModel?>(const DummyUserModel()),
      );

  @override
  SessionRepository get repository => throw UnimplementedError();
}

class MockBlocSession extends BlocSession {
  MockBlocSession()
    : super(
        signInWithGoogleUsecase: FakeSignInWithGoogleUsecase(),
        signOutUsecase: FakeSignOutUsecase(),
        getUserStreamUsecase: FakeGetUserStreamUsecase(),
      );
}

class MockCreateGameUsecase implements CreateGameUsecase {
  @override
  Future<Either<ErrorItem, void>> call(GameModel game) async {
    return Right<ErrorItem, void>(null);
  }

  @override
  GameRepository get repository => throw UnimplementedError();
}

class DummyGetGameStreamUsecase implements GetGameStreamUsecase {
  DummyGetGameStreamUsecase();
  final Map<String, StreamController<Either<ErrorItem, GameModel?>>>
  _controllers = <String, StreamController<Either<ErrorItem, GameModel?>>>{};

  void setGame(GameModel game) {
    final String gameId = game.id;
    if (!_controllers.containsKey(gameId)) {
      _controllers[gameId] =
          StreamController<Either<ErrorItem, GameModel?>>.broadcast();
    }
    _controllers[gameId]!.add(Right<ErrorItem, GameModel?>(game));
  }

  @override
  Stream<Either<ErrorItem, GameModel?>> call(String gameId) {
    if (!_controllers.containsKey(gameId)) {
      _controllers[gameId] =
          StreamController<Either<ErrorItem, GameModel?>>.broadcast();
      // Emitir un valor inicial
      final GameModel game = GameModel(
        id: gameId,
        name: 'Partida Test',
        admin: const DummyUserModel(),
        spectators: const <UserModel>[],
        players: const <UserModel>[],
        votes: const <VoteModel>[],
        isActive: true,
        createdAt: DateTime.now(),
        deck: const <CardModel>[],
      );
      _controllers[gameId]!.add(Right<ErrorItem, GameModel?>(game));
    }
    return _controllers[gameId]!.stream;
  }

  @override
  GameRepository get repository => throw UnimplementedError();
}

void main() {
  group('BlocGame', () {
    late BlocGame blocGame;

    late MockBlocSession mockBlocSession;
    late MockCreateGameUsecase mockCreateGameUsecase;
    late BlocModal blocModal;
    late BlocNavigator blocNavigator;
    late DummyGetGameStreamUsecase dummyGetGameStreamUsecase;

    setUp(() {
      mockBlocSession = MockBlocSession();
      mockCreateGameUsecase = MockCreateGameUsecase();
      blocModal = BlocModal(); // Instancia mínima
      blocNavigator = BlocNavigator(mockBlocSession);
      dummyGetGameStreamUsecase = DummyGetGameStreamUsecase();
      blocGame = BlocGame(
        blocSession: mockBlocSession,
        createGameUsecase: mockCreateGameUsecase,
        getGameStreamUsecase: dummyGetGameStreamUsecase,
        blocModal: blocModal,
        blocNavigator: blocNavigator,
      );
    });

    test('Estado inicial es GameModel.empty()', () {
      expect(blocGame.selectedGame, isA<GameModel>());
      expect(blocGame.selectedGame.isNew, isTrue);
    });

    test('createGame crea un nuevo GameModel con el admin logueado', () async {
      await blocGame.createGame(name: 'Partida Test');
      await Future<void>.delayed(
        Duration.zero,
      ); // Espera a que el stream procese el valor
      final GameModel game = blocGame.selectedGame;
      expect(game.name, 'Partida Test');
      expect(game.admin.id, 'dummy');
      expect(game.isNew, isFalse); // Dependiendo de la lógica
    });

    test('updateGameName actualiza el nombre de la partida', () {
      blocGame.createGame(name: 'Partida Test');
      blocGame.setName('Nuevo Nombre');
      expect(blocGame.selectedGame.name, 'Nuevo Nombre');
    });

    test('updateGame persiste y mantiene el draft actualizado', () async {
      await blocGame.createGame(name: 'Partida Persistida');
      final String oldId = blocGame.selectedGame.id;
      blocGame.setName('Nombre Actualizado');
      // Simula que el backend persiste el modelo actualizado
      dummyGetGameStreamUsecase.setGame(blocGame.selectedGame);
      await blocGame.updateGame();
      // Espera a que el stream procese el valor
      await Future<void>.delayed(Duration.zero);
      expect(blocGame.selectedGame.name, 'Nombre Actualizado');
      expect(blocGame.selectedGame.id, oldId);
    });

    test('updateGame no lanza errores si se llama sin cambios', () async {
      await blocGame.createGame(name: 'Partida Simple');
      await Future<void>.delayed(Duration.zero);
      expect(() => blocGame.updateGame(), returnsNormally);
    });

    test('dispose no lanza errores', () {
      expect(() => blocGame.dispose(), returnsNormally);
    });
  });
}
