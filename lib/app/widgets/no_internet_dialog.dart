import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mob_lab_manger/app/bloc/theme_bloc.dart';
import 'package:mob_lab_manger/app/bloc/connectivity/connectivity_bloc.dart';

// This function will be called by screens with their own context
void showCustomNoInternetDialog(BuildContext screenContext) {
  debugPrint(
      '[NoInternetDialog] Attempting to show dialog using screenContext.');

  final isDarkMode =
      screenContext.read<ThemeBloc>().state.themeMode == ThemeMode.dark;
  final dialogBackgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;
  final textColor = isDarkMode ? Colors.white70 : Colors.black54;
  final titleColor = isDarkMode ? Colors.white : Colors.black87;
  final buttonColor = Theme.of(screenContext).colorScheme.primary;

  showDialog<void>(
    context: screenContext, // Use the passed screenContext
    barrierDismissible: false,
    builder: (BuildContext dialogContext) {
      // This is the dialog's own context
      return PopScope(
        canPop: false,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          backgroundColor: dialogBackgroundColor,
          icon: Icon(
            Icons.wifi_off_rounded,
            color: isDarkMode
                ? Colors.orangeAccent.shade200
                : Colors.orange.shade700,
            size: 48,
          ),
          title: Text(
            'No Internet Connection',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: titleColor, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            'Please check your internet connection and try again to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(
              bottom: 20.0, top: 10.0, left: 20, right: 20),
          actions: <Widget>[
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              label: const Text('Retry',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                minimumSize: const Size(120, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                debugPrint(
                    '[NoInternetDialog - Retry Button] Pressed. Adding ConnectivityManuallyChecked event.');
                // Use dialogContext to find the BLoC, as it's part of the dialog's tree
                BlocProvider.of<ConnectivityBloc>(dialogContext)
                    .add(ConnectivityManuallyChecked());
              },
            ),
          ],
        ),
      );
    },
  );
}
