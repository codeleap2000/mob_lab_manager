import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_lab_manger/app/bloc/theme_bloc.dart';
import 'package:mob_lab_manger/app/navigation/app_router.dart';
import 'package:mob_lab_manger/app/widgets/custom_elevated_button.dart';
import 'package:mob_lab_manger/app/widgets/staggered_entrance_animation.dart';
import 'package:mob_lab_manger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mob_lab_manger/app/theme/pin_input_theme.dart'; // Import the new Pinput themes
import 'package:pinput/pinput.dart';

class OTPScreen extends StatefulWidget {
  final String? email;

  const OTPScreen({super.key, this.email});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  final int _otpLength = 6;

  @override
  void initState() {
    super.initState();
    _otpFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _verifyOtp() {
    final enteredOtp = _otpController.text;
    if (enteredOtp.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please enter a complete $_otpLength-digit OTP.')),
      );
      return;
    }

    if (widget.email != null) {
      context.read<AuthBloc>().add(VerifyCustomOtpSubmitted(
            email: widget.email!,
            otp: enteredOtp,
            firebaseUserId:
                context.read<AuthBloc>().state.firebaseUser?.uid ?? '',
          ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: Email not found for OTP verification.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode =
        context.watch<ThemeBloc>().state.themeMode == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;

    const Duration initialDelay = Duration(milliseconds: 100);
    const Duration staggerStep = Duration(milliseconds: 80);
    int staggerIndex = 0;

    // Get Pinput themes from the separate file
    final defaultPinTheme = PinInputThemes.getPinTheme(
        context: context,
        isDarkMode: isDarkMode,
        colorScheme: colorScheme,
        textTheme: textTheme);
    final focusedPinTheme = PinInputThemes.getFocusedPinTheme(
        context: context,
        isDarkMode: isDarkMode,
        colorScheme: colorScheme,
        textTheme: textTheme);
    final submittedPinTheme = PinInputThemes.getSubmittedPinTheme(
        context: context,
        isDarkMode: isDarkMode,
        colorScheme: colorScheme,
        textTheme: textTheme);
    final errorPinTheme = PinInputThemes.getErrorPinTheme(
        context: context,
        isDarkMode: isDarkMode,
        colorScheme: colorScheme,
        textTheme: textTheme);

    return PopScope(
      canPop: true,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error));
            _otpController.clear();
          } else if (state.status == AuthStatus.otpVerifiedSuccessfully) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(
                  content: Text('OTP Verified Successfully! Proceeding...')));
            final String emailToPass =
                widget.email ?? state.emailForOtpScreen ?? "user@example.com";
            final String userIdToPass = state.firebaseUser?.uid ??
                "user_${DateTime.now().millisecondsSinceEpoch}";
            context.goNamed(
              AppRoutes.completeProfile,
              extra: {'email': emailToPass, 'userId': userIdToPass},
            );
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
              // NO ThemeToggleButton HERE
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 20.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Card(
                      elevation: isDarkMode ? 3 : 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      color: Theme.of(context)
                          .cardColor
                          .withAlpha(isDarkMode ? 235 : 250),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StaggeredEntranceAnimation(
                              delay:
                                  initialDelay + staggerStep * staggerIndex++,
                              child: Icon(
                                Icons.phonelink_lock_outlined,
                                size: 60,
                                color: colorScheme.primary,
                              ),
                            ),
                            StaggeredEntranceAnimation(
                              delay:
                                  initialDelay + staggerStep * staggerIndex++,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: Text(
                                  'Verify Your Account',
                                  style: textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            StaggeredEntranceAnimation(
                              delay:
                                  initialDelay + staggerStep * staggerIndex++,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 12.0, bottom: 24.0),
                                child: Text(
                                  widget.email != null &&
                                          widget.email!.isNotEmpty
                                      ? 'An OTP has been sent to your email address:\n${widget.email}'
                                      : 'An OTP has been sent to your email address.',
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                            StaggeredEntranceAnimation(
                              delay:
                                  initialDelay + staggerStep * staggerIndex++,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Pinput(
                                  controller: _otpController,
                                  focusNode: _otpFocusNode,
                                  length: _otpLength,
                                  defaultPinTheme: defaultPinTheme,
                                  focusedPinTheme: focusedPinTheme,
                                  submittedPinTheme: submittedPinTheme,
                                  errorPinTheme: errorPinTheme,
                                  pinputAutovalidateMode:
                                      PinputAutovalidateMode.onSubmit,
                                  showCursor: true,
                                  onCompleted: (pin) {
                                    debugPrint('Pinput onCompleted: $pin');
                                  },
                                  validator: (s) {
                                    if (s == null || s.length < _otpLength) {
                                      return 'Please enter all $_otpLength digits';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            StaggeredEntranceAnimation(
                              delay:
                                  initialDelay + staggerStep * staggerIndex++,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20.0, bottom: 12.0),
                                child: BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, authState) {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: CustomElevatedButton(
                                        text: 'Verify OTP',
                                        isLoading: authState.status ==
                                            AuthStatus
                                                .otpVerificationInProgress,
                                        onPressed: authState.status ==
                                                AuthStatus
                                                    .otpVerificationInProgress
                                            ? null
                                            : _verifyOtp,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            StaggeredEntranceAnimation(
                              delay:
                                  initialDelay + staggerStep * staggerIndex++,
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Resend OTP clicked (Not Implemented)')),
                                  );
                                },
                                child: Text(
                                  "Didn't receive code? Resend OTP",
                                  style: TextStyle(color: colorScheme.primary),
                                ),
                              ),
                            ),
                            StaggeredEntranceAnimation(
                              delay:
                                  initialDelay + staggerStep * staggerIndex++,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TextButton.icon(
                                    icon: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 16),
                                    label: const Text("Back to Sign Up"),
                                    onPressed: () {
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go(AppRoutes.signup);
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[700],
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
