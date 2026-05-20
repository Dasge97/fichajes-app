import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../data/auth_repository.dart';
import '../domain/session.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._repository);

  final AuthRepository _repository;

  Session? _session;
  bool _loading = false;
  String? _error;

  Session? get session => _session;
  bool get isAuthenticated => _session != null;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> restoreSession() async {
    try {
      _session = await _repository.restoreSession();
    } catch (_) {
      _session = null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _session = await _repository.login(email: email, password: password);
    } on DioException catch (e) {
      _error = _mensajeLogin(e);
    } on StateError catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error inesperado al iniciar sesion: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String _mensajeLogin(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401) {
      return 'Credenciales incorrectas (401). Revisa email y password.';
    }
    if (status == 403) {
      final data = e.response?.data;
      if (data is Map && data['codigo'] == 'USUARIO_SIN_TRABAJADOR_MOVIL') {
        return 'Este usuario no tiene trabajador vinculado para usar la app movil.';
      }
      return 'Acceso denegado (403). Revisa permisos o estado de la cuenta.';
    }
    if (status != null) {
      return 'El backend respondio con HTTP $status.';
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout => 'No conecta con el backend: timeout.',
      DioExceptionType.receiveTimeout => 'El backend tarda demasiado en responder.',
      DioExceptionType.connectionError => 'No conecta con el backend. Revisa API_BASE_URL y Symfony.',
      DioExceptionType.badCertificate => 'Certificado no valido.',
      DioExceptionType.cancel => 'Peticion cancelada.',
      _ => 'No se pudo iniciar sesion: ${e.message}',
    };
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {
      // La salida local no debe bloquear la vuelta al login.
    }
    _session = null;
    notifyListeners();
  }
}
