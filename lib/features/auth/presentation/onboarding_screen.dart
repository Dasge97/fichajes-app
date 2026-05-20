import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/entro_theme.dart';
import '../../../core/widgets/entro_widgets.dart';

// ─── Welcome ──────────────────────────────────────────────────────────────────
class OnboardWelcomeScreen extends StatelessWidget {
  const OnboardWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EC.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const EntroLogo(dark: true, size: 20),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text('Saltar', style: ET.sans(size: 14, color: EC.textOnDark2)),
                  ),
                ],
              ),
              const Spacer(),
              // Big time display
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '08:00',
                    style: ET.mono(size: 88, weight: FontWeight.w500, color: EC.accent),
                  ),
                  Text(
                    '14:32',
                    // ignore: deprecated_member_use
                    style: ET.mono(size: 88, weight: FontWeight.w500, color: EC.textOnDark.withOpacity(0.25)),
                  ),
                  Text(
                    '17:30',
                    // ignore: deprecated_member_use
                    style: ET.mono(size: 88, weight: FontWeight.w500, color: EC.textOnDark.withOpacity(0.12)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                'Tu jornada,\nen un toque.',
                style: ET.sans(size: 34, weight: FontWeight.w700, color: EC.textOnDark, height: 1.05),
              ),
              const SizedBox(height: 12),
              Text(
                'Inicia, pausa y finaliza tu jornada laboral con un solo gesto. Sin formularios, sin esperas.',
                style: ET.sans(size: 15, color: EC.textOnDark2),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _PageDots(current: 0, dark: true),
                  GestureDetector(
                    onTap: () => context.go('/onboarding/permissions'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                      decoration: BoxDecoration(
                        color: EC.accent,
                        borderRadius: BorderRadius.circular(ER.full),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Siguiente',
                            style: ET.sans(size: 16, weight: FontWeight.w700, color: EC.ink),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18, color: EC.ink),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Permissions ──────────────────────────────────────────────────────────────
class OnboardPermissionsScreen extends StatefulWidget {
  const OnboardPermissionsScreen({super.key});

  @override
  State<OnboardPermissionsScreen> createState() => _OnboardPermissionsScreenState();
}

class _OnboardPermissionsScreenState extends State<OnboardPermissionsScreen> {
  final _perms = [true, true, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EC.bgCanvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/onboarding/welcome'),
                    child: const Icon(Icons.arrow_back_rounded, size: 22, color: EC.ink),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text('Saltar', style: ET.sans(size: 14, color: EC.text3)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Solo lo\nimprescindible.',
                style: ET.sans(size: 30, weight: FontWeight.w700, height: 1.05),
              ),
              const SizedBox(height: 10),
              Text(
                'Necesitamos un par de permisos. Puedes cambiarlos en cualquier momento.',
                style: ET.sans(size: 15, color: EC.text2),
              ),
              const SizedBox(height: 26),
              _PermCard(
                icon: Icons.location_on_rounded,
                title: 'Ubicación al fichar',
                body: 'Comprueba que estás en un centro autorizado. Solo en el momento del fichaje.',
                value: _perms[0],
                onChanged: (v) => setState(() => _perms[0] = v),
              ),
              const SizedBox(height: 12),
              _PermCard(
                icon: Icons.notifications_none_rounded,
                title: 'Avisos de jornada',
                body: 'Recordatorios para iniciar, pausar y cerrar. Discretos.',
                value: _perms[1],
                onChanged: (v) => setState(() => _perms[1] = v),
              ),
              const SizedBox(height: 12),
              _PermCard(
                icon: Icons.fingerprint_rounded,
                title: 'Face ID / huella',
                body: 'Entra en la app sin escribir tu PIN.',
                value: _perms[2],
                onChanged: (v) => setState(() => _perms[2] = v),
              ),
              const Spacer(),
              PrimaryBtn(
                label: 'Continuar',
                onTap: () => context.go('/onboarding/center'),
              ),
              const SizedBox(height: 12),
              const Center(child: _PageDots(current: 1)),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermCard extends StatelessWidget {
  const _PermCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return EntroCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: EC.cardWarm,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: EC.line),
            ),
            child: Icon(icon, size: 20, color: EC.ink),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ET.sans(size: 15, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(body, style: ET.sans(size: 13, color: EC.text2, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: EntroToggle(value: value, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}

// ─── Center selection ─────────────────────────────────────────────────────────
class OnboardCenterScreen extends StatefulWidget {
  const OnboardCenterScreen({super.key});

  @override
  State<OnboardCenterScreen> createState() => _OnboardCenterScreenState();
}

class _OnboardCenterScreenState extends State<OnboardCenterScreen> {
  int _selected = 0;

  static const _centers = [
    ('Oficina Madrid',    'C/ Velázquez 24 · 28001'),
    ('Oficina Barcelona', 'Av. Diagonal 405 · 08008'),
    ('Remoto / casa',     'Sin localización requerida'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EC.bgCanvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => context.go('/onboarding/permissions'),
                child: const Icon(Icons.arrow_back_rounded, size: 22, color: EC.ink),
              ),
              const SizedBox(height: 24),
              Text(
                '¿Dónde sueles\ntrabajar?',
                style: ET.sans(size: 30, weight: FontWeight.w700, height: 1.05),
              ),
              const SizedBox(height: 10),
              Text(
                'Selecciona tu centro principal. Podrás cambiarlo al fichar.',
                style: ET.sans(size: 15, color: EC.text2),
              ),
              const SizedBox(height: 24),
              ...List.generate(_centers.length, (i) {
                final sel = i == _selected;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = i),
                    child: EntroCard(
                      borderColor: sel ? EC.ink : EC.line,
                      borderWidth: sel ? 2 : 1,
                      padding: EdgeInsets.all(sel ? 13 : 14),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: sel ? EC.ink : EC.cardWarm,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: sel ? EC.accent : EC.text2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _centers[i].$1,
                                  style: ET.sans(size: 15, weight: FontWeight.w600),
                                ),
                                Text(
                                  _centers[i].$2,
                                  style: ET.sans(size: 12, color: EC.text3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              PrimaryBtn(
                label: 'Empezar a fichar',
                onTap: () => context.go('/login'),
              ),
              const SizedBox(height: 12),
              const Center(child: _PageDots(current: 2)),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Page dots ────────────────────────────────────────────────────────────────
class _PageDots extends StatelessWidget {
  const _PageDots({required this.current, this.dark = false});

  final int current;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final baseColor = dark ? EC.textOnDark : EC.ink;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final active = i == current;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 24 : 6,
          height: 6,
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: active ? baseColor : baseColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
