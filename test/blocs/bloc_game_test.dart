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
