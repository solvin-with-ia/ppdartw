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

  group('BlocGame con servicios fake', () {
    test('updateNameDraft updates the name locally', () {
      blocGame.updateNameDraft('Test Game');
      expect(blocGame.selectedGame.name, 'Test Game');
    });

    test('setName updates the name via setter', () {
      blocGame.setName('Setter Name');
      expect(blocGame.selectedGame.name, 'Setter Name');
    });

    test('selectRoleDraft updates the draft role', () {
      blocGame.selectRoleDraft(Role.jugador);
      expect(blocGame.selectedGame.role, Role.jugador);
      blocGame.selectRoleDraft(Role.espectador);
      expect(blocGame.selectedGame.role, Role.espectador);
    });

    test(
      'isNameValid returns false for short names and true for valid names',
      () {
        blocGame.setName('ab');
        expect(blocGame.isNameValid, isFalse);
        blocGame.setName('validName');
        expect(blocGame.isNameValid, isTrue);
      },
    );

    test('calculateAverage returns 0 if votes are not revealed', () {
      expect(blocGame.calculateAverage(), 0.0);
    });
  });
}
