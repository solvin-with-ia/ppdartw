import 'dart:async';
import 'package:jocaagura_domain/jocaagura_domain.dart';
import '../../domain/services/service_ws_database.dart';

/// FakeServiceWsDatabase simula un backend en memoria para pruebas y desarrollo.
/// No tiene persistencia: todos los datos se pierden al reiniciar la app.
class FakeServiceWsDatabase implements ServiceWsDatabase {
  final Map<String, Map<String, Map<String, dynamic>>> _collections =
      <String, Map<String, Map<String, dynamic>>>{};
  final Map<String, Map<String, BlocGeneral<Map<String, dynamic>?>>> _docBlocs =
      <String, Map<String, BlocGeneral<Map<String, dynamic>?>>>{};
  final Map<String, BlocGeneral<List<Map<String, dynamic>>>> _collectionBlocs =
      <String, BlocGeneral<List<Map<String, dynamic>>>>{};

  @override
  Future<void> saveDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    _collections.putIfAbsent(
      collection,
      () => <String, Map<String, dynamic>>{},
    );
    _collections[collection]![docId] = data;
    // Notifica a los listeners del documento
    _docBlocs.putIfAbsent(
      collection,
      () => <String, BlocGeneral<Map<String, dynamic>?>>{},
    );
    _docBlocs[collection]!.putIfAbsent(
      docId,
      () => BlocGeneral<Map<String, dynamic>?>(null),
    );
    _docBlocs[collection]![docId]!.value = data;
    // Notifica a los listeners de la colección
    _collectionBlocs.putIfAbsent(
      collection,
      () => BlocGeneral<List<Map<String, dynamic>>>(<Map<String, dynamic>>[]),
    );
    _collectionBlocs[collection]!.value = _collections[collection]!.values
        .toList();
  }

  @override
  Future<Map<String, dynamic>?> readDocument({
    required String collection,
    required String docId,
  }) async {
    return _collections[collection]?[docId];
  }

  @override
  Stream<Map<String, dynamic>?> documentStream({
    required String collection,
    required String docId,
  }) {
    _docBlocs.putIfAbsent(
      collection,
      () => <String, BlocGeneral<Map<String, dynamic>?>>{},
    );
    final BlocGeneral<Map<String, dynamic>?> bloc = _docBlocs[collection]!
        .putIfAbsent(docId, () => BlocGeneral<Map<String, dynamic>?>(null));
    // Emitir el valor actual si existe
    if (_collections[collection]?[docId] != null) {
      bloc.value = _collections[collection]![docId];
    }
    return bloc.stream;
  }

  @override
  Stream<List<Map<String, dynamic>>> collectionStream({
    required String collection,
  }) {
    final BlocGeneral<List<Map<String, dynamic>>> bloc = _collectionBlocs
        .putIfAbsent(
          collection,
          () =>
              BlocGeneral<List<Map<String, dynamic>>>(<Map<String, dynamic>>[]),
        );
    // Emitir el valor actual si existe
    if (_collections[collection]?.isNotEmpty ?? false) {
      bloc.value = _collections[collection]!.values.toList();
    }
    return bloc.stream;
  }

  void dispose() {
    // 1. Limpia _collections
    _collections.clear();

    // 2. Recorre todos los BlocGeneral de _docBlocs y llama dispose
    for (final Map<String, BlocGeneral<Map<String, dynamic>?>> collection
        in _docBlocs.values) {
      for (final BlocGeneral<Map<String, dynamic>?> bloc in collection.values) {
        bloc.dispose();
      }
      collection.clear();
    }
    _docBlocs.clear();

    // 3. Recorre todos los BlocGeneral de _collectionBlocs y llama dispose
    for (final BlocGeneral<List<Map<String, dynamic>>> bloc
        in _collectionBlocs.values) {
      bloc.dispose();
    }
    _collectionBlocs.clear();
  }
}
