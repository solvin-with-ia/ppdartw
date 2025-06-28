import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/blocs/bloc_game.dart';
import 'package:ppdartw/blocs/bloc_modal.dart';
import 'package:ppdartw/blocs/bloc_navigator.dart';
import 'package:ppdartw/blocs/bloc_session.dart';
import 'package:ppdartw/domain/enums/role.dart';
import 'package:ppdartw/domain/models/game_model.dart';
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
      await blocGame.setUserRole(user: fakeSession.currentUser!, role: Role.jugador);
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
      await blocGame.setUserRole(user: fakeSession.currentUser!, role: Role.espectador);
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
      await blocGame.setUserRole(user: fakeSession.currentUser!, role: Role.jugador);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(blocGame.selectedRole, Role.jugador);
      await blocGame.setUserRole(user: fakeSession.currentUser!, role: Role.espectador);
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
}
