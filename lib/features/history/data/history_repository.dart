import '../../../core/network/api_client.dart';
import '../domain/history_models.dart';

class HistoryRepository {
  const HistoryRepository(this._apiClient);

  final ApiClient _apiClient;

  /// GET /api/v1/mobile/historial/semana?fecha=YYYY-MM-DD
  /// Si [fecha] es null se usa la semana actual.
  Future<List<WeekDayData>> fetchWeekData({String? fecha}) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/mobile/historial/semana',
      queryParameters: fecha != null ? {'fecha': fecha} : null,
    );
    final data = response.data ?? {};
    final dias = data['dias'] is List ? data['dias'] as List : [];
    return dias
        .whereType<Map<String, dynamic>>()
        .map(WeekDayData.fromJson)
        .toList();
  }

  /// GET /api/v1/mobile/fichajes/historial?fecha=YYYY-MM-DD
  /// Para "hoy" pasa fecha='today' o la fecha ISO.
  Future<DayHistory> fetchDayHistory(String fecha) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/mobile/fichajes/historial',
      queryParameters: {'fecha': fecha},
    );
    final data = response.data ?? {};
    return DayHistory.fromJson(data);
  }
}
