import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../restaurant_providers.dart';

class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminStatsProvider),
      child: statsAsync.when(
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
                    onPressed: () => ref.invalidate(adminStatsProvider),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ],
        ),
        data: (stats) {
          final cards = [
            ('Completados', '${stats.pedidosCompletados}', Icons.check_circle),
            ('En proceso', '${stats.pedidosEnProceso}', Icons.timelapse),
            ('Cancelados', '${stats.pedidosCancelados}', Icons.cancel),
            (
              'Demora prom.',
              '${stats.promedioDemora.toStringAsFixed(1)} min',
              Icons.timer
            ),
            ('Mesas libres', '${stats.mesasLibres}', Icons.event_available),
            ('Mesas ocupadas', '${stats.mesasOcupadas}', Icons.event_busy),
            ('Mesas inactivas', '${stats.mesasInactivas}', Icons.block),
            (
              'Ingresos',
              '\$${stats.ingresosTotales.toStringAsFixed(2)}',
              Icons.attach_money
            ),
            ('Pagados', '${stats.pedidosPagados}', Icons.payments),
            (
              'Ticket prom.',
              '\$${stats.ticketPromedio.toStringAsFixed(2)}',
              Icons.receipt_long
            ),
          ];

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final item = cards[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.$3),
                      const Spacer(),
                      Text(
                        item.$2,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(item.$1),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
