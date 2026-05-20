class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.cuerpo,
    required this.leida,
    required this.creadaEn,
  });

  final String id;

  /// "olvido_salida" | "ausencia_resuelta" | "cambio_horario" | "pausa_larga" | "nuevo_dispositivo"
  final String tipo;
  final String titulo;
  final String cuerpo;
  final bool leida;
  final DateTime creadaEn;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: (json['id'] as String?) ?? '',
      tipo: (json['tipo'] as String?) ?? '',
      titulo: (json['titulo'] as String?) ?? '',
      cuerpo: (json['cuerpo'] as String?) ?? '',
      leida: (json['leida'] as bool?) ?? false,
      creadaEn: DateTime.tryParse((json['creadaEn'] as String?) ?? '') ?? DateTime.now(),
    );
  }
}
