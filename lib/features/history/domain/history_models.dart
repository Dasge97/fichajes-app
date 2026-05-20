class WeekDayData {
  const WeekDayData({
    required this.fecha,
    required this.diaSemana,
    required this.tipo,
    required this.hoy,
    required this.trabajado,
    required this.previsto,
    required this.tieneFichajes,
    this.inicio,
    this.fin,
  });

  /// "2026-05-14"
  final String fecha;

  /// 1=L ... 7=D
  final int diaSemana;

  /// "trabajo" | "descanso" | "ausencia" | "futuro"
  final String tipo;

  final bool hoy;
  final Duration trabajado;
  final Duration previsto;
  final bool tieneFichajes;
  final String? inicio;
  final String? fin;

  factory WeekDayData.fromJson(Map<String, dynamic> json) {
    return WeekDayData(
      fecha: (json['fecha'] as String?) ?? '',
      diaSemana: (json['diaSemana'] as num?)?.toInt() ?? 1,
      tipo: (json['tipo'] as String?) ?? 'futuro',
      hoy: (json['hoy'] as bool?) ?? false,
      trabajado: Duration(seconds: (json['trabajadoSegundos'] as num?)?.toInt() ?? 0),
      previsto: Duration(seconds: (json['previstosSegundos'] as num?)?.toInt() ?? 0),
      tieneFichajes: (json['tieneFichajes'] as bool?) ?? false,
      inicio: json['inicio'] as String?,
      fin: json['fin'] as String?,
    );
  }
}

class HistoryEvent {
  const HistoryEvent({
    required this.id,
    required this.tipo,
    required this.ocurridoEn,
    this.estadoCumplimiento,
    this.motivoDesvio,
    this.centroId,
    this.metodoRegistro,
  });

  final String id;

  /// "clock-in" | "pause-start" | "pause-end" | "clock-out"
  final String tipo;

  final DateTime ocurridoEn;
  final String? estadoCumplimiento;
  final String? motivoDesvio;
  final String? centroId;
  final String? metodoRegistro;

  factory HistoryEvent.fromJson(Map<String, dynamic> json) {
    return HistoryEvent(
      id: (json['id'] as String?) ?? '',
      tipo: (json['tipo'] as String?) ?? '',
      ocurridoEn: DateTime.tryParse((json['ocurridoEn'] as String?) ?? '') ?? DateTime.now(),
      estadoCumplimiento: json['estadoCumplimiento'] as String?,
      motivoDesvio: json['motivoDesvio'] as String?,
      centroId: json['centroId'] as String?,
      metodoRegistro: json['metodoRegistro'] as String?,
    );
  }
}

class DayHistory {
  const DayHistory({
    required this.fecha,
    required this.trabajado,
    required this.pausas,
    required this.previsto,
    required this.eventos,
    this.estado,
  });

  final String fecha;
  final Duration trabajado;
  final Duration pausas;
  final Duration previsto;
  final List<HistoryEvent> eventos;

  /// "activa" | "finalizada" | "ausencia" | etc.
  final String? estado;

  factory DayHistory.fromJson(Map<String, dynamic> json) {
    final eventos = json['eventos'] is List
        ? (json['eventos'] as List)
            .whereType<Map<String, dynamic>>()
            .map(HistoryEvent.fromJson)
            .toList()
        : <HistoryEvent>[];
    return DayHistory(
      fecha: (json['fecha'] as String?) ?? '',
      trabajado: Duration(seconds: (json['trabajadoSegundos'] as num?)?.toInt() ?? 0),
      pausas: Duration(seconds: (json['pausasSegundos'] as num?)?.toInt() ?? 0),
      previsto: Duration(seconds: (json['previstosSegundos'] as num?)?.toInt() ?? 0),
      eventos: eventos,
      estado: json['estado'] as String?,
    );
  }
}
