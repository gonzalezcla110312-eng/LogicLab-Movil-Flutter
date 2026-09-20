import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/exceptions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models.dart';
import '../restaurant_providers.dart';

class CreateOrderPage extends ConsumerStatefulWidget {
  final Mesa mesa;
  final Pedido? pedido;

  const CreateOrderPage({
    super.key,
    required this.mesa,
    this.pedido,
  });

  @override
  ConsumerState<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends ConsumerState<CreateOrderPage> {
  final Map<int, int> cantidades = {};
  final Map<int, String> notas = {};
  bool saving = false;

  bool get isEditing => widget.pedido != null;

  @override
  void initState() {
    super.initState();
    final pedido = widget.pedido;
    if (pedido != null) {
      for (final d in pedido.detalles) {
        if (d.platilloId > 0) {
          cantidades[d.platilloId] = d.cantidad;
          if (d.notas.isNotEmpty) {
            notas[d.platilloId] = d.notas;
          }
        }
      }
    }
  }

  Future<void> _guardar() async {
    final user = ref.read(authProvider).usuario;
    if (user == null) return;

    final items = cantidades.entries
        .where((e) => e.value > 0)
        .map(
          (e) => {
            'platillo_id': e.key,
            'cantidad': e.value,
            'notas': notas[e.key] ?? '',
          },
        )
        .toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un platillo')),
      );
      return;
    }

    setState(() => saving = true);
    try {
      final api = ref.read(restaurantApiProvider);
      if (isEditing) {
        await api.actualizarPedido(
          pedidoId: widget.pedido!.id,
          items: items,
        );
      } else {
        await api.crearPedido(
          mesaId: widget.mesa.id,
          usuarioId: user.id,
          items: items,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Pedido actualizado' : 'Pedido creado'),
        ),
      );
      Navigator.of(context).pop(true);
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
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuHoyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Editar · Mesa ${widget.mesa.numero}'
              : 'Pedido · Mesa ${widget.mesa.numero}',
        ),
      ),
      body: menuAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$e', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(menuHoyProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No hay platillos disponibles'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              final qty = cantidades[item.platilloId] ?? 0;
              return ListTile(
                title: Text(item.nombre),
                subtitle: Text(
                  item.descripcion.isEmpty
                      ? '\$${item.precio.toStringAsFixed(2)}'
                      : '${item.descripcion}\n\$${item.precio.toStringAsFixed(2)}',
                ),
                isThreeLine: item.descripcion.isNotEmpty,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: qty <= 0
                          ? null
                          : () => setState(() {
                                cantidades[item.platilloId] = qty - 1;
                              }),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$qty'),
                    IconButton(
                      onPressed: () => setState(() {
                        cantidades[item.platilloId] = qty + 1;
                      }),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: saving ? null : _guardar,
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(isEditing ? Icons.save : Icons.send),
            label: Text(
              saving
                  ? 'Guardando...'
                  : isEditing
                      ? 'Guardar cambios'
                      : 'Crear pedido',
            ),
          ),
        ),
      ),
    );
  }
}
