import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/network/api_client.dart';
import '../domain/session.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  static const _emailKey        = 'session_email';
  static const _tokenKey        = 'session_token';
  static const _displayNameKey  = 'session_display_name';
  static const _inicialesKey    = 'session_iniciales';
  static const _tenantIdKey     = 'session_tenant_id';
  static const _trabajadorIdKey = 'session_trabajador_id';
  static const _puestoKey       = 'session_puesto';
  static const _codigoEmpleadoKey = 'session_codigo_empleado';
  static const _centroIdKey     = 'session_centro_id';
  static const _horasSemanaKey  = 'session_horas_semana';

  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Session> login({required String email, required String password}) async {
    final response = await _apiClient.dio.post<Map<String, dynamic>>(
      '/api/v1/login',
      data: {'email': email, 'password': password},
    );

    final data      = response.data ?? {};
    final usuario   = data['usuario']   is Map<String, dynamic> ? data['usuario']   as Map<String, dynamic> : <String, dynamic>{};
    final trabajador = data['trabajador'] is Map<String, dynamic> ? data['trabajador'] as Map<String, dynamic> : <String, dynamic>{};

    final session = Session(
      email:             (usuario['email']           as String?)  ?? email,
      token:              data['token']              as String?,
      displayName:        trabajador['nombre']       as String?,
      iniciales:          trabajador['iniciales']    as String?,
      tenantId:           usuario['tenantId']        as String?,
      trabajadorId:       trabajador['trabajadorId'] as String?,
      puesto:             trabajador['puesto']       as String?,
      codigoEmpleado:     trabajador['codigoEmpleado'] as String?,
      centroId:           trabajador['centroId']     as String?,
      horasSemana:        (trabajador['horasSemana'] as num?)?.toInt(),
      notificacionesSinLeer: (data['notificacionesSinLeer'] as num?)?.toInt() ?? 0,
    );

    if (session.token == null || session.trabajadorId == null) {
      throw StateError('Este usuario no tiene un trabajador vinculado para usar la app movil.');
    }

    _apiClient.setBearerToken(session.token);
    await _storage.write(key: _emailKey,           value: session.email);
    await _storage.write(key: _tokenKey,           value: session.token);
    await _storage.write(key: _displayNameKey,     value: session.displayName);
    await _storage.write(key: _inicialesKey,       value: session.iniciales);
    await _storage.write(key: _tenantIdKey,        value: session.tenantId);
    await _storage.write(key: _trabajadorIdKey,    value: session.trabajadorId);
    await _storage.write(key: _puestoKey,          value: session.puesto);
    await _storage.write(key: _codigoEmpleadoKey,  value: session.codigoEmpleado);
    await _storage.write(key: _centroIdKey,        value: session.centroId);
    await _storage.write(key: _horasSemanaKey,     value: session.horasSemana?.toString());

    return session;
  }

  Future<Session?> restoreSession() async {
    final email = await _storage.read(key: _emailKey);
    if (email == null || email.isEmpty) return null;

    final session = Session(
      email:          email,
      token:          await _storage.read(key: _tokenKey),
      displayName:    await _storage.read(key: _displayNameKey),
      iniciales:      await _storage.read(key: _inicialesKey),
      tenantId:       await _storage.read(key: _tenantIdKey),
      trabajadorId:   await _storage.read(key: _trabajadorIdKey),
      puesto:         await _storage.read(key: _puestoKey),
      codigoEmpleado: await _storage.read(key: _codigoEmpleadoKey),
      centroId:       await _storage.read(key: _centroIdKey),
      horasSemana:    int.tryParse(await _storage.read(key: _horasSemanaKey) ?? ''),
    );
    _apiClient.setBearerToken(session.token);
    return session;
  }

  Future<void> logout() async {
    _apiClient.setBearerToken(null);
    await _storage.deleteAll();
  }
}
