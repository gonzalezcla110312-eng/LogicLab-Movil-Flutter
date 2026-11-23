import 'package:flutter/material.dart';
import 'main.dart';

class PedidosCocina extends StatefulWidget {
  const PedidosCocina({super.key, required this.api, required this.rol});
  final Api api;
  final String rol;
  @override
  State<PedidosCocina> createState() => _PedidosCocinaState();
}

class _PedidosCocinaState extends State<PedidosCocina> {
  List<Map<String, dynamic>> pedidos = [];
  bool cargando = true;
  String error = '';
  String filtro = 'TODOS';

  bool get cocina => widget.rol.toLowerCase() == 'cocinero';
  String get ruta => cocina
      ? '/api/mesas/pedidos/activos/cocina'
      : '/api/mesas/pedidos';

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    setState(() { cargando = true; error = ''; });
    try {
      final respuesta = await widget.api.pedir('GET', ruta);
      final datos = respuesta is Map ? respuesta['datos'] : respuesta;
      final lista = datos is List ? datos
          : datos is Map && datos['pedidos'] is List ? datos['pedidos']
          : datos is Map && datos['items'] is List ? datos['items']
          : <dynamic>[];
      if (!mounted) return;
      setState(() {
        pedidos = lista.whereType<Map>()
            .map((p) => Map<String, dynamic>.from(p)).toList();
      });
    } catch (e) {
      if (mounted) setState(() { error = e.toString(); });
    } finally {
      if (mounted) setState(() { cargando = false; });
    }
  }

  Future<void> cambiarEstado(int id, String estado) async {
    try {
      await widget.api.pedir('PATCH', '/api/mesas/pedidos/$id/estado',
        {'estado': estado});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pedido #$id actualizado a $estado')));
      await cargar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())));
    }
  }

  Widget pedido(Map<String, dynamic> p) {
    final id = int.tryParse(p['id'].toString()) ?? 0;
    final estado = (p['estado'] ?? p['estadoPedido'] ?? '').toString().toUpperCase();
    final detalles = p['detalles'] is List ? p['detalles'] as List : <dynamic>[];
    final mesa = p['mesa_id'] ?? p['mesa'] ?? '?';
    final estados = cocina
        ? const ['COCINANDO', 'PARA_ENTREGA', 'ENTREGADO']
        : const ['COCINANDO', 'PARA_ENTREGA', 'ENTREGADO', 'PAGADO', 'CERRADO', 'CANCELADO'];
    return Card(
      color: const Color(0xFF341E1B),
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Pedido #$id · Mesa $mesa',
              style: const TextStyle(color: dorado, fontSize: 18,
                fontWeight: FontWeight.bold))),
            Chip(label: Text(estado.isEmpty ? 'SIN ESTADO' : estado)),
          ]),
          for (final d in detalles)
            if (d is Map)
              Padding(padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  '${d['cantidad'] ?? 1} × ${d['platillo'] is Map ? d['platillo']['nombre'] : d['nombre'] ?? 'Platillo #${d['platillo_id']}'}'
                  '${d['notas'] == null || d['notas'].toString().isEmpty ? '' : ' · ${d['notas']}'}')),
          const SizedBox(height: 8),
          Wrap(spacing: 7, runSpacing: 7, children: [
            for (final siguiente in estados)
              if (siguiente != estado)
                OutlinedButton(
                  onPressed: id > 0 ? () => cambiarEstado(id, siguiente) : null,
                  child: Text(siguiente),
                ),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibles = pedidos.where((p) =>
      filtro == 'TODOS' ||
      (p['estado'] ?? p['estadoPedido'] ?? '').toString().toUpperCase() == filtro).toList();
    return Column(children: [
      ListTile(
        title: Text(cocina ? 'COCINA' : 'PEDIDOS',
          style: const TextStyle(color: dorado, fontSize: 25,
            fontWeight: FontWeight.bold)),
        subtitle: const Text('Seguimiento de pedidos en tiempo real'),
        trailing: IconButton(onPressed: cargar,
          icon: const Icon(Icons.refresh)),
      ),
      SingleChildScrollView(scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final estado in const [
            'TODOS', 'COCINANDO', 'PARA_ENTREGA', 'ENTREGADO', 'PAGADO',
          ])
            Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(label: Text(estado),
                selected: filtro == estado,
                onSelected: (_) => setState(() { filtro = estado; }))),
        ])),
      if (cargando)
        const Expanded(child: Center(child: CircularProgressIndicator()))
      else if (error.isNotEmpty)
        Expanded(child: Center(child: Text(error)))
      else if (visibles.isEmpty)
        const Expanded(child: Center(child: Text('No hay pedidos para mostrar')))
      else
        Expanded(child: RefreshIndicator(onRefresh: cargar,
          child: ListView(padding: const EdgeInsets.all(12),
            children: visibles.map(pedido).toList()))),
    ]);
  }
}
