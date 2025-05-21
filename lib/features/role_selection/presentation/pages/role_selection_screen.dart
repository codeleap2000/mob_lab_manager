import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mob_lab_manger/app/bloc/theme_bloc.dart';
import 'package:mob_lab_manger/app/widgets/theme_toggle_button.dart';
import 'package:mob_lab_manger/app/bloc/connectivity/connectivity_bloc.dart'; // Import ConnectivityBloc
import 'package:mob_lab_manger/app/widgets/no_internet_dialog.dart'; // Import the renamed dialog

class RoleSelectionScreen extends StatefulWidget {
  // Changed to StatefulWidget
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    // Trigger an initial check or ensure the BLoC is listening
    // The BLoC constructor already calls add(ConnectivitySubscriptionRequested())
    // If you want to force a check specifically when this screen loads:
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (mounted) {
    //     context.read<ConnectivityBloc>().add(ConnectivityManuallyChecked());
    //   }
    // });
  }

  void _showDialogIfNeeded(BuildContext currentContext) {
    if (!_isDialogShowing) {
      debugPrint('[RoleSelectionScreen] Showing NoInternetDialog.');
      _isDialogShowing = true;
      showCustomNoInternetDialog(currentContext); // Use the new dialog function
    } else {
      debugPrint('[RoleSelectionScreen] NoInternetDialog already showing.');
    }
  }

  void _dismissDialogIfNeeded(BuildContext currentContext) {
    if (_isDialogShowing) {
      debugPrint('[RoleSelectionScreen] Dismissing NoInternetDialog.');
      // Check if a dialog is the current top route before trying to pop
      // This check might not be strictly necessary if _isDialogShowing is managed well
      if (Navigator.of(currentContext).canPop()) {
        Navigator.of(currentContext).pop();
      }
      _isDialogShowing = false;
    } else {
      debugPrint(
          '[RoleSelectionScreen] NoInternetDialog not showing, no need to dismiss.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
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
          // Use a different context name
          debugPrint(
              '[RoleSelectionScreen - Listener] Connectivity State: ${state.status}');
          if (state.status == AppConnectionStatus.disconnected) {
            _showDialogIfNeeded(listenerContext); // Use listenerContext
          } else if (state.status == AppConnectionStatus.connected) {
            _dismissDialogIfNeeded(listenerContext); // Use listenerContext
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
                  padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Align(
                        alignment: Alignment.topRight,
                        child: ThemeToggleButton(),
                      ),
                      const Spacer(flex: 1),
                      Text(
                        'Welcome to MobLabManger!',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please select your role to continue:',
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 50),
                      _RoleButton(
                        text: 'Admin',
                        icon: Icons.admin_panel_settings_outlined,
                        onPressed: () {
                          // Example: Check internet before proceeding
                          final connectivityState =
                              context.read<ConnectivityBloc>().state;
                          if (connectivityState.status ==
                              AppConnectionStatus.connected) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Admin Role Selected')),
                            );
                            // TODO: Navigate to Admin screen
                          } else {
                            debugPrint(
                                '[RoleSelectionScreen - AdminButton] No internet. Triggering check/dialog.');
                            _showDialogIfNeeded(
                                context); // Show dialog if not already showing
                            // Or force a check if you want the loading indicator
                            // context.read<ConnectivityBloc>().add(ConnectivityManuallyChecked());
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _RoleButton(
                        text: 'Technician',
                        icon: Icons.build_circle_outlined,
                        onPressed: () {
                          // Similar check for other buttons
                          final connectivityState =
                              context.read<ConnectivityBloc>().state;
                          if (connectivityState.status ==
                              AppConnectionStatus.connected) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Technician Role Selected')),
                            );
                          } else {
                            _showDialogIfNeeded(context);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _RoleButton(
                        text: 'Customer',
                        icon: Icons.person_outline,
                        color: colorScheme.secondary,
                        onPressed: () {
                          final connectivityState =
                              context.read<ConnectivityBloc>().state;
                          if (connectivityState.status ==
                              AppConnectionStatus.connected) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Customer Role Selected')),
                            );
                          } else {
                            _showDialogIfNeeded(context);
                          }
                        },
                      ),
                      const Spacer(flex: 2),
                      BlocBuilder<ConnectivityBloc, ConnectivityState>(
                        builder: (context, state) {
                          if (state.status == AppConnectionStatus.loading &&
                              !_isDialogShowing) {
                            return const Center(
                                child: CircularProgressIndicator());
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

class _RoleButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;

  const _RoleButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 24),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 3,
      ).merge(Theme.of(context).elevatedButtonTheme.style),
    );
  }
}
