import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/entro_theme.dart';
import '../../../core/widgets/entro_widgets.dart';
import '../data/history_repository.dart';
import '../domain/history_models.dart';

// ─── HistoryScreen ────────────────────────────────────────────────────────────
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final HistoryRepository _repo;
  late Future<_HistoryData> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repo = HistoryRepository(context.read<ApiClient>());
    _future = _load();
  }

  Future<_HistoryData> _load() async {
    final week = await _repo.fetchWeekData();
    final today = await _repo.fetchDayHistory('today');
    return _HistoryData(week: week, today: today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EC.bgCanvas,
      body: SafeArea(
        child: FutureBuilder<_HistoryData>(
          future: _future,
          builder: (context, snapshot) {
            final data = snapshot.data;
            return Column(
              children: [
                // ── Header ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Historial',
                        style: ET.sans(size: 22, weight: FontWeight.w700),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: EC.cardWarm,
                          shape: BoxShape.circle,
                          border: Border.all(color: EC.line),
                        ),
                        child: const Icon(Icons.tune_rounded, size: 18, color: EC.ink),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Week strip ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: data == null
                      ? _WeekStripSkeleton()
                      : _WeekStrip(
                          days: data.week,
                          onTapDay: (fecha) => context.push('/history/$fecha'),
                        ),
                ),
                const SizedBox(height: 14),

                // ── Today summary card ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: data == null
                      ? const SizedBox(height: 64)
                      : _TodaySummaryCard(dayHistory: data.today, weekDay: data.todayWeekDay),
                ),
                const SizedBox(height: 8),

                // ── Timeline section ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(left: 24, top: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SectionLabel('Eventos'),
                  ),
                ),

                if (snapshot.connectionState == ConnectionState.waiting)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (data != null)
                  Expanded(
                    child: _TimelineList(
                      eventos: data.today.eventos,
                      jornada: data.today,
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Week strip ───────────────────────────────────────────────────────────────
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.days, required this.onTapDay});

  final List<WeekDayData> days;
  final void Function(String fecha) onTapDay;

  static const _letras = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(days.length, (i) {
        final day = days[i];
        final letra = day.diaSemana >= 1 && day.diaSemana <= 7
            ? _letras[day.diaSemana - 1]
            : '?';
        final numDia = day.fecha.length >= 10 ? day.fecha.substring(8, 10) : '';

        final isOff = day.tipo == 'descanso' || day.diaSemana == 7;
        final bg = day.hoy
            ? EC.ink
            : isOff
                ? EC.cardWarm
                : EC.card;
        final textColor = day.hoy
            ? EC.textOnDark
            : isOff
                ? EC.text3
                : EC.text;
        final borderColor = day.hoy ? EC.ink : EC.line;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              if (!day.hoy && day.tipo != 'futuro') onTapDay(day.fecha);
            },
            child: Container(
              margin: i < days.length - 1
                  ? const EdgeInsets.only(right: 6)
                  : EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Text(
                    letra,
                    style: ET.sans(
                      size: 11,
                      weight: FontWeight.w500,
                      color: textColor,
                    ).copyWith(
                      color: day.hoy ? EC.textOnDark.withOpacity(0.7) : textColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    numDia,
                    style: ET.mono(size: 15, weight: FontWeight.w600, color: textColor),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _WeekStripSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        return Expanded(
          child: Container(
            margin: i < 6 ? const EdgeInsets.only(right: 6) : EdgeInsets.zero,
            height: 56,
            decoration: BoxDecoration(
              color: EC.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: EC.line),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Today summary card ───────────────────────────────────────────────────────
class _TodaySummaryCard extends StatelessWidget {
  const _TodaySummaryCard({required this.dayHistory, required this.weekDay});

  final DayHistory dayHistory;
  final WeekDayData? weekDay;

  static const _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  static const _diasSemana = [
    'lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo',
  ];

  String _subtitulo() {
    final now = DateTime.now();
    final mes = now.month >= 1 && now.month <= 12 ? _meses[now.month - 1] : '';
    final diaSem = weekDay != null && weekDay!.diaSemana >= 1 && weekDay!.diaSemana <= 7
        ? _diasSemana[weekDay!.diaSemana - 1]
        : '';
    return 'Hoy · $diaSem ${now.day} $mes';
  }

  (PillTone, String) _estadoPill() {
    final estado = dayHistory.estado ?? '';
    return switch (estado) {
      'activa' || 'working' => (PillTone.success, 'En jornada'),
      'paused' => (PillTone.warn, 'En pausa'),
      'finalizada' || 'finished' => (PillTone.ink, 'Finalizada'),
      'ausencia' => (PillTone.error, 'Ausencia'),
      _ => (PillTone.neutral, 'Sin iniciar'),
    };
  }

  @override
  Widget build(BuildContext context) {
    final previstoH = dayHistory.previsto.inHours;
    final previstoM = dayHistory.previsto.inMinutes.remainder(60);
    final previstoStr = previstoM > 0 ? '${previstoH}h ${previstoM}min' : '${previstoH}h';
    final (tone, label) = _estadoPill();

    return EntroCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _subtitulo(),
                  style: ET.sans(size: 12, weight: FontWeight.w500, color: EC.text3),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      fmtDurationHuman(dayHistory.trabajado),
                      style: ET.mono(size: 22, weight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ $previstoStr previstas',
                      style: ET.sans(size: 13, color: EC.text2),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          EntroPill(label: label, tone: tone),
        ],
      ),
    );
  }
}

// ─── Timeline list ────────────────────────────────────────────────────────────
class _TimelineList extends StatelessWidget {
  const _TimelineList({required this.eventos, required this.jornada});

  final List<HistoryEvent> eventos;
  final DayHistory jornada;

  bool get _jornadaActiva {
    final estado = jornada.estado ?? '';
    return estado == 'activa' || estado == 'working' || estado == 'paused';
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      itemCount: eventos.length + (_jornadaActiva ? 1 : 0),
      itemBuilder: (context, i) {
        if (i < eventos.length) {
          return EventRow(
            event: eventos[i],
            last: i == eventos.length - 1 && !_jornadaActiva,
          );
        }
        // Franja "siguiente accion"
        return _NextActionBanner();
      },
    );
  }
}

class _NextActionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: EC.cardWarm,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EC.line, style: BorderStyle.solid)
            .copyWith(
          bottom: const BorderSide(color: EC.line, style: BorderStyle.solid),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded, size: 16, color: EC.text3),
          const SizedBox(width: 10),
          Text(
            'Siguiente: reanudacion o salida',
            style: ET.sans(size: 13, color: EC.text2),
          ),
        ],
      ),
    );
  }
}

// ─── _HistoryData ─────────────────────────────────────────────────────────────
class _HistoryData {
  const _HistoryData({required this.week, required this.today});

  final List<WeekDayData> week;
  final DayHistory today;

  WeekDayData? get todayWeekDay {
    try {
      return week.firstWhere((d) => d.hoy);
    } catch (_) {
      return null;
    }
  }
}

// ─── EventRow (shared widget) ─────────────────────────────────────────────────
class EventRow extends StatelessWidget {
  const EventRow({required this.event, this.last = false, super.key});

  final HistoryEvent event;
  final bool last;

  static IconData _iconFor(String tipo) => switch (tipo) {
        'clock-in' => Icons.play_arrow_rounded,
        'pause-start' => Icons.pause_rounded,
        'pause-end' => Icons.play_arrow_rounded,
        'clock-out' => Icons.stop_rounded,
        _ => Icons.schedule_rounded,
      };

  static String _labelFor(String tipo) => switch (tipo) {
        'clock-in' => 'Entrada',
        'pause-start' => 'Pausa',
        'pause-end' => 'Reanudacion',
        'clock-out' => 'Salida',
        _ => tipo,
      };

  @override
  Widget build(BuildContext context) {
    final timeStr = '${event.ocurridoEn.toLocal().hour.toString().padLeft(2, '0')}:'
        '${event.ocurridoEn.toLocal().minute.toString().padLeft(2, '0')}';

    final hasBadge = event.motivoDesvio != null && event.motivoDesvio!.isNotEmpty;
    final isWarn = event.estadoCumplimiento == 'warn' || event.estadoCumplimiento == 'warning';
    final isError = event.estadoCumplimiento == 'error' || event.estadoCumplimiento == 'violation';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna timeline (circulo + linea)
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: EC.cardWarm,
                    shape: BoxShape.circle,
                    border: Border.all(color: EC.line),
                  ),
                  child: Icon(_iconFor(event.tipo), size: 14, color: EC.text2),
                ),
                if (!last)
                  Container(
                    width: 2,
                    height: hasBadge ? 44 : 28,
                    color: EC.line,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _labelFor(event.tipo),
                          style: ET.sans(size: 15, weight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        timeStr,
                        style: ET.mono(size: 15, weight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (hasBadge) ...[
                    const SizedBox(height: 4),
                    EntroPill(
                      label: event.motivoDesvio!,
                      tone: isError
                          ? PillTone.error
                          : isWarn
                              ? PillTone.warn
                              : PillTone.neutral,
                      icon: (isError || isWarn) ? Icons.warning_amber_rounded : null,
                      dot: !(isError || isWarn),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
