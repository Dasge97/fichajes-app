import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/entro_theme.dart';
import 'core/widgets/entro_widgets.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/onboarding_screen.dart';
import 'features/clocking/presentation/clocking_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/history/presentation/history_detail_screen.dart';
import 'features/absences/presentation/absences_screen.dart';
import 'features/absences/presentation/absence_request_screen.dart';
import 'features/corrections/presentation/corrections_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';

class FichajesApp extends StatelessWidget {
  const FichajesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    final router = GoRouter(
      initialLocation: '/clocking',
      refreshListenable: auth,
      redirect: (context, state) {
        final loc = state.matchedLocation;
        final isPublic = loc == '/login' || loc.startsWith('/onboarding');
        if (!auth.isAuthenticated && !isPublic) return '/onboarding/welcome';
        if (auth.isAuthenticated && isPublic) return '/clocking';
        return null;
      },
      routes: [
        // Auth / Onboarding
        GoRoute(path: '/onboarding/welcome',     builder: (_, __) => const OnboardWelcomeScreen()),
        GoRoute(path: '/onboarding/permissions', builder: (_, __) => const OnboardPermissionsScreen()),
        GoRoute(path: '/onboarding/center',      builder: (_, __) => const OnboardCenterScreen()),
        GoRoute(path: '/login',                  builder: (_, __) => const LoginScreen()),

        // Shell con las 4 tabs
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/clocking',  builder: (_, __) => const ClockingScreen()),
            GoRoute(path: '/history',   builder: (_, __) => const HistoryScreen()),
            GoRoute(path: '/absences',  builder: (_, __) => const AbsencesScreen()),
            GoRoute(path: '/profile',   builder: (_, __) => const ProfileScreen()),
          ],
        ),

        // Rutas secundarias (sin TabBar)
        GoRoute(
          path: '/history/:date',
          builder: (_, state) => HistoryDetailScreen(date: state.pathParameters['date'] ?? ''),
        ),
        GoRoute(path: '/absences/new',  builder: (_, __) => const AbsenceRequestScreen()),
        GoRoute(path: '/corrections',   builder: (_, __) => const CorrectionsScreen()),
        GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      ],
    );

    return MaterialApp.router(
      title: 'entroya',
      debugShowCheckedModeBanner: false,
      theme: EntroTheme.build(),
      routerConfig: router,
    );
  }
}

// ─── Shell con TabBar ─────────────────────────────────────────────────────────
class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});
  final Widget child;

  static const _routes = ['/clocking', '/history', '/absences', '/profile'];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _routes.indexWhere((r) => loc.startsWith(r));

    return Scaffold(
      body: child,
      bottomNavigationBar: EntroTabBar(
        currentIndex: idx < 0 ? 0 : idx,
        onTap: (i) => context.go(_routes[i]),
      ),
    );
  }
}
