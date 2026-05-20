import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/entro_theme.dart';
import '../../../core/widgets/entro_widgets.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final session = auth.session;

    return EntroScaffold(
      showAppBar: true,
      title: 'Perfil',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                EntroAvatar(size: 64, initials: _initials(session?.displayName ?? session?.email ?? '')),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session?.displayName ?? session?.email ?? 'Empleado',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session?.email ?? '',
                        style: const TextStyle(color: EntroColors.mute, fontSize: 13),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'ID ${session?.trabajadorId ?? '-'} · Tenant ${session?.tenantId ?? '-'}',
                        style: const TextStyle(
                          color: EntroColors.mute,
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FutureBuilder<Map<String, dynamic>>(
              future: _loadSummary(context),
              builder: (context, snapshot) {
                final data = snapshot.data ?? {};
                final pendingCorrections = (data['correccionesPendientes'] as num?)?.toInt() ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SummaryCard(data: data, loading: snapshot.connectionState == ConnectionState.waiting),
                    const SizedBox(height: 14),
                    const EntroSectionLabel('Mi jornada'),
                    EntroCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          EntroMenuRow(
                            icon: Icons.format_list_bulleted_rounded,
                            label: 'Historial de fichajes',
                            hint: data['periodo'] is Map<String, dynamic>
                                ? (data['periodo'] as Map<String, dynamic>)['label'] as String?
                                : null,
                            onTap: () => context.go('/history'),
                          ),
                          EntroMenuRow(
                            icon: Icons.edit_outlined,
                            label: 'Correcciones',
                            trailing: pendingCorrections > 0
                                ? EntroPill(label: '$pendingCorrections', tone: EntroPillTone.warning)
                                : const Icon(Icons.chevron_right_rounded, color: EntroColors.mute2, size: 18),
                            last: true,
                            onTap: () => context.go('/corrections'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout_rounded, size: 16),
              label: Text(auth.loading ? 'Cerrando...' : 'Cerrar sesion'),
              style: TextButton.styleFrom(foregroundColor: EntroColors.danger),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _loadSummary(BuildContext context) async {
    final response = await context.read<ApiClient>().dio.get<Map<String, dynamic>>('/api/v1/mobile/resumen');
    return response.data ?? {};
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data, required this.loading});

  final Map<String, dynamic> data;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final periodo = data['periodo'] is Map<String, dynamic>
        ? data['periodo'] as Map<String, dynamic>
        : <String, dynamic>{};
    final trabajado = _durationFromSeconds(data['trabajadoSegundos']);
    final previsto = _durationFromSeconds(data['previstoSegundos']);
    final saldo = _durationFromSeconds(data['saldoSegundos']);
    final progress = previsto.inSeconds <= 0
        ? 0.0
        : (trabajado.inSeconds / previsto.inSeconds).clamp(0.0, 1.0);

    return EntroCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (periodo['label'] as String?) ?? 'Periodo actual',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                loading ? 'Cargando' : 'Hasta hoy',
                style: const TextStyle(color: EntroColors.mute, fontSize: 11.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ProfileStat('Trabajadas', formatDurationCompact(trabajado)),
              _ProfileStat('Previstas', formatDurationCompact(previsto)),
              _ProfileStat('Saldo', _formatSigned(saldo), warning: saldo.isNegative),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: EntroColors.ink,
              backgroundColor: EntroColors.border,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat(this.label, this.value, {this.warning = false});

  final String label;
  final String value;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: EntroColors.mute, fontSize: 11.5)),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: warning ? EntroColors.warningInk : EntroColors.ink,
              fontFamily: 'monospace',
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _initials(String value) {
  final parts = value.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) {
    return 'US';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}

Duration _durationFromSeconds(Object? value) {
  return Duration(seconds: (value as num?)?.toInt() ?? 0);
}

String _formatSigned(Duration value) {
  final abs = value.abs();
  final formatted = formatDurationCompact(abs);
  if (value.inSeconds == 0) {
    return formatted;
  }
  return '${value.isNegative ? '-' : '+'}$formatted';
}
