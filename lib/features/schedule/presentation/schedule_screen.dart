import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/entro_theme.dart';
import '../../../core/widgets/entro_widgets.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EntroScaffold(
      showAppBar: true,
      title: 'Mi horario',
      back: true,
      right: const EntroIconButton(icon: Icons.calendar_today_rounded),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _load(context),
        builder: (context, snapshot) {
          final data = snapshot.data ?? {};
          final days = data['dias'] is List
              ? (data['dias'] as List).whereType<Map<String, dynamic>>().map(_dayFromJson).toList()
              : <_ScheduleDay>[];
          final previsto = Duration(seconds: (data['previstoSegundos'] as num?)?.toInt() ?? 0);
          final workDays = days.where((day) => day.kind == _DayKind.work || day.kind == _DayKind.today).length;
          final absences = days.where((day) => day.kind == _DayKind.absence).length;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              children: [
                _WeekNav(title: '${data['semanaInicio'] ?? ''} - ${data['semanaFin'] ?? ''}'),
                const SizedBox(height: 12),
                EntroCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SEMANA ACTUAL',
                            style: TextStyle(
                              color: EntroColors.mute,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text.rich(
                            TextSpan(
                              text: formatDurationCompact(previsto),
                              children: [
                                TextSpan(
                                  text: '',
                                  style: TextStyle(
                                    color: EntroColors.mute,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const EntroPill(
                              label: 'Semana', tone: EntroPillTone.info),
                          const SizedBox(height: 6),
                          Text(
                            '$workDays dias · $absences ausencias',
                            style: const TextStyle(
                              color: EntroColors.mute,
                              fontFamily: 'monospace',
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final day in days)
                        Expanded(child: _WeekBar(day: day)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: days.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) => _ScheduleRow(day: days[index]),
                ),
              ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _load(BuildContext context) async {
    final response = await context.read<ApiClient>().dio.get<Map<String, dynamic>>('/api/v1/mobile/horarios/semana');
    return response.data ?? {};
  }

  _ScheduleDay _dayFromJson(Map<String, dynamic> json) {
    final date = DateTime.tryParse((json['fecha'] as String?) ?? '') ?? DateTime.now();
    final type = (json['tipo'] as String?) ?? '';
    final seconds = (json['previstoSegundos'] as num?)?.toInt() ?? 0;
    return _ScheduleDay(
      _weekday(date.weekday),
      date.day,
      json['inicio'] == null ? '-' : '${json['inicio']} - ${json['fin']}',
      seconds == 0 ? '-' : '${(seconds / 3600).round()}h',
      (json['nota'] as String?) ?? '',
      (json['hoy'] as bool? ?? false)
          ? _DayKind.today
          : switch (type) {
              'ausencia' => _DayKind.absence,
              'descanso' => _DayKind.off,
              _ => _DayKind.work,
            },
    );
  }

  String _weekday(int day) {
    return const ['', 'Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'][day];
  }
}

class _WeekNav extends StatelessWidget {
  const _WeekNav({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _NavBox(icon: Icons.chevron_left_rounded),
        Column(
          children: [
            Text(title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            const Text('Semana actual',
                style: TextStyle(color: EntroColors.mute, fontSize: 11.5)),
          ],
        ),
        _NavBox(icon: Icons.chevron_right_rounded),
      ],
    );
  }
}

class _NavBox extends StatelessWidget {
  const _NavBox({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: EntroColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: EntroColors.borderStrong),
      ),
      child: Icon(icon, size: 18),
    );
  }
}

class _WeekBar extends StatelessWidget {
  const _WeekBar({required this.day});

  final _ScheduleDay day;

  @override
  Widget build(BuildContext context) {
    final height = switch (day.kind) {
      _DayKind.off => 3.0,
      _DayKind.absence => 12.0,
      _DayKind.today => 32.0,
      _DayKind.work => day.hours == '5h' ? 20.0 : 32.0,
    };
    final color = switch (day.kind) {
      _DayKind.off => EntroColors.border,
      _DayKind.absence => EntroColors.warning,
      _DayKind.today => EntroColors.ink,
      _DayKind.work => EntroColors.mute2,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            day.label.substring(0, 1),
            style: TextStyle(
              color: day.kind == _DayKind.today
                  ? EntroColors.ink
                  : EntroColors.mute2,
              fontSize: 11.5,
              fontWeight: day.kind == _DayKind.today
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.day});

  final _ScheduleDay day;

  @override
  Widget build(BuildContext context) {
    final isToday = day.kind == _DayKind.today;
    final isOff = day.kind == _DayKind.off;

    return Opacity(
      opacity: isOff ? 0.7 : 1,
      child: EntroCard(
        color: isToday ? EntroColors.ink : EntroColors.surface,
        borderColor: isToday ? EntroColors.ink : EntroColors.border,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 46,
              decoration: BoxDecoration(
                color:
                    isToday ? Colors.white.withOpacity(0.12) : EntroColors.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.label.toUpperCase(),
                    style: TextStyle(
                      color: isToday ? Colors.white70 : EntroColors.mute,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${day.number}',
                    style: TextStyle(
                      color: isToday ? Colors.white : EntroColors.ink,
                      fontFamily: 'monospace',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        day.slot,
                        style: TextStyle(
                          color: isToday ? Colors.white : EntroColors.ink,
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        day.hours,
                        style: TextStyle(
                          color: isToday
                              ? Colors.white.withOpacity(0.9)
                              : EntroColors.mute,
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    day.note,
                    style: TextStyle(
                      color: isToday
                          ? Colors.white.withOpacity(0.65)
                          : EntroColors.mute,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            if (day.kind == _DayKind.absence) ...[
              const SizedBox(width: 8),
              const EntroPill(label: 'Ausencia', tone: EntroPillTone.warning),
            ],
            if (isToday) ...[
              const SizedBox(width: 8),
              const EntroPill(label: 'Hoy', tone: EntroPillTone.success),
            ],
          ],
        ),
      ),
    );
  }
}

enum _DayKind { today, work, absence, off }

class _ScheduleDay {
  const _ScheduleDay(
      this.label, this.number, this.slot, this.hours, this.note, this.kind);

  final String label;
  final int number;
  final String slot;
  final String hours;
  final String note;
  final _DayKind kind;
}
