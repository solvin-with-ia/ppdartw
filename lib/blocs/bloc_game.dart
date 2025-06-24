import 'dart:async';

import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../domain/enums/role.dart';
import '../domain/models/game_model.dart';
import '../domain/models/vote_model.dart';
import '../domain/usecases/game/create_game_usecase.dart';
import '../domain/usecases/game/get_game_stream_usecase.dart';
import '../shared/deck.dart';
import '../ui/modals/name_and_role_modal.dart';
import '../views/enum_views.dart';
import 'bloc_modal.dart';
import 'bloc_navigator.dart';
import 'bloc_session.dart';

/// Bloc para manejar la lógica de creación y estado de la partida actual.
class BlocGame {
  BlocGame({
    required this.blocSession,
    required this.createGameUsecase,
    required this.getGameStreamUsecase,
    required this.blocModal,
    required this.blocNavigator,
  }) {
    init();
  }

  final GetGameStreamUsecase getGameStreamUsecase;
  StreamSubscription<Either<ErrorItem, GameModel?>>? _gameSubscription;
  final BlocNavigator blocNavigator;

  Future<void> init() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    await blocSession.signInWithGoogleUsecase.call();
    blocNavigator.goTo(EnumViews.createGame);
    // Navegación reactiva según el estado del juego
    _gameBloc.addFunctionToProcessTValueOnStream('navigateOnGameChange', (
      GameModel game,
    ) {
      // Ejemplo: si el juego está creado y el usuario está autenticado, navega a la mesa central
      final UserModel? user = blocSession.user;
      if (user != null && game.id.isNotEmpty) {
        blocNavigator.goTo(EnumViews.centralStage);
      }
    });

    // También puedes agregar lógica reactiva para el usuario si lo deseas
    blocSession.userStream.listen((UserModel? user) {
      if (user == null) {
        blocNavigator.goTo(EnumViews.splash);
      }
    });
  }

  final BlocModal blocModal;
  final BlocSession blocSession;
  final CreateGameUsecase createGameUsecase;

  final BlocGeneral<GameModel> _gameBloc = BlocGeneral<GameModel>(
    GameModel.empty(),
  );

  Stream<GameModel> get gameStream => _gameBloc.stream;
  GameModel get selectedGame => _gameBloc.value;

  /// Valida si el nombre de la partida es válido según las reglas de negocio (>= 3 caracteres)
  bool get isNameValid => _gameBloc.value.name.trim().length >= 3;

  Future<void> createMyGame() async {
    await createGame(name: selectedGame.name);
    showNameAndRoleModal();
  }

  Future<void> createGame({required String name}) async {
    final UserModel? admin = blocSession.user;
    if (admin == null) {
      // Aquí podrías redirigir al login, por ahora simplemente retorna
      return;
    }
    // Usuarios fake para pruebas
    const UserModel fakePlayer = UserModel(
      id: 'fake_player',
      displayName: 'Jugador Fake',
      photoUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
      email: 'jugador@fake.com',
      jwt: <String, dynamic>{},
    );
    const UserModel fakeSpectator = UserModel(
      id: 'fake_spectator',
      displayName: 'Espectador Fake',
      photoUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
      email: 'espectador@fake.com',
      jwt: <String, dynamic>{},
    );
    final GameModel game = GameModel(
      id: _generateUuid(),
      name: name,
      admin: admin,
      spectators: <UserModel>[fakeSpectator],
      players: <UserModel>[admin, fakePlayer],
      votes: const <VoteModel>[],
      isActive: true,
      createdAt: DateTime.now(),
      deck: defaultPlanningPokerDeck,
    );
    await createGameUsecase.call(game);
    _subscribeToGame(game.id);
    // Actualiza el draft reactivo tras crear
    _gameBloc.value = game;
  }

  /// Actualiza el draft actual (selectedGame) y persiste los cambios en backend.
  Future<void> updateGame() async {
    final String previousId = _gameBloc.value.id;
    // Persistir cambios (el usecase actúa como save/update)
    await createGameUsecase.call(_gameBloc.value);
    // Actualiza el draft local (no-op, solo para consistencia)
    _gameBloc.value = _gameBloc.value;
    // Solo resuscribirse si el id cambió
    if (_gameBloc.value.id != previousId) {
      _subscribeToGame(_gameBloc.value.id);
    }
  }

  /// Suscribe el bloc al stream de un juego específico y actualiza el estado reactivo.
  void _subscribeToGame(String gameId) {
    _gameSubscription?.cancel();
    _gameSubscription = getGameStreamUsecase(gameId).listen((
      Either<ErrorItem, GameModel?> either,
    ) {
      either.fold(
        (ErrorItem error) {
          // Aquí puedes manejar errores de stream en el futuro.
        },
        (GameModel? game) {
          if (game != null) {
            _gameBloc.value = game;
          }
        },
      );
    });
  }

  Role? get selectedRole => _gameBloc.value.role;

  /// Inscribe cualquier usuario en la lista correspondiente según el rol y actualiza el GameModel.
  /// Útil para admins que gestionan la mesa o para operaciones avanzadas.
  Future<void> setUserRole({
    required UserModel user,
    required Role role,
  }) async {
    final GameModel game = _gameBloc.value;
    // Remover usuario de ambas listas
    final List<UserModel> updatedPlayers = List<UserModel>.from(game.players)
      ..removeWhere((UserModel u) => u.id == user.id);
    final List<UserModel> updatedSpectators = List<UserModel>.from(
      game.spectators,
    )..removeWhere((UserModel u) => u.id == user.id);
    // Agregar a la lista correspondiente
    if (role == Role.jugador) {
      updatedPlayers.add(user);
    } else {
      updatedSpectators.add(user);
    }
    // Actualizar el modelo y persistir
    _gameBloc.value = game.copyWith(
      players: updatedPlayers,
      spectators: updatedSpectators,
      role: role,
    );
    await updateGame();
  }

  /// Inscribe SOLO al usuario actual (el que está en sesión) en la lista correspondiente según el rol y actualiza el GameModel.
  /// Este es el método que debe consumir el modal de selección de rol.
  Future<void> setCurrentUserRole(Role role) async {
    final UserModel? user = blocSession.user;
    if (user == null) {
      return;
    }
    await setUserRole(user: user, role: role);
  }

  void selectRoleDraft(Role role) {
    _gameBloc.value = _gameBloc.value.copyWith(role: role);
  }

  void updateNameDraft(String name) {
    _gameBloc.value = _gameBloc.value.copyWith(name: name);
  }

  void confirmRoleSelection() {
    setCurrentUserRole(selectedRole ?? Role.jugador);
    blocModal.hideModal();
  }

  /// Muestra el modal para seleccionar nombre y rol, y gestiona la inscripción reactiva del usuario.
  void showNameAndRoleModal() {
    blocModal.showModal(NameAndRoleModal(blocGame: this));
  }

  void setName(String newName) {
    updateNameDraft(newName);
  }

  void dispose() {
    _gameSubscription?.cancel();
    _gameBloc.dispose();
  }

  String _generateUuid() {
    // Puedes reemplazar esto por un paquete uuid si lo deseas
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
