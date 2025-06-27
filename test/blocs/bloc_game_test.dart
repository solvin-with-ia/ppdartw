import 'package:flutter_test/flutter_test.dart';
import 'package:ppdartw/blocs/bloc_game.dart';
import 'package:ppdartw/blocs/bloc_modal.dart';
import 'package:ppdartw/blocs/bloc_navigator.dart';
import 'package:ppdartw/blocs/bloc_session.dart';
import 'package:ppdartw/domain/enums/role.dart';
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
      final Role? roleAntes = blocGame.selectedGame.role;
      blocGame.setName('Solo cambia el nombre');
      expect(blocGame.selectedGame.role, roleAntes);
    });
  });
}
