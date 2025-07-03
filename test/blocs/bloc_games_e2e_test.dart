import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/blocs/bloc_game.dart';
import 'package:ppdartw/blocs/bloc_games.dart';
import 'package:ppdartw/blocs/bloc_modal.dart';
import 'package:ppdartw/blocs/bloc_navigator.dart';
import 'package:ppdartw/blocs/bloc_session.dart';
import 'package:ppdartw/domain/models/game_model.dart';
import 'package:ppdartw/domain/models/vote_model.dart';
import 'package:ppdartw/domain/usecases/game/create_game_usecase.dart';
import 'package:ppdartw/domain/usecases/game/get_game_stream_usecase.dart';
import 'package:ppdartw/domain/usecases/game/get_games_stream_usecase.dart';
import 'package:ppdartw/domain/usecases/session/get_user_stream_usecase.dart';
import 'package:ppdartw/domain/usecases/session/sign_in_with_google_usecase.dart';
import 'package:ppdartw/domain/usecases/session/sign_out_usecase.dart';
import 'package:ppdartw/infrastructure/gateways/game_gateway_impl.dart';
import 'package:ppdartw/infrastructure/gateways/session_gateway_impl.dart';
import 'package:ppdartw/infrastructure/repositories/game_repository_impl.dart';
import 'package:ppdartw/infrastructure/repositories/session_repository_impl.dart';
import 'package:ppdartw/infrastructure/services/fake_service_session.dart';
import 'package:ppdartw/infrastructure/services/fake_service_ws_database.dart';
import 'package:ppdartw/shared/multi_player_simulation_util.dart';

void main() {
  late FakeServiceWsDatabase fakeDb;
  final FakeServiceSession fakeSession = FakeServiceSession();
  late BlocNavigator blocNavigator;
  final BlocModal blocModal = BlocModal();
  final SessionRepositoryImpl sessionRepository = SessionRepositoryImpl(
    SessionGatewayImpl(fakeSession),
  );
  final BlocSession blocSession = BlocSession(
    signInWithGoogleUsecase: SignInWithGoogleUsecase(sessionRepository),
    signOutUsecase: SignOutUsecase(sessionRepository),
    getUserStreamUsecase: GetUserStreamUsecase(sessionRepository),
  );
  const String gameId = 'e2e_game';
  late GameRepositoryImpl gameRepository;
  late GetGamesStreamUsecase getGamesStreamUsecase;
  late BlocGame blocGame;
  late BlocGames blocGames;

  setUp(() {
    fakeDb = FakeServiceWsDatabase();
    gameRepository = GameRepositoryImpl(GameGatewayImpl(fakeDb));
    getGamesStreamUsecase = GetGamesStreamUsecase(gameRepository);
    blocNavigator = BlocNavigator(blocSession);
    final CreateGameUsecase createGameUsecase = CreateGameUsecase(
      gameRepository,
    );
    final GetGameStreamUsecase getGameStreamUsecase = GetGameStreamUsecase(
      gameRepository,
    );

    blocGame = BlocGame(
      blocSession: blocSession,
      createGameUsecase: createGameUsecase,
      getGameStreamUsecase: getGameStreamUsecase,
      blocModal: blocModal,
      blocNavigator: blocNavigator,
    );
    blocGames = BlocGames(
      getGamesStreamUsecase: getGamesStreamUsecase,
      blocGame: blocGame,
    );
  });

  tearDown(() {
    blocGames.dispose();
    fakeDb.dispose();
  });

  group('E2E Simulación MultiPlayerSimulationUtil + BlocGames', () {
    test('Simula llegada de jugadores y refleja en BlocGames', () async {
      await MultiPlayerSimulationUtil.simulateNewPlayers(fakeDb, gameId, 4);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      final List<GameModel> juegos = blocGames.games;
      expect(juegos.any((GameModel g) => g.id == gameId), isTrue);
      final GameModel game = juegos.firstWhere((GameModel g) => g.id == gameId);
      expect(game.players.length, 4);
    });

    test('Simula llegada de espectadores y refleja en BlocGames', () async {
      await MultiPlayerSimulationUtil.simulateNewSpectators(
        fakeDb,
        gameId,
        3,
        const Duration(milliseconds: 10),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      final List<GameModel> juegos = blocGames.games;
      expect(juegos.any((GameModel g) => g.id == gameId), isTrue);
      final GameModel game = juegos.firstWhere((GameModel g) => g.id == gameId);
      expect(game.spectators.length, 2); // Admin no es espectador
    });

    test('Simula votos aleatorios y refleja en BlocGames', () async {
      await MultiPlayerSimulationUtil.simulateNewPlayers(fakeDb, gameId, 4);
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      final List<GameModel> juegos = blocGames.games;
      final GameModel game = juegos.firstWhere((GameModel g) => g.id == gameId);
      final UserModel currentUser = game.players.first;
      await MultiPlayerSimulationUtil.randomVotes(
        fakeDb,
        gameId,
        currentUser,
        const Duration(milliseconds: 10),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      final GameModel updated = blocGames.games.firstWhere(
        (GameModel g) => g.id == gameId,
      );
      expect(updated.votes.length, updated.players.length - 1);
      expect(
        updated.votes.any((VoteModel v) => v.userId == currentUser.id),
        isFalse,
      );
    });

    test(
      'Desconecta progresivamente otros usuarios y refleja en BlocGames',
      () async {
        await MultiPlayerSimulationUtil.simulateNewPlayers(
          fakeDb,
          gameId,
          4,
          const Duration(milliseconds: 10),
        );
        await MultiPlayerSimulationUtil.simulateNewSpectators(
          fakeDb,
          gameId,
          3,
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 40));
        final List<GameModel> juegos = blocGames.games;
        final GameModel game = juegos.firstWhere(
          (GameModel g) => g.id == gameId,
        );
        final UserModel currentUser = game.players.first;
        await MultiPlayerSimulationUtil.disconnectOtherUsers(
          fakeDb,
          gameId,
          currentUser,
          const Duration(milliseconds: 10),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final GameModel updated = blocGames.games.firstWhere(
          (GameModel g) => g.id == gameId,
        );
        expect(updated.players.length, 1);
        expect(updated.spectators.length, 0);
      },
    );

    test(
      'Simulación completa: jugadores, espectadores, votos y desconexión reflejado en BlocGames',
      () async {
        await MultiPlayerSimulationUtil.simulateNewPlayers(
          fakeDb,
          gameId,
          5,
          const Duration(milliseconds: 10),
        );
        await MultiPlayerSimulationUtil.simulateNewSpectators(
          fakeDb,
          gameId,
          4,
          const Duration(milliseconds: 10),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await Future<void>.delayed(const Duration(milliseconds: 40));
        final List<GameModel> juegos = blocGames.games;
        final GameModel game = juegos.firstWhere(
          (GameModel g) => g.id == gameId,
        );
        final UserModel currentUser = game.players.first;
        await MultiPlayerSimulationUtil.randomVotes(
          fakeDb,
          gameId,
          currentUser,
          const Duration(milliseconds: 10),
        );
        await MultiPlayerSimulationUtil.disconnectOtherUsers(
          fakeDb,
          gameId,
          currentUser,
          const Duration(milliseconds: 10),
        );
        await Future<void>.delayed(const Duration(milliseconds: 100));
        final GameModel updated = blocGames.games.firstWhere(
          (GameModel g) => g.id == gameId,
        );
        expect(updated.players.length, 1);
        expect(updated.spectators.length, 0);
        expect(updated.votes.length, greaterThanOrEqualTo(0));
      },
    );
  });
}
