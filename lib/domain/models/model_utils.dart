import 'dart:convert';

/// Utilidades genéricas para convertir listas de modelos desde/hacia JSON.

List<T> convertJsonToModelList<T>(
  dynamic jsonList,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (jsonList == null) {
    return <T>[];
  }
  if (jsonList is List) {
    return jsonList.map<T>((dynamic e) {
      if (e is Map<String, dynamic>) {
        return fromJson(e);
      } else if (e is Map) {
        return fromJson(Map<String, dynamic>.from(e));
      } else if (e is String) {
        try {
          final dynamic decoded = jsonDecode(e);
          if (decoded is Map<String, dynamic>) {
            return fromJson(decoded);
          } else if (decoded is Map) {
            return fromJson(Map<String, dynamic>.from(decoded));
          }
        } catch (_) {}
      }
      throw ArgumentError('Elemento no convertible a Map<String, dynamic>: $e');
    }).toList();
  }
  return <T>[];
}

List<Map<String, dynamic>> modelListToJson<T>(
  List<T> list,
  Map<String, dynamic> Function(T) toJson,
) {
  return list.map((T e) => toJson(e)).toList();
}
