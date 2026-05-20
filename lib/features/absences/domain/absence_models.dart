class AbsenceBalance {
  const AbsenceBalance({
    required this.configurado,
    this.total,
    this.disponibles,
    required this.disfrutados,
    required this.pendientes,
  });

  final bool configurado;
  final int? total;
  final int? disponibles;
  final int disfrutados;
  final int pendientes;

  factory AbsenceBalance.fromJson(Map<String, dynamic> json) {
    final total = (json['total'] as num?)?.toInt();
    final disponibles = (json['disponibles'] as num?)?.toInt();
    return AbsenceBalance(
      configurado: (json['configurado'] as bool?) ?? (total != null && total > 0),
      total: total,
      disponibles: disponibles,
      disfrutados: (json['disfrutados'] as num?)?.toInt() ?? 0,
      pendientes: (json['pendientes'] as num?)?.toInt() ?? 0,
    );
  }

  factory AbsenceBalance.empty() => const AbsenceBalance(
        configurado: false,
        disfrutados: 0,
        pendientes: 0,
      );
}

class AbsenceItem {
  const AbsenceItem({
    required this.id,
    required this.tipo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    this.motivo,
    required this.diasSolicitados,
  });

  final String id;
  final String tipo;
  final String fechaInicio;
  final String fechaFin;

  /// pendiente | aprobada | rechazada
  final String estado;
  final String? motivo;
  final int diasSolicitados;

  factory AbsenceItem.fromJson(Map<String, dynamic> json) {
    return AbsenceItem(
      id: (json['id'] as String?) ?? '',
      tipo: (json['tipo'] as String?) ?? 'Ausencia',
      fechaInicio: (json['fechaInicio'] as String?) ?? '',
      fechaFin: (json['fechaFin'] as String?) ?? '',
      estado: (json['estado'] as String?) ?? 'pendiente',
      motivo: json['motivo'] as String?,
      diasSolicitados: (json['diasSolicitados'] as num?)?.toInt() ?? 1,
    );
  }
}
