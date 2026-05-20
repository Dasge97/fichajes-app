import '../../../core/network/api_client.dart';
import '../domain/clocking_state.dart';

class ClockingRepository {
  ClockingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<ClockingSummary> fetchSummary() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/mobile/fichajes/estado',
    );
    final data = response.data ?? {};
    final trabajador = data['trabajador'] is Map<String, dynamic>
        ? data['trabajador'] as Map<String, dynamic>
        : <String, dynamic>{};
    final eventos = data['eventosHoy'] is List
        ? (data['eventosHoy'] as List)
            .whereType<Map<String, dynamic>>()
            .map(_eventFromJson)
            .toList()
        : <ClockingEvent>[];
    final proximoTramo = data['proximoTramo'] is Map<String, dynamic>
        ? data['proximoTramo'] as Map<String, dynamic>
        : null;

    return ClockingSummary(
      status: _statusFromApi(data['estado'] as String?),
      workedToday: Duration(seconds: (data['trabajadoSegundos'] as num?)?.toInt() ?? 0),
      fetchedAt: DateTime.now(),
      targetToday: Duration(seconds: (data['objetivoSegundos'] as num?)?.toInt() ?? 0),
      pausasToday: Duration(seconds: (data['pausasSegundos'] as num?)?.toInt() ?? 0),
      eventsToday: eventos,
      nextSlot: proximoTramo == null
          ? null
          : ClockingNextSlot(
              name: (proximoTramo['nombre'] as String?) ?? 'Horario',
              start: (proximoTramo['inicio'] as String?) ?? '',
              end: (proximoTramo['fin'] as String?) ?? '',
            ),
      employeeId: trabajador['trabajadorId'] as String?,
      employeeName: trabajador['nombre'] as String?,
    );
  }

  Future<void> registerAction({
    required String employeeId,
    required ClockingAction action,
  }) async {
    await _apiClient.dio.post(
      '/api/v1/mobile/fichajes/eventos',
      data: {
        'empleadoId': employeeId,
        'tipo': action.apiType,
        'ocurridoEn': DateTime.now().toIso8601String(),
        'politica': 'marcar',
        'idempotencyKey': 'mobile-${DateTime.now().microsecondsSinceEpoch}',
      },
    );
  }

  WorkdayStatus _statusFromApi(String? value) {
    return switch (value) {
      'working' => WorkdayStatus.working,
      'paused' => WorkdayStatus.paused,
      'finished' => WorkdayStatus.finished,
      _ => WorkdayStatus.notStarted,
    };
  }

  ClockingEvent _eventFromJson(Map<String, dynamic> json) {
    return ClockingEvent(
      type: (json['tipo'] as String?) ?? '',
      occurredAt: DateTime.tryParse((json['ocurridoEn'] as String?) ?? '') ?? DateTime.now(),
      compliance: json['estadoCumplimiento'] as String?,
      reason: json['motivoDesvio'] as String?,
    );
  }
}
