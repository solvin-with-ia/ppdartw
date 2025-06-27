import '../domain/models/card_model.dart';
import '../domain/models/game_model.dart';
import '../domain/models/vote_model.dart';

/// Utilidades relacionadas con el modelo de juego
class GameUtils {
  /// Calcula el promedio de los votos revelados (solo cartas numéricas)
  static double calculateAverage(GameModel game) {
    if (!game.votesRevealed) {
      return 0;
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
      return 0;
    }
    final double sum = values.fold(0.0, (double a, double b) => a + b);
    return sum / values.length;
  }
}
