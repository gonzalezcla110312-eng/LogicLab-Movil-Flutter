import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/models.dart';
import '../restaurant_providers.dart';
import 'create_order_page.dart';

class OccupiedTablePage extends ConsumerStatefulWidget {
  final Mesa mesa;

  const OccupiedTablePage({super.key, required this.mesa});

  @override
  ConsumerState<OccupiedTablePage> createState() => _OccupiedTablePageState();
}

class _OccupiedTablePageState extends ConsumerState<OccupiedTablePage> {
  Pedido? pedido;
  bool loading = true;
  bool acting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await ref
          .read(restaurantApiProvider)
          .getPedidoActivo(widget.mesa.id);
      if (!mounted) return;
      setState(() {
        pedido = data;
        loading = false;
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.message;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = '$e';
        loading = false;
      });
    }
  }

  Future<void> _cambiarEstado(String estado, String okMessage) async {
    final actual = pedido;
    if (actual == null) return;

    setState(() => acting = true);
    try {
      await ref.read(restaurantApiProvider).actualizarEstadoPedido(
            pedidoId: actual.id,
            estado: estado,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(okMessage)),
      );
      if (estado == 'PAGADO') {
        Navigator.of(context).pop(true);
        return;
      }
      await _cargar();
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => acting = false);
    }
  }

  Future<void> _editarPedido() async {
    final actual = pedido;
    if (actual == null) return;

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CreateOrderPage(
          mesa: widget.mesa,
          pedido: actual,
        ),
      ),
    );

    if (changed == true) {
      await _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final actual = pedido;
    final estado = (actual?.estado ?? '').toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: Text('Mesa ${widget.mesa.numero}'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _cargar,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : actual == null
                  ? const Center(child: Text('No hay pedido activo'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Pedido #${actual.id}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const Spacer(),
                                    Chip(label: Text(actual.estado)),
                                  ],
                                ),
                                Text(
                                  'Total: \$${actual.total.toStringAsFixed(2)}',
                                ),
                                const SizedBox(height: 12),
                                ...actual.detalles.map(
                                  (d) => Text(
                                    '• ${d.cantidad}x ${d.nombre}'
                                    '${d.notas.isEmpty ? '' : ' (${d.notas})'}',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: acting ? null : _editarPedido,
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar pedido'),
                        ),
                        const SizedBox(height: 12),
                        if (estado != 'ENTREGADO' && estado != 'PAGADO')
                          FilledButton.tonalIcon(
                            onPressed: acting
                                ? null
                                : () => _cambiarEstado(
                                      'ENTREGADO',
                                      'Pedido marcado como entregado',
                                    ),
                            icon: const Icon(Icons.room_service),
                            label: const Text('Entregado'),
                          ),
                        if (estado == 'ENTREGADO') ...[
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: acting
                                ? null
                                : () => _cambiarEstado(
                                      'PAGADO',
                                      'Pedido marcado como pagado',
                                    ),
                            icon: const Icon(Icons.payments),
                            label: const Text('Pagado'),
                          ),
                        ],
                        if (acting) ...[
                          const SizedBox(height: 24),
                          const Center(child: CircularProgressIndicator()),
                        ],
                      ],
                    ),
    );
  }
}
