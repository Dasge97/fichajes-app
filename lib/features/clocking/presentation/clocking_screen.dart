import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/entro_theme.dart';
import '../../../core/widgets/entro_widgets.dart';
import '../domain/clocking_state.dart';
import 'clocking_controller.dart';

class ClockingScreen extends StatefulWidget {
  const ClockingScreen({super.key});

  @override
  State<ClockingScreen> createState() => _ClockingScreenState();
}

class _ClockingScreenState extends State<ClockingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final summary = context.read<ClockingController>().summary;
      if (summary?.status == WorkdayStatus.working && mounted) {
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClockingController>().load();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ClockingController>();
    final summary = controller.summary;

    if (controller.loading && summary == null) {
      return const EntroScaffold(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (summary == null) {
      return EntroScaffold(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 42, color: EntroColors.mute),
              const SizedBox(height: 14),
              Text(
                controller.error ?? 'No se pudo cargar el estado de fichaje.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: EntroColors.mute),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => context.read<ClockingController>().load(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return EntroScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.status == WorkdayStatus.finished
                          ? 'Hasta manana, ${_firstName(summary.employeeName)}'
                          : 'Hola, ${_firstName(summary.employeeName)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _dateLabel(DateTime.now()),
                      style: TextStyle(color: EntroColors.mute, fontSize: 13),
                    ),
                  ],
                ),
                EntroAvatar(
                  initials: _initials(summary.employeeName),
                  showAlert: summary.status == WorkdayStatus.notStarted,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _HeroTimer(summary: summary),
            const SizedBox(height: 20),
            _ActionButtons(summary: summary, loading: controller.loading),
            const SizedBox(height: 12),
            _NextSlot(summary: summary),
            if (controller.message != null) ...[
              const SizedBox(height: 12),
              _FeedbackToast(message: controller.message!),
            ],
            if (controller.error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: controller.error!),
            ],
            _TodayMiniHistory(summary: summary),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return EntroCard(
      color: EntroColors.dangerBg,
      borderColor: const Color(0xFFF3CCCC),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: EntroColors.dangerInk, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: EntroColors.dangerInk, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTimer extends StatelessWidget {
  const _HeroTimer({required this.summary});

  final ClockingSummary summary;

  @override
  Widget build(BuildContext context) {
    final status = summary.status;
    final worked = _liveWorked(summary);
    final live = _formatClock(worked);
    final today = formatDurationCompact(worked);

    return EntroCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              EntroPill(label: status.label, tone: _toneFor(status)),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 14, color: EntroColors.mute),
                  const SizedBox(width: 6),
                  Text(
                    _timeLabel(DateTime.now()),
                    style: const TextStyle(
                      color: EntroColors.mute,
                      fontSize: 11.5,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            live,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 52,
              height: 1,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
              color: status == WorkdayStatus.paused
                  ? EntroColors.warningInk
                  : EntroColors.ink,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HOY',
                    style: TextStyle(
                      color: EntroColors.mute,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      text: today,
                      children: [
                        TextSpan(
                          text: summary.targetToday == Duration.zero
                              ? ''
                              : ' / ${formatDurationCompact(summary.targetToday)}',
                          style: const TextStyle(
                            color: EntroColors.mute,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              _Progress(summary: summary),
            ],
          ),
        ],
      ),
    );
  }

  String _formatClock(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.summary});

  final ClockingSummary summary;

  @override
  Widget build(BuildContext context) {
    final status = summary.status;
    final pct = summary.targetToday == Duration.zero
        ? 0.0
        : (_liveWorked(summary).inSeconds / summary.targetToday.inSeconds).clamp(0.0, 1.0);
    final color = switch (summary.status) {
      WorkdayStatus.paused => EntroColors.warning,
      WorkdayStatus.finished => EntroColors.success,
      _ => EntroColors.ink,
    };

    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              color: color,
              backgroundColor: EntroColors.border,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(pct * 100).round()}%',
            style: const TextStyle(
              color: EntroColors.mute,
              fontFamily: 'monospace',
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.summary, required this.loading});

  final ClockingSummary summary;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final actions = summary.availableActions;
    final primary = actions.first;
    final finish = actions.contains(ClockingAction.finish)
        ? ClockingAction.finish
        : null;
    final isFinished = summary.status == WorkdayStatus.finished;

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _primaryCallback(context, isFinished, loading, primary),
          icon: Icon(
              isFinished ? Icons.chevron_right_rounded : _iconFor(primary),
              size: 18),
          label: Text(isFinished ? 'Ver resumen' : primary.label),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: isFinished || primary == ClockingAction.finish
                ? EntroColors.surface
                : EntroColors.ink,
            foregroundColor: isFinished || primary == ClockingAction.finish
                ? EntroColors.ink
                : Colors.white,
            side: isFinished || primary == ClockingAction.finish
                ? const BorderSide(color: EntroColors.borderStrong)
                : BorderSide.none,
          ),
        ),
        if (finish != null && primary != finish) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: loading
                ? null
                : () => context.read<ClockingController>().register(finish),
            icon: const Icon(Icons.stop_rounded, size: 16),
            label: const Text('Finalizar jornada'),
            style:
                OutlinedButton.styleFrom(foregroundColor: EntroColors.danger),
          ),
        ],
      ],
    );
  }

  VoidCallback? _primaryCallback(
    BuildContext context,
    bool isFinished,
    bool loading,
    ClockingAction primary,
  ) {
    if (isFinished) {
      return () {};
    }
    if (loading) {
      return null;
    }
    return () => context.read<ClockingController>().register(primary);
  }
}

class _NextSlot extends StatelessWidget {
  const _NextSlot({required this.summary});

  final ClockingSummary summary;

  @override
  Widget build(BuildContext context) {
    final status = summary.status;
    final slot = summary.nextSlot;
    final cfg = switch (status) {
      WorkdayStatus.notStarted => (
          EntroColors.infoBg,
          EntroColors.ink,
          Icons.schedule_rounded,
          slot == null ? 'Sin horario asignado para hoy' : 'Tu turno empieza a las ${slot.start}',
          slot == null ? 'Consulta con tu responsable' : '${slot.name} · ${slot.start}-${slot.end}'
        ),
      WorkdayStatus.working => (
          EntroColors.warningBg,
          EntroColors.warningInk,
          Icons.pause_rounded,
          slot == null ? 'Jornada en curso' : 'Horario de hoy hasta las ${slot.end}',
          slot == null ? 'Sin tramo asignado' : slot.name
        ),
      WorkdayStatus.paused => (
          Colors.white,
          EntroColors.warningInk,
          Icons.schedule_rounded,
          _lastEventText(summary, 'pause-start') ?? 'En pausa',
          slot == null ? 'Sin tramo asignado' : 'Horario de hoy hasta las ${slot.end}'
        ),
      WorkdayStatus.finished => (
          Colors.white,
          EntroColors.successInk,
          Icons.check_rounded,
          _lastEventText(summary, 'clock-out') ?? 'Jornada cerrada',
          'Total trabajado: ${formatDurationCompact(summary.workedToday)}'
        ),
    };

    final cardColor = switch (status) {
      WorkdayStatus.paused => EntroColors.warningBg,
      WorkdayStatus.finished => EntroColors.successBg,
      _ => EntroColors.surface,
    };
    final border = switch (status) {
      WorkdayStatus.paused => const Color(0xFFF0E1C5),
      WorkdayStatus.finished => const Color(0xFFD5ECDF),
      _ => EntroColors.border,
    };

    return EntroCard(
      color: cardColor,
      borderColor: border,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cfg.$1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(cfg.$3, color: cfg.$2, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cfg.$4,
                  style: TextStyle(
                    color: cfg.$2,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cfg.$5,
                  style: TextStyle(
                      color: cfg.$2.withOpacity(0.75), fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayMiniHistory extends StatelessWidget {
  const _TodayMiniHistory({required this.summary});

  final ClockingSummary summary;

  @override
  Widget build(BuildContext context) {
    final events = summary.eventsToday.map(_eventFromApi).toList();

    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hoy',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  'Ver historial completo',
                  style: TextStyle(color: EntroColors.mute, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          EntroCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < events.length; i++)
                  _MiniEventRow(event: events[i], last: i == events.length - 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniEventRow extends StatelessWidget {
  const _MiniEventRow({required this.event, required this.last});

  final _MiniEvent event;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: last
              ? BorderSide.none
              : const BorderSide(color: EntroColors.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: event.bg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(event.icon, color: event.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event.label,
              style:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            event.time,
            style: const TextStyle(
              color: EntroColors.mute,
              fontSize: 11.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackToast extends StatelessWidget {
  const _FeedbackToast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EntroColors.ink,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_rounded,
                color: Color(0xFF86EFAC), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniEvent {
  const _MiniEvent(this.time, this.label, this.icon, this.bg, this.color);

  final String time;
  final String label;
  final IconData icon;
  final Color bg;
  final Color color;
}

_MiniEvent _eventFromApi(ClockingEvent event) {
  final hour = event.occurredAt.toLocal().toString().substring(11, 16);
  return switch (event.type) {
    'clock-in' => _MiniEvent(hour, 'Entrada', Icons.login_rounded, EntroColors.successBg, EntroColors.successInk),
    'pause-start' => _MiniEvent(hour, 'Pausa', Icons.pause_rounded, EntroColors.warningBg, EntroColors.warningInk),
    'pause-end' => _MiniEvent(hour, 'Reanudacion', Icons.play_arrow_rounded, EntroColors.successBg, EntroColors.successInk),
    'clock-out' => _MiniEvent(hour, 'Salida', Icons.logout_rounded, EntroColors.dangerBg, EntroColors.dangerInk),
    _ => _MiniEvent(hour, event.type, Icons.schedule_rounded, EntroColors.neutralPill, EntroColors.mute),
  };
}

EntroPillTone _toneFor(WorkdayStatus status) {
  return switch (status) {
    WorkdayStatus.notStarted => EntroPillTone.muted,
    WorkdayStatus.working => EntroPillTone.success,
    WorkdayStatus.paused => EntroPillTone.warning,
    WorkdayStatus.finished => EntroPillTone.info,
  };
}

IconData _iconFor(ClockingAction action) {
  return switch (action) {
    ClockingAction.start => Icons.play_arrow_rounded,
    ClockingAction.pause => Icons.pause_rounded,
    ClockingAction.resume => Icons.play_arrow_rounded,
    ClockingAction.finish => Icons.stop_rounded,
  };
}

String _firstName(String? value) {
  final clean = (value ?? 'Empleado').trim();
  if (clean.isEmpty) {
    return 'Empleado';
  }
  return clean.split(RegExp(r'\s+')).first;
}

String _initials(String? value) {
  final parts = (value ?? 'Empleado').trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    return 'EM';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}

Duration _liveWorked(ClockingSummary summary) {
  if (summary.status != WorkdayStatus.working) {
    return summary.workedToday;
  }
  return summary.workedToday + DateTime.now().difference(summary.fetchedAt);
}

String _timeLabel(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

String _dateLabel(DateTime date) {
  const days = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
  const months = ['', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
  return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month]}';
}

String? _lastEventText(ClockingSummary summary, String type) {
  final matches = summary.eventsToday.where((event) => event.type == type).toList();
  if (matches.isEmpty) {
    return null;
  }
  final date = matches.last.occurredAt.toLocal();
  final hour = date.toString().substring(11, 16);
  return switch (type) {
    'pause-start' => 'En pausa desde las $hour',
    'clock-out' => 'Jornada cerrada a las $hour',
    _ => hour,
  };
}
