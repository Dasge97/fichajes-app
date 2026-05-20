enum WorkdayStatus {
  notStarted,
  working,
  paused,
  finished,
}

extension WorkdayStatusLabel on WorkdayStatus {
  String get label {
    return switch (this) {
      WorkdayStatus.notStarted => 'Sin iniciar',
      WorkdayStatus.working => 'En jornada',
      WorkdayStatus.paused => 'En pausa',
      WorkdayStatus.finished => 'Jornada finalizada',
    };
  }
}

enum ClockingAction {
  start,
  pause,
  resume,
  finish,
}

extension ClockingActionLabel on ClockingAction {
  String get label {
    return switch (this) {
      ClockingAction.start => 'Iniciar jornada',
      ClockingAction.pause => 'Pausar',
      ClockingAction.resume => 'Reanudar',
      ClockingAction.finish => 'Finalizar jornada',
    };
  }

  String get apiType {
    return switch (this) {
      ClockingAction.start => 'clock-in',
      ClockingAction.pause => 'pause-start',
      ClockingAction.resume => 'pause-end',
      ClockingAction.finish => 'clock-out',
    };
  }
}

class ClockingSummary {
  const ClockingSummary({
    required this.status,
    required this.workedToday,
    required this.fetchedAt,
    this.targetToday = Duration.zero,
    this.pausasToday = Duration.zero,
    this.eventsToday = const [],
    this.nextSlot,
    this.employeeId,
    this.employeeName,
  });

  final WorkdayStatus status;
  final Duration workedToday;
  final DateTime fetchedAt;
  final Duration targetToday;
  final Duration pausasToday;
  final List<ClockingEvent> eventsToday;
  final ClockingNextSlot? nextSlot;
  final String? employeeId;
  final String? employeeName;

  List<ClockingAction> get availableActions {
    return switch (status) {
      WorkdayStatus.notStarted => [ClockingAction.start],
      WorkdayStatus.working => [ClockingAction.pause, ClockingAction.finish],
      WorkdayStatus.paused => [ClockingAction.resume, ClockingAction.finish],
      WorkdayStatus.finished => [ClockingAction.start],
    };
  }
}

class ClockingEvent {
  const ClockingEvent({
    required this.type,
    required this.occurredAt,
    this.compliance,
    this.reason,
  });

  final String type;
  final DateTime occurredAt;
  final String? compliance;
  final String? reason;
}

class ClockingNextSlot {
  const ClockingNextSlot({
    required this.name,
    required this.start,
    required this.end,
  });

  final String name;
  final String start;
  final String end;
}
