import 'package:flutter_test/flutter_test.dart';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import 'package:ppdartw/domain/models/game_model.dart';

import 'package:ppdartw/shared/game_deck_utils.dart';

void main() {
  group('game_deck_utils', () {
    test('cleanSeats elimina usuarios no válidos', () {
      const UserModel user1 = UserModel(
        id: '1',
        displayName: 'A',
        email: '',
        photoUrl: '',
        jwt: <String, dynamic>{},
      );
      const UserModel user2 = UserModel(
        id: '2',
        displayName: 'B',
        email: '',
        photoUrl: '',
        jwt: <String, dynamic>{},
      );
      const UserModel user3 = UserModel(
        id: '3',
        displayName: 'C',
        email: '',
        photoUrl: '',
        jwt: <String, dynamic>{},
      );
      final GameModel game = GameModel.empty().copyWith(
        players: <UserModel>[user1],
        spectators: <UserModel>[user2],
      );
      final List<UserModel> seats = <UserModel>[user1, user2, user3];
      final List<UserModel?> result = GameDeckUtils.cleanSeats(
        game,
        user1,
        seats,
      );
      expect(result, <UserModel?>[user1, user2, null]);
    });

    test('getPrevSeatMap mapea correctamente', () {
      const UserModel user1 = UserModel(
        id: '1',
        displayName: 'A',
        email: '',
        photoUrl: '',
        jwt: <String, dynamic>{},
      );
      const UserModel user2 = UserModel(
        id: '2',
        displayName: 'B',
        email: '',
        photoUrl: '',
        jwt: <String, dynamic>{},
      );
      final List<UserModel?> previousSeats = <UserModel?>[user1, null, user2];
      final GameModel game = GameModel.empty().copyWith(
        players: <UserModel>[user1],
        spectators: <UserModel>[user2],
      );
      const UserModel currentUser = user1;
      final List<UserModel?> seats = GameDeckUtils.updateSeatsOnGameChange(
        game,
        currentUser,
        previousSeats: previousSeats,
      );
      final Map<String, int> map = GameDeckUtils.getPrevSeatMap(user1, seats);
      // Verifica que el usuario '2' esté presente en el mapeo y el índice sea válido
      expect(map.containsKey('2'), isTrue);
      expect(map['2'], isNotNull);
      expect(map['2'], inInclusiveRange(0, seats.length - 1));
    });

    test('shuffleList no modifica la original y es aleatorio', () {
      final List<int> list = <int>[1, 2, 3, 4, 5];
      final List<int> shuffled = GameDeckUtils.shuffleList(list);
      expect(
        shuffled,
        isNot(equals(list)),
      ); // Puede fallar ocasionalmente si el orden es igual
      expect(list, <int>[1, 2, 3, 4, 5]);
      expect(shuffled.toSet(), list.toSet());
    });

    test('pickRandomIndex retorna índice válido', () {
      final List<int> list = <int>[10, 20, 30];
      final int idx = GameDeckUtils.pickRandomIndex(list);
      expect(idx, inInclusiveRange(0, 2));
    });

    test('pickRandomIndex assert si lista vacía (debug only)', () {
      expect(
        () => GameDeckUtils.pickRandomIndex(<dynamic>[]),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
