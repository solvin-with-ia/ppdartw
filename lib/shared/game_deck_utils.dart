import 'dart:math';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../domain/models/game_model.dart';

/// Elimina de la mesa los usuarios que ya no están en el juego ni son currentUser
class GameDeckUtils {
  /// Asigna los asientos de Planning Poker: el usuario actual siempre en el asiento protagonista.
  /// Asigna los asientos de Planning Poker: el usuario actual siempre en el asiento protagonista.
  /// Esta es la función oficial de asignación de asientos para todos los bloques y tests.
  static List<UserModel?> updateSeatsOnGameChange(
    GameModel game,
    UserModel? current, {
    int seatsLength = 12,
    int protagonistSeatPlace = 8,
    List<UserModel?>? previousSeats,
  }) {
    if (seatsLength <= protagonistSeatPlace) {
      seatsLength = protagonistSeatPlace + 1;
    }
    if (current == null) {
      return List<UserModel?>.filled(seatsLength, null);
    }
    final List<UserModel?> modifiedSeats = previousSeats != null
        ? cleanSeats(game, current, previousSeats)
        : List<UserModel?>.filled(seatsLength, null);
    final List<UserModel?> seats = List<UserModel?>.filled(seatsLength, null);
    seats[protagonistSeatPlace] = current;
    final Map<String, int> prevSeatMap = getPrevSeatMap(current, modifiedSeats);
    final List<UserModel> players = game.players
        .where((UserModel u) => u.id != current.id)
        .toList();
    final List<UserModel> spectators = game.spectators
        .where((UserModel u) => u.id != current.id)
        .toList();
    final Set<int> occupied = <int>{protagonistSeatPlace};
    for (final UserModel player in players) {
      final int? prev = prevSeatMap[player.id];
      if (prev != null && seats[prev] == null && !occupied.contains(prev)) {
        seats[prev] = player;
        occupied.add(prev);
      }
    }
    final List<UserModel> playersNotSeated = players
        .where((UserModel p) => !seats.any((UserModel? u) => u?.id == p.id))
        .toList();
    final List<UserModel> shuffledPlayersNotSeated = shuffleList(
      playersNotSeated,
    );
    final List<int> freeSeats = List<int>.generate(
      seatsLength,
      (int i) => i,
    ).where((int i) => !occupied.contains(i) && seats[i] == null).toList();
    for (final UserModel player in shuffledPlayersNotSeated) {
      if (freeSeats.isNotEmpty) {
        final int idx = pickRandomIndex(freeSeats);
        seats[freeSeats[idx]] = player;
        occupied.add(freeSeats[idx]);
        freeSeats.removeAt(idx);
      }
    }
    final List<UserModel> spectatorsNotSeated = spectators
        .where((UserModel s) => !seats.any((UserModel? u) => u?.id == s.id))
        .toList();
    final List<UserModel> shuffledSpectatorsNotSeated = shuffleList(
      spectatorsNotSeated,
    );
    final List<int> freeSeatsForSpectators = List<int>.generate(
      seatsLength,
      (int i) => i,
    ).where((int i) => seats[i] == null).toList();
    for (final UserModel spectator in shuffledSpectatorsNotSeated) {
      if (freeSeatsForSpectators.isNotEmpty) {
        final int idx = pickRandomIndex(freeSeatsForSpectators);
        seats[freeSeatsForSpectators[idx]] = spectator;
        freeSeatsForSpectators.removeAt(idx);
      }
    }
    return seats;
  }

  static List<UserModel?> cleanSeats(
    GameModel game,
    UserModel current,
    List<UserModel?> seats,
  ) {
    final List<UserModel?> modifiedSeats = List<UserModel?>.from(seats);
    final Set<String> validIds = <String>{
      current.id,
      ...game.players.map((UserModel u) => u.id),
      ...game.spectators.map((UserModel u) => u.id),
    };
    for (int i = 0; i < modifiedSeats.length; i++) {
      final UserModel? user = modifiedSeats[i];
      // Nunca limpiar el asiento protagonista si es el usuario actual
      if (i == 8 && user != null && user.id == current.id) {
        continue;
      }
      if (user != null && !validIds.contains(user.id)) {
        modifiedSeats[i] = null;
      }
    }
    return modifiedSeats;
  }

  /// Mapea id usuario → índice previo en asientos (excepto currentUser)
  static Map<String, int> getPrevSeatMap(
    UserModel current,
    List<UserModel?> modifiedSeats,
  ) {
    final Map<String, int> map = <String, int>{};
    for (int i = 0; i < modifiedSeats.length; i++) {
      final UserModel? user = modifiedSeats[i];
      if (user != null && user.id != current.id) {
        map[user.id] = i;
      }
    }
    return map;
  }

  /// Mezcla una copia de la lista (Fisher-Yates)
  static List<T> shuffleList<T>(List<T> list) {
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
  static int pickRandomIndex<T>(List<T> list) {
    assert(list.isNotEmpty, 'No hay elementos para elegir');
    final Random random = Random();
    return random.nextInt(list.length);
  }
}
