import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../restaurant/presentation/pages/admin_page.dart';
import '../../../restaurant/presentation/pages/cocina_page.dart';
import '../../../restaurant/presentation/pages/mesero_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.usuario;
    final role = (user?.role ?? '').toLowerCase();
    final fullName = [
      user?.name,
      user?.lastName,
    ].where((e) => e != null && e.trim().isNotEmpty).join(' ');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(fullName.isEmpty ? 'Dashboard' : fullName),
            Text(
              _roleLabel(role),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: switch (role) {
        'mesero' => const MeseroPage(),
        'cocinero' => const CocinaPage(),
        'administrador' => const AdminPage(),
        _ => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Rol no soportado: ${user?.role ?? 'desconocido'}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
      },
    );
  }

  String _roleLabel(String role) {
    return switch (role) {
      'mesero' => 'Mesero',
      'cocinero' => 'Cocina',
      'administrador' => 'Administrador',
      _ => role.isEmpty ? 'Sin rol' : role,
    };
  }
}
