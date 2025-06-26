import 'dart:async';
import 'dart:math';

import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../domain/enums/role.dart';
import '../domain/models/card_model.dart';
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
  // --- Lógica de asientos para la mesa de Planning Poker ---
  static const int seatsCount = 12;
  static const int protagonistSeat = 8;
  List<UserModel?> _seatsOfPlanningPoker = List<UserModel?>.filled(
    seatsCount,
    null,
  );

  /// Getter público para la UI
  List<UserModel?> get seatsOfPlanningPoker =>
      List<UserModel?>.unmodifiable(_seatsOfPlanningPoker);

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
      final UserModel? user = blocSession.user;
      if (user != null && game.id.isNotEmpty) {
        blocNavigator.goTo(EnumViews.centralStage);
      }
    });

    // Actualiza los asientos cada vez que cambia el juego
    _gameBloc.addFunctionToProcessTValueOnStream('settingSeats', (
      GameModel game,
    ) {
      _updateSeatsOnGameChange(game);
    });

    blocSession.userStream.listen((UserModel? user) {
      if (user == null) {
        blocNavigator.goTo(EnumViews.splash);
      }
    });
  }

  /// Actualiza los asientos cada vez que cambia el juego
  void _updateSeatsOnGameChange(GameModel game) {
    final UserModel? current = blocSession.user;
    if (current == null) {
      return;
    }

    // Limpieza de asientos: elimina usuarios que ya no están en el juego ni son currentUser
    _cleanSeats(game, current);

    // 1. Inicializa asientos vacíos
    final List<UserModel?> seats = List<UserModel?>.filled(seatsCount, null);
    // 2. currentUser siempre en asiento 8
    seats[protagonistSeat] = current;

    // 3. Mapeo usuario→índice previo (excepto currentUser)
    final Map<String, int> prevSeatMap = _getPrevSeatMap(current);

    // 4. Separa jugadores y espectadores (sin currentUser)
    final List<UserModel> players = game.players
        .where((UserModel u) => u.id != current.id)
        .toList();
    final List<UserModel> spectators = game.spectators
        .where((UserModel u) => u.id != current.id)
        .toList();
    final Set<int> occupied = <int>{protagonistSeat};

    // 5. Jugadores: conserva asiento previo si está libre
    for (final UserModel player in players) {
      final int? prev = prevSeatMap[player.id];
      if (prev != null && seats[prev] == null && !occupied.contains(prev)) {
        seats[prev] = player;
        occupied.add(prev);
      }
    }

    // 6. Jugadores restantes: mezcla y asigna aleatorio entre libres
    final List<UserModel> playersNotSeated = players
        .where((UserModel p) => !seats.contains(p))
        .toList();
    final List<UserModel> shuffledPlayersNotSeated = _shuffleList(
      playersNotSeated,
    );
    final List<int> freeSeats = List<int>.generate(
      seatsCount,
      (int i) => i,
    ).where((int i) => !occupied.contains(i) && seats[i] == null).toList();
    for (final UserModel player in shuffledPlayersNotSeated) {
      if (freeSeats.isNotEmpty) {
        final int idx = _pickRandomIndex(freeSeats);
        seats[freeSeats[idx]] = player;
        occupied.add(freeSeats[idx]);
        freeSeats.removeAt(idx);
      }
    }

    // 7. Espectadores: mezcla y asigna aleatorio entre libres
    final List<UserModel> spectatorsNotSeated = spectators
        .where((UserModel s) => !seats.contains(s))
        .toList();
    final List<UserModel> shuffledSpectatorsNotSeated = _shuffleList(
      spectatorsNotSeated,
    );
    final List<int> freeSeatsForSpectators = List<int>.generate(
      seatsCount,
      (int i) => i,
    ).where((int i) => seats[i] == null).toList();
    for (final UserModel spectator in shuffledSpectatorsNotSeated) {
      if (freeSeatsForSpectators.isNotEmpty) {
        final int idx = _pickRandomIndex(freeSeatsForSpectators);
        seats[freeSeatsForSpectators[idx]] = spectator;
        freeSeatsForSpectators.removeAt(idx);
      }
    }

    _seatsOfPlanningPoker = seats;
  }

  /// Elimina de la mesa los usuarios que ya no están en el juego ni son currentUser
  void _cleanSeats(GameModel game, UserModel current) {
    final Set<String> validIds = <String>{
      current.id,
      ...game.players.map((UserModel u) => u.id),
      ...game.spectators.map((UserModel u) => u.id),
    };
    for (int i = 0; i < _seatsOfPlanningPoker.length; i++) {
      final UserModel? user = _seatsOfPlanningPoker[i];
      if (user != null && !validIds.contains(user.id)) {
        _seatsOfPlanningPoker[i] = null;
      }
    }
  }

  /// Mapea id usuario → índice previo en asientos (excepto currentUser)
  Map<String, int> _getPrevSeatMap(UserModel current) {
    final Map<String, int> map = <String, int>{};
    for (int i = 0; i < _seatsOfPlanningPoker.length; i++) {
      final UserModel? user = _seatsOfPlanningPoker[i];
      if (user != null && user.id != current.id) {
        map[user.id] = i;
      }
    }
    return map;
  }

  /// Mezcla una copia de la lista (Fisher-Yates)
  List<T> _shuffleList<T>(List<T> list) {
    final Random random = Random();
    final List<T> copy = List<T>.from(list);
    for (int i = copy.length - 1; i > 0; i--) {
      final int j = random.nextInt(i + 1);
      final T tmp = copy[i];
      copy[i] = copy[j];
      copy[j] = tmp;
    }
    return copy;
  }

  /// Devuelve un índice aleatorio válido para la lista
  int _pickRandomIndex<T>(List<T> list) {
    if (list.isEmpty) {
      throw StateError('No hay elementos para elegir');
    }
    final Random random = Random();
    return random.nextInt(list.length);
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
      spectators: const <UserModel>[fakeSpectator],
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
  double? calculateAverage() {
    final GameModel game = _gameBloc.value;
    if (!game.votesRevealed) {
      return null;
    }
    final List<VoteModel> votes = game.votes;
    final List<CardModel> deck = game.deck;
    final List<double> values = votes
        .map((VoteModel vote) {
          final CardModel card = deck.firstWhere(
            (CardModel c) => c.id == vote.cardId,
            orElse: () =>
                const CardModel(id: '', display: '', value: 0, description: ''),
          );
          return card.value.toDouble();
        })
        .whereType<double>()
        .toList();
    if (values.isEmpty) {
      return null;
    }
    final double sum = values.fold(0.0, (double a, double b) => a + b);
    return sum / values.length;
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
