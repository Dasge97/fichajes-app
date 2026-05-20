import '../../../core/network/api_client.dart';
import '../domain/notification_model.dart';

class NotificationsRepository {
  const NotificationsRepository(this._apiClient);

  final ApiClient _apiClient;

  /// GET /api/v1/mobile/notificaciones?filtro=todas|sin_leer|acciones
  /// Devuelve (sinLeer, lista).
  Future<(int sinLeer, List<NotificationItem> items)> fetchNotificaciones({
    String filtro = 'todas',
  }) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/mobile/notificaciones',
      queryParameters: {'filtro': filtro},
    );
    final data = response.data ?? {};
    final sinLeer = (data['sinLeer'] as num?)?.toInt() ?? 0;
    final lista = data['items'] is List ? data['items'] as List : [];
    final items = lista
        .whereType<Map<String, dynamic>>()
        .map(NotificationItem.fromJson)
        .toList();
    return (sinLeer, items);
  }

  /// PATCH /api/v1/mobile/notificaciones/:id/leer
  Future<void> marcarLeida(String id) async {
    await _apiClient.dio.patch<void>('/api/v1/mobile/notificaciones/$id/leer');
  }

  /// DELETE /api/v1/mobile/notificaciones
  Future<void> limpiarTodas() async {
    await _apiClient.dio.delete<void>('/api/v1/mobile/notificaciones');
  }
}
