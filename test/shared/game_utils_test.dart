import 'package:flutter_test/flutter_test.dart';
import 'package:ppdartw/domain/models/card_model.dart';
import 'package:ppdartw/domain/models/game_model.dart';
import 'package:ppdartw/domain/models/vote_model.dart';
import 'package:ppdartw/shared/game_utils.dart';

void main() {
  group('calculateAverage', () {
    test('returns 0 if votes are not revealed', () {
      final GameModel game = GameModel.empty().copyWith(votesRevealed: false);
      expect(GameUtils.calculateAverage(game), 0.0);
    });

    test('returns 0 if there are no valid votes', () {
      final GameModel game = GameModel.empty().copyWith(
        votes: <VoteModel>[],
        deck: <CardModel>[],
        votesRevealed: true,
      );
      expect(GameUtils.calculateAverage(game), 0.0);
    });

    test('returns correct average when votes are revealed and valid', () {
      const CardModel card = CardModel(
        id: '1',
        display: '1',
        value: 5,
        description: 'Five',
      );
      final VoteModel vote = VoteModel(userId: 'user1', cardId: card.id);
      final GameModel game = GameModel.empty().copyWith(
        deck: <CardModel>[card],
        votes: <VoteModel>[vote],
        votesRevealed: true,
      );
      expect(GameUtils.calculateAverage(game), 5.0);
    });

    test('returns average of multiple votes', () {
      const CardModel card1 = CardModel(
        id: '1',
        display: '1',
        value: 3,
        description: 'Three',
      );
      const CardModel card2 = CardModel(
        id: '2',
        display: '2',
        value: 7,
        description: 'Seven',
      );
      final List<VoteModel> votes = <VoteModel>[
        VoteModel(userId: 'user1', cardId: card1.id),
        VoteModel(userId: 'user2', cardId: card2.id),
      ];
      final GameModel game = GameModel.empty().copyWith(
        deck: <CardModel>[card1, card2],
        votes: votes,
        votesRevealed: true,
      );
      expect(GameUtils.calculateAverage(game), 5.0);
    });

    test('ignores votes with cardId not in deck', () {
      const CardModel card1 = CardModel(
        id: '1',
        display: '1',
        value: 4,
        description: 'Four',
      );
      // Voto válido y voto inválido (cardId no existe en deck)
      final List<VoteModel> votes = <VoteModel>[
        VoteModel(userId: 'user1', cardId: card1.id),
        const VoteModel(userId: 'user2', cardId: 'no-existe'),
      ];
      final GameModel game = GameModel.empty().copyWith(
        deck: <CardModel>[card1],
        votes: votes,
        votesRevealed: true,
      );
      // Solo debe promediar el voto válido (4.0)
      expect(GameUtils.calculateAverage(game), 4.0);
    });
  });
}
