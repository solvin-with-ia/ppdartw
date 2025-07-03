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
import 'package:ppdartw/ui/modals/games_list_modal.dart';

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

  group('BlocGames flujo de juegos', () {
    test('Inicializa con lista vacía y sin juego seleccionado', () async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(blocGames.games, isEmpty);
      expect(blocGames.selectedGame.id, GameModel.empty().id);
    });

    test(
      'Actualiza lista de juegos al agregar un juego en el fakeDb',
      () async {
        final Map<String, dynamic> gameJson = GameModel.empty()
            .copyWith(id: 'g1', name: 'J1')
            .toJson();
        fakeDb.saveDocument(collection: 'games', docId: 'g1', data: gameJson);
        await Future<void>.delayed(const Duration(milliseconds: 40));
        expect(blocGames.games.where((GameModel g) => g.id == 'g1').length, 1);
      },
    );

    test('Deselecciona el juego si desaparece de la lista', () async {
      final Map<String, dynamic> gameJson = GameModel.empty()
          .copyWith(id: 'g2', name: 'J2')
          .toJson();
      fakeDb.saveDocument(collection: 'games', docId: 'g2', data: gameJson);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      blocGames.selectGame('g2');
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(blocGames.selectedGame.id, 'g2');
      fakeDb.deleteDocument(collection: 'games', docId: 'g2');
      // Espera hasta que selectedGame.id sea vacío o timeout
      await Future.doWhile(() async {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return blocGames.selectedGame.id != GameModel.empty().id;
      });
      expect(blocGames.selectedGame.id, GameModel.empty().id);
    });

    test('No selecciona juego si ID no existe', () async {
      blocGames.selectGame('nope');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(blocGames.selectedGame.id, GameModel.empty().id);
    });

    test('Selecciona un juego existente', () async {
      final Map<String, dynamic> gameJson = GameModel.empty()
          .copyWith(id: 'g3', name: 'J3')
          .toJson();
      fakeDb.saveDocument(collection: 'games', docId: 'g3', data: gameJson);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      blocGames.selectGame('g3');
      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(blocGames.selectedGame.id, 'g3');
    });
  });

  group('Modal de selección de juegos', () {
    test('showGamesModal muestra el modal con la lista de juegos', () async {
      // Insertar dos juegos
      final Map<String, dynamic> game1 = GameModel.empty()
          .copyWith(id: 'gA', name: 'A')
          .toJson();
      final Map<String, dynamic> game2 = GameModel.empty()
          .copyWith(id: 'gB', name: 'B')
          .toJson();
      fakeDb.saveDocument(collection: 'games', docId: 'gA', data: game1);
      fakeDb.saveDocument(collection: 'games', docId: 'gB', data: game2);
      await Future<void>.delayed(const Duration(milliseconds: 40));
      blocGames.showGamesModal();
      // El modal debe estar mostrando GamesListModal
      expect(blocModal.isShowing, isTrue);
      expect(
        blocModal.currentModal.runtimeType.toString(),
        contains('GamesListModal'),
      );
    });

    test(
      'Seleccionar juego desde el modal actualiza selectedGame y cierra el modal',
      () async {
        final Map<String, dynamic> game1 = GameModel.empty()
            .copyWith(id: 'gA', name: 'A')
            .toJson();
        fakeDb.saveDocument(collection: 'games', docId: 'gA', data: game1);
        await Future<void>.delayed(const Duration(milliseconds: 20));
        blocGames.showGamesModal();
        // Simula selección de juego llamando al callback del modal
        final dynamic modal = blocModal.currentModal;
        if (modal is GamesListModal) {
          modal.onSelect(blocGames.games.first);
        }
        await Future<void>.delayed(const Duration(milliseconds: 40));
        expect(blocGames.selectedGame.id, 'gA');
        expect(blocModal.isShowing, isFalse);
      },
    );

    test('Cancelar el modal no selecciona juego y cierra el modal', () async {
      final Map<String, dynamic> game1 = GameModel.empty()
          .copyWith(id: 'gA', name: 'A')
          .toJson();
      fakeDb.saveDocument(collection: 'games', docId: 'gA', data: game1);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      blocGames.showGamesModal();
      final dynamic modal = blocModal.currentModal;
      if (modal is GamesListModal) {
        modal.onCancel();
      }
      expect(blocGames.selectedGame.id, GameModel.empty().id);
      expect(blocModal.isShowing, isFalse);
    });
  });
}
