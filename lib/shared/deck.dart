import '../domains/models/card_model.dart';

/// Baraja Planning Poker por defecto (Fibonacci + comodines)
final List<CardModel> defaultPlanningPokerDeck = <CardModel>[
  const CardModel(id: '0', display: '0', value: 0, description: 'Carta 0'),
  const CardModel(id: '1', display: '1', value: 1, description: 'Carta 1'),
  const CardModel(id: '3', display: '3', value: 3, description: 'Carta 3'),
  const CardModel(id: '5', display: '5', value: 5, description: 'Carta 5'),
  const CardModel(id: '8', display: '8', value: 8, description: 'Carta 8'),
  const CardModel(id: '13', display: '13', value: 13, description: 'Carta 13'),
  const CardModel(id: '21', display: '21', value: 21, description: 'Carta 21'),
  const CardModel(id: '34', display: '34', value: 34, description: 'Carta 34'),
  const CardModel(id: '55', display: '55', value: 55, description: 'Carta 55'),
  const CardModel(id: '89', display: '89', value: 89, description: 'Carta 89'),
  const CardModel(
    id: '?',
    display: '?',
    value: -1,
    description: 'Carta incógnita',
    isSpecial: true,
  ),
  const CardModel(
    id: 'coffee',
    display: '☕',
    value: -1,
    description: 'Carta café',
    isSpecial: true,
  ),
];
