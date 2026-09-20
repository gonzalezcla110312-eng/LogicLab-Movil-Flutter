import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../restaurant_providers.dart';
import 'create_order_page.dart';
import 'occupied_table_page.dart';

class MeseroPage extends ConsumerWidget {
  const MeseroPage({super.key});

  Color _colorForEstado(String estado) {
    return switch (estado.toUpperCase()) {
      'LIBRE' => Colors.green,
      'OCUPADA' => Colors.orange,
      'INACTIVA' => Colors.grey,
      _ => Colors.blueGrey,
    };
  }

  bool _isOcupada(Mesa mesa) => mesa.estado.toUpperCase() == 'OCUPADA';

  Future<void> _openMesa(
    BuildContext context,
    WidgetRef ref,
    Mesa mesa,
  ) async {
    if (!mesa.activa) return;

    final page = _isOcupada(mesa)
        ? OccupiedTablePage(mesa: mesa)
        : CreateOrderPage(mesa: mesa);

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
    ref.invalidate(mesasProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mesasAsync = ref.watch(mesasProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(mesasProvider),
      child: mesasAsync.when(
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
                    onPressed: () => ref.invalidate(mesasProvider),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ],
        ),
        data: (mesas) {
          if (mesas.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No hay mesas disponibles')),
              ],
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: mesas.length,
            itemBuilder: (context, index) {
              final mesa = mesas[index];
              return _MesaCard(
                mesa: mesa,
                color: _colorForEstado(mesa.estado),
                onTap: mesa.activa
                    ? () => _openMesa(context, ref, mesa)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class _MesaCard extends StatelessWidget {
  final Mesa mesa;
  final Color color;
  final VoidCallback? onTap;

  const _MesaCard({
    required this.mesa,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    foregroundColor: color,
                    child: Text('${mesa.numero}'),
                  ),
                  const Spacer(),
                  Icon(
                    mesa.activa ? Icons.table_restaurant : Icons.block,
                    color: color,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'Mesa ${mesa.numero}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(mesa.estado),
            ],
          ),
        ),
      ),
    );
  }
}
