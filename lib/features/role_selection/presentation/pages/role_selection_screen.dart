import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_lab_manger/app/bloc/theme_bloc.dart';
import 'package:mob_lab_manger/app/navigation/app_router.dart';
import 'package:mob_lab_manger/app/widgets/custom_elevated_button.dart';
import 'package:mob_lab_manger/app/widgets/theme_toggle_button.dart';
import 'package:mob_lab_manger/app/bloc/connectivity/connectivity_bloc.dart';
import 'package:mob_lab_manger/app/widgets/no_internet_dialog.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isDialogShowing = false;
  bool _isCheckingInternet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _performInternetCheck(null);
      }
    });
  }

  Future<void> _performInternetCheck(String? targetRoute) async {
    if (!mounted) return;
    setState(() {
      _isCheckingInternet = true;
    });

    context.read<ConnectivityBloc>().add(ConnectivityManuallyChecked());

    Stream<ConnectivityState> blocStream =
        context.read<ConnectivityBloc>().stream;
    ConnectivityState resultingState;
    try {
      resultingState = await blocStream
          .firstWhere((state) => state.status != AppConnectionStatus.loading);
    } catch (e) {
      debugPrint("Error waiting for connectivity state: $e");
      if (mounted) {
        setState(() => _isCheckingInternet = false);
      }
      _showDialogIfNeeded();
      return;
    }

    if (!mounted) return;
    setState(() {
      _isCheckingInternet = false;
    });

    if (resultingState.status == AppConnectionStatus.connected) {
      debugPrint(
          "[RoleSelectionScreen] Internet connected. Target route: $targetRoute");
      _dismissDialogIfNeeded();
      if (targetRoute != null) {
        context.push(targetRoute);
      }
    } else {
      debugPrint(
          "[RoleSelectionScreen] Internet disconnected. Showing dialog.");
      _showDialogIfNeeded();
    }
  }

  void _showDialogIfNeeded() {
    if (!mounted || _isDialogShowing) {
      if (_isDialogShowing)
        debugPrint("[RoleSelectionScreen] Dialog already considered showing.");
      if (!mounted)
        debugPrint(
            "[RoleSelectionScreen] Not showing dialog, widget not mounted.");
      return;
    }
    debugPrint("[RoleSelectionScreen] Showing NoInternetDialog.");
    setState(() {
      _isDialogShowing = true;
    });
    // This is line 99 where the error was reported.
    // With showCustomNoInternetDialog now explicitly returning Future<void>,
    // this .then() call is perfectly valid.
    showCustomNoInternetDialog(context).then((_) {
      debugPrint(
          "[RoleSelectionScreen] NoInternetDialog was dismissed (Future completed).");
      if (mounted) {
        setState(() {
          _isDialogShowing = false;
        });
      }
    });
  }

  void _dismissDialogIfNeeded() {
    if (!mounted || !_isDialogShowing) {
      if (!_isDialogShowing)
        debugPrint(
            "[RoleSelectionScreen] No dialog to dismiss or not mounted.");
      return;
    }
    debugPrint("[RoleSelectionScreen] Dismissing NoInternetDialog.");
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    // The .then() in _showDialogIfNeeded will set _isDialogShowing to false when dialog is popped.
    // However, if we are dismissing it before it's naturally popped, ensure the flag is reset.
    if (mounted) {
      setState(() {
        _isDialogShowing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // final colorScheme = Theme.of(context).colorScheme; // REMOVED - Unused local variable
    final isDarkMode =
        context.watch<ThemeBloc>().state.themeMode == ThemeMode.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        SystemNavigator.pop();
      },
      child: BlocListener<ConnectivityBloc, ConnectivityState>(
        listener: (listenerContext, state) {
          debugPrint(
              '[RoleSelectionScreen - Listener] Connectivity State: ${state.status}');
          if (state.status == AppConnectionStatus.disconnected) {
            _showDialogIfNeeded();
          } else if (state.status == AppConnectionStatus.connected) {
            _dismissDialogIfNeeded();
          }
        },
        child: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                isDarkMode
                    ? 'assets/splash/dark_mode_wave_bg.png'
                    : 'assets/splash/light_mode_wave_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                      color: isDarkMode ? Colors.black : Colors.grey[300]);
                },
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Align(
                        alignment: Alignment.topRight,
                        child: ThemeToggleButton(),
                      ),
                      const Spacer(flex: 2),
                      Text(
                        'Welcome to MobLabManger!',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Please select your role to continue:',
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge?.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black),
                      ),
                      const SizedBox(height: 60),
                      CustomElevatedButton(
                        text: 'Shop Owner',
                        iconData: Icons.storefront_outlined,
                        isLoading: _isCheckingInternet,
                        onPressed: _isCheckingInternet
                            ? null
                            : () {
                                _performInternetCheck(AppRoutes.login);
                              },
                      ),
                      const SizedBox(height: 25),
                      CustomElevatedButton(
                        text: 'Customer',
                        iconData: Icons.person_search_outlined,
                        type: CustomButtonType.secondary,
                        isLoading: _isCheckingInternet,
                        onPressed: _isCheckingInternet
                            ? null
                            : () {
                                _performInternetCheck(AppRoutes.customerHome);
                              },
                      ),
                      const Spacer(flex: 3),
                      BlocBuilder<ConnectivityBloc, ConnectivityState>(
                        builder: (context, state) {
                          if (state.status == AppConnectionStatus.loading &&
                              !_isDialogShowing) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
