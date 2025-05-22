import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mob_lab_manger/app/bloc/theme_bloc.dart';
import 'package:mob_lab_manger/app/bloc/connectivity/connectivity_bloc.dart';
import 'package:mob_lab_manger/app/navigation/app_router.dart';
import 'package:mob_lab_manger/app/theme/app_theme.dart';
import 'package:mob_lab_manger/core/network/network_info.dart';
import 'package:mob_lab_manger/features/profile/presentation/bloc/profile_completion_bloc.dart'; // New Import
// SplashBloc is no longer used
// import 'package:mob_lab_manger/features/splash/presentation/bloc/splash_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MobLabMangerApp());
}

class MobLabMangerApp extends StatelessWidget {
  const MobLabMangerApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[MobLabMangerApp] Building App...');
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
          BlocProvider(create: (context) {
            debugPrint('[MobLabMangerApp] Creating ThemeBloc...');
            return ThemeBloc();
          }),
          BlocProvider(create: (context) {
            debugPrint('[MobLabMangerApp] Creating ConnectivityBloc...');
            return ConnectivityBloc(
              networkInfo: RepositoryProvider.of<NetworkInfo>(context),
            );
          }),
          BlocProvider(// Provide ProfileCompletionBloc
              create: (context) {
            debugPrint('[MobLabMangerApp] Creating ProfileCompletionBloc...');
            return ProfileCompletionBloc();
          }),
        ],
        // Assuming each screen handles its own internet dialog now
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            debugPrint(
                '[MobLabMangerApp] Building MaterialApp.router with themeMode: ${themeState.themeMode}');
            return MaterialApp.router(
              title: 'MobLabManger',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              routerConfig: AppRouter.router,
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
