import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/models.dart';
import '../restaurant_providers.dart';

class CocinaPage extends ConsumerWidget {
  const CocinaPage({super.key});

  Future<void> _accion(
    BuildContext context,
    WidgetRef ref, {
    required Future<void> Function() action,
    required String okMessage,
  }) async {
    try {
      await action();
      ref.invalidate(cocinaPedidosProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(okMessage)),
      );
    } on AuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pedidosAsync = ref.watch(cocinaPedidosProvider);
    final api = ref.watch(restaurantApiProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(cocinaPedidosProvider),
      child: pedidosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          children: [
            const SizedBox(height: 120),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text('$e', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref.invalidate(cocinaPedidosProvider),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ],
        ),
        data: (pedidos) {
          if (pedidos.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No hay pedidos activos en cocina')),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return _PedidoCard(
                pedido: pedido,
                onListo: () => _accion(
                  context,
                  ref,
                  okMessage: 'Pedido listo para entrega',
                  action: () => api.actualizarEstadoPedido(
                    pedidoId: pedido.id,
                    estado: 'PARA_ENTREGA',
                  ),
                ),
                onEntregar: () => _accion(
                  context,
                  ref,
                  okMessage: 'Pedido entregado',
                  action: () => api.entregarPedido(pedido.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onListo;
  final VoidCallback onEntregar;

  const _PedidoCard({
    required this.pedido,
    required this.onListo,
    required this.onEntregar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Mesa ${pedido.mesaNumero}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Chip(label: Text(pedido.estado)),
              ],
            ),
            Text('Pedido #${pedido.id} · ${pedido.minutos} min'),
            const SizedBox(height: 8),
            ...pedido.detalles.map(
              (d) => Text(
                '• ${d.cantidad}x ${d.nombre}'
                '${d.notas.isEmpty ? '' : ' (${d.notas})'}',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (pedido.estado.toUpperCase() == 'COCINANDO')
                  FilledButton(
                    onPressed: onListo,
                    child: const Text('Listo'),
                  ),
                if (pedido.estado.toUpperCase() == 'PARA_ENTREGA') ...[
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: onEntregar,
                    child: const Text('Entregar'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
