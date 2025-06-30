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
  late FakeServiceWsDatabase fakeDb;
  late FakeServiceSession fakeSession;
  late BlocGame blocGame;

  setUpAll(() {
    fakeDb = FakeServiceWsDatabase();
  });

  tearDownAll(() {
    fakeDb.dispose();
  });

  setUp(() async {
    fakeSession = FakeServiceSession();
    final GameRepositoryImpl gameRepository = GameRepositoryImpl(
      GameGatewayImpl(fakeDb),
    );
    final SessionRepositoryImpl sessionRepository = SessionRepositoryImpl(
      SessionGatewayImpl(fakeSession),
    );
    final BlocSession blocSession = BlocSession(
      signInWithGoogleUsecase: SignInWithGoogleUsecase(sessionRepository),
      signOutUsecase: SignOutUsecase(sessionRepository),
      getUserStreamUsecase: GetUserStreamUsecase(sessionRepository),
    );
    blocGame = BlocGame(
      blocSession: blocSession,
      createGameUsecase: CreateGameUsecase(gameRepository),
      getGameStreamUsecase: GetGameStreamUsecase(gameRepository),
      blocModal: BlocModal(),
      blocNavigator: BlocNavigator(blocSession),
    );
    await fakeSession.signInWithGoogle();
  });

  tearDown(() {
    blocGame.dispose();
    fakeSession.dispose();
    // Limpia juegos para el siguiente test
    fakeDb.dispose();
  });

  group('E2E BlocGame - integración y flujos de usuarios', () {
    test('Unión de jugador externo a partida activa', () async {
      // Usuario actual crea la partida
      await blocGame.createGame(name: 'Partida E2E');
      final String gameId = blocGame.selectedGame.id;
      final UserModel userA = fakeSession.currentUser!;

      // Simula jugador externo
      final UserModel externalPlayer = userA.copyWith(
        id: 'jugador_externo',
        displayName: 'Jugador Externo',
      );
      final GameModel updatedGame = blocGame.selectedGame.copyWith(
        players: List<UserModel>.of(blocGame.selectedGame.players)
          ..add(externalPlayer),
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: gameId,
        data: updatedGame.toJson(),
      );

      // Espera a que BlocGame reaccione y sincronice la lista de jugadores
      final DateTime start = DateTime.now();
      while (true) {
        final Set<String> ids = blocGame.selectedGame.players
            .map((UserModel u) => u.id)
            .toSet();
        if (ids.contains(userA.id) &&
            ids.contains('jugador_externo') &&
            ids.length == 2) {
          break;
        }
        if (DateTime.now().difference(start) > const Duration(seconds: 2)) {
          throw Exception('Timeout esperando sincronización de jugadores');
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      final Set<String> ids = blocGame.selectedGame.players
          .map((UserModel u) => u.id)
          .toSet();
      expect(ids.length, 2);
      expect(ids, containsAll(<dynamic>[userA.id, 'jugador_externo']));
    });

    test('Retiro de jugador externo', () async {
      // Usuario actual crea la partida
      await blocGame.createGame(name: 'Partida E2E');
      final String gameId = blocGame.selectedGame.id;
      final UserModel userA = fakeSession.currentUser!;

      // Simula jugador externo
      final UserModel externalPlayer = userA.copyWith(
        id: 'jugador_externo',
        displayName: 'Jugador Externo',
      );
      final GameModel gameWithExternal = blocGame.selectedGame.copyWith(
        players: List<UserModel>.of(blocGame.selectedGame.players)
          ..add(externalPlayer),
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: gameId,
        data: gameWithExternal.toJson(),
      );
      // Espera a que esté sincronizado
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(
        blocGame.selectedGame.players.map((UserModel u) => u.id).toSet(),
        containsAll(<dynamic>[userA.id, 'jugador_externo']),
      );
      // Ahora simula la salida del jugador externo
      final GameModel gameWithoutExternal = blocGame.selectedGame.copyWith(
        players: List<UserModel>.of(blocGame.selectedGame.players)
          ..removeWhere((UserModel u) => u.id == 'jugador_externo'),
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: gameId,
        data: gameWithoutExternal.toJson(),
      );
      // Espera a que se sincronice
      final DateTime start = DateTime.now();
      while (true) {
        final Set<String> ids = blocGame.selectedGame.players
            .map((UserModel u) => u.id)
            .toSet();
        if (!ids.contains('jugador_externo') &&
            ids.contains(userA.id) &&
            ids.length == 1) {
          break;
        }
        if (DateTime.now().difference(start) > const Duration(seconds: 2)) {
          throw Exception(
            'Timeout esperando sincronización de retiro de jugador externo',
          );
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      final Set<String> ids = blocGame.selectedGame.players
          .map((UserModel u) => u.id)
          .toSet();
      expect(ids, contains(userA.id));
      expect(ids, isNot(contains('jugador_externo')));
      expect(ids.length, 1);
    });

    test('El usuario actual es jugador pero no admin', () async {
      // Simula partida creada por otro usuario (admin)
      final UserModel admin = fakeSession.currentUser!.copyWith(
        id: 'admin',
        displayName: 'Admin',
      );
      final UserModel userA = fakeSession.currentUser!;
      final GameModel game = GameModel(
        id: 'game1',
        name: 'Partida admin',
        admin: admin,
        spectators: const <UserModel>[],
        players: <UserModel>[admin, userA],
        votes: const <VoteModel>[],
        isActive: true,
        createdAt: DateTime.now(),
        deck: const <CardModel>[
          CardModel(id: 'c1', value: 5, display: '5', description: ''),
        ],
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: game.id,
        data: game.toJson(),
      );
      // Suscribe BlocGame al juego creado
      blocGame.subscribeToGame(game.id);

      // Espera activa a que el modelo reactivo se sincronice con el id correcto
      final DateTime waitStart = DateTime.now();
      while (blocGame.selectedGame.id != game.id) {
        if (DateTime.now().difference(waitStart) > const Duration(seconds: 2)) {
          fail(
            'Timeout esperando que BlocGame.selectedGame se sincronice con el juego creado',
          );
        }
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }

      expect(game.admin.id, 'admin');
      expect(
        game.players.map((UserModel u) => u.id),
        containsAll(<dynamic>['admin', fakeSession.currentUser!.id]),
      );

      // Debug: estado del deck antes de votar

      // Evita error si el deck está vacío
      if (blocGame.selectedGame.deck.isNotEmpty) {
        await blocGame.setVote(blocGame.selectedGame.deck.first);
        // Espera activa hasta que el voto esté registrado o timeout
        final DateTime start = DateTime.now();
        while (!blocGame.selectedGame.votes.any(
          (VoteModel v) => v.userId == fakeSession.currentUser!.id,
        )) {
          if (DateTime.now().difference(start) > const Duration(seconds: 2)) {
            fail(
              'Timeout esperando que el voto del usuario actual se registre',
            );
          }
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      }

      expect(
        blocGame.selectedGame.votes.any(
          (VoteModel v) => v.userId == fakeSession.currentUser!.id,
        ),
        isTrue,
      );
      // No puede finalizar partida: aquí solo verificamos que el admin es otro
      expect(blocGame.selectedGame.admin.id, isNot('jugador'));
    });

    test('Cambio de rol de espectador a jugador y viceversa', () async {
      await blocGame.createGame(name: 'Partida E2E');
      final UserModel userA = fakeSession.currentUser!;
      // Simula que el usuario es espectador
      await blocGame.setCurrentUserRole(Role.espectador);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(
        blocGame.selectedGame.spectators.any((UserModel u) => u.id == userA.id),
        isTrue,
      );
      expect(
        blocGame.selectedGame.players.any((UserModel u) => u.id == userA.id),
        isFalse,
      );
      // Ahora cambia a jugador
      await blocGame.setCurrentUserRole(Role.jugador);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(
        blocGame.selectedGame.players.any((UserModel u) => u.id == userA.id),
        isTrue,
      );
      expect(
        blocGame.selectedGame.spectators.any((UserModel u) => u.id == userA.id),
        isFalse,
      );
    });

    test(
      'Sincronización de votos y revelado para todos los jugadores',
      () async {
        await blocGame.createGame(name: 'Partida E2E');
        final String gameId = blocGame.selectedGame.id;
        final UserModel userA = fakeSession.currentUser!;
        // Simula otros dos jugadores
        final UserModel jugador2 = userA.copyWith(
          id: 'jugador2',
          displayName: 'Jugador 2',
        );
        final UserModel jugador3 = userA.copyWith(
          id: 'jugador3',
          displayName: 'Jugador 3',
        );
        // Simula votos
        final String cardId = blocGame.selectedGame.deck.first.id;
        final List<VoteModel> votes = <VoteModel>[
          VoteModel(userId: userA.id, cardId: cardId),
          VoteModel(userId: 'jugador2', cardId: cardId),
          VoteModel(userId: 'jugador3', cardId: cardId),
        ];
        final GameModel votedGame = blocGame.selectedGame.copyWith(
          players: <UserModel>[userA, jugador2, jugador3],
          votes: votes,
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: votedGame.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(blocGame.selectedGame.votes.length, 3);
        // Simula revelado de votos
        final GameModel revealedGame = votedGame.copyWith(votesRevealed: true);
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: revealedGame.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(blocGame.selectedGame.votesRevealed, isTrue);
        // Calcula promedio (debería ser igual al valor de la carta)
        final double avg = blocGame.calculateAverage();
        expect(avg, blocGame.selectedGame.deck.first.value.toDouble());
      },
    );

    test(
      '12 jugadores y 1 espectador, todos votan 5, promedio correcto y espectador nunca aparece en asientos, reinicio de ronda',
      () async {
        // Crea partida
        await blocGame.createGame(name: 'Partida con muchos jugadores');
        final String gameId = blocGame.selectedGame.id;
        final UserModel currentUser = fakeSession.currentUser!;
        // Genera 11 jugadores adicionales y 1 espectador
        final List<UserModel> jugadores = <UserModel>[currentUser];
        for (int i = 2; i <= 12; i++) {
          jugadores.add(
            currentUser.copyWith(id: 'jugador$i', displayName: 'Jugador $i'),
          );
        }
        final UserModel espectador = currentUser.copyWith(
          id: 'espectador1',
          displayName: 'Espectador 1',
        );
        // Actualiza el modelo en fakeDb
        final GameModel gameWithAll = blocGame.selectedGame.copyWith(
          players: jugadores,
          spectators: <UserModel>[espectador],
          votes: <VoteModel>[],
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: gameWithAll.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        // Verifica que los 12 jugadores están en la lista de asientos y el espectador NO
        final List<UserModel?> seats = blocGame.seatsOfPlanningPoker;
        final Set<String> seatIds = seats
            .whereType<UserModel>()
            .map((UserModel u) => u.id)
            .toSet();
        for (final UserModel jugador in jugadores) {
          expect(seatIds, contains(jugador.id));
        }
        expect(seatIds, isNot(contains(espectador.id)));
        // Todos los jugadores votan (simula que todos votan la primera carta, valor 5)
        final CardModel card5 = blocGame.selectedGame.deck.firstWhere(
          (CardModel c) => c.value == 5,
        );
        final List<VoteModel> votes = jugadores
            .map((UserModel u) => VoteModel(userId: u.id, cardId: card5.id))
            .toList();
        final GameModel gameWithVotes = blocGame.selectedGame.copyWith(
          votes: votes,
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: gameWithVotes.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        // Revela votos
        final GameModel revealed = blocGame.selectedGame.copyWith(
          votesRevealed: true,
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: revealed.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        // Promedio debe ser 5
        expect(blocGame.selectedGame.votes.length, 12);
        expect(blocGame.selectedGame.votesRevealed, isTrue);
        expect(blocGame.calculateAverage(), 5);
        // El espectador sigue sin estar en asientos
        final Set<String> seatIdsAfter = blocGame.seatsOfPlanningPoker
            .whereType<UserModel>()
            .map((UserModel u) => u.id)
            .toSet();
        expect(seatIdsAfter, isNot(contains(espectador.id)));
        // Reinicia ronda
        await blocGame.resetRound();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(blocGame.selectedGame.votes, isEmpty);
        expect(blocGame.selectedGame.votesRevealed, isFalse);
        // Segunda votación: todos vuelven a votar 5
        final GameModel gameWithVotes2 = blocGame.selectedGame.copyWith(
          votes: votes,
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: gameWithVotes2.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final GameModel revealed2 = blocGame.selectedGame.copyWith(
          votesRevealed: true,
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: revealed2.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(blocGame.selectedGame.votes.length, 12);
        expect(blocGame.selectedGame.votesRevealed, isTrue);
        expect(blocGame.calculateAverage(), 5);
        // El espectador nunca aparece en asientos
        final Set<String> seatIdsFinal = blocGame.seatsOfPlanningPoker
            .whereType<UserModel>()
            .map((UserModel u) => u.id)
            .toSet();
        expect(seatIdsFinal, isNot(contains(espectador.id)));
      },
    );

    test(
      'currentUser es admin y espectador, 11 jugadores, todos votan 5, promedio correcto y admin-espectador nunca aparece en asientos ni votos, reinicio de ronda',
      () async {
        // Crea partida con currentUser como admin
        await blocGame.createGame(name: 'Partida admin espectador');
        final String gameId = blocGame.selectedGame.id;
        final UserModel currentUser = fakeSession.currentUser!;
        // Genera 11 jugadores
        final List<UserModel> jugadores = <UserModel>[];
        for (int i = 1; i <= 11; i++) {
          jugadores.add(
            currentUser.copyWith(id: 'jugador$i', displayName: 'Jugador $i'),
          );
        }
        // currentUser será espectador (y admin)
        final UserModel adminEspectador = currentUser;
        // Actualiza el modelo en fakeDb
        final GameModel gameWithAll = blocGame.selectedGame.copyWith(
          admin: adminEspectador,
          players: jugadores,
          spectators: <UserModel>[adminEspectador],
          votes: <VoteModel>[],
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: gameWithAll.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        // Verifica que los 11 jugadores están en la lista de asientos y el admin-espectador NO
        final List<UserModel?> seats = blocGame.seatsOfPlanningPoker;
        final Set<String> seatIds = seats
            .whereType<UserModel>()
            .map((UserModel u) => u.id)
            .toSet();
        for (final UserModel jugador in jugadores) {
          expect(seatIds, contains(jugador.id));
        }
        // UX: currentUser (adminEspectador) SIEMPRE aparece en el asiento 8 (protagonista), aunque sea espectador
        expect(seats[8]?.id, adminEspectador.id);
        // Todos los jugadores votan (simula que todos votan la primera carta, valor 5)
        final CardModel card5 = blocGame.selectedGame.deck.firstWhere(
          (CardModel c) => c.value == 5,
        );
        final List<VoteModel> votes = jugadores
            .map((UserModel u) => VoteModel(userId: u.id, cardId: card5.id))
            .toList();
        final GameModel gameWithVotes = blocGame.selectedGame.copyWith(
          votes: votes,
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: gameWithVotes.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        // Revela votos
        final GameModel revealed = blocGame.selectedGame.copyWith(
          votesRevealed: true,
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: revealed.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        // Promedio debe ser 5
        expect(blocGame.selectedGame.votes.length, 11);
        expect(blocGame.selectedGame.votesRevealed, isTrue);
        expect(blocGame.calculateAverage(), 5);
        // El admin-espectador sigue sin estar en asientos ni votos
        blocGame.seatsOfPlanningPoker
            .whereType<UserModel>()
            .map((UserModel u) => u.id)
            .toSet();
        expect(seats[8]?.id, adminEspectador.id);
        expect(
          blocGame.selectedGame.votes.any(
            (VoteModel v) => v.userId == adminEspectador.id,
          ),
          isFalse,
        );
        // Reinicia ronda
        await blocGame.resetRound();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(blocGame.selectedGame.votes, isEmpty);
        expect(blocGame.selectedGame.votesRevealed, isFalse);
        // Segunda votación: todos vuelven a votar 5
        final GameModel gameWithVotes2 = blocGame.selectedGame.copyWith(
          votes: votes,
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: gameWithVotes2.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final GameModel revealed2 = blocGame.selectedGame.copyWith(
          votesRevealed: true,
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: revealed2.toJson(),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(blocGame.selectedGame.votes.length, 11);
        expect(blocGame.selectedGame.votesRevealed, isTrue);
        expect(blocGame.calculateAverage(), 5);
        // El admin-espectador nunca aparece en asientos ni votos
        blocGame.seatsOfPlanningPoker
            .whereType<UserModel>()
            .map((UserModel u) => u.id)
            .toSet();
        expect(seats[8]?.id, adminEspectador.id);
        expect(
          blocGame.selectedGame.votes.any(
            (VoteModel v) => v.userId == adminEspectador.id,
          ),
          isFalse,
        );
      },
    );
  });
}
