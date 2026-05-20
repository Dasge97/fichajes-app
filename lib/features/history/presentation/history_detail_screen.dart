import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/entro_theme.dart';
import '../../../core/widgets/entro_widgets.dart';
import '../data/history_repository.dart';
import '../domain/history_models.dart';
import 'history_screen.dart' show EventRow;

// ─── HistoryDetailScreen ──────────────────────────────────────────────────────
class HistoryDetailScreen extends StatefulWidget {
  const HistoryDetailScreen({required this.date, super.key});

  final String date;

  @override
  State<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends State<HistoryDetailScreen> {
  late Future<DayHistory> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = HistoryRepository(context.read<ApiClient>())
        .fetchDayHistory(widget.date);
  }

  // ── Formatear la cabecera tipo "Viernes 13 mayo" ─────────────────────────
  static const _diasSemana = [
    'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo',
  ];
  static const _meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  String _formatFecha(String fecha) {
    try {
      final dt = DateTime.parse(fecha);
      // weekday: 1=L..7=D
      final diaSem = _diasSemana[dt.weekday - 1];
      final mes = _meses[dt.month - 1];
      return '$diaSem ${dt.day} $mes';
    } catch (_) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EC.bgCanvas,
      body: SafeArea(
        child: FutureBuilder<DayHistory>(
          future: _future,
          builder: (context, snapshot) {
            final day = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          color: Colors.transparent,
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            size: 22,
                            color: EC.ink,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _formatFecha(widget.date),
                          textAlign: TextAlign.center,
                          style: ET.sans(size: 14, weight: FontWeight.w600),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          color: Colors.transparent,
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 20,
                            color: EC.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── DarkCard resumen ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: day == null
                      ? _DarkCardSkeleton()
                      : _DarkSummaryCard(day: day),
                ),
                const SizedBox(height: 4),

                // ── Timeline de eventos ─────────────────────────────────────
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (day != null)
                  Expanded(
                    child: _DetailTimeline(day: day),
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

// ─── DarkCard resumen ─────────────────────────────────────────────────────────
class _DarkSummaryCard extends StatelessWidget {
  const _DarkSummaryCard({required this.day});

  final DayHistory day;

  (PillTone, String) _estadoPill() {
    final estado = day.estado ?? '';
    return switch (estado) {
      'activa' || 'working' => (PillTone.success, 'En jornada'),
      'paused' => (PillTone.warn, 'En pausa'),
      'finalizada' || 'finished' => (PillTone.ink, 'Finalizada'),
      'ausencia' => (PillTone.error, 'Ausencia'),
      _ => (PillTone.neutral, 'Sin datos'),
    };
  }

  String _extraLabel() {
    if (day.previsto.inSeconds == 0) return '';
    final diff = day.trabajado - day.previsto;
    final mins = diff.inMinutes.abs();
    if (mins < 1) return '';
    return diff.isNegative ? '- $mins min de menos' : '+ $mins min de mas';
  }

  Color _extraColor() {
    if (day.previsto.inSeconds == 0) return EC.textOnDark2;
    final diff = day.trabajado - day.previsto;
    return diff.isNegative ? EC.error : EC.accentDeep;
  }

  List<_TimelineSegment> _buildSegments() {
    if (day.eventos.isEmpty) return [];
    final events = [...day.eventos]
      ..sort((a, b) => a.ocurridoEn.compareTo(b.ocurridoEn));

    final first = events.first.ocurridoEn;
    final last = events.last.ocurridoEn;
    final totalMs = last.difference(first).inMilliseconds;
    if (totalMs <= 0) return [];

    final segments = <_TimelineSegment>[];
    for (int i = 0; i < events.length - 1; i++) {
      final start = events[i].ocurridoEn;
      final end = events[i + 1].ocurridoEn;
      final from = start.difference(first).inMilliseconds / totalMs;
      final width = end.difference(start).inMilliseconds / totalMs;
      final isPausa = events[i].tipo == 'pause-start';
      segments.add(_TimelineSegment(from: from, width: width, isPausa: isPausa));
    }
    return segments;
  }

  String _timeAxisLabel(int idx) {
    final events = [...day.eventos]
      ..sort((a, b) => a.ocurridoEn.compareTo(b.ocurridoEn));
    if (events.isEmpty) return '';
    final target = idx == 0
        ? events.first.ocurridoEn
        : idx == 2
            ? events.last.ocurridoEn
            : events.length > 1
                ? events[events.length ~/ 2].ocurridoEn
                : events.first.ocurridoEn;
    return '${target.toLocal().hour.toString().padLeft(2, '0')}:'
        '${target.toLocal().minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final (tone, pillLabel) = _estadoPill();
    final extraLabel = _extraLabel();
    final segments = _buildSegments();

    // Tiempo total en formato H:MM
    final horas = day.trabajado.inHours;
    final mins = day.trabajado.inMinutes.remainder(60);
    final totalStr = '$horas:${mins.toString().padLeft(2, '0')}';

    final previstoH = day.previsto.inHours;
    final previstoM = day.previsto.inMinutes.remainder(60);
    final previstoStr = previstoM > 0 ? '${previstoH}h ${previstoM}min' : '${previstoH}h';

    return DarkCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pill estado + extra
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: tone == PillTone.ink
                      ? EC.ink
                      : tone == PillTone.success
                          ? EC.successSoft
                          : tone == PillTone.warn
                              ? EC.warnSoft
                              : tone == PillTone.error
                                  ? EC.errorSoft
                                  : EC.cardWarm,
                  borderRadius: BorderRadius.circular(ER.full),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Text(
                  pillLabel,
                  style: ET.sans(
                    size: 12,
                    weight: FontWeight.w600,
                    color: EC.textOnDark,
                  ),
                ),
              ),
              if (extraLabel.isNotEmpty)
                Text(
                  extraLabel,
                  style: ET.sans(size: 12, color: _extraColor()),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Tiempo gigante
          Text(
            totalStr,
            style: ET.mono(size: 54, weight: FontWeight.w500, color: EC.textOnDark)
                .copyWith(height: 1),
          ),
          const SizedBox(height: 4),

          // Previstas · N fichajes
          Text(
            'de $previstoStr previstas · ${day.eventos.length} fichajes',
            style: ET.sans(size: 13, color: EC.textOnDark2),
          ),
          const SizedBox(height: 18),

          // Mini timeline bar
          ClipRRect(
            borderRadius: BorderRadius.circular(ER.full),
            child: SizedBox(
              height: 8,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(color: Colors.white.withOpacity(0.12)),
                      for (final seg in segments)
                        Positioned(
                          left: seg.from * constraints.maxWidth,
                          width: (seg.width * constraints.maxWidth).clamp(0.0, constraints.maxWidth),
                          top: 0,
                          bottom: 0,
                          child: Container(
                            color: seg.isPausa
                                ? Colors.white.withOpacity(0.25)
                                : EC.accent,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Eje de tiempos
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              3,
              (i) => Text(
                _timeAxisLabel(i),
                style: ET.mono(size: 11, color: EC.textOnDark2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineSegment {
  const _TimelineSegment({
    required this.from,
    required this.width,
    required this.isPausa,
  });
  final double from;
  final double width;
  final bool isPausa;
}

class _DarkCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DarkCard(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(
            color: EC.textOnDark2,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

// ─── Detail timeline + resumen ────────────────────────────────────────────────
class _DetailTimeline extends StatelessWidget {
  const _DetailTimeline({required this.day});

  final DayHistory day;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        // Eventos
        ...List.generate(day.eventos.length, (i) {
          return EventRow(
            event: day.eventos[i],
            last: i == day.eventos.length - 1,
          );
        }),

        const SizedBox(height: 16),

        // Resumen 2x2
        _SummaryGrid(day: day),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.day});

  final DayHistory day;

  String _extraStr() {
    if (day.previsto.inSeconds == 0) return '--';
    final diff = day.trabajado - day.previsto;
    final mins = diff.inMinutes.abs();
    return diff.isNegative ? '- ${mins}min' : '+ ${mins}min';
  }

  String _centroStr() {
    // Tomamos el centroId del primer evento que lo tenga
    for (final e in day.eventos) {
      if (e.centroId != null && e.centroId!.isNotEmpty) return e.centroId!;
    }
    return '--';
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total', fmtDurationHuman(day.trabajado)),
      ('Pausas', fmtDurationHuman(day.pausas)),
      ('Extras', _extraStr()),
      ('Centro', _centroStr()),
    ];

    return EntroCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('Resumen'),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: items.map((item) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.$1,
                    style: ET.sans(size: 11, color: EC.text3),
                  ),
                  Text(
                    item.$2,
                    style: ET.mono(size: 16, weight: FontWeight.w600),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
