import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/entro_theme.dart';
import '../../../core/widgets/entro_widgets.dart';

class AbsencesScreen extends StatelessWidget {
  const AbsencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EntroScaffold(
      showAppBar: true,
      title: 'Ausencias',
      right: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: EntroColors.ink, borderRadius: BorderRadius.circular(9)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
      ),
      child: FutureBuilder<Map<String, dynamic>>(
        future: _load(context),
        builder: (context, snapshot) {
          final data = snapshot.data ?? {};
          final saldo = data['saldoVacaciones'] is Map<String, dynamic>
              ? data['saldoVacaciones'] as Map<String, dynamic>
              : <String, dynamic>{};
          final items = data['items'] is List
              ? (data['items'] as List).whereType<Map<String, dynamic>>().map(_itemFromJson).toList()
              : <_AbsenceItem>[];

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _BalanceCard(saldo: saldo),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Solicitar ausencia'),
                ),
                const SizedBox(height: 18),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Solicitudes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('Este ano', style: TextStyle(color: EntroColors.mute, fontSize: 11.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else if (items.isEmpty)
                  const Text('No hay solicitudes.', style: TextStyle(color: EntroColors.mute))
                else
                  for (final item in items) ...[
                    _AbsenceRow(item: item),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _load(BuildContext context) async {
    final response = await context.read<ApiClient>().dio.get<Map<String, dynamic>>('/api/v1/mobile/ausencias');
    return response.data ?? {};
  }

  _AbsenceItem _itemFromJson(Map<String, dynamic> json) {
    final status = (json['estado'] as String?) ?? '';
    final start = (json['fechaInicio'] as String?) ?? '';
    final end = (json['fechaFin'] as String?) ?? '';
    return _AbsenceItem(
      (json['tipo'] as String?) ?? 'Ausencia',
      start == end ? start : '$start - $end',
      '',
      switch (status) {
        'aprobada' => EntroPillTone.success,
        'rechazada' => EntroPillTone.danger,
        _ => EntroPillTone.warning,
      },
      status.isEmpty ? 'pendiente' : status,
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.saldo});

  final Map<String, dynamic> saldo;

  @override
  Widget build(BuildContext context) {
    final disponibles = (saldo['disponibles'] as num?)?.toInt();
    final total = (saldo['total'] as num?)?.toInt();
    final disfrutados = (saldo['disfrutados'] as num?)?.toInt() ?? 0;
    final pendientes = (saldo['pendientes'] as num?)?.toInt() ?? 0;
    final hasConfiguredBalance = total != null && disponibles != null && total > 0;
    return EntroCard(
      color: EntroColors.ink,
      borderColor: EntroColors.ink,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SALDO DE VACACIONES ${DateTime.now().year}',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.6),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(text: hasConfiguredBalance ? '$disponibles' : '$disfrutados', children: [
                  TextSpan(text: hasConfiguredBalance ? ' / $total' : ' dias', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 22)),
                ]),
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 38, height: 1, fontWeight: FontWeight.w500, letterSpacing: 0),
              ),
              Text(
                'Aprobados: $disfrutados\nPendientes: $pendientes',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.35),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: hasConfiguredBalance ? disfrutados / total : 0,
              minHeight: 6,
              color: Colors.white,
              backgroundColor: Colors.white.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _AbsenceRow extends StatelessWidget {
  const _AbsenceRow({required this.item});

  final _AbsenceItem item;

  @override
  Widget build(BuildContext context) {
    return EntroCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: EntroColors.bg, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.calendar_today_rounded, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.type, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.days.isEmpty ? item.range : '${item.range} · ${item.days}', style: const TextStyle(color: EntroColors.mute, fontSize: 11.5)),
              ],
            ),
          ),
          EntroPill(label: item.status, tone: item.tone),
        ],
      ),
    );
  }
}

class _AbsenceItem {
  const _AbsenceItem(this.type, this.range, this.days, this.tone, this.status);

  final String type;
  final String range;
  final String days;
  final EntroPillTone tone;
  final String status;
}
