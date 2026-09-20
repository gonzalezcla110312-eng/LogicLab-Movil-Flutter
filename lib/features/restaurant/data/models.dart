import '../../../core/network/api_helpers.dart';

class Mesa {
  final int id;
  final int numero;
  final String estado;
  final bool activa;

  const Mesa({
    required this.id,
    required this.numero,
    required this.estado,
    required this.activa,
  });

  factory Mesa.fromJson(Map<String, dynamic> json) {
    return Mesa(
      id: asInt(json['id']),
      numero: asInt(json['numero']),
      estado: asString(json['estado'], fallback: 'LIBRE'),
      activa: json['activa'] == true || json['activa'] == 1,
    );
  }
}

class MenuItem {
  final int platilloId;
  final String nombre;
  final String descripcion;
  final double precio;

  const MenuItem({
    required this.platilloId,
    required this.nombre,
    required this.descripcion,
    required this.precio,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      platilloId: asInt(json['platillo_id'] ?? json['id']),
      nombre: asString(json['nombre']),
      descripcion: asString(json['descripcion']),
      precio: asDouble(json['precio']),
    );
  }
}

class PedidoDetalle {
  final int platilloId;
  final String nombre;
  final int cantidad;
  final String notas;

  const PedidoDetalle({
    required this.platilloId,
    required this.nombre,
    required this.cantidad,
    required this.notas,
  });

  factory PedidoDetalle.fromJson(Map<String, dynamic> json) {
    return PedidoDetalle(
      platilloId: asInt(json['platillo_id']),
      nombre: asString(
        json['platillo_nombre'] ?? json['nombre'],
        fallback: 'Platillo',
      ),
      cantidad: asInt(json['cantidad'], fallback: 1),
      notas: asString(json['notas']),
    );
  }
}

class Pedido {
  final int id;
  final int mesaId;
  final int mesaNumero;
  final String estado;
  final double total;
  final int minutos;
  final List<PedidoDetalle> detalles;

  const Pedido({
    required this.id,
    required this.mesaId,
    required this.mesaNumero,
    required this.estado,
    required this.total,
    required this.minutos,
    required this.detalles,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final rawDetalles = json['detalles'] ?? json['items'] ?? const [];
    return Pedido(
      id: asInt(json['id']),
      mesaId: asInt(json['mesa_id']),
      mesaNumero: asInt(json['mesa_numero'] ?? json['mesa_id']),
      estado: asString(json['estado'], fallback: 'COCINANDO'),
      total: asDouble(json['total']),
      minutos: asInt(
        json['minutos_transcurridos'] ?? json['minutos_abierto'],
      ),
      detalles: (rawDetalles is List)
          ? rawDetalles.map((e) => PedidoDetalle.fromJson(asMap(e))).toList()
          : const [],
    );
  }
}

class AdminStats {
  final int pedidosCompletados;
  final int pedidosCancelados;
  final int pedidosEnProceso;
  final double promedioDemora;
  final int mesasOcupadas;
  final int mesasLibres;
  final int mesasInactivas;
  final double ingresosTotales;
  final int pedidosPagados;
  final double ticketPromedio;

  const AdminStats({
    required this.pedidosCompletados,
    required this.pedidosCancelados,
    required this.pedidosEnProceso,
    required this.promedioDemora,
    required this.mesasOcupadas,
    required this.mesasLibres,
    required this.mesasInactivas,
    required this.ingresosTotales,
    required this.pedidosPagados,
    required this.ticketPromedio,
  });

  factory AdminStats.fromJson({
    required Map<String, dynamic> estadisticas,
    Map<String, dynamic>? ingresos,
  }) {
    return AdminStats(
      pedidosCompletados: asInt(estadisticas['pedidos_completados']),
      pedidosCancelados: asInt(estadisticas['pedidos_cancelados']),
      pedidosEnProceso: asInt(estadisticas['pedidos_en_proceso']),
      promedioDemora: asDouble(
        estadisticas['promedio_demora_preparacion_min'],
      ),
      mesasOcupadas: asInt(estadisticas['mesas_ocupadas']),
      mesasLibres: asInt(estadisticas['mesas_libres']),
      mesasInactivas: asInt(estadisticas['mesas_inactivas']),
      ingresosTotales: asDouble(ingresos?['ingresos_totales']),
      pedidosPagados: asInt(ingresos?['pedidos_pagados']),
      ticketPromedio: asDouble(ingresos?['ticket_promedio']),
    );
  }
}
