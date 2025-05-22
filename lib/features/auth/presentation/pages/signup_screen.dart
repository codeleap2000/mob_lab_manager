import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_lab_manger/app/bloc/theme_bloc.dart';
import 'package:mob_lab_manger/app/navigation/app_router.dart';
import 'package:mob_lab_manger/app/widgets/custom_elevated_button.dart';
import 'package:mob_lab_manger/app/widgets/custom_text_form_field.dart';
import 'package:mob_lab_manger/app/widgets/gradient_logo.dart';
import 'package:mob_lab_manger/app/widgets/staggered_entrance_animation.dart';
import 'package:mob_lab_manger/app/widgets/auth_bottom_action_link.dart';
import 'package:mob_lab_manger/app/bloc/connectivity/connectivity_bloc.dart'; // For internet check
import 'package:mob_lab_manger/app/widgets/no_internet_dialog.dart';
import 'package:mob_lab_manger/features/auth/domain/entities/password_validation_result.dart';
import 'package:mob_lab_manger/features/auth/presentation/widgets/password_conditions_widget.dart';
import 'package:mob_lab_manger/features/auth/presentation/bloc/auth_bloc.dart'; // Import AuthBloc

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isNoInternetDialogShowing = false;
  // bool _isSigningUp = false; // Now handled by AuthBloc's state
  bool _showPasswordConditions = false;
  String _currentPassword = "";

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  late List<PasswordValidationRule> _passwordRules;

  @override
  void initState() {
    super.initState();
    _setupPasswordRules();
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onPasswordFocusChange);
    _confirmPasswordFocusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Initial internet check (can be removed if AuthBloc/actions handle it)
        // context.read<ConnectivityBloc>().add(ConnectivityManuallyChecked());
      }
    });
  }

  void _setupPasswordRules() {
    _passwordRules = [
      PasswordValidationRule(
          description: 'At least 8 characters',
          validator: (p) => p.length >= 8),
      PasswordValidationRule(
          description: 'One uppercase letter (A-Z)',
          validator: (p) => p.contains(RegExp(r'[A-Z]'))),
      PasswordValidationRule(
          description: 'One lowercase letter (a-z)',
          validator: (p) => p.contains(RegExp(r'[a-z]'))),
      PasswordValidationRule(
          description: 'One number (0-9)',
          validator: (p) => p.contains(RegExp(r'[0-9]'))),
      PasswordValidationRule(
          description: 'One special character (!@#\$%^&*)',
          validator: (p) => p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))),
    ];
  }

  void _onPasswordFocusChange() {
    if (mounted) {
      setState(() {
        _showPasswordConditions = _passwordFocusNode.hasFocus;
      });
    }
  }

  void _onPasswordChanged(String password) {
    if (mounted) {
      setState(() {
        _currentPassword = password;
      });
    }
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onPasswordFocusChange);
    _confirmPasswordFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _triggerSignup() {
    // Renamed from _performSignup
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      if (mounted) setState(() {});
      return;
    }
    bool allRulesMet = _passwordRules
        .every((rule) => rule.validator(_passwordController.text));
    if (!allRulesMet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please meet all password requirements.')),
      );
      if (mounted) setState(() {});
      return;
    }

    final connectivityState = context.read<ConnectivityBloc>().state;
    if (connectivityState.status != AppConnectionStatus.connected) {
      _showNoInternetDialogIfNeeded();
      return;
    }

    // Dispatch event to AuthBloc
    context.read<AuthBloc>().add(SignupWithFirebaseRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  void _showNoInternetDialogIfNeeded() {
    if (!mounted || _isNoInternetDialogShowing) return;
    // Check current connectivity state one last time before showing
    final currentConnectivity = context.read<ConnectivityBloc>().state.status;
    if (currentConnectivity == AppConnectionStatus.disconnected) {
      setState(() => _isNoInternetDialogShowing = true);
      showCustomNoInternetDialog(context).then((_) {
        if (mounted) setState(() => _isNoInternetDialogShowing = false);
      });
    }
  }

  void _dismissNoInternetDialogIfNeeded() {
    if (mounted && _isNoInternetDialogShowing) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      // No need to setState here, .then in _showNoInternetDialogIfNeeded handles it
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

    return PopScope(
      canPop: true,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ConnectivityBloc, ConnectivityState>(
            listener: (context, state) {
              debugPrint(
                  '[SignupScreen - Listener] Connectivity State: ${state.status}');
              if (state.status == AppConnectionStatus.disconnected) {
                _showNoInternetDialogIfNeeded();
              } else if (state.status == AppConnectionStatus.connected) {
                _dismissNoInternetDialogIfNeeded();
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.status == AuthStatus.failure &&
                  state.errorMessage != null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: Theme.of(context).colorScheme.error));
              } else if (state.status == AuthStatus.customOtpSent) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content:
                          Text('OTP sent to: ${state.emailForOtpScreen}')));
                // Navigate to OTP screen, passing the email
                context.pushNamed(AppRoutes.otpVerification,
                    extra: state.emailForOtpScreen);
              }
            },
          ),
        ],
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
              // No ThemeToggleButton as per your request for this screen
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 40.0),
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
                            horizontal: 20.0, vertical: 28.0),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StaggeredEntranceAnimation(
                                delay:
                                    initialDelay + staggerStep * staggerIndex++,
                                child: const GradientLogo(
                                  logoAssetPath:
                                      'assets/logos/mobile_repair_logo.png',
                                  height: 50,
                                  width: 50,
                                ),
                              ),
                              StaggeredEntranceAnimation(
                                delay:
                                    initialDelay + staggerStep * staggerIndex++,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    'Create Your Account',
                                    style: textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              StaggeredEntranceAnimation(
                                delay:
                                    initialDelay + staggerStep * staggerIndex++,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: CustomTextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    isFocused: _emailFocusNode.hasFocus,
                                    hintText: 'Email Address',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    enforceGmail: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Please enter your email';
                                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                          .hasMatch(value))
                                        return 'Invalid email format';
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              StaggeredEntranceAnimation(
                                delay:
                                    initialDelay + staggerStep * staggerIndex++,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: CustomTextFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    isFocused: _passwordFocusNode.hasFocus,
                                    hintText: 'Password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: _isPasswordObscured,
                                    onChanged: _onPasswordChanged,
                                    suffixIconWidget: IconButton(
                                      icon: Icon(
                                        _isPasswordObscured
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color:
                                            colorScheme.primary.withAlpha(200),
                                      ),
                                      onPressed: () => setState(() =>
                                          _isPasswordObscured =
                                              !_isPasswordObscured),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Please enter a password';
                                      // Final validation of rules is done in _triggerSignup
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return SizeTransition(
                                    sizeFactor: animation,
                                    axisAlignment: -1.0,
                                    child: FadeTransition(
                                        opacity: animation, child: child),
                                  );
                                },
                                child: _showPasswordConditions
                                    ? StaggeredEntranceAnimation(
                                        key: const ValueKey(
                                            'password_conditions'),
                                        delay: Duration.zero,
                                        child: PasswordConditionsWidget(
                                          rules: _passwordRules,
                                          currentPassword: _currentPassword,
                                        ),
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('empty_conditions')),
                              ),
                              StaggeredEntranceAnimation(
                                delay:
                                    initialDelay + staggerStep * staggerIndex++,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: CustomTextFormField(
                                    controller: _confirmPasswordController,
                                    focusNode: _confirmPasswordFocusNode,
                                    isFocused:
                                        _confirmPasswordFocusNode.hasFocus,
                                    hintText: 'Confirm Password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText: _isConfirmPasswordObscured,
                                    suffixIconWidget: IconButton(
                                      icon: Icon(
                                        _isConfirmPasswordObscured
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color:
                                            colorScheme.primary.withAlpha(200),
                                      ),
                                      onPressed: () => setState(() =>
                                          _isConfirmPasswordObscured =
                                              !_isConfirmPasswordObscured),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty)
                                        return 'Please confirm your password';
                                      if (value != _passwordController.text)
                                        return 'Passwords do not match';
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              StaggeredEntranceAnimation(
                                delay:
                                    initialDelay + staggerStep * staggerIndex++,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: BlocBuilder<AuthBloc, AuthState>(
                                    builder: (context, authState) {
                                      final isLoading = authState.status ==
                                              AuthStatus.loading ||
                                          authState.status ==
                                              AuthStatus
                                                  .firebaseSignupSuccess ||
                                          authState.status ==
                                              AuthStatus.customOtpSending;
                                      return SizedBox(
                                        width: double.infinity,
                                        child: CustomElevatedButton(
                                          text: 'Sign Up',
                                          isLoading: isLoading,
                                          onPressed:
                                              isLoading ? null : _triggerSignup,
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
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: AuthBottomActionLink(
                                    leadingText: "Already have an account?",
                                    actionText: 'Log in',
                                    onActionPressed: () {
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go(AppRoutes.login);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
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
