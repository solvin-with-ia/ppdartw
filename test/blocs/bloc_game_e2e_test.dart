import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/blocs/bloc_game.dart';
import 'package:ppdartw/blocs/bloc_modal.dart';
import 'package:ppdartw/blocs/bloc_navigator.dart';
import 'package:ppdartw/blocs/bloc_session.dart';
import 'package:ppdartw/domain/models/game_model.dart';
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
      // TODO: Implementar flujo y verificación
    });

    test('El usuario actual es jugador pero no admin', () async {
      // TODO: Implementar flujo y verificación
    });

    test('Cambio de rol de espectador a jugador y viceversa', () async {
      // TODO: Implementar flujo y verificación
    });

    test(
      'Sincronización de votos y revelado para todos los jugadores',
      () async {
        // TODO: Implementar flujo y verificación
      },
    );
  });
}
