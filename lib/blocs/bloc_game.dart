import 'dart:async';

import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../domain/enums/role.dart';
import '../domain/models/card_model.dart';
import '../domain/models/game_model.dart';
import '../domain/models/vote_model.dart';
import '../domain/usecases/game/create_game_usecase.dart';
import '../domain/usecases/game/get_game_stream_usecase.dart';
import '../shared/deck.dart';
import '../shared/game_deck_utils.dart';
import '../shared/game_utils.dart';
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
  // --- Lógica de asientos para la mesa de Planning Poker ---
  static const int seatsCount = 12;
  static const int protagonistSeat = 8;
  List<UserModel?> _seatsOfPlanningPoker = List<UserModel?>.filled(
    seatsCount,
    null,
  );
  Stream<GameModel> get gameStream => _gameBloc.stream;
  GameModel get selectedGame => _gameBloc.value;

  /// Getter público para la UI
  List<UserModel?> get seatsOfPlanningPoker =>
      List<UserModel?>.unmodifiable(_seatsOfPlanningPoker);

  final GetGameStreamUsecase getGameStreamUsecase;
  StreamSubscription<Either<ErrorItem, GameModel?>>? _gameSubscription;
  final BlocNavigator blocNavigator;
  final BlocModal blocModal;
  final BlocSession blocSession;
  final CreateGameUsecase createGameUsecase;

  final BlocGeneral<GameModel> _gameBloc = BlocGeneral<GameModel>(
    GameModel.empty(),
  );

  Future<void> init() async {
    await blocSession.signInWithGoogleUsecase.call();
    // Navegación reactiva según el estado del juego
    _gameBloc.addFunctionToProcessTValueOnStream('navigateOnGameChange', (
      GameModel game,
    ) {
      final UserModel? user = blocSession.user;
      if (user != null && game.id.isNotEmpty) {
        blocNavigator.goTo(EnumViews.centralStage);
      }
    });

    // Actualiza los asientos cada vez que cambia el juego
    _gameBloc.addFunctionToProcessTValueOnStream('settingSeats', (
      GameModel game,
    ) {
      _seatsOfPlanningPoker = GameDeckUtils.updateSeatsOnGameChange(
        game,
        blocSession.user,
        previousSeats: _seatsOfPlanningPoker,
      );
    });

    blocSession.userStream.listen((UserModel? user) {
      if (user == null) {
        blocNavigator.goTo(EnumViews.splash);
      } else if (_gameBloc.value.id.isEmpty) {
        blocNavigator.goTo(EnumViews.createGame);
      } else {
        blocNavigator.goTo(EnumViews.centralStage);
      }
    });
  }

  /// Valida si el nombre de la partida es válido según las reglas de negocio (>= 3 caracteres)
  bool get isNameValid => _gameBloc.value.name.trim().length >= 3;

  Future<void> createMyGame() async {
    await createGame(name: selectedGame.name);
    showNameAndRoleModal();
  }

  Future<void> createGame({required String name, String? gameId}) async {
    final UserModel? admin = blocSession.user;
    if (admin == null) {
      // Aquí podrías redirigir al login, por ahora simplemente retorna
      return;
    }

    final GameModel game = GameModel(
      id: gameId ?? _generateUuid(),
      name: name,
      admin: admin,
      spectators: const <UserModel>[],
      players: <UserModel>[admin],
      votes: const <VoteModel>[],
      isActive: true,
      createdAt: DateTime.now(),
      deck: defaultPlanningPokerDeck,
    );
    await createGameUsecase.call(game);
    subscribeToGame(game.id);
    // Actualiza el draft reactivo tras crear
    _gameBloc.value = game;
  }

  /// Actualiza el draft actual (selectedGame) y persiste los cambios en backend.
  Future<void> updateGame() async {
    // Persistir cambios (el usecase actúa como save/update)
    await createGameUsecase.call(_gameBloc.value);
    // Actualiza el draft local (no-op, solo para consistencia)
    _gameBloc.value = _gameBloc.value;
  }

  /// Suscribe el bloc al stream de un juego específico y actualiza el estado reactivo.
  void subscribeToGame(String gameId) {
    _gameSubscription?.cancel();
    if (gameId == 'none' || gameId.isEmpty) {
      _gameBloc.value = GameModel.empty();
      return;
    }
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

  /// Determina el rol del usuario actual por pertenencia a las listas.
  Role? get selectedRole {
    final UserModel? user = blocSession.user;
    if (user == null) {
      return null;
    }
    if (_gameBloc.value.players.any((UserModel u) => u.id == user.id)) {
      return Role.jugador;
    }
    if (_gameBloc.value.spectators.any((UserModel u) => u.id == user.id)) {
      return Role.espectador;
    }
    return null;
  }

  /// Revela los votos (cartas) de todos los jugadores
  Future<void> revealVotes() async {
    _gameBloc.value = _gameBloc.value.copyWith(votesRevealed: true);
    await updateGame();
  }

  /// Oculta los votos (cartas)
  Future<void> hideVotes() async {
    _gameBloc.value = _gameBloc.value.copyWith(votesRevealed: false);
    await updateGame();
  }

  /// Calcula el promedio de los votos revelados (solo cartas numéricas)
  double calculateAverage() {
    return GameUtils.calculateAverage(_gameBloc.value);
  }

  /// Reinicia la ronda: limpia los votos y oculta las cartas
  Future<void> resetRound() async {
    _gameBloc.value = _gameBloc.value.copyWith(
      votes: <VoteModel>[],
      votesRevealed: false,
    );
    await updateGame();
  }

  /// Permite al usuario actual seleccionar una carta (votar). Si ya votó, reemplaza su voto.
  Future<void> setVote(CardModel card) async {
    final UserModel? user = blocSession.user;
    if (user == null) {
      return;
    }
    final GameModel game = _gameBloc.value;
    final List<VoteModel> updatedVotes = List<VoteModel>.from(game.votes)
      ..removeWhere((VoteModel v) => v.userId == user.id);
    updatedVotes.add(VoteModel(userId: user.id, cardId: card.id));
    _gameBloc.value = game.copyWith(votes: updatedVotes);
    await updateGame();
  }

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

  Role? _roleDraft;
  Role? get roleDraft => _roleDraft ?? selectedRole;

  void selectRoleDraft(Role role) {
    // unicamente para disparar el evento de cambio de rol
    _gameBloc.value = selectedGame;
    if (_roleDraft != role) {
      _roleDraft = role;
    }
  }

  void setName(String name) {
    _gameBloc.value = _gameBloc.value.copyWith(name: name);
  }

  void confirmRoleSelection() {
    final Role roleToSet = _roleDraft ?? selectedRole ?? Role.jugador;
    setCurrentUserRole(roleToSet);
    blocModal.hideModal();
    _roleDraft = null;
  }

  /// Muestra el modal para seleccionar nombre y rol, y gestiona la inscripción reactiva del usuario.
  void showNameAndRoleModal() {
    blocModal.showModal(NameAndRoleModal(blocGame: this));
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
