import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ppdartw/infrastructure/services/fake_service_ws_database.dart';

void main() {
  group('FakeServiceWsDatabase', () {
    late FakeServiceWsDatabase db;
    const String collection = 'games';
    const String docId = 'game1';
    final Map<String, dynamic> gameJson = <String, dynamic>{
      'id': docId,
      'name': 'Test Game',
      'admin': <String, String>{'id': 'admin1'},
      'players': <dynamic>[],
      'votes': <dynamic>[],
      'isActive': true,
      'createdAt': DateTime(2025).toIso8601String(),
      'finishedAt': null,
      'currentStory': '',
      'stories': <String>[],
      'deck': <dynamic>[],
      'revealTimeout': 30,
    };

    setUp(() {
      db = FakeServiceWsDatabase();
    });

    test('saveDocument and readDocument roundtrip', () async {
      await db.saveDocument(
        collection: collection,
        docId: docId,
        data: gameJson,
      );
      final Map<String, dynamic>? result = await db.readDocument(
        collection: collection,
        docId: docId,
      );
      expect(result, isNotNull);
      expect(result!['id'], docId);
      expect(result['name'], 'Test Game');
    });

    test('readDocument returns null if not found', () async {
      final Map<String, dynamic>? result = await db.readDocument(
        collection: collection,
        docId: 'unknown',
      );
      expect(result, isNull);
    });

    test('documentStream emits on save', () async {
      final List<Map<String, dynamic>?> emitted = <Map<String, dynamic>?>[];
      final StreamSubscription<Map<String, dynamic>?> sub = db
          .documentStream(collection: collection, docId: docId)
          .listen(emitted.add);
      await db.saveDocument(
        collection: collection,
        docId: docId,
        data: gameJson,
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emitted.last, isNotNull);
      expect(emitted.last!['id'], docId);
      await sub.cancel();
    });

    test('collectionStream emits on save', () async {
      final List<List<Map<String, dynamic>>> emitted =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> sub = db
          .collectionStream(collection: collection)
          .listen(emitted.add);
      await db.saveDocument(
        collection: collection,
        docId: docId,
        data: gameJson,
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emitted.last, isNotEmpty);
      expect(emitted.last.first['id'], docId);
      await sub.cancel();
    });

    test('multiple docs in collectionStream', () async {
      final List<List<Map<String, dynamic>>> emitted =
          <List<Map<String, dynamic>>>[];
      final StreamSubscription<List<Map<String, dynamic>>> sub = db
          .collectionStream(collection: collection)
          .listen(emitted.add);
      await db.saveDocument(
        collection: collection,
        docId: 'g1',
        data: <String, dynamic>{...gameJson, 'id': 'g1'},
      );
      await db.saveDocument(
        collection: collection,
        docId: 'g2',
        data: <String, dynamic>{...gameJson, 'id': 'g2'},
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(emitted.last.length, 2);
      expect(
        emitted.last.map((Map<String, dynamic> g) => g['id']).toSet(),
        <String>{'g1', 'g2'},
      );
      await sub.cancel();
    });
  });
}
