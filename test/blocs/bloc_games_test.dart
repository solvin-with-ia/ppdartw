import 'package:flutter_test/flutter_test.dart';
import 'package:ppdartw/blocs/bloc_game.dart';
import 'package:ppdartw/blocs/bloc_games.dart';
import 'package:ppdartw/blocs/bloc_modal.dart';
import 'package:ppdartw/blocs/bloc_navigator.dart';
import 'package:ppdartw/blocs/bloc_session.dart';
import 'package:ppdartw/domain/models/game_model.dart';
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

void main() {
  late FakeServiceWsDatabase fakeDb;
  final FakeServiceSession fakeServiceSession = FakeServiceSession();
  final SessionGatewayImpl sessionGatewayImpl = SessionGatewayImpl(
    fakeServiceSession,
  );
  late GameRepositoryImpl gameRepository;
  late GetGamesStreamUsecase getGamesStreamUsecase;
  late GetGameStreamUsecase getGameStreamUsecase;
  late BlocGame blocGame;
  late BlocGames blocGames;
  late BlocSession blocSession;
  late BlocModal blocModal;
  late BlocNavigator blocNavigator;
  final SessionRepositoryImpl sessionRepositoryImpl = SessionRepositoryImpl(
    sessionGatewayImpl,
  );
  setUp(() {
    fakeDb = FakeServiceWsDatabase();
    gameRepository = GameRepositoryImpl(GameGatewayImpl(fakeDb));
    final CreateGameUsecase createGameUsecase = CreateGameUsecase(
      gameRepository,
    );

    getGamesStreamUsecase = GetGamesStreamUsecase(gameRepository);
    getGameStreamUsecase = GetGameStreamUsecase(gameRepository);
    blocSession = BlocSession(
      signInWithGoogleUsecase: SignInWithGoogleUsecase(sessionRepositoryImpl),
      signOutUsecase: SignOutUsecase(sessionRepositoryImpl),
      getUserStreamUsecase: GetUserStreamUsecase(sessionRepositoryImpl),
    );
    blocModal = BlocModal();
    blocNavigator = BlocNavigator(blocSession);
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

  test('Inicializa con lista vacía y sin juego seleccionado', () {
    expect(blocGames.games.value, isEmpty);
    expect(blocGames.selectedGame.value, isNull);
  });

  test('Actualiza lista de juegos al agregar un juego en el fakeDb', () async {
    final Map<String, dynamic> gameJson = GameModel.empty()
        .copyWith(id: 'g1', name: 'J1')
        .toJson();
    fakeDb.saveDocument(collection: 'games', docId: 'g1', data: gameJson);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(
      blocGames.games.value.where((GameModel g) => g.id == 'g1').length,
      1,
    );
  });

  test('Deselecciona el juego si desaparece de la lista', () async {
    final Map<String, dynamic> gameJson = GameModel.empty()
        .copyWith(id: 'g2', name: 'J2')
        .toJson();
    fakeDb.saveDocument(collection: 'games', docId: 'g2', data: gameJson);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    blocGames.selectGame('g2');
    expect(blocGames.selectedGame.value?.id, 'g2');
    fakeDb.deleteDocument(collection: 'games', docId: 'g2');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(blocGames.selectedGame.value, isNull);
  });

  test('No selecciona juego si ID no existe', () async {
    blocGames.selectGame('nope');
    expect(blocGames.selectedGame.value, isNull);
  });

  test('Selecciona un juego existente', () async {
    final Map<String, dynamic> gameJson = GameModel.empty()
        .copyWith(id: 'g3', name: 'J3')
        .toJson();
    fakeDb.saveDocument(collection: 'games', docId: 'g3', data: gameJson);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    blocGames.selectGame('g3');
    expect(blocGames.selectedGame.value?.id, 'g3');
  });
}
