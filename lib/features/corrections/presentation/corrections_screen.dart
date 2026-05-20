import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/entro_theme.dart';
import '../../../core/widgets/entro_widgets.dart';

class CorrectionsScreen extends StatelessWidget {
  const CorrectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return EntroScaffold(
      showAppBar: true,
      title: 'Correcciones',
      back: true,
      child: FutureBuilder<List<_CorrectionItem>>(
        future: _load(context),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              children: [
                EntroCard(
                  color: EntroColors.infoBg,
                  borderColor: const Color(0xFFE5E9F1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.warning_amber_rounded, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          items.isEmpty
                              ? 'No hay correcciones pendientes para revisar.'
                              : 'Tienes ${items.length} correcciones registradas.',
                          style: const TextStyle(color: EntroColors.ink2, fontSize: 13, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else
                  for (final item in items) ...[
                    _CorrectionRow(item: item),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }

  Future<List<_CorrectionItem>> _load(BuildContext context) async {
    final response = await context.read<ApiClient>().dio.get<Map<String, dynamic>>('/api/v1/mobile/correcciones');
    final items = response.data?['items'];
    if (items is! List) {
      return [];
    }
    return items.whereType<Map<String, dynamic>>().map((json) {
      final status = (json['estado'] as String?) ?? '';
      final date = DateTime.tryParse((json['eventoFecha'] as String?) ?? '');
      final day = date == null ? '' : date.toLocal().toString().substring(0, 10);
      final time = date == null ? '' : date.toLocal().toString().substring(11, 16);
      return _CorrectionItem(
        day,
        time,
        (json['eventoTipo'] as String?) ?? 'Fichaje',
        (json['motivo'] as String?) ?? '',
        switch (status) {
          'aprobada' => EntroPillTone.success,
          'pendiente' => EntroPillTone.warning,
          _ => EntroPillTone.info,
        },
        status,
      );
    }).toList();
  }
}

class _CorrectionRow extends StatelessWidget {
  const _CorrectionRow({required this.item});

  final _CorrectionItem item;

  @override
  Widget build(BuildContext context) {
    return EntroCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.day} · ${item.time}',
                  style:
                      const TextStyle(color: EntroColors.mute, fontSize: 11.5),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  item.note,
                  style:
                      const TextStyle(color: EntroColors.mute, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              EntroPill(label: item.status, tone: item.tone),
            ],
          ),
        ],
      ),
    );
  }
}

class _CorrectionItem {
  const _CorrectionItem(this.day, this.time, this.label, this.note, this.tone,
      this.status);

  final String day;
  final String time;
  final String label;
  final String note;
  final EntroPillTone tone;
  final String status;
}
