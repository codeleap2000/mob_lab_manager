import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_lab_manger/features/auth/presentation/pages/login_screen.dart'; // New import
import 'package:mob_lab_manger/features/customer/presentation/pages/customer_home_screen.dart'; // New import
import 'package:mob_lab_manger/features/role_selection/presentation/pages/role_selection_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const String roleSelection = '/';
  static const String login = '/login';
  static const String customerHome = '/customer-home';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.roleSelection,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.roleSelection,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const RoleSelectionScreen(),
          type: PageTransitionType.fade,
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const LoginScreen(),
          type: PageTransitionType.slideRight, // Example transition
        ),
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const CustomerHomeScreen(),
          type: PageTransitionType.slideRight, // Example transition
        ),
      ),
    ],
  );
}

enum PageTransitionType { fade, slideRight, slideLeft, scale, none }

CustomTransitionPage _buildPageWithTransition<T>({
  required LocalKey key,
  required Widget child,
  PageTransitionType type = PageTransitionType.fade,
  Duration transitionDuration = const Duration(milliseconds: 350),
  Duration reverseTransitionDuration = const Duration(milliseconds: 300),
  Curve curve = Curves.easeInOutCubic,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, pageChild) {
      switch (type) {
        case PageTransitionType.fade:
          return FadeTransition(
              opacity: animation.drive(CurveTween(curve: curve)),
              child: pageChild);
        case PageTransitionType.slideRight:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation.drive(CurveTween(curve: curve))),
            child: pageChild,
          );
        case PageTransitionType.slideLeft:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(animation.drive(CurveTween(curve: curve))),
            child: pageChild,
          );
        case PageTransitionType.scale:
          return ScaleTransition(
              scale: animation.drive(CurveTween(curve: curve)),
              child: pageChild);
        case PageTransitionType.none:
          return pageChild;
      }
    },
    transitionDuration:
        type == PageTransitionType.none ? Duration.zero : transitionDuration,
    reverseTransitionDuration: type == PageTransitionType.none
        ? Duration.zero
        : reverseTransitionDuration,
  );
}
