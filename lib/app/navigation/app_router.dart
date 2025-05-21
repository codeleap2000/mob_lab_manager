import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// No longer importing from global_no_internet_dialog.dart for navigatorKey
import 'package:mob_lab_manger/features/role_selection/presentation/pages/role_selection_screen.dart';

// Define the navigator key at the top level of this file or within the class
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const String roleSelection =
      '/'; // RoleSelection is now the initial/root route
}

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey, // Use the locally defined navigatorKey
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
