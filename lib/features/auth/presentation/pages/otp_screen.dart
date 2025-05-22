import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_lab_manger/app/bloc/theme_bloc.dart';
import 'package:mob_lab_manger/app/navigation/app_router.dart';
import 'package:mob_lab_manger/app/widgets/custom_elevated_button.dart';
import 'package:mob_lab_manger/app/widgets/staggered_entrance_animation.dart';

class OTPScreen extends StatefulWidget {
  final String? email;

  const OTPScreen({super.key, this.email});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _verifyOtp() async {
    final enteredOtp = _otpController.text;
    if (enteredOtp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid OTP 6 digits OTP.')),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _isVerifying = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isVerifying = false);

    // Simulate OTP verification: For testing, let's assume "123456" is the correct OTP
    // This makes the 'else' block reachable.
    bool otpVerified = (enteredOtp == "123456");

    if (otpVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP $enteredOtp Verified Successfully!')),
      );
      final String emailToPass = widget.email ?? "user@example.com";
      final String placeholderUserId =
          "user_${DateTime.now().millisecondsSinceEpoch}";

      context.goNamed(
        AppRoutes.completeProfile,
        extra: {'email': emailToPass, 'userId': placeholderUserId},
      );
    } else {
      // This block is now reachable
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode =
        context.watch<ThemeBloc>().state.themeMode == ThemeMode.dark;

    const Duration initialDelay = Duration(milliseconds: 100);
    const Duration staggerStep = Duration(milliseconds: 80);
    int staggerIndex = 0;

    return PopScope(
      canPop: true,
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
                            delay: initialDelay + staggerStep * staggerIndex++,
                            child: Icon(
                              Icons.phonelink_lock_outlined,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          StaggeredEntranceAnimation(
                            delay: initialDelay + staggerStep * staggerIndex++,
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
                            delay: initialDelay + staggerStep * staggerIndex++,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 12.0, bottom: 24.0),
                              child: Text(
                                widget.email != null && widget.email!.isNotEmpty
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
                            delay: initialDelay + staggerStep * staggerIndex++,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: TextField(
                                controller: _otpController,
                                focusNode: _otpFocusNode,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                style: textTheme.headlineSmall?.copyWith(
                                    letterSpacing: 10,
                                    fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: '------',
                                  hintStyle: textTheme.headlineSmall?.copyWith(
                                      letterSpacing: 10,
                                      color: isDarkMode
                                          ? Colors.grey[700]
                                          : Colors.grey[400]),
                                  counterText: "",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withAlpha(100))),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2)),
                                  filled: true,
                                  fillColor: Theme.of(context)
                                      .canvasColor
                                      .withAlpha((0.5 * 255).round()),
                                ),
                              ),
                            ),
                          ),
                          StaggeredEntranceAnimation(
                            delay: initialDelay + staggerStep * staggerIndex++,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 28.0, bottom: 12.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: CustomElevatedButton(
                                  text: 'Verify OTP',
                                  isLoading: _isVerifying,
                                  onPressed: _isVerifying ? null : _verifyOtp,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          StaggeredEntranceAnimation(
                            delay: initialDelay + staggerStep * staggerIndex++,
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
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                          ),
                          StaggeredEntranceAnimation(
                            delay: initialDelay + staggerStep * staggerIndex++,
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
    );
  }
}
