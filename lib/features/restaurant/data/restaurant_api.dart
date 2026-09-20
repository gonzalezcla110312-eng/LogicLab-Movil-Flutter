import 'package:dio/dio.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/network/api_helpers.dart';
import 'models.dart';

class RestaurantApi {
  final Dio dio;

  RestaurantApi(this.dio);

  Future<List<Mesa>> getMesas() async {
    final response = await dio.get('/mesas');
    return asMapList(response.data).map(Mesa.fromJson).toList();
  }

  Future<List<MenuItem>> getMenuHoy() async {
    try {
      final response = await dio.get('/menu-dia/hoy');
      final datos = unwrapDatos(response.data);
      final items = asMap(datos)['items'];
      if (items is List && items.isNotEmpty) {
        return items.map((e) => MenuItem.fromJson(asMap(e))).toList();
      }
    } catch (_) {
      // Si no hay menú del día, usamos platillos.
    }

    final platillos = await dio.get('/platillos');
    return asMapList(platillos.data)
        .where((e) => e['activo'] == true || e['activo'] == 1 || e['activo'] == null)
        .map(MenuItem.fromJson)
        .toList();
  }

  Future<void> crearPedido({
    required int mesaId,
    required int usuarioId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await dio.post(
      '/mesas/$mesaId/pedidos',
      data: {
        'usuario_id': usuarioId,
        'items': items,
      },
    );
    unwrapDatos(response.data);
  }

  Future<Pedido?> getPedidoActivo(int mesaId) async {
    try {
      final response = await dio.get('/mesas/$mesaId/pedido-activo');
      final datos = unwrapDatos(response.data);
      if (datos == null) return null;
      return Pedido.fromJson(asMap(datos));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrowApi(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      rethrowApi(e);
    }
  }

  Future<void> actualizarPedido({
    required int pedidoId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await dio.put(
      '/mesas/pedidos/$pedidoId',
      data: {'items': items},
    );
    unwrapDatos(response.data);
  }

  Future<List<Pedido>> getPedidosCocina() async {
    final response = await dio.get('/mesas/pedidos/activos/cocina');
    return asMapList(response.data).map(Pedido.fromJson).toList();
  }

  Future<void> actualizarEstadoPedido({
    required int pedidoId,
    required String estado,
  }) async {
    final response = await dio.patch(
      '/mesas/pedidos/$pedidoId/estado',
      data: {'estado': estado},
    );
    unwrapDatos(response.data);
  }

  Future<void> entregarPedido(int pedidoId) async {
    final response = await dio.patch('/mesas/pedidos/$pedidoId/entregar');
    unwrapDatos(response.data);
  }

  Future<AdminStats> getAdminStats() async {
    final statsRes = await dio.get('/admin/dashboard/estadisticas');
    final ingresosRes = await dio.get('/admin/dashboard/ingresos');
    return AdminStats.fromJson(
      estadisticas: asMap(unwrapDatos(statsRes.data)),
      ingresos: asMap(unwrapDatos(ingresosRes.data)),
    );
  }

  String messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is String) {
      return data['error'] as String;
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de espera agotado';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar al servidor';
    }
    return 'Error de red (${e.response?.statusCode ?? 'sin código'})';
  }

  Never rethrowApi(Object error) {
    if (error is AuthException) throw error;
    if (error is DioException) {
      throw AuthException(messageFromDio(error));
    }
    throw const AuthException('Ocurrió un error inesperado');
  }
}
