import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
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

class MockBlocSession extends BlocSession {
  MockBlocSession()
    : super(
        signInWithGoogleUsecase: FakeSignInWithGoogleUsecase(),
        signOutUsecase: FakeSignOutUsecase(),
        getUserStreamUsecase: FakeGetUserStreamUsecase(),
      );

  @override
  UserModel? get user => const DummyUserModel();
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

    group('Votación y flujo de ronda', () {
      setUp(() async {
        await blocGame.createGame(name: 'Ronda Test');
        await Future<void>.delayed(Duration.zero);
      });

      test('Los votos están ocultos por defecto', () {
        expect(blocGame.selectedGame.votesRevealed, isFalse);
      });

      test('revealVotes cambia votesRevealed a true', () async {
        await blocGame.revealVotes();
        expect(blocGame.selectedGame.votesRevealed, isTrue);
      });

      test('hideVotes cambia votesRevealed a false', () async {
        await blocGame.revealVotes();
        await blocGame.hideVotes();
        expect(blocGame.selectedGame.votesRevealed, isFalse);
      });

      test('calculateAverage retorna null si los votos no están revelados', () {
        expect(blocGame.calculateAverage(), isNull);
      });

      test(
        'calculateAverage retorna el promedio correcto cuando los votos están revelados',
        () async {
          // Simula votos de cartas numéricas solo del usuario actual
          final List<CardModel> deck = <CardModel>[
            const CardModel(
              id: '1',
              display: '1',
              value: 1,
              description: 'Uno',
            ),
            const CardModel(
              id: '2',
              display: '2',
              value: 2,
              description: 'Dos',
            ),
            const CardModel(
              id: '3',
              display: '3',
              value: 3,
              description: 'Tres',
            ),
          ];
          await blocGame.createGame(name: 'Promedio Test');
          // No hay setter público para deck, pero el deck por defecto tiene cartas, así que usamos las cartas del deck por defecto
          // Vota primero por la carta 1
          await blocGame.setVote(deck[0]);
          // Vota por la carta 3 (esto reemplaza el voto anterior)
          await blocGame.setVote(deck[2]);
          await blocGame.revealVotes();
          final double? promedio = blocGame.calculateAverage();
          expect(promedio, closeTo(3.0, 0.01));
        },
      );

      test('resetRound limpia votos y oculta cartas', () async {
        // Simula votos y revela
        // Simula votos y revela usando solo métodos públicos
        await blocGame.createGame(name: 'Ronda Test 2');
        // No hay forma directa de setear votes/votesRevealed salvo exponer un método de test o usar los métodos públicos
        // Aquí solo verificamos que resetRound limpia los votos y oculta las cartas tras revealVotes + setVote
        await blocGame.setVote(
          const CardModel(id: '1', display: '1', value: 1, description: 'Uno'),
        );
        await blocGame.revealVotes();
        await blocGame.resetRound();
        expect(blocGame.selectedGame.votes, isEmpty);
        expect(blocGame.selectedGame.votesRevealed, isFalse);
      });
    });

    group('Lógica de asientos', () {
      setUp(() async {
        await blocGame.createGame(name: 'Mesa Test');
        await Future<void>.delayed(Duration.zero);
        // Inserta explícitamente al usuario actual en la lista de jugadores del modelo
        final UserModel current = blocGame.blocSession.user!;
        final GameModel updated = blocGame.selectedGame.copyWith(
          players: <UserModel>[
            current,
            ...blocGame.selectedGame.players.where(
              (UserModel u) => u.id != current.id,
            ),
          ],
        );
        dummyGetGameStreamUsecase.setGame(updated);
        await Future<void>.delayed(Duration.zero);
      });

      test('El usuario actual siempre está en la posición 8', () {
        final List<UserModel?> seats = blocGame.seatsOfPlanningPoker;
        if (seats[BlocGame.protagonistSeat]?.id !=
            blocGame.blocSession.user?.id) {
          // Debug: imprime los asientos si falla
          for (int i = 0; i < seats.length; i++) {
            debugPrint('Silla $i: ${seats[i]?.id ?? 'Vacía'}');
          }
        }
        expect(
          seats[BlocGame.protagonistSeat]?.id,
          blocGame.blocSession.user?.id,
        );
      });

      test(
        'Los demás jugadores/espectadores se distribuyen en los asientos y no hay duplicados',
        () async {
          // Agrega varios jugadores y espectadores
          const UserModel jugador2 = UserModel(
            id: 'j2',
            displayName: 'J2',
            email: '',
            photoUrl: '',
            jwt: <String, dynamic>{},
          );
          const UserModel espectador1 = UserModel(
            id: 'e1',
            displayName: 'E1',
            email: '',
            photoUrl: '',
            jwt: <String, dynamic>{},
          );
          await blocGame.setUserRole(user: jugador2, role: Role.jugador);
          await blocGame.setUserRole(user: espectador1, role: Role.espectador);
          final List<UserModel?> seats = blocGame.seatsOfPlanningPoker;
          final Set<String> ids = seats
              .whereType<UserModel>()
              .map((UserModel u) => u.id)
              .toSet();
          // Los usuarios deben estar presentes
          expect(ids.contains('j2'), isTrue);
          expect(ids.contains('e1'), isTrue);
          expect(ids.contains('dummy'), isTrue);
          // No debe haber duplicados
          expect(ids.length, seats.whereType<UserModel>().length);
          // El usuario actual nunca debe estar en otra posición que no sea la 8
          for (int i = 0; i < seats.length; i++) {
            if (i != BlocGame.protagonistSeat) {
              expect(
                seats[i]?.id == 'dummy',
                isFalse,
                reason: 'El usuario actual solo debe estar en la posición 8',
              );
            }
          }
        },
      );

      test(
        'Los asientos vacíos son null y limpieza de asientos funciona',
        () async {
          final List<UserModel?> seats = blocGame.seatsOfPlanningPoker;
          // Si hay menos de 12 usuarios, debe haber nulls
          expect(seats.where((UserModel? u) => u == null).isNotEmpty, isTrue);
          // Simula que un usuario sale del juego y verifica limpieza
          const UserModel jugador2 = UserModel(
            id: 'j2',
            displayName: 'J2',
            email: '',
            photoUrl: '',
            jwt: <String, dynamic>{},
          );
          await blocGame.setUserRole(user: jugador2, role: Role.jugador);
          expect(
            blocGame.seatsOfPlanningPoker
                .where((UserModel? u) => u?.id == 'j2')
                .isNotEmpty,
            isTrue,
          );
          // Elimina al jugador
          await blocGame.setUserRole(user: jugador2, role: Role.espectador);
          // Simula salida: elimina del modelo manualmente y actualiza el stream
          final GameModel game = blocGame.selectedGame.copyWith(
            players: blocGame.selectedGame.players
                .where((UserModel u) => u.id != 'j2')
                .toList(),
            spectators: blocGame.selectedGame.spectators
                .where((UserModel u) => u.id != 'j2')
                .toList(),
          );
          dummyGetGameStreamUsecase.setGame(game);
          await Future<void>.delayed(Duration.zero);
          expect(
            blocGame.seatsOfPlanningPoker
                .where((UserModel? u) => u?.id == 'j2')
                .isEmpty,
            isTrue,
          );
        },
      );

      test(
        'El reshuffle cambia la disposición (excepto el usuario actual)',
        () async {
          const UserModel jugador2 = UserModel(
            id: 'j2',
            displayName: 'J2',
            email: '',
            photoUrl: '',
            jwt: <String, dynamic>{},
          );
          const UserModel espectador1 = UserModel(
            id: 'e1',
            displayName: 'E1',
            email: '',
            photoUrl: '',
            jwt: <String, dynamic>{},
          );
          await blocGame.setUserRole(user: jugador2, role: Role.jugador);
          await blocGame.setUserRole(user: espectador1, role: Role.espectador);

          final List<UserModel?> seats1 = List<UserModel?>.from(
            blocGame.seatsOfPlanningPoker,
          );

          final List<UserModel?> seats2 = blocGame.seatsOfPlanningPoker;
          // El usuario actual sigue en la posición 8
          expect(
            seats2[BlocGame.protagonistSeat]?.id,
            blocGame.blocSession.user?.id,
          );
          // Al menos uno de los otros asientos cambió
          final bool changed = List<bool>.generate(
            12,
            (int i) =>
                i != BlocGame.protagonistSeat && seats1[i]?.id != seats2[i]?.id,
          ).any((bool b) => b);
          expect(changed, isTrue);
        },
      );
    });
  });
}
