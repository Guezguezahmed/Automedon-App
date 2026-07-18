import 'package:flutter/foundation.dart';
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
import 'screens/mon_agence_screen.dart';
import 'screens/reservation_detail_screen.dart';

/// Bridges Riverpod's authProvider (bool) to a ChangeNotifier that
/// GoRouter can listen to via `refreshListenable`, without GoRouter
/// itself being recreated on every auth change.
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen<bool>(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final _goRouterRefreshProvider = Provider<GoRouterRefreshNotifier>((ref) {
  return GoRouterRefreshNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_goRouterRefreshProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider); // lu au moment du redirect, pas watché
      final path = state.uri.toString();
      final isSplash = path == '/splash';
      final isLogin = path == '/login';

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
        path: '/monagence',
        builder: (context, state) => const MonAgenceScreen(),
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
      GoRoute(
        path: '/reservations/:id',
        builder: (context, state) => ReservationDetailScreen(
          reservationId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
});