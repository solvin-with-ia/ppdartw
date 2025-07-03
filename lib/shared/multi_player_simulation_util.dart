import 'dart:async';
import 'dart:math';

import 'package:jocaagura_domain/jocaagura_domain.dart';

import '../domain/models/game_model.dart';
import '../domain/models/vote_model.dart';
import '../infrastructure/services/fake_service_ws_database.dart';

class MultiPlayerSimulationUtil {
  /// Simula la llegada progresiva de jugadores a una partida.
  static Future<void> simulateNewPlayers(
    FakeServiceWsDatabase fakeDb,
    String gameId, [
    int limOfPlayers = 6,
    Duration delay = const Duration(seconds: 3),
  ]) async {
    // Si el juego no existe, créalo con admin por defecto
    Map<String, dynamic>? gameJson = await fakeDb.readDocument(
      collection: 'games',
      docId: gameId,
    );
    if (gameJson == null) {
      const UserModel admin = UserModel(
        id: 'admin',
        displayName: 'Admin',
        email: 'admin@simu.com',
        photoUrl: '',
        jwt: <String, dynamic>{},
      );
      final GameModel game = GameModel.empty().copyWith(
        id: gameId,
        name: 'SimuGame',
        admin: admin,
        players: <UserModel>[admin],
        isActive: true,
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: gameId,
        data: game.toJson(),
      );
    }
    // Agrega jugadores cada 3 segundos
    for (int i = 1; i < limOfPlayers; i++) {
      await Future<void>.delayed(delay);
      gameJson = await fakeDb.readDocument(collection: 'games', docId: gameId);
      if (gameJson == null) {
        break;
      }
      final GameModel game = GameModel.fromJson(gameJson);
      final UserModel newPlayer = UserModel(
        id: 'player_$i',
        displayName: 'Jugador $i',
        email: 'jugador$i@simu.com',
        photoUrl: '',
        jwt: const <String, dynamic>{},
      );
      if (game.players.any((UserModel u) => u.id == newPlayer.id)) {
        continue;
      }
      final GameModel updatedGame = game.copyWith(
        players: <UserModel>[...game.players, newPlayer],
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: gameId,
        data: updatedGame.toJson(),
      );
    }
  }

  /// Simula la llegada progresiva de espectadores a una partida.
  ///
  /// [fakeDb] es la base de datos fake para la simulación.
  /// [gameId] es el ID de la partida a simular.
  /// [limOfSpectators] es el límite de espectadores a agregar (por defecto 6).
  /// [delay] es el tiempo de espera entre iteraciones (por defecto 3 segundos).
  static Future<void> simulateNewSpectators(
    FakeServiceWsDatabase fakeDb,
    String gameId, [
    int limOfSpectators = 6,
    Duration delay = const Duration(seconds: 3),
  ]) async {
    Map<String, dynamic>? gameJson = await fakeDb.readDocument(
      collection: 'games',
      docId: gameId,
    );
    if (gameJson == null) {
      const UserModel admin = UserModel(
        id: 'admin',
        displayName: 'Admin',
        email: 'admin@simu.com',
        photoUrl: '',
        jwt: <String, dynamic>{},
      );
      final GameModel game = GameModel.empty().copyWith(
        id: gameId,
        name: 'SimuGame',
        admin: admin,
        players: <UserModel>[admin],
        spectators: <UserModel>[],
        isActive: true,
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: gameId,
        data: game.toJson(),
      );
    }
    for (int i = 1; i < limOfSpectators; i++) {
      await Future<void>.delayed(delay);
      gameJson = await fakeDb.readDocument(collection: 'games', docId: gameId);
      if (gameJson == null) {
        break;
      }
      final GameModel game = GameModel.fromJson(gameJson);
      final UserModel newSpectator = UserModel(
        id: 'spectator_$i',
        displayName: 'Espectador $i',
        email: 'espectador$i@simu.com',
        photoUrl: '',
        jwt: const <String, dynamic>{},
      );
      if (game.spectators.any((UserModel u) => u.id == newSpectator.id)) {
        continue;
      }
      final GameModel updatedGame = game.copyWith(
        spectators: <UserModel>[...game.spectators, newSpectator],
      );
      await fakeDb.saveDocument(
        collection: 'games',
        docId: gameId,
        data: updatedGame.toJson(),
      );
    }
  }

  /// Simula votos aleatorios de los jugadores (excepto currentUser).
  static Future<void> randomVotes(
    FakeServiceWsDatabase fakeDb,
    String gameId,
    UserModel currentUser, [
    Duration delay = const Duration(seconds: 2),
  ]) async {
    final Random random = Random();
    while (true) {
      final Map<String, dynamic>? gameJson = await fakeDb.readDocument(
        collection: 'games',
        docId: gameId,
      );
      if (gameJson == null) {
        break;
      }
      final GameModel game = GameModel.fromJson(gameJson);
      if (game.votesRevealed) {
        break;
      }
      final List<UserModel> jugadores = game.players
          .where((UserModel u) => u.id != currentUser.id)
          .toList();
      final Set<String> votantes = game.votes
          .map((VoteModel v) => v.userId)
          .toSet();
      final List<UserModel> noVotados = jugadores
          .where((UserModel u) => !votantes.contains(u.id))
          .toList();
      if (noVotados.isEmpty) {
        break;
      }
      final UserModel jugador = noVotados[random.nextInt(noVotados.length)];
      final int voto = random.nextInt(13) + 1; // Suponiendo cartas 1-13
      final VoteModel newVote = VoteModel(
        userId: jugador.id,
        cardId: 'card_$voto',
      );
      final List<VoteModel> updatedVotes = <VoteModel>[...game.votes, newVote];
      final GameModel updatedGame = game.copyWith(votes: updatedVotes);
      await fakeDb.saveDocument(
        collection: 'games',
        docId: gameId,
        data: updatedGame.toJson(),
      );
      await Future<void>.delayed(delay);
    }
  }

  /// Desconecta progresivamente jugadores/espectadores excepto currentUser.
  static Future<void> disconnectOtherUsers(
    FakeServiceWsDatabase fakeDb,
    String gameId,
    UserModel currentUser, [
    Duration delay = const Duration(seconds: 2),
  ]) async {
    while (true) {
      final Map<String, dynamic>? gameJson = await fakeDb.readDocument(
        collection: 'games',
        docId: gameId,
      );
      if (gameJson == null) {
        break;
      }
      final GameModel game = GameModel.fromJson(gameJson);
      final List<UserModel> jugadores = game.players
          .where((UserModel u) => u.id != currentUser.id)
          .toList();
      final List<UserModel> espectadores = game.spectators
          .where((UserModel u) => u.id != currentUser.id)
          .toList();
      if (jugadores.isEmpty && espectadores.isEmpty) {
        break;
      }
      if (jugadores.isNotEmpty) {
        final UserModel toRemove = jugadores.first;
        final GameModel updatedGame = game.copyWith(
          players: game.players
              .where((UserModel u) => u.id != toRemove.id)
              .toList(),
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: updatedGame.toJson(),
        );
      } else if (espectadores.isNotEmpty) {
        final UserModel toRemove = espectadores.first;
        final GameModel updatedGame = game.copyWith(
          spectators: game.spectators
              .where((UserModel u) => u.id != toRemove.id)
              .toList(),
        );
        await fakeDb.saveDocument(
          collection: 'games',
          docId: gameId,
          data: updatedGame.toJson(),
        );
      }
      await Future<void>.delayed(delay);
    }
  }
}
