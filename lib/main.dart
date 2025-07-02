import 'package:flutter/material.dart';

import 'blocs/bloc_game.dart';
import 'blocs/bloc_games.dart';
import 'blocs/bloc_loading.dart';
import 'blocs/bloc_modal.dart';
import 'blocs/bloc_navigator.dart';
import 'blocs/bloc_session.dart';
import 'blocs/bloc_theme.dart';
import 'domain/repositories/game_repository.dart';
import 'domain/repositories/session_repository.dart';
import 'domain/services/service_session.dart';
import 'domain/services/service_ws_database.dart';
import 'domain/usecases/game/create_game_usecase.dart';
import 'domain/usecases/game/get_game_stream_usecase.dart';
import 'domain/usecases/game/get_games_stream_usecase.dart';
import 'domain/usecases/session/get_user_stream_usecase.dart';
// Importa los usecases de sesión y juego
import 'domain/usecases/session/sign_in_with_google_usecase.dart';
import 'domain/usecases/session/sign_out_usecase.dart';
import 'infrastructure/gateways/game_gateway_impl.dart';
import 'infrastructure/gateways/session_gateway_impl.dart';
import 'infrastructure/repositories/game_repository_impl.dart';
import 'infrastructure/repositories/session_repository_impl.dart';
import 'infrastructure/services/fake_service_session.dart';
import 'infrastructure/services/fake_service_ws_database.dart';
import 'shared/app_state_manager.dart';
import 'shared/theme.dart';
import 'ui/widgets/project_views_widget.dart';

void main() {
  final BlocTheme blocTheme = BlocTheme();
  final ServiceSession serviceSession = FakeServiceSession();
  final ServiceWsDatabase serviceWsDatabase = FakeServiceWsDatabase();

  final SessionRepository sessionRepository = SessionRepositoryImpl(
    SessionGatewayImpl(serviceSession),
  );

  // Instancia los usecases de sesión
  final SignInWithGoogleUsecase signInWithGoogleUsecase =
      SignInWithGoogleUsecase(sessionRepository);
  final SignOutUsecase signOutUsecase = SignOutUsecase(sessionRepository);
  final GetUserStreamUsecase getUserStreamUsecase = GetUserStreamUsecase(
    sessionRepository,
  );

  final GetGameStreamUsecase getGameStreamUsecase = GetGameStreamUsecase(
    GameRepositoryImpl(GameGatewayImpl(serviceWsDatabase)),
  );

  final BlocSession blocSession = BlocSession(
    signInWithGoogleUsecase: signInWithGoogleUsecase,
    signOutUsecase: signOutUsecase,
    getUserStreamUsecase: getUserStreamUsecase,
  );

  // Instancia GameRepository y los usecases de juego
  final GameGatewayImpl gameGateway = GameGatewayImpl(serviceWsDatabase);
  final GameRepository gameRepository = GameRepositoryImpl(gameGateway);
  final CreateGameUsecase createGameUsecase = CreateGameUsecase(gameRepository);

  final BlocModal blocModal = BlocModal();
  final BlocNavigator blocNavigator = BlocNavigator(blocSession);
  final BlocGame blocGame = BlocGame(
    blocModal: blocModal,
    blocSession: blocSession,
    createGameUsecase: createGameUsecase,
    getGameStreamUsecase: getGameStreamUsecase,
    blocNavigator: blocNavigator,
  );

  final GetGamesStreamUsecase getGamesStreamUsecase = GetGamesStreamUsecase(
    gameRepository,
  );
  final BlocGames blocGames = BlocGames(
    getGamesStreamUsecase: getGamesStreamUsecase,
    blocGame: blocGame,
  );

  final BlocLoading blocLoading = BlocLoading();

  runApp(
    AppStateManager(
      blocTheme: blocTheme,
      blocSession: blocSession,
      blocGame: blocGame,
      blocGames: blocGames,
      blocNavigator: blocNavigator,
      blocLoading: blocLoading,
      blocModal: blocModal,
      child: const MyApp(),
    ),
  );
}

// Asegúrate de inicializar BlocSession correctamente en main.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: planningPokerTheme,
      home: Builder(
        builder: (BuildContext context) {
          final BlocNavigator blocNavigator = AppStateManager.of(
            context,
          ).blocNavigator;
          final BlocLoading blocLoading = AppStateManager.of(
            context,
          ).blocLoading;
          return ProjectViewsWidget(
            blocNavigator: blocNavigator,
            blocLoading: blocLoading,
          );
        },
      ),
    );
  }
}
