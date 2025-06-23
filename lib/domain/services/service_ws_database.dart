/// Abstracta para operaciones CRUD y streams en un backend tipo Firestore/Firebase.
/// Permite guardar, leer y subscribirse a documentos y colecciones por modelo.
abstract class ServiceWsDatabase {
  /// Guarda (crea o actualiza) un documento en la colección indicada.
  Future<void> saveDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  });

  /// Lee un documento único por colección y ID.
  Future<Map<String, dynamic>?> readDocument({
    required String collection,
    required String docId,
  });

  /// Expone un stream de un documento único.
  Stream<Map<String, dynamic>?> documentStream({
    required String collection,
    required String docId,
  });

  /// Expone un stream de toda la colección.
  Stream<List<Map<String, dynamic>>> collectionStream({
    required String collection,
  });
}
