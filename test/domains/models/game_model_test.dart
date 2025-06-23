import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/domains/models/card_model.dart';
import 'package:ppdartw/domains/models/game_model.dart';
import 'package:ppdartw/domains/models/model_utils.dart';
import 'package:ppdartw/domains/models/vote_model.dart';

void main() {
  group('CardModel', () {
    test('fromJson and toJson roundtrip', () {
      const CardModel card = CardModel(
        id: 'fib_3',
        display: '3',
        value: 3,
        description: 'Fibonacci 3',
      );
      final Map<String, dynamic> json = card.toJson();
      final CardModel card2 = CardModel.fromJson(json);
      expect(card2, card);
      expect(card2.toJson(), json);
    });
    test('copyWith works', () {
      const CardModel card = CardModel(
        id: 'fib_1',
        display: '1',
        value: 1,
        description: 'desc',
      );
      final CardModel card2 = card.copyWith(display: '2', value: 2);
      expect(card2.display, '2');
      expect(card2.value, 2);
      expect(card2.id, card.id);
    });
  });

  group('VoteModel', () {
    test('fromJson and toJson roundtrip', () {
      const VoteModel vote = VoteModel(userId: 'user1', cardId: 'fib_3');
      final Map<String, dynamic> json = vote.toJson();
      final VoteModel vote2 = VoteModel.fromJson(json);
      expect(vote2, vote);
      expect(vote2.toJson(), json);
    });
    test('copyWith works', () {
      const VoteModel vote = VoteModel(userId: 'user1', cardId: 'fib_1');
      final VoteModel vote2 = vote.copyWith(cardId: 'fib_2');
      expect(vote2.cardId, 'fib_2');
      expect(vote2.userId, vote.userId);
    });
    test('default cardId is empty', () {
      const VoteModel vote = VoteModel(userId: 'user2');
      expect(vote.cardId, '');
    });
  });

  group('GameModel', () {
    test('fromJson y toJson roundtrip con deck no vacío', () {
      final List<CardModel> deck = <CardModel>[
        const CardModel(
          id: 'fib_1',
          display: '1',
          value: 1,
          description: 'desc',
        ),
        const CardModel(
          id: 'fib_2',
          display: '2',
          value: 2,
          description: 'desc',
        ),
      ];
      final GameModel model = GameModel(
        id: 'g1',
        name: 'Partida',
        admin: const UserModel(
          id: 'u',
          displayName: 'a',
          photoUrl: '',
          email: '',
          jwt: <String, dynamic>{},
        ),
        spectators: const <UserModel>[],
        players: const <UserModel>[],
        votes: const <VoteModel>[],
        isActive: true,
        createdAt: DateTime(2025),
        deck: deck,
      );
      final Map<String, dynamic> json = model.toJson();
      final GameModel model2 = GameModel.fromJson(json);
      expect(model2.deck, equals(deck));
      expect(
        model2.toJson()['deck'],
        equals(deck.map((CardModel c) => c.toJson()).toList()),
      );
    });
    test('fromJson y toJson roundtrip con deck vacío', () {
      final GameModel model = GameModel(
        id: 'g2',
        name: 'Vacía',
        admin: const UserModel(
          id: 'u',
          displayName: 'a',
          photoUrl: '',
          email: '',
          jwt: <String, dynamic>{},
        ),
        spectators: const <UserModel>[],
        players: const <UserModel>[],
        votes: const <VoteModel>[],
        isActive: false,
        createdAt: DateTime(2025),
        deck: const <CardModel>[],
      );
      final Map<String, dynamic> json = model.toJson();
      final GameModel model2 = GameModel.fromJson(json);
      expect(model2.deck, isEmpty);
      expect(model2.toJson()['deck'], isEmpty);
    });
    const UserModel user1 = UserModel(
      id: 'user1',
      displayName: 'Alice',
      photoUrl: '',
      email: 'alice@example.com',
      jwt: <String, dynamic>{},
    );
    const UserModel user2 = UserModel(
      id: 'user2',
      displayName: 'Bob',
      photoUrl: '',
      email: 'bob@example.com',
      jwt: <String, dynamic>{},
    );
    const CardModel card1 = CardModel(
      id: 'fib_1',
      display: '1',
      value: 1,
      description: 'Fibonacci 1',
    );
    const CardModel card2 = CardModel(
      id: 'fib_2',
      display: '2',
      value: 2,
      description: 'Fibonacci 2',
    );
    const VoteModel vote1 = VoteModel(userId: 'user1', cardId: 'fib_1');
    const VoteModel vote2 = VoteModel(userId: 'user2');

    GameModel buildGameModel({
      List<VoteModel>? votes,
      List<UserModel>? players,
      List<CardModel>? deck,
      bool? isActive,
    }) {
      return GameModel(
        id: 'game1',
        name: 'Sprint 1',
        admin: user1,
        spectators: const <UserModel>[user2],
        players: players ?? <UserModel>[user1, user2],
        votes: votes ?? <VoteModel>[vote1, vote2],
        isActive: isActive ?? true,
        createdAt: DateTime.parse('2025-06-16T12:00:00.000'),
        currentStory: 'Historia #1',
        stories: const <String>['Historia #1', 'Historia #2'],
        deck: deck ?? <CardModel>[card1, card2],
        revealTimeout: 30,
      );
    }

    test('fromJson and toJson roundtrip', () {
      final GameModel game = buildGameModel();
      final Map<String, dynamic> json = game.toJson();
      final GameModel game2 = GameModel.fromJson(json);
      expect(game2.id, game.id);
      expect(game2.name, game.name);
      expect(
        game2.votes.map((VoteModel v) => v.userId).toList(),
        game.votes.map((VoteModel v) => v.userId).toList(),
      );
      expect(
        game2.votes.map((VoteModel v) => v.cardId).toList(),
        game.votes.map((VoteModel v) => v.cardId).toList(),
      );
      expect(
        game2.deck.map((CardModel c) => c.id).toList(),
        game.deck.map((CardModel c) => c.id).toList(),
      );
      expect(
        game2.players.map((UserModel u) => u.id).toList(),
        game.players.map((UserModel u) => u.id).toList(),
      );
      expect(
        game2.spectators.map((UserModel u) => u.id).toList(),
        game.spectators.map((UserModel u) => u.id).toList(),
      );
      expect(game2.stories, game.stories);
    });

    test('handles empty votes and deck', () {
      final GameModel game = buildGameModel(
        votes: <VoteModel>[],
        deck: <CardModel>[],
      );
      final Map<String, dynamic> json = game.toJson();
      final GameModel game2 = GameModel.fromJson(json);
      expect(game2.votes, isEmpty);
      expect(game2.deck, isEmpty);
    });

    test('handles no players', () {
      final GameModel game = buildGameModel(players: <UserModel>[]);
      final Map<String, dynamic> json = game.toJson();
      final GameModel game2 = GameModel.fromJson(json);
      expect(game2.players, isEmpty);
    });

    test('simulate voting and reveal', () {
      // Simula que todos votan y luego se revela
      final List<VoteModel> votes = <VoteModel>[
        const VoteModel(userId: 'user1', cardId: 'fib_2'),
        const VoteModel(userId: 'user2', cardId: 'fib_1'),
      ];
      final GameModel game = buildGameModel(votes: votes, isActive: false);
      expect(game.isActive, false);
      expect(game.votes.every((VoteModel v) => v.cardId.isNotEmpty), true);
    });
  });

  group('modelListToJson & convertJsonToModelList', () {
    test('roundtrip CardModel', () {
      final List<CardModel> cards = <CardModel>[
        const CardModel(id: 'fib_1', display: '1', value: 1, description: ''),
        const CardModel(id: 'fib_2', display: '2', value: 2, description: ''),
      ];
      final List<Map<String, dynamic>> json = modelListToJson<CardModel>(
        cards,
        (CardModel c) => c.toJson(),
      );
      final List<CardModel> cards2 = convertJsonToModelList<CardModel>(
        json,
        CardModel.fromJson,
      );
      expect(cards2, cards);
    });
    test('roundtrip VoteModel', () {
      final List<VoteModel> votes = <VoteModel>[
        const VoteModel(userId: 'u1', cardId: 'c1'),
        const VoteModel(userId: 'u2'),
      ];
      final List<Map<String, dynamic>> json = modelListToJson<VoteModel>(
        votes,
        (VoteModel v) => v.toJson(),
      );
      final List<VoteModel> votes2 = convertJsonToModelList<VoteModel>(
        json,
        VoteModel.fromJson,
      );
      expect(votes2, votes);
    });
  });
}
