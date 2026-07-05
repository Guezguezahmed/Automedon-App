import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/providers.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/leasing_screen.dart';
import 'screens/gestion_flotte_screen.dart';
import 'screens/services_screen.dart';
import 'screens/historique_screen.dart';
import 'screens/signalements_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    // Always start at the splash screen
    initialLocation: '/splash',
    redirect: (context, state) {
      final path = state.uri.toString();
      final isSplash = path == '/splash';
      final isLogin = path == '/login';

      // Don't intercept the splash screen — it handles its own navigation
      if (isSplash) return null;

      if (!authState && !isLogin) return '/login';
      if (authState && isLogin) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScaffold(),
      ),
      GoRoute(
        path: '/leasing',
        builder: (context, state) => const LeasingScreen(),
      ),
      GoRoute(
        path: '/gestion_flotte',
        builder: (context, state) => const GestionFlotteScreen(),
      ),
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServicesScreen(),
      ),
      GoRoute(
        path: '/historique',
        builder: (context, state) => const HistoriqueScreen(),
      ),
      GoRoute(
        path: '/signalements',
        builder: (context, state) => const SignalementsScreen(),
      ),
    ],
  );
});
