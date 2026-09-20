import '../error/exceptions.dart';

Map<String, dynamic> asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  throw const AuthException('Respuesta inválida del servidor');
}

dynamic unwrapDatos(dynamic data) {
  final map = asMap(data);
  if (map['exito'] == false) {
    final error = map['error'];
    if (error is String && error.isNotEmpty) {
      throw AuthException(error);
    }
    throw const AuthException('La solicitud no se pudo completar');
  }
  return map.containsKey('datos') ? map['datos'] : map;
}

List<Map<String, dynamic>> asMapList(dynamic data) {
  final value = data is List ? data : unwrapDatos(data);
  if (value is! List) {
    throw const AuthException('Se esperaba una lista');
  }
  return value.map((e) => asMap(e)).toList();
}

int asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double asDouble(dynamic value, {double fallback = 0}) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

String asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}
