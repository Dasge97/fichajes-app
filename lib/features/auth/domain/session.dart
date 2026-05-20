class Session {
  const Session({
    required this.email,
    this.token,
    this.displayName,
    this.iniciales,
    this.tenantId,
    this.trabajadorId,
    this.puesto,
    this.codigoEmpleado,
    this.centroId,
    this.horasSemana,
    this.notificacionesSinLeer = 0,
  });

  final String email;
  final String? token;
  final String? displayName;
  final String? iniciales;
  final String? tenantId;
  final String? trabajadorId;
  final String? puesto;
  final String? codigoEmpleado;
  final String? centroId;
  final int? horasSemana;
  final int notificacionesSinLeer;
}
