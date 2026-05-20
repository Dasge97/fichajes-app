class MonthlySummary {
  const MonthlySummary({
    required this.label,
    required this.jornadasFichadas,
    required this.trabajado,
    required this.previsto,
    required this.saldo,
    required this.ausenciasAprobadas,
  });

  /// Ej: "Mayo 2026"
  final String label;
  final int jornadasFichadas;
  final Duration trabajado;
  final Duration previsto;

  /// Positivo = extra, negativo = déficit
  final Duration saldo;
  final int ausenciasAprobadas;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    final periodo = json['periodo'] is Map<String, dynamic>
        ? json['periodo'] as Map<String, dynamic>
        : <String, dynamic>{};
    return MonthlySummary(
      label: (periodo['label'] as String?) ?? '',
      jornadasFichadas: (json['jornadasFichadas'] as num?)?.toInt() ?? 0,
      trabajado: Duration(seconds: (json['trabajadoSegundos'] as num?)?.toInt() ?? 0),
      previsto: Duration(seconds: (json['previstoSegundos'] as num?)?.toInt() ?? 0),
      saldo: Duration(seconds: (json['saldoSegundos'] as num?)?.toInt() ?? 0),
      ausenciasAprobadas: (json['ausenciasAprobadas'] as num?)?.toInt() ?? 0,
    );
  }
}
