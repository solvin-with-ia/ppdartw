import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ppdartw/blocs/bloc_game.dart';
import 'package:ppdartw/blocs/bloc_modal.dart';
import 'package:ppdartw/blocs/bloc_navigator.dart';
import 'package:ppdartw/blocs/bloc_session.dart';
import 'package:ppdartw/domain/enums/role.dart';
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

class MockBlocSession extends Mock implements BlocSession {}

class MockCreateGameUsecase implements CreateGameUsecase {
  @override
  Future<Either<ErrorItem, void>> call(GameModel game) async {
    return Right<ErrorItem, void>(null);
  }

  @override
  GameRepository get repository => throw UnimplementedError();
}

class DummyGetGameStreamUsecase implements GetGameStreamUsecase {
  final Map<String, StreamController<Either<ErrorItem, GameModel?>>>
  _controllers = <String, StreamController<Either<ErrorItem, GameModel?>>>{};

  static final Map<String, String> _initialNames = <String, String>{};
  static final Map<String, List<CardModel>> _initialDecks =
      <String, List<CardModel>>{};
  static final Map<String, GameModel> _lastSetGame = <String, GameModel>{};

  void setGame(GameModel game) {
    final String gameId = game.id;
    _lastSetGame[gameId] = game;
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
      // Si hay un modelo seteado, emítelo como primer valor
      if (_lastSetGame.containsKey(gameId)) {
        _controllers[gameId]!.add(
          Right<ErrorItem, GameModel?>(_lastSetGame[gameId]),
        );
      } else {
        final String initialName = _initialNames[gameId] ?? 'Partida Test';
        final List<CardModel> initialDeck =
            _initialDecks[gameId] ?? const <CardModel>[];
        final GameModel game = GameModel(
          id: gameId,
          name: initialName,
          admin: const DummyUserModel(),
          spectators: const <UserModel>[],
          players: const <UserModel>[],
          votes: const <VoteModel>[],
          isActive: true,
          createdAt: DateTime.now(),
          deck: initialDeck,
        );
        _controllers[gameId]!.add(Right<ErrorItem, GameModel?>(game));
      }
    }
    return _controllers[gameId]!.stream;
  }

  static void setInitialName(String gameId, String name) {
    _initialNames[gameId] = name;
  }

  static void setInitialDeck(String gameId, List<CardModel> deck) {
    _initialDecks[gameId] = deck;
  }

  @override
  GameRepository get repository => throw UnimplementedError();
}

void main() {
  group('BlocGame basic isolated methods', () {
    late BlocGame blocGame;

    setUp(() {
      blocGame = BlocGame(
        blocSession: DummyBlocSession(),
        createGameUsecase: DummyCreateGameUsecase(),
        getGameStreamUsecase: DummyGetGameStreamUsecase(),
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(DummyBlocSession()),
      );
    });

    test('updateNameDraft updates the name locally', () {
      blocGame.updateNameDraft('Test Game');
      expect(blocGame.selectedGame.name, 'Test Game');
    });

    test('setName updates the name via setter', () {
      blocGame.setName('Setter Name');
      expect(blocGame.selectedGame.name, 'Setter Name');
    });

    test('selectRoleDraft updates the draft role', () {
      blocGame.selectRoleDraft(Role.jugador);
      expect(blocGame.selectedGame.role, Role.jugador);
      blocGame.selectRoleDraft(Role.espectador);
      expect(blocGame.selectedGame.role, Role.espectador);
    });

    test(
      'isNameValid returns false for short names and true for valid names',
      () {
        blocGame.setName('ab');
        expect(blocGame.isNameValid, isFalse);
        blocGame.setName('validName');
        expect(blocGame.isNameValid, isTrue);
      },
    );

    test('calculateAverage returns 0 if votes are not revealed', () {
      expect(blocGame.calculateAverage(), 0.0);
    });
  });
}
