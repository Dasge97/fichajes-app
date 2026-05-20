import 'package:flutter/material.dart';
import '../theme/entro_theme.dart';

// ─── Logo ─────────────────────────────────────────────────────────────────────
class EntroLogo extends StatelessWidget {
  const EntroLogo({this.size = 20, this.dark = false, super.key});
  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Text(
      'entroya',
      style: ET.sans(
        size: size,
        weight: FontWeight.w700,
        color: dark ? EC.textOnDark : EC.ink,
        letterSpacing: size * -0.03,
      ),
    );
  }
}

// ─── Cards ────────────────────────────────────────────────────────────────────
class EntroCard extends StatelessWidget {
  const EntroCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = ER.md,
    this.color = EC.card,
    this.borderColor = EC.line,
    this.borderWidth = 1.0,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: box);
    }
    return box;
  }
}

class DarkCard extends StatelessWidget {
  const DarkCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.radius = ER.lg,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: EC.ink,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

// ─── Pills ────────────────────────────────────────────────────────────────────
enum PillTone { neutral, success, warn, error, ink, accent, muted, warning, info, danger }

// Alias usado por el resto de pantallas
typedef EntroPillTone = PillTone;

class EntroPill extends StatelessWidget {
  const EntroPill({
    required this.label,
    this.tone = PillTone.neutral,
    this.dot = true,
    this.icon,
    super.key,
  });

  final String label;
  final PillTone tone;
  final bool dot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      PillTone.success || PillTone.info  => (EC.successSoft, EC.success),
      PillTone.warn    || PillTone.warning => (EC.warnSoft, EC.warn),
      PillTone.error   || PillTone.danger => (EC.errorSoft, EC.error),
      PillTone.ink     => (EC.ink, EC.textOnDark),
      PillTone.accent  => (EC.accent, EC.ink),
      PillTone.neutral || PillTone.muted => (EC.cardWarm, EC.text2),
    };
    final hasBorder = tone == PillTone.neutral;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(ER.full),
        border: hasBorder ? Border.all(color: EC.line) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot && icon == null) ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: ET.sans(size: 12, weight: FontWeight.w600, color: fg, letterSpacing: -0.005),
          ),
        ],
      ),
    );
  }
}

// ─── Avatar iniciales ─────────────────────────────────────────────────────────
class EntroAvatar extends StatelessWidget {
  const EntroAvatar({required this.initials, this.size = 60, this.showAlert = false, super.key});
  final String initials;
  final double size;
  final bool showAlert;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: EC.ink, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: ET.sans(size: size * 0.36, weight: FontWeight.w700, color: EC.accent, letterSpacing: -0.02),
      ),
    );
    if (!showAlert) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: EC.error,
              shape: BoxShape.circle,
              border: Border.all(color: EC.bgCanvas, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Botones ──────────────────────────────────────────────────────────────────
class PrimaryBtn extends StatelessWidget {
  const PrimaryBtn({
    required this.label,
    this.onTap,
    this.icon,
    this.accentStyle = false,
    this.width = double.infinity,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool accentStyle;
  final double width;

  @override
  Widget build(BuildContext context) {
    final bg = accentStyle ? EC.accent : EC.ink;
    final fg = accentStyle ? EC.ink : EC.textOnDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(ER.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: width == double.infinity ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, color: fg, size: 20), const SizedBox(width: 10)],
            Text(label, style: ET.sans(size: 17, weight: FontWeight.w600, color: fg)),
          ],
        ),
      ),
    );
  }
}

class SoftBtn extends StatelessWidget {
  const SoftBtn({
    required this.label,
    this.onTap,
    this.icon,
    this.width = double.infinity,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: EC.cardWarm,
          borderRadius: BorderRadius.circular(ER.md),
          border: Border.all(color: EC.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: width == double.infinity ? MainAxisSize.max : MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, color: EC.ink, size: 18), const SizedBox(width: 10)],
            Text(label, style: ET.sans(size: 15, weight: FontWeight.w600, color: EC.ink)),
          ],
        ),
      ),
    );
  }
}

// ─── Menu row ─────────────────────────────────────────────────────────────────
class EntroMenuRow extends StatelessWidget {
  const EntroMenuRow({
    required this.icon,
    required this.label,
    this.hint,
    this.last = false,
    this.destructive = false,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? hint;
  final bool last;
  final bool destructive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = destructive ? EC.error : EC.text;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: last ? BorderSide.none : const BorderSide(color: EC.lineSoft)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: ET.sans(size: 14, weight: FontWeight.w500, color: fg)),
                  if (hint != null) Text(hint!, style: ET.sans(size: 12, color: EC.text3)),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: destructive ? EC.error : EC.text3,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {this.bottom = 6, super.key});
  final String text;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Text(
        text.toUpperCase(),
        style: ET.sans(size: 11, weight: FontWeight.w600, color: EC.text3, letterSpacing: 0.8),
      ),
    );
  }
}

// ─── TabBar ───────────────────────────────────────────────────────────────────
class EntroTabBar extends StatelessWidget {
  const EntroTabBar({required this.currentIndex, required this.onTap, super.key});
  final int currentIndex;
  final void Function(int) onTap;

  static const _items = [
    (Icons.access_time_rounded, 'Inicio'),
    (Icons.calendar_today_rounded, 'Historial'),
    (Icons.event_available_rounded, 'Ausencias'),
    (Icons.person_rounded, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 26),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        border: const Border(top: BorderSide(color: EC.line)),
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final active = i == currentIndex;
          final (icon, label) = _items[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 22, color: active ? EC.ink : EC.text3),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: ET.sans(size: 11, weight: FontWeight.w500, color: active ? EC.ink : EC.text3),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Bell con badge ───────────────────────────────────────────────────────────
class BellIconWithBadge extends StatelessWidget {
  const BellIconWithBadge({this.count = 0, this.onTap, super.key});
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none_rounded, size: 22, color: EC.ink),
          if (count > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: EC.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: EC.bgCanvas, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────────
class EntroProgressBar extends StatelessWidget {
  const EntroProgressBar({
    required this.progress,
    this.height = 8,
    this.color = EC.accent,
    this.bgColor,
    super.key,
  });

  final double progress;
  final double height;
  final Color color;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(ER.full),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(ER.full),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Toggle ───────────────────────────────────────────────────────────────────
class EntroToggle extends StatelessWidget {
  const EntroToggle({required this.value, this.onChanged, super.key});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 26,
        decoration: BoxDecoration(
          color: value ? EC.ink : EC.line,
          borderRadius: BorderRadius.circular(ER.full),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1))],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helpers de formato ───────────────────────────────────────────────────────
String fmtDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}

String fmtDurationHuman(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h == 0) return '${m}min';
  if (m == 0) return '${h}h';
  return '${h}h ${m}min';
}

/// Alias usado por varias pantallas. Ej: "4h 12min" o "42min"
String formatDurationCompact(Duration d) => fmtDurationHuman(d);

// ─── EntroIconButton ──────────────────────────────────────────────────────────
class EntroIconButton extends StatelessWidget {
  const EntroIconButton({required this.icon, this.onTap, this.size = 36, super.key});
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: EC.card,
          borderRadius: BorderRadius.circular(ER.sm),
          border: Border.all(color: EC.line),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: size * 0.5, color: EC.ink),
      ),
    );
  }
}

// ─── EntroScaffold ────────────────────────────────────────────────────────────
/// Wrapper básico de scaffold. Si [showAppBar] es true renderiza un AppBar simple.
class EntroScaffold extends StatelessWidget {
  const EntroScaffold({
    required this.child,
    this.showAppBar = false,
    this.title,
    this.back = false,
    this.right,
    super.key,
  });

  final Widget child;
  final bool showAppBar;
  final String? title;
  final bool back;
  final Widget? right;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EC.bgCanvas,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: EC.bgCanvas,
              elevation: 0,
              automaticallyImplyLeading: back,
              title: title != null
                  ? Text(title!, style: ET.sans(size: 17, weight: FontWeight.w600))
                  : null,
              actions: right != null ? [Padding(padding: const EdgeInsets.only(right: 16), child: right!)] : null,
            )
          : null,
      body: child,
    );
  }
}
