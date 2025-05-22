import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mob_lab_manger/app/bloc/theme_bloc.dart';
import 'package:mob_lab_manger/app/bloc/connectivity/connectivity_bloc.dart';
import 'package:mob_lab_manger/app/navigation/app_router.dart';
import 'package:mob_lab_manger/app/theme/app_theme.dart';
import 'package:mob_lab_manger/core/network/network_info.dart';
import 'package:mob_lab_manger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mob_lab_manger/features/profile/presentation/bloc/profile_completion_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[AppMain] Firebase Initialized Successfully');
  } catch (e) {
    debugPrint('[AppMain] Firebase Initialization Failed: $e');
    // Handle Firebase initialization error if necessary
    // For example, show a critical error screen or prevent app launch
  }

  // You can set up a global BLoC observer for debugging if needed
  // Bloc.observer = const AppBlocObserver(); // Create AppBlocObserver class if you use this

  runApp(const MobLabMangerApp());
}

class MobLabMangerApp extends StatelessWidget {
  const MobLabMangerApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[MobLabMangerApp] Building App Root...');
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<NetworkInfo>(
          create: (context) {
            debugPrint('[MobLabMangerApp] Creating NetworkInfoImpl...');
            return NetworkInfoImpl(
              connectionChecker: InternetConnectionChecker.instance,
              connectivity: Connectivity(),
            );
          },
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // SplashBloc was removed as per your request
          BlocProvider(create: (context) {
            debugPrint('[MobLabMangerApp] Creating ThemeBloc...');
            return ThemeBloc();
          }),
          BlocProvider(create: (context) {
            debugPrint('[MobLabMangerApp] Creating ConnectivityBloc...');
            return ConnectivityBloc(
              networkInfo: RepositoryProvider.of<NetworkInfo>(context),
            ); // Note: ConnectivitySubscriptionRequested is added in BLoC constructor
          }),
          BlocProvider(create: (context) {
            debugPrint('[MobLabMangerApp] Creating AuthBloc...');
            return AuthBloc();
          }),
          BlocProvider(create: (context) {
            debugPrint('[MobLabMangerApp] Creating ProfileCompletionBloc...');
            return ProfileCompletionBloc();
          }),
        ],
        // Global BlocListener for ConnectivityBloc was removed.
        // Each screen (RoleSelectionScreen, LoginScreen, SignupScreen, etc.)
        // will have its own BlocListener for ConnectivityBloc to show its local dialog.
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            debugPrint(
                '[MobLabMangerApp] Building MaterialApp.router with themeMode: ${themeState.themeMode}');
            return MaterialApp.router(
              title: 'MobLabManger',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme
                  .darkTheme, // Make sure you have a darkTheme defined in app_theme.dart
              themeMode: themeState.themeMode,
              routerConfig: AppRouter
                  .router, // AppRouter.router already has the navigatorKey
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
