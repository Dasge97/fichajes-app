import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../data/clocking_repository.dart';
import '../domain/clocking_state.dart';

class ClockingController extends ChangeNotifier {
  ClockingController(this._repository);

  final ClockingRepository _repository;

  ClockingSummary? _summary;
  bool _loading = false;
  String? _message;
  String? _error;

  ClockingSummary? get summary => _summary;
  bool get loading => _loading;
  String? get message => _message;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _summary = await _repository.fetchSummary();
    } on DioException catch (e) {
      _error = _messageFromDio(e);
    } catch (e) {
      _error = 'No se pudo cargar el fichaje: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(ClockingAction action) async {
    final employeeId = _summary?.employeeId;
    if (employeeId == null) {
      _message = 'No hay empleado vinculado.';
      notifyListeners();
      return;
    }

    _loading = true;
    _message = null;
    _error = null;
    notifyListeners();

    try {
      await _repository.registerAction(employeeId: employeeId, action: action);
      _message = 'Accion registrada.';
      _summary = await _repository.fetchSummary();
    } on DioException catch (e) {
      _error = _messageFromDio(e);
    } catch (e) {
      _error = 'No se pudo registrar la accion: $e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String _messageFromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map && data['codigo'] != null) {
      return '${data['codigo']}';
    }
    if (status != null) {
      return 'Backend HTTP $status';
    }
    return switch (e.type) {
      DioExceptionType.connectionTimeout => 'No conecta con el backend: timeout.',
      DioExceptionType.receiveTimeout => 'El backend tarda demasiado en responder.',
      DioExceptionType.connectionError => 'No conecta con el backend. Revisa Symfony y API_BASE_URL.',
      _ => 'Error de red: ${e.message}',
    };
  }
}
