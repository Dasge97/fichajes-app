import '../../../core/network/api_client.dart';
import '../domain/absence_models.dart';

class AbsencesRepository {
  const AbsencesRepository(this._apiClient);

  final ApiClient _apiClient;

  /// GET /api/v1/mobile/ausencias
  /// Returns (balance, items)
  Future<(AbsenceBalance, List<AbsenceItem>)> fetchAusencias() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/mobile/ausencias',
    );
    final data = response.data ?? {};

    final balanceJson = data['saldoVacaciones'] is Map<String, dynamic>
        ? data['saldoVacaciones'] as Map<String, dynamic>
        : <String, dynamic>{};
    final balance = balanceJson.isNotEmpty
        ? AbsenceBalance.fromJson(balanceJson)
        : AbsenceBalance.empty();

    final itemsList = data['items'] is List ? data['items'] as List : [];
    final items = itemsList
        .whereType<Map<String, dynamic>>()
        .map(AbsenceItem.fromJson)
        .toList();

    return (balance, items);
  }

  /// POST /api/v1/mobile/ausencias
  Future<void> crearAusencia({
    required String tipo,
    required String fechaInicio,
    required String fechaFin,
    String? motivo,
  }) async {
    await _apiClient.dio.post<void>(
      '/api/v1/mobile/ausencias',
      data: {
        'tipo': tipo,
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
        if (motivo != null && motivo.isNotEmpty) 'motivo': motivo,
      },
    );
  }
}
