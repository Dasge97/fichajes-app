import '../../../core/network/api_client.dart';
import '../domain/profile_models.dart';

class ProfileRepository {
  const ProfileRepository(this._apiClient);

  final ApiClient _apiClient;

  /// GET /api/v1/mobile/resumen?fecha=YYYY-MM
  /// Si [fecha] es null se usa el mes actual.
  Future<MonthlySummary> fetchResumen({String? fecha}) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/mobile/resumen',
      queryParameters: fecha != null ? {'fecha': fecha} : null,
    );
    return MonthlySummary.fromJson(response.data ?? {});
  }
}
