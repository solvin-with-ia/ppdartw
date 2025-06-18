import 'package:flutter/material.dart';

import 'blocs/bloc_game.dart';
import 'blocs/bloc_loading.dart';
import 'blocs/bloc_navigator.dart';
import 'blocs/bloc_session.dart';
import 'blocs/bloc_theme.dart';
import 'domains/repositories/game_repository.dart';
import 'domains/repositories/session_repository.dart';
import 'domains/services/service_session.dart';
import 'domains/usecases/game/create_game_usecase.dart';
import 'domains/usecases/session/get_user_stream_usecase.dart';
// Importa los usecases de sesión y juego
import 'domains/usecases/session/sign_in_with_google_usecase.dart';
import 'domains/usecases/session/sign_out_usecase.dart';
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

  final BlocSession blocSession = BlocSession(
    signInWithGoogleUsecase: signInWithGoogleUsecase,
    signOutUsecase: signOutUsecase,
    getUserStreamUsecase: getUserStreamUsecase,
  );

  // Instancia GameRepository y los usecases de juego
  final GameGatewayImpl gameGateway = GameGatewayImpl(FakeServiceWsDatabase());
  final GameRepository gameRepository = GameRepositoryImpl(gameGateway);
  final CreateGameUsecase createGameUsecase = CreateGameUsecase(gameRepository);

  final BlocGame blocGame = BlocGame(
    blocSession: blocSession,
    createGameUsecase: createGameUsecase,
  );

  final BlocNavigator blocNavigator = BlocNavigator(blocSession);
  final BlocLoading blocLoading = BlocLoading();
  runApp(
    AppStateManager(
      blocTheme: blocTheme,
      blocSession: blocSession,
      blocGame: blocGame,
      blocNavigator: blocNavigator,
      blocLoading: blocLoading,
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
