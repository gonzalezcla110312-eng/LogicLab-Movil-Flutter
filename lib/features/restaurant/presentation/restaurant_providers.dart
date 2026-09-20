import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_provider.dart';
import '../data/models.dart';
import '../data/restaurant_api.dart';

final restaurantApiProvider = Provider<RestaurantApi>((ref) {
  return RestaurantApi(ref.watch(dioProvider));
});

final mesasProvider = FutureProvider.autoDispose<List<Mesa>>((ref) {
  return ref.watch(restaurantApiProvider).getMesas();
});

final menuHoyProvider = FutureProvider.autoDispose<List<MenuItem>>((ref) {
  return ref.watch(restaurantApiProvider).getMenuHoy();
});

final cocinaPedidosProvider =
    FutureProvider.autoDispose<List<Pedido>>((ref) {
  return ref.watch(restaurantApiProvider).getPedidosCocina();
});

final adminStatsProvider = FutureProvider.autoDispose<AdminStats>((ref) {
  return ref.watch(restaurantApiProvider).getAdminStats();
});
