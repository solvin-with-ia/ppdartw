import 'dart:async';
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
import 'package:ppdartw/infrastructure/gateways/game_gateway_impl.dart';
import 'package:ppdartw/infrastructure/gateways/session_gateway_impl.dart';
import 'package:ppdartw/infrastructure/repositories/game_repository_impl.dart';
import 'package:ppdartw/infrastructure/repositories/session_repository_impl.dart';
import 'package:ppdartw/infrastructure/services/fake_service_session.dart';
import 'package:ppdartw/infrastructure/services/fake_service_ws_database.dart';
import 'package:ppdartw/views/enum_views.dart';

void main() {
  late BlocGame blocGame;

  late FakeServiceWsDatabase fakeDb;
  late FakeServiceSession fakeSession;
  late GameRepository gameRepository;
  late SessionRepository sessionRepository;
  late CreateGameUsecase createGameUsecase;
  late GetGameStreamUsecase getGameStreamUsecase;
  late BlocSession blocSession;

  setUp(() {
    fakeDb = FakeServiceWsDatabase();
    fakeSession = FakeServiceSession();
    gameRepository = GameRepositoryImpl(GameGatewayImpl(fakeDb));
    sessionRepository = SessionRepositoryImpl(SessionGatewayImpl(fakeSession));
    createGameUsecase = CreateGameUsecase(gameRepository);
    getGameStreamUsecase = GetGameStreamUsecase(gameRepository);
    blocSession = BlocSession(
      signInWithGoogleUsecase: SignInWithGoogleUsecase(sessionRepository),
      signOutUsecase: SignOutUsecase(sessionRepository),
      getUserStreamUsecase: GetUserStreamUsecase(sessionRepository),
    );
    blocGame = BlocGame(
      blocSession: blocSession,
      createGameUsecase: createGameUsecase,
      getGameStreamUsecase: getGameStreamUsecase,
      blocModal: BlocModal(),
      blocNavigator: BlocNavigator(blocSession),
    );
  });
  tearDownAll(() {
    blocGame.dispose();
    fakeDb.dispose();
    fakeSession.dispose();
  });

  group('calculateAverage', () {
    late BlocGame blocGame;
    late FakeServiceWsDatabase fakeDb;
    late FakeServiceSession fakeSession;
    late GameRepository gameRepository;
    late SessionRepository sessionRepository;
    late CreateGameUsecase createGameUsecase;
    late GetGameStreamUsecase getGameStreamUsecase;
    late BlocSession blocSession;

    Future<void> awaitUntil(
      bool Function() condition, {
      Duration timeout = const Duration(seconds: 2),
    }) async {
      final DateTime start = DateTime.now();
      while (!condition()) {
        if (DateTime.now().difference(start) > timeout) {
          throw Exception('Timeout esperando condición en el test');
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }

    setUp(() async {
      fakeDb = FakeServiceWsDatabase();
      fakeSession = FakeServiceSession();
      gameRepository = GameRepositoryImpl(GameGatewayImpl(fakeDb));
      sessionRepository = SessionRepositoryImpl(
        SessionGatewayImpl(fakeSession),
      );
      createGameUsecase = CreateGameUsecase(gameRepository);
      getGameStreamUsecase = GetGameStreamUsecase(gameRepository);
      blocSession = BlocSession(
        signInWithGoogleUsecase: SignInWithGoogleUsecase(sessionRepository),
        signOutUsecase: SignOutUsecase(sessionRepository),
        getUserStreamUsecase: GetUserStreamUsecase(sessionRepository),
      );
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      // Autenticación previa
      await fakeSession.signInWithGoogle();
      await blocGame.createGame(name: 'Partida Average');
      await awaitUntil(() => blocGame.selectedGame.id.isNotEmpty);
    });

    test('retorna 0.0 si votesRevealed es false', () {
      expect(blocGame.calculateAverage(), 0.0);
    });

    test('retorna 0.0 si no hay votos y votesRevealed es true', () async {
      final GameModel modificado = blocGame.selectedGame.copyWith(
        votes: <VoteModel>[],
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: modificado.id,
        data: modificado.toJson(),
      );
      await awaitUntil(() => blocGame.selectedGame.votes.isEmpty);
      await blocGame.revealVotes();
      await awaitUntil(() => blocGame.selectedGame.votesRevealed);
      expect(blocGame.calculateAverage(), 0.0);
    });

    test('retorna 0.0 si todos los votos son no numéricos', () async {
      final UserModel user = fakeSession.currentUser!;
      final List<CardModel> deck = <CardModel>[
        const CardModel(
          id: 'x',
          display: '?',
          value: -1,
          description: '',
        ), // carta especial/no numérica,
        const CardModel(id: '1', display: '1', value: 1, description: ''),
      ];
      final VoteModel vote = VoteModel(userId: user.id, cardId: 'x');
      final GameModel modificado = blocGame.selectedGame.copyWith(
        deck: deck,
        votes: <VoteModel>[vote],
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: modificado.id,
        data: modificado.toJson(),
      );
      await awaitUntil(() => blocGame.selectedGame.votes.length == 1);
      await blocGame.revealVotes();
      await awaitUntil(() => blocGame.selectedGame.votesRevealed);
      expect(blocGame.calculateAverage(), 0.0);
    });

    test('calcula promedio solo de votos numéricos', () async {
      final UserModel user = fakeSession.currentUser!;
      final List<CardModel> deck = <CardModel>[
        const CardModel(
          id: 'x',
          display: '?',
          value: -1,
          description: '',
        ), // carta especial/no numérica,
        const CardModel(id: '1', display: '1', value: 1, description: ''),
        const CardModel(id: '2', display: '2', value: 2, description: ''),
      ];
      final List<VoteModel> votes = <VoteModel>[
        VoteModel(userId: user.id, cardId: '1'),
        const VoteModel(userId: 'otro', cardId: '2'),
      ];
      final GameModel modificado = blocGame.selectedGame.copyWith(
        deck: deck,
        votes: votes,
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: modificado.id,
        data: modificado.toJson(),
      );
      await awaitUntil(() => blocGame.selectedGame.votes.length == 2);
      await blocGame.revealVotes();
      await awaitUntil(() => blocGame.selectedGame.votesRevealed);
      expect(blocGame.calculateAverage(), closeTo(1.5, 0.0001));
    });

    test('ignora votos no numéricos', () async {
      final UserModel user = fakeSession.currentUser!;
      final List<CardModel> deck = <CardModel>[
        const CardModel(
          id: 'x',
          display: '?',
          value: -1,
          description: '',
        ), // carta especial/no numérica,
        const CardModel(id: '1', display: '1', value: 1, description: ''),
        const CardModel(id: '2', display: '2', value: 2, description: ''),
      ];
      final List<VoteModel> votes = <VoteModel>[
        VoteModel(userId: user.id, cardId: '1'),
        const VoteModel(userId: 'otro', cardId: 'x'),
        const VoteModel(userId: 'otro2', cardId: '2'),
      ];
      final GameModel modificado = blocGame.selectedGame.copyWith(
        deck: deck,
        votes: votes,
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: modificado.id,
        data: modificado.toJson(),
      );
      await awaitUntil(() => blocGame.selectedGame.votes.length == 3);
      await blocGame.revealVotes();
      await awaitUntil(() => blocGame.selectedGame.votesRevealed);
      expect(blocGame.calculateAverage(), closeTo(1.5, 0.0001));
    });

    test('calcula promedio decimal correctamente', () async {
      final UserModel user = fakeSession.currentUser!;
      final List<CardModel> deck = <CardModel>[
        const CardModel(id: '1', display: '1', value: 1, description: ''),
        const CardModel(id: '3', display: '3', value: 3, description: ''),
      ];
      final List<VoteModel> votes = <VoteModel>[
        VoteModel(userId: user.id, cardId: '1'),
        const VoteModel(userId: 'otro', cardId: '3'),
      ];
      final GameModel modificado = blocGame.selectedGame.copyWith(
        deck: deck,
        votes: votes,
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: modificado.id,
        data: modificado.toJson(),
      );
      await awaitUntil(() => blocGame.selectedGame.votes.length == 2);
      await blocGame.revealVotes();
      await awaitUntil(() => blocGame.selectedGame.votesRevealed);
      expect(blocGame.calculateAverage(), closeTo(2.0, 0.0001));
    });
  });

  group('setName', () {
    test('actualiza el nombre correctamente', () {
      blocGame.setName('Test Game');
      expect(blocGame.selectedGame.name, 'Test Game');
    });

    test('sobrescribe el nombre anterior', () {
      blocGame.setName('Primer Nombre');
      blocGame.setName('Segundo Nombre');
      expect(blocGame.selectedGame.name, 'Segundo Nombre');
    });

    test('permite nombres vacíos', () {
      blocGame.setName('');
      expect(blocGame.selectedGame.name, '');
    });

    test('permite nombres con caracteres especiales', () {
      blocGame.setName('¡Juego #1! 🚀');
      expect(blocGame.selectedGame.name, '¡Juego #1! 🚀');
    });

    test('no afecta otros campos del modelo', () {
      final Role? roleAntes = blocGame.selectedRole;
      blocGame.setName('Solo cambia el nombre');
      expect(blocGame.selectedRole, roleAntes);
    });
  });

  group('selectRoleDraft', () {
    test(
      'cambia el draft a jugador, pero el rol real no cambia hasta confirmar',
      () {
        final Role? antes = blocGame.selectedRole;
        blocGame.selectRoleDraft(Role.jugador);
        expect(blocGame.selectedRole, antes);
        blocGame.confirmRoleSelection();
        expect(blocGame.selectedRole, Role.jugador);
      },
    );

    test(
      'cambia el draft a espectador, pero el rol real no cambia hasta confirmar',
      () {
        final Role? antes = blocGame.selectedRole;
        blocGame.selectRoleDraft(Role.espectador);
        expect(blocGame.selectedRole, antes);
        blocGame.confirmRoleSelection();
        expect(blocGame.selectedRole, Role.espectador);
      },
    );

    test('no afecta el nombre ni otros campos', () {
      final String nombreAntes = blocGame.selectedGame.name;
      blocGame.selectRoleDraft(Role.jugador);
      expect(blocGame.selectedGame.name, nombreAntes);
    });
  });

  test('roleDraft refleja el valor seleccionado en el draft', () {
    blocGame.selectRoleDraft(Role.espectador);
    expect(blocGame.roleDraft, Role.espectador);
    blocGame.selectRoleDraft(Role.jugador);
    expect(blocGame.roleDraft, Role.jugador);
  });

  test('roleDraft vuelve al valor real tras confirmar', () {
    blocGame.selectRoleDraft(Role.espectador);
    blocGame.confirmRoleSelection();
    expect(blocGame.roleDraft, blocGame.selectedRole);
  });

  group('confirmRoleSelection', () {
    test('confirma el draft y actualiza el rol real', () {
      blocGame.selectRoleDraft(Role.espectador);
      blocGame.confirmRoleSelection();
      expect(blocGame.selectedRole, Role.espectador);
      expect(
        blocGame.roleDraft,
        Role.espectador,
      ); // draft limpio, refleja el real
    });

    test('si no hay draft ni rol, asigna jugador por defecto', () {
      // Asegúrate de que no hay draft ni rol antes
      // (en este contexto, al inicio del test, selectedRole es null)
      blocGame.confirmRoleSelection();
      expect(blocGame.selectedRole, Role.jugador);
      expect(blocGame.roleDraft, Role.jugador);
    });

    test('limpia el draft tras confirmar', () {
      blocGame.selectRoleDraft(Role.jugador);
      blocGame.confirmRoleSelection();
      // Cambiar a espectador, pero no confirmar
      blocGame.selectRoleDraft(Role.espectador);
      expect(blocGame.roleDraft, Role.espectador);
      blocGame.confirmRoleSelection();
      expect(blocGame.roleDraft, blocGame.selectedRole);
    });
  });

  group('createGame', () {
    setUp(() async {
      if (fakeSession.currentUser == null) {
        await fakeSession.signInWithGoogle();
      }
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    test('crea un juego con nombre válido', () async {
      await blocGame.createGame(name: 'Nueva Partida');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(blocGame.selectedGame.name, 'Nueva Partida');
      expect(blocGame.selectedGame.id.isNotEmpty, isTrue);
    });
    test('el id generado no es vacío y es único', () async {
      await blocGame.createGame(name: 'Partida 1');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final String id1 = blocGame.selectedGame.id;
      await blocGame.createGame(name: 'Partida 2');
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final String id2 = blocGame.selectedGame.id;
      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));
    });
    test('el usuario autenticado está en la lista de players', () async {
      await blocGame.createGame(name: 'Partida con Usuario');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final String userId = fakeSession.currentUser!.id;
      expect(
        blocGame.selectedGame.players.any((UserModel u) => u.id == userId),
        isTrue,
      );
    });
    test('isNameValid es false si el nombre es menor a 3 caracteres', () async {
      blocGame.setName('ab');
      expect(blocGame.isNameValid, isFalse);
      blocGame.setName('abc');
      expect(blocGame.isNameValid, isTrue);
    });
  });

  group('createMyGame', () {
    setUp(() async {
      if (fakeSession.currentUser == null) {
        await fakeSession.signInWithGoogle();
      }
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    test('crea un juego válido con el nombre actual', () async {
      blocGame.setName('Partida MyGame');
      await blocGame.createMyGame();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(blocGame.selectedGame.name, 'Partida MyGame');
      expect(blocGame.selectedGame.id.isNotEmpty, isTrue);
    });
    test('muestra el modal de nombre y rol tras crear', () async {
      blocGame.setName('Partida Modal');
      await blocGame.createMyGame();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(blocGame.blocModal.isShowing, isTrue);
      expect(
        blocGame.blocModal.currentModal?.runtimeType.toString(),
        contains('NameAndRoleModal'),
      );
    });
    test('el usuario autenticado está en players tras crearMyGame', () async {
      blocGame.setName('Partida con Usuario');
      await blocGame.createMyGame();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final String userId = fakeSession.currentUser!.id;
      expect(
        blocGame.selectedGame.players.any((UserModel u) => u.id == userId),
        isTrue,
      );
    });
    test('el id es único si se llama varias veces', () async {
      blocGame.setName('Partida 1');
      await blocGame.createMyGame();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      final String id1 = blocGame.selectedGame.id;
      blocGame.setName('Partida 2');
      await blocGame.createMyGame();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      final String id2 = blocGame.selectedGame.id;
      expect(id1, isNotEmpty);
      expect(id2, isNotEmpty);
      expect(id1, isNot(equals(id2)));
    });
  });

  group('setUserRole', () {
    setUp(() async {
      if (fakeSession.currentUser == null) {
        await fakeSession.signInWithGoogle();
      }
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await blocGame.createGame(name: 'Partida Roles');
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    test('asigna correctamente el rol de jugador', () async {
      await blocGame.setUserRole(
        user: fakeSession.currentUser!,
        role: Role.jugador,
      );
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(blocGame.selectedRole, Role.jugador);
      final String userId = fakeSession.currentUser!.id;
      expect(
        blocGame.selectedGame.players.any((UserModel u) => u.id == userId),
        isTrue,
      );
      expect(
        blocGame.selectedGame.spectators.any((UserModel u) => u.id == userId),
        isFalse,
      );
    });
    test('asigna correctamente el rol de espectador', () async {
      await blocGame.setUserRole(
        user: fakeSession.currentUser!,
        role: Role.espectador,
      );
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(blocGame.selectedRole, Role.espectador);
      final String userId = fakeSession.currentUser!.id;
      expect(
        blocGame.selectedGame.spectators.any((UserModel u) => u.id == userId),
        isTrue,
      );
      expect(
        blocGame.selectedGame.players.any((UserModel u) => u.id == userId),
        isFalse,
      );
    });
    test('los cambios de rol son reactivos en selectedRole', () async {
      await blocGame.setUserRole(
        user: fakeSession.currentUser!,
        role: Role.jugador,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(blocGame.selectedRole, Role.jugador);
      await blocGame.setUserRole(
        user: fakeSession.currentUser!,
        role: Role.espectador,
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(blocGame.selectedRole, Role.espectador);
    });
  });

  group('gameStream', () {
    setUp(() async {
      if (fakeSession.currentUser == null) {
        await fakeSession.signInWithGoogle();
      }
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    test('emite GameModel.empty al inicializar', () async {
      expect(
        blocGame.gameStream,
        emits(
          predicate<GameModel>(
            (GameModel game) => game.id == '' && game.name == '',
          ),
        ),
      );
    });
    test('emite el modelo tras crear un juego', () async {
      await blocGame.createGame(name: 'Stream Test');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(
        blocGame.gameStream,
        emits(
          predicate<GameModel>((GameModel game) => game.name == 'Stream Test'),
        ),
      );
    });
    test('emite el nuevo estado cuando se actualiza en fakeDb', () async {
      await blocGame.createGame(name: 'Stream Test');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final String gameId = blocGame.selectedGame.id;
      const String nuevoNombre = 'Stream Modificado';
      final GameModel modificado = blocGame.selectedGame.copyWith(
        name: nuevoNombre,
      );
      final List<Matcher> expectedStates = <Matcher>[
        predicate<GameModel>((GameModel game) => game.name == 'Stream Test'),
        predicate<GameModel>((GameModel game) => game.name == nuevoNombre),
      ];
      // Escucha el stream y espera los dos estados
      expectLater(blocGame.gameStream, emitsInOrder(expectedStates));
      await fakeDb.saveDocument(
        collection: 'games',
        docId: gameId,
        data: modificado.toJson(),
      );
    });
  });

  group('selectedGame', () {
    setUp(() async {
      if (fakeSession.currentUser == null) {
        await fakeSession.signInWithGoogle();
      }
      // Limpia el juego antes de cada test
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    test('devuelve GameModel.empty al inicializar', () {
      expect(blocGame.selectedGame.id, '');
      expect(blocGame.selectedGame.name, '');
      expect(blocGame.selectedGame.players, isEmpty);
      expect(blocGame.selectedGame.spectators, isEmpty);
    });
    test('refleja el juego creado', () async {
      await blocGame.createGame(name: 'Partida BlocTest');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(blocGame.selectedGame.id.isNotEmpty, isTrue);
      expect(blocGame.selectedGame.name, 'Partida BlocTest');
      expect(
        blocGame.selectedGame.players.any(
          (UserModel u) => u.id == fakeSession.currentUser!.id,
        ),
        isTrue,
      );
    });
    test('se actualiza cuando se guarda un nuevo estado en fakeDb', () async {
      await blocGame.createGame(name: 'Partida BlocTest');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final String gameId = blocGame.selectedGame.id;
      const String nuevoNombre = 'Partida Modificada';
      final GameModel modificado = blocGame.selectedGame.copyWith(
        name: nuevoNombre,
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: gameId,
        data: modificado.toJson(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(blocGame.selectedGame.name, nuevoNombre);
    });
  });

  group('selectedRole', () {
    setUp(() async {
      if (fakeSession.currentUser == null) {
        await fakeSession.signInWithGoogle();
      }
      // Crea un juego realista y espera a la suscripción
      await blocGame.createGame(name: 'Test Game');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(blocGame.selectedGame.id.isNotEmpty, isTrue);
    });
    test(
      'reactivo: devuelve Role.jugador si el usuario está en players',
      () async {
        if (fakeSession.currentUser == null) {
          await fakeSession.signInWithGoogle();
        }
        final UserModel user = fakeSession.currentUser!;
        final String gameId = blocGame.selectedGame.id;
        final GameModel playersGame = blocGame.selectedGame.copyWith(
          players: <UserModel>[user],
          spectators: <UserModel>[],
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: playersGame.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
        expect(blocGame.selectedRole, Role.jugador);
      },
    );

    test(
      'reactivo: devuelve Role.espectador si el usuario está en spectators',
      () async {
        if (fakeSession.currentUser == null) {
          await fakeSession.signInWithGoogle();
        }
        final UserModel user = fakeSession.currentUser!;
        final String gameId = blocGame.selectedGame.id;
        final GameModel spectatorsGame = blocGame.selectedGame.copyWith(
          players: <UserModel>[],
          spectators: <UserModel>[user],
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: spectatorsGame.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
        expect(blocGame.selectedRole, Role.espectador);
      },
    );

    test(
      'reactivo: devuelve null si el usuario no está en ninguna lista',
      () async {
        if (fakeSession.currentUser == null) {
          await fakeSession.signInWithGoogle();
        }
        final String gameId = blocGame.selectedGame.id;
        final GameModel noneGame = blocGame.selectedGame.copyWith(
          players: <UserModel>[],
          spectators: <UserModel>[],
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: noneGame.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
        expect(blocGame.selectedRole, isNull);
      },
    );

    test('devuelve null si no hay usuario en sesión', () async {
      await blocGame.blocSession.signOut();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(blocGame.selectedRole, isNull);
      // Simula usuario nuevamente
      await fakeSession.signInWithGoogle();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      // Verifica que el usuario vuelve a estar disponible
      expect(fakeSession.currentUser, isNotNull);
    });
  });

  group('setVote', () {
    setUp(() async {
      if (fakeSession.currentUser == null) {
        await fakeSession.signInWithGoogle();
      }
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await blocGame.createGame(name: 'Partida Votos');
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    test('un usuario puede votar y el voto aparece en votes', () async {
      const CardModel card = CardModel(
        id: 'carta1',
        display: '5',
        value: 5,
        description: 'Cinco',
      );
      await blocGame.setVote(card);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      final String userId = fakeSession.currentUser!.id;
      expect(
        blocGame.selectedGame.votes.any(
          (VoteModel v) => v.userId == userId && v.cardId == card.id,
        ),
        isTrue,
      );
    });
    test('si vota de nuevo reemplaza su voto', () async {
      const CardModel card1 = CardModel(
        id: 'carta1',
        display: '5',
        value: 5,
        description: 'Cinco',
      );
      const CardModel card2 = CardModel(
        id: 'carta2',
        display: '8',
        value: 8,
        description: 'Ocho',
      );
      await blocGame.setVote(card1);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await blocGame.setVote(card2);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      final String userId = fakeSession.currentUser!.id;
      expect(
        blocGame.selectedGame.votes
            .where((VoteModel v) => v.userId == userId)
            .length,
        1,
      );
      expect(
        blocGame.selectedGame.votes.any(
          (VoteModel v) => v.userId == userId && v.cardId == card2.id,
        ),
        isTrue,
      );
    });
    test('no vota si no hay usuario autenticado', () async {
      await blocGame.blocSession.signOut();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      const CardModel card = CardModel(
        id: 'carta1',
        display: '5',
        value: 5,
        description: 'Cinco',
      );
      await blocGame.setVote(card);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(blocGame.selectedGame.votes.isEmpty, isTrue);
    });
  });

  group('revealVotes', () {
    setUp(() async {
      if (fakeSession.currentUser == null) {
        await fakeSession.signInWithGoogle();
      }
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await blocGame.createGame(name: 'Partida Reveal');
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    test('votesRevealed es false inicialmente', () async {
      expect(blocGame.selectedGame.votesRevealed, isFalse);
    });
    test('revealVotes cambia votesRevealed a true y persiste', () async {
      await blocGame.revealVotes();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(blocGame.selectedGame.votesRevealed, isTrue);
    });
    test('revealVotes no afecta los votos existentes', () async {
      const CardModel card = CardModel(
        id: 'carta1',
        display: '5',
        value: 5,
        description: 'Cinco',
      );
      await blocGame.setVote(card);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final List<VoteModel> votosAntes = List<VoteModel>.from(
        blocGame.selectedGame.votes,
      );
      await blocGame.revealVotes();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(blocGame.selectedGame.votes, votosAntes);
    });
    test('revealVotes es idempotente (puede llamarse varias veces)', () async {
      await blocGame.revealVotes();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await blocGame.revealVotes();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(blocGame.selectedGame.votesRevealed, isTrue);
    });
  });

  group('hideVotes', () {
    setUp(() async {
      if (fakeSession.currentUser == null) {
        await fakeSession.signInWithGoogle();
      }
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await blocGame.createGame(name: 'Partida Hide');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await blocGame.revealVotes();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    test('votesRevealed es true tras revealVotes', () async {
      expect(blocGame.selectedGame.votesRevealed, isTrue);
    });
    test('hideVotes cambia votesRevealed a false y persiste', () async {
      await blocGame.hideVotes();
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(blocGame.selectedGame.votesRevealed, isFalse);
    });
    test('hideVotes no afecta los votos existentes', () async {
      const CardModel card = CardModel(
        id: 'carta1',
        display: '5',
        value: 5,
        description: 'Cinco',
      );
      await blocGame.setVote(card);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final List<VoteModel> votosAntes = List<VoteModel>.from(
        blocGame.selectedGame.votes,
      );
      await blocGame.hideVotes();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(blocGame.selectedGame.votes, votosAntes);
    });
    test('hideVotes es idempotente (puede llamarse varias veces)', () async {
      await blocGame.hideVotes();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await blocGame.hideVotes();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(blocGame.selectedGame.votesRevealed, isFalse);
    });
  });

  group('resetRound', () {
    setUp(() async {
      if (fakeSession.currentUser == null) {
        await fakeSession.signInWithGoogle();
      }
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await blocGame.createGame(name: 'Partida Reset');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await blocGame.setVote(
        const CardModel(
          id: 'carta1',
          display: '5',
          value: 5,
          description: 'Cinco',
        ),
      );
      await blocGame.revealVotes();
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    test('limpia los votos', () async {
      expect(blocGame.selectedGame.votes.isNotEmpty, isTrue);
      await blocGame.resetRound();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(blocGame.selectedGame.votes.isEmpty, isTrue);
    });
    test('pone votesRevealed en false', () async {
      expect(blocGame.selectedGame.votesRevealed, isTrue);
      await blocGame.resetRound();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(blocGame.selectedGame.votesRevealed, isFalse);
    });
    test('no afecta otros campos relevantes', () async {
      final String nombreAntes = blocGame.selectedGame.name;
      final List<UserModel> jugadoresAntes = List<UserModel>.from(
        blocGame.selectedGame.players,
      );
      await blocGame.resetRound();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(blocGame.selectedGame.name, nombreAntes);
      expect(
        blocGame.selectedGame.players.map((UserModel u) => u.id).toList(),
        equals(jugadoresAntes.map((UserModel u) => u.id).toList()),
      );
    });
    test('es idempotente (puede llamarse varias veces)', () async {
      await blocGame.resetRound();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await blocGame.resetRound();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(blocGame.selectedGame.votes.isEmpty, isTrue);
      expect(blocGame.selectedGame.votesRevealed, isFalse);
    });
  });

  group('updateGame', () {
    setUp(() async {
      if (fakeSession.currentUser == null) {
        await fakeSession.signInWithGoogle();
      }
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await blocGame.createGame(name: 'Partida Update');
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    test('persiste cambios de nombre en el backend', () async {
      blocGame.setName('Nuevo Nombre');
      await blocGame.updateGame();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      // Forzamos reload desde el backend
      final String id = blocGame.selectedGame.id;
      final Map<String, dynamic>? gameReloaded = await fakeDb.readDocument(
        collection: 'games',
        docId: id,
      );
      expect(gameReloaded!['name'], 'Nuevo Nombre');
    });
    test('persiste votos y votesRevealed', () async {
      const CardModel card = CardModel(
        id: 'carta1',
        display: '5',
        value: 5,
        description: 'Cinco',
      );
      await blocGame.setVote(card);
      await blocGame.revealVotes();
      await blocGame.updateGame();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final String id = blocGame.selectedGame.id;
      final Map<String, dynamic>? gameReloaded = await fakeDb.readDocument(
        collection: 'games',
        docId: id,
      );
      expect(gameReloaded!['votesRevealed'], true);
      expect(
        (gameReloaded['votes'] as List<Map<String, dynamic>>).any(
          (Map<String, dynamic> v) => v['cardId'] == 'carta1',
        ),
        isTrue,
      );
    });
    test('es idempotente si no hay cambios', () async {
      final String idAntes = blocGame.selectedGame.id;
      await blocGame.updateGame();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final String idDespues = blocGame.selectedGame.id;
      expect(idDespues, idAntes);
    });
    test('si el id cambia, se resuscribe correctamente', () async {
      final String idAntes = blocGame.selectedGame.id;
      // Simula cambio de id (nuevo juego)
      await blocGame.createGame(name: 'Nuevo Juego', gameId: 'nuevo_id');
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(blocGame.selectedGame.id, isNot(idAntes));
    });
  });

  group('showNameAndRoleModal', () {
    test('muestra el modal de nombre y rol', () {
      // Asegura que el modal no está visible al inicio
      expect(blocGame.blocModal.isShowing, isFalse);
      blocGame.showNameAndRoleModal();
      expect(blocGame.blocModal.isShowing, isTrue);
      // El widget mostrado debe ser NameAndRoleModal
      expect(
        blocGame.blocModal.currentModal?.runtimeType.toString(),
        contains('NameAndRoleModal'),
      );
      // Oculta el modal para limpiar estado
      blocGame.blocModal.hideModal();
      expect(blocGame.blocModal.isShowing, isFalse);
    });
  });

  Future<void> waitForView(
    BlocNavigator navigator,
    EnumViews expected, {
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final Completer<void> completer = Completer<void>();
    final StreamSubscription<EnumViews> sub = navigator.viewStream.listen((
      EnumViews view,
    ) {
      if (view == expected) {
        completer.complete();
      }
    });
    if (navigator.currentView == expected) {
      await sub.cancel();
      return;
    }
    await completer.future.timeout(
      timeout,
      onTimeout: () {
        sub.cancel();
        throw Exception('Timeout esperando vista $expected');
      },
    );
    await sub.cancel();
  }

  // NOTA IMPORTANTE:
  // Para que los tests de navegación sean deterministas y reflejen el flujo real,
  // primero se debe crear el BlocGame (lo que instala los listeners sobre el userStream),
  // y luego ejecutar el login (signInWithGoogle). Así el listener reacciona y navega.
  // Si se hace el login antes de crear el bloc, el stream no emite y la navegación no ocurre.
  group('init', () {
    setUp(() async {
      // Asegura que no haya usuario antes de cada test
      await fakeSession.signOut();
      expect(fakeSession.currentUser, isNull);
      expect(blocSession.user, isNull);
    });

    test('setup asegura usuario activo', () async {
      await fakeSession.signInWithGoogle();
      expect(fakeSession.currentUser, isNotNull);
      expect(blocSession.user, isNotNull);
    });

    test('navega a createGame tras iniciar sesión y no haber juego', () async {
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await fakeSession.signInWithGoogle();
      if (blocGame.blocNavigator.currentView != EnumViews.createGame) {
        await waitForView(blocGame.blocNavigator, EnumViews.createGame);
      }
      expect(blocGame.blocNavigator.currentView, EnumViews.createGame);
    });

    test('navega a centralStage si usuario y juego están presentes', () async {
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await fakeSession.signInWithGoogle();
      await blocGame.createGame(name: 'Partida Init');
      if (blocGame.blocNavigator.currentView != EnumViews.centralStage) {
        await waitForView(blocGame.blocNavigator, EnumViews.centralStage);
      }
      expect(blocGame.blocNavigator.currentView, EnumViews.centralStage);
    });

    test('navega a splash si el usuario se desconecta', () async {
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await fakeSession.signInWithGoogle();
      await fakeSession.signOut();
      if (blocGame.blocNavigator.currentView != EnumViews.splash) {
        await waitForView(blocGame.blocNavigator, EnumViews.splash);
      }
      expect(blocGame.blocNavigator.currentView, EnumViews.splash);
    });

    test('actualiza asientos al cambiar el juego', () async {
      blocGame = BlocGame(
        blocSession: blocSession,
        createGameUsecase: createGameUsecase,
        getGameStreamUsecase: getGameStreamUsecase,
        blocModal: BlocModal(),
        blocNavigator: BlocNavigator(blocSession),
      );
      await fakeSession.signInWithGoogle();
      final List<UserModel?> seatsAntes = List<UserModel?>.from(
        blocGame.seatsOfPlanningPoker,
      );
      await blocGame.createGame(name: 'Nueva Partida');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      final List<UserModel?> seatsDespues = blocGame.seatsOfPlanningPoker;
      expect(seatsDespues, isNot(equals(seatsAntes)));
    });
  });
}
