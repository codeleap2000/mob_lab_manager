import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_lab_manger/features/auth/presentation/pages/login_screen.dart';
import 'package:mob_lab_manger/features/auth/presentation/pages/otp_screen.dart';
import 'package:mob_lab_manger/features/auth/presentation/pages/signup_screen.dart';
import 'package:mob_lab_manger/features/customer/presentation/pages/customer_home_screen.dart';
import 'package:mob_lab_manger/features/profile/presentation/pages/complete_profile_screen.dart'; // New Import
import 'package:mob_lab_manger/features/role_selection/presentation/pages/role_selection_screen.dart';
// Placeholder for Home Screen after profile completion
// import 'package/features/home/presentation/pages/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static const String roleSelection = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otpVerification = '/otp-verification';
  static const String completeProfile = '/complete-profile'; // New Route
  static const String customerHome = '/customer-home';
  static const String home = '/home'; // Placeholder for main app home
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
          type: PageTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const SignupScreen(),
          type: PageTransitionType.slideRight,
        ),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: AppRoutes.otpVerification,
        pageBuilder: (context, state) {
          final String? email = state.extra as String?;
          return _buildPageWithTransition(
            key: state.pageKey,
            child: OTPScreen(email: email),
            type: PageTransitionType.slideRight,
          );
        },
      ),
      GoRoute(
        // New Route for Complete Profile
        path: AppRoutes.completeProfile,
        name: AppRoutes.completeProfile,
        pageBuilder: (context, state) {
          // Expecting a map with 'email' and 'userId'
          final Map<String, String>? args = state.extra as Map<String, String>?;
          final String email = args?['email'] ??
              'default@example.com'; // Provide default or handle error
          final String userId = args?['userId'] ??
              'default_user_id'; // Provide default or handle error
          return _buildPageWithTransition(
            key: state.pageKey,
            child: CompleteProfileScreen(email: email, userId: userId),
            type: PageTransitionType.slideRight,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.customerHome,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          child: const CustomerHomeScreen(),
          type: PageTransitionType.slideRight,
        ),
      ),
      // Placeholder Home Screen Route
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _buildPageWithTransition(
          key: state.pageKey,
          // Replace with your actual HomeScreen later
          child: Scaffold(
              appBar: AppBar(title: const Text("Home")),
              body: const Center(child: Text("Welcome Home!"))),
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
