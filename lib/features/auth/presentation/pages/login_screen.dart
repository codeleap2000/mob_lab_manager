import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mob_lab_manger/app/bloc/theme_bloc.dart';
import 'package:mob_lab_manger/app/navigation/app_router.dart';
import 'package:mob_lab_manger/app/widgets/custom_elevated_button.dart';
import 'package:mob_lab_manger/app/widgets/custom_text_form_field.dart';
import 'package:mob_lab_manger/app/widgets/gradient_logo.dart';
import 'package:mob_lab_manger/app/widgets/social_login_buttons.dart';
import 'package:mob_lab_manger/app/widgets/staggered_entrance_animation.dart';
import 'package:mob_lab_manger/app/widgets/theme_toggle_button.dart';
import 'package:mob_lab_manger/app/widgets/auth_bottom_action_link.dart';
import 'package:mob_lab_manger/app/bloc/connectivity/connectivity_bloc.dart';
import 'package:mob_lab_manger/app/widgets/no_internet_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isDialogShowing = false;
  bool _isLoggingIn = false;
  bool _isPasswordObscured = true; // State for password visibility

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ConnectivityBloc>().add(ConnectivityManuallyChecked());
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _performLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() => _isLoggingIn = true);

    context.read<ConnectivityBloc>().add(ConnectivityManuallyChecked());
    Stream<ConnectivityState> blocStream =
        context.read<ConnectivityBloc>().stream;
    ConnectivityState connectivityState;
    try {
      connectivityState = await blocStream
          .firstWhere((state) => state.status != AppConnectionStatus.loading);
    } catch (e) {
      debugPrint("Error waiting for connectivity state: $e");
      if (mounted) setState(() => _isLoggingIn = false);
      _showDialogIfNeeded();
      return;
    }

    if (!mounted) return;
    if (connectivityState.status != AppConnectionStatus.connected) {
      setState(() => _isLoggingIn = false);
      _showDialogIfNeeded();
      return;
    }

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoggingIn = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login attempt for: ${_emailController.text}')),
    );
  }

  void _showDialogIfNeeded() {
    if (!mounted || _isDialogShowing) return;
    setState(() => _isDialogShowing = true);
    showCustomNoInternetDialog(context).then((_) {
      if (mounted) setState(() => _isDialogShowing = false);
    });
  }

  void _dismissDialogIfNeeded() {
    if (mounted && _isDialogShowing) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      _isDialogShowing = false;
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
      child: BlocListener<ConnectivityBloc, ConnectivityState>(
        listener: (listenerContext, state) {
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
              const Positioned(
                top: kToolbarHeight - 20,
                right: 10,
                child: ThemeToggleButton(
                  containerPadding: EdgeInsets.all(4),
                  iconSize: 24,
                ),
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
                            horizontal: 20.0, vertical: 24.0),
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
                                  height: 55,
                                  width: 55,
                                ),
                              ),
                              StaggeredEntranceAnimation(
                                delay:
                                    initialDelay + staggerStep * staggerIndex++,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    'Welcome to My Lab',
                                    style: textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              StaggeredEntranceAnimation(
                                delay:
                                    initialDelay + staggerStep * staggerIndex++,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Please login to your account',
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
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                          .hasMatch(value)) {
                                        return 'Please enter a valid email format';
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
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: CustomTextFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    isFocused: _passwordFocusNode.hasFocus,
                                    hintText: 'Password',
                                    prefixIcon: Icons.lock_outline_rounded,
                                    obscureText:
                                        _isPasswordObscured, // Use state variable
                                    suffixIconWidget: IconButton(
                                      // Add toggle button
                                      icon: Icon(
                                        _isPasswordObscured
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color:
                                            colorScheme.primary.withAlpha(200),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordObscured =
                                              !_isPasswordObscured;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
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
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: CustomElevatedButton(
                                      text: 'Log in',
                                      isLoading: _isLoggingIn,
                                      onPressed:
                                          _isLoggingIn ? null : _performLogin,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ),
                              StaggeredEntranceAnimation(
                                delay:
                                    initialDelay + staggerStep * staggerIndex++,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0),
                                    child: TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Forgot Password clicked (Not Implemented)')),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 0),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              StaggeredEntranceAnimation(
                                delay:
                                    initialDelay + staggerStep * staggerIndex++,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: SocialLoginButtons(
                                    onGoogleLogin: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Google Login clicked (Not Implemented)')),
                                      );
                                    },
                                    onFacebookLogin: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Facebook Login clicked (Not Implemented)')),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              StaggeredEntranceAnimation(
                                delay:
                                    initialDelay + staggerStep * staggerIndex++,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: AuthBottomActionLink(
                                    leadingText: "Don't have an account?",
                                    actionText: 'Sign up',
                                    onActionPressed: () {
                                      context.push(AppRoutes.signup);
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
