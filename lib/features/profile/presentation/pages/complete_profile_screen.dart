import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';
import 'package:mob_lab_manger/app/bloc/theme_bloc.dart';
import 'package:mob_lab_manger/app/navigation/app_router.dart';
import 'package:mob_lab_manger/app/widgets/custom_elevated_button.dart';
import 'package:mob_lab_manger/app/widgets/custom_text_form_field.dart';
import 'package:mob_lab_manger/app/widgets/staggered_entrance_animation.dart';
import 'package:mob_lab_manger/app/widgets/theme_toggle_button.dart';
import 'package:mob_lab_manger/app/bloc/connectivity/connectivity_bloc.dart';
import 'package:mob_lab_manger/app/widgets/no_internet_dialog.dart';
import 'package:mob_lab_manger/features/profile/presentation/bloc/profile_completion_bloc.dart';
import 'package:mob_lab_manger/features/profile/presentation/widgets/profile_image_picker.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String email;
  final String userId;

  const CompleteProfileScreen({
    super.key,
    required this.email,
    required this.userId,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _shopNameController;
  late TextEditingController _whatsappController;
  late TextEditingController _addressController;

  late FocusNode _fullNameFocus;
  late FocusNode _shopNameFocus;
  late FocusNode _whatsappFocus;
  late FocusNode _addressFocus;

  // This local _selectedCountry is mainly for the initial display before BLoC might have a value,
  // or as a fallback. The BLoC state should be the source of truth for the UI.
  Country _selectedCountry = Country.parse('PK');

  bool _isNoInternetDialogShowing = false;

  @override
  void initState() {
    super.initState();

    context.read<ProfileCompletionBloc>().add(ProfileCompletionLoadInitial(
        email: widget.email, userId: widget.userId));

    // Initialize controllers from BLoC's initial state (which has defaults or passed email/userId)
    final initialProfileFromBloc =
        context.read<ProfileCompletionBloc>().state.userProfile;

    _fullNameController =
        TextEditingController(text: initialProfileFromBloc.fullName);
    _shopNameController =
        TextEditingController(text: initialProfileFromBloc.shopName);
    _whatsappController =
        TextEditingController(text: initialProfileFromBloc.whatsappNumber);
    _addressController =
        TextEditingController(text: initialProfileFromBloc.shopAddress);

    if (initialProfileFromBloc.countryCode.isNotEmpty) {
      try {
        _selectedCountry = Country.parse(initialProfileFromBloc.countryCode);
      } catch (e) {
        debugPrint(
            "Error parsing initial country code from BLoC: ${initialProfileFromBloc.countryCode}");
        // Keep default _selectedCountry if parsing fails
      }
    }

    _fullNameFocus = FocusNode()..addListener(_onFocusChange);
    _shopNameFocus = FocusNode()..addListener(_onFocusChange);
    _whatsappFocus = FocusNode()..addListener(_onFocusChange);
    _addressFocus = FocusNode()..addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ConnectivityBloc>().add(ConnectivityManuallyChecked());
      }
    });
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _shopNameController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _fullNameFocus.removeListener(_onFocusChange);
    _shopNameFocus.removeListener(_onFocusChange);
    _whatsappFocus.removeListener(_onFocusChange);
    _addressFocus.removeListener(_onFocusChange);
    _fullNameFocus.dispose();
    _shopNameFocus.dispose();
    _whatsappFocus.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  void _showNoInternetDialogIfNeeded() {
    if (!mounted || _isNoInternetDialogShowing) return;
    setState(() => _isNoInternetDialogShowing = true);
    showCustomNoInternetDialog(context).then((_) {
      if (mounted) setState(() => _isNoInternetDialogShowing = false);
    });
  }

  void _dismissNoInternetDialogIfNeeded() {
    if (mounted && _isNoInternetDialogShowing) {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      _isNoInternetDialogShowing = false;
    }
  }

  void _submitProfile() {
    final connectivityState = context.read<ConnectivityBloc>().state;
    if (connectivityState.status != AppConnectionStatus.connected) {
      _showNoInternetDialogIfNeeded();
      return;
    }
    context.read<ProfileCompletionBloc>().add(ProfileSubmitted());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode =
        context.watch<ThemeBloc>().state.themeMode == ThemeMode.dark;

    const Duration initialDelay = Duration(milliseconds: 100);
    const Duration staggerStep = Duration(milliseconds: 80);
    int staggerIndex = 0;

    return BlocConsumer<ProfileCompletionBloc, ProfileCompletionState>(
      listener: (context, profileStateListener) {
        // Renamed context to avoid conflict
        if (profileStateListener.status == ProfileCompletionStatus.failure &&
            profileStateListener.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                SnackBar(content: Text(profileStateListener.errorMessage!)));
        }
        if (profileStateListener.status == ProfileCompletionStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')));
          context.go(AppRoutes.home);
        }
      },
      builder: (context, profileState) {
        // Update text controllers if BLoC data differs and user isn't focused
        if (!_fullNameFocus.hasFocus &&
            _fullNameController.text != profileState.userProfile.fullName) {
          _fullNameController.text = profileState.userProfile.fullName;
        }
        if (!_shopNameFocus.hasFocus &&
            _shopNameController.text != profileState.userProfile.shopName) {
          _shopNameController.text = profileState.userProfile.shopName;
        }
        if (!_whatsappFocus.hasFocus &&
            _whatsappController.text !=
                profileState.userProfile.whatsappNumber) {
          _whatsappController.text = profileState.userProfile.whatsappNumber;
        }
        if (!_addressFocus.hasFocus &&
            _addressController.text != profileState.userProfile.shopAddress) {
          _addressController.text = profileState.userProfile.shopAddress;
        }

        // Update local _selectedCountry based on BLoC state for display purposes
        // This ensures the UI for country picker display is in sync with BLoC
        try {
          if (profileState.userProfile.countryCode.isNotEmpty &&
              _selectedCountry.countryCode !=
                  profileState.userProfile.countryCode) {
            _selectedCountry =
                Country.parse(profileState.userProfile.countryCode);
          }
        } catch (e) {
          debugPrint(
              "Error parsing country code from BLoC state in builder: ${profileState.userProfile.countryCode}");
        }

        return PopScope(
          canPop: profileState.status != ProfileCompletionStatus.submitting,
          child: BlocListener<ConnectivityBloc, ConnectivityState>(
            listener: (context, connectivityStateListener) {
              if (connectivityStateListener.status ==
                  AppConnectionStatus.disconnected) {
                _showNoInternetDialogIfNeeded();
              } else if (connectivityStateListener.status ==
                  AppConnectionStatus.connected) {
                _dismissNoInternetDialogIfNeeded();
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
                      top: 40, right: 16, child: ThemeToggleButton()),
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 30.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Card(
                          elevation: isDarkMode ? 4 : 8,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0)),
                          color: Theme.of(context)
                              .cardColor
                              .withAlpha(isDarkMode ? 235 : 250),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: profileState.formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  StaggeredEntranceAnimation(
                                    delay: initialDelay +
                                        staggerStep * staggerIndex++,
                                    child: Text('Complete Your Profile',
                                        style: textTheme.headlineSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 20),
                                  StaggeredEntranceAnimation(
                                    delay: initialDelay +
                                        staggerStep * staggerIndex++,
                                    child: ProfileImagePicker(
                                      localPhotoFile: profileState
                                          .userProfile.localPhotoFile,
                                      existingPhotoUrl:
                                          profileState.userProfile.photoUrl,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  StaggeredEntranceAnimation(
                                    delay: initialDelay +
                                        staggerStep * staggerIndex++,
                                    child: CustomTextFormField(
                                      controller: _fullNameController,
                                      focusNode: _fullNameFocus,
                                      isFocused: _fullNameFocus.hasFocus,
                                      hintText: 'Full Name*',
                                      prefixIcon: Icons.person_outline,
                                      onChanged: (value) => context
                                          .read<ProfileCompletionBloc>()
                                          .add(ProfileFullNameChanged(value)),
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                              ? 'Full name is required'
                                              : null,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  StaggeredEntranceAnimation(
                                    delay: initialDelay +
                                        staggerStep * staggerIndex++,
                                    child: CustomTextFormField(
                                      controller: _shopNameController,
                                      focusNode: _shopNameFocus,
                                      isFocused: _shopNameFocus.hasFocus,
                                      hintText: 'Shop Name*',
                                      prefixIcon: Icons.storefront_outlined,
                                      onChanged: (value) => context
                                          .read<ProfileCompletionBloc>()
                                          .add(ProfileShopNameChanged(value)),
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                              ? 'Shop name is required'
                                              : null,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  StaggeredEntranceAnimation(
                                    delay: initialDelay +
                                        staggerStep * staggerIndex++,
                                    child: TextFormField(
                                      initialValue:
                                          profileState.userProfile.email,
                                      readOnly: true,
                                      style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.grey[400]
                                              : Colors.grey[700]),
                                      decoration: InputDecoration(
                                        labelText:
                                            'Email Address (Cannot be changed)',
                                        prefixIcon: Icon(Icons.email_outlined,
                                            color: isDarkMode
                                                ? Colors.grey[500]
                                                : Colors.grey[600]),
                                        filled: true,
                                        fillColor: isDarkMode
                                            ? Colors.grey[800]
                                                ?.withAlpha((0.5 * 255).round())
                                            : Colors.grey[200]?.withAlpha(
                                                (0.5 * 255).round()),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            borderSide: BorderSide.none),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  StaggeredEntranceAnimation(
                                    delay: initialDelay +
                                        staggerStep * staggerIndex++,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            showCountryPicker(
                                              context: context,
                                              countryListTheme:
                                                  CountryListThemeData(
                                                bottomSheetHeight:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.7,
                                                backgroundColor:
                                                    Theme.of(context).cardColor,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft:
                                                      Radius.circular(20.0),
                                                  topRight:
                                                      Radius.circular(20.0),
                                                ),
                                                inputDecoration:
                                                    InputDecoration(
                                                  labelText: 'Search Country',
                                                  hintText: 'Start typing...',
                                                  prefixIcon:
                                                      const Icon(Icons.search),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color: const Color(
                                                              0xFF8C98A8)
                                                          .withAlpha((0.2 * 255)
                                                              .round()),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // REMOVED incorrect initialValue parameter
                                              onSelect: (Country country) {
                                                context
                                                    .read<
                                                        ProfileCompletionBloc>()
                                                    .add(ProfileCountryChanged(
                                                      countryCode:
                                                          country.countryCode,
                                                      dialCode:
                                                          '+${country.phoneCode}',
                                                    ));
                                                // _selectedCountry will be updated by BLoC state rebuilding UI
                                              },
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 15),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .canvasColor
                                                  .withAlpha(
                                                      (0.8 * 255).round()),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            child: Text(
                                              // Display from BLoC state, fallback to local _selectedCountry if BLoC is not yet updated
                                              profileState.userProfile.dialCode
                                                      .isNotEmpty
                                                  ? profileState
                                                      .userProfile.dialCode
                                                  : (_selectedCountry
                                                          .phoneCode.isNotEmpty
                                                      ? '+${_selectedCountry.phoneCode}'
                                                      : 'Select'),
                                              style: textTheme.bodyLarge
                                                  ?.copyWith(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: CustomTextFormField(
                                            controller: _whatsappController,
                                            focusNode: _whatsappFocus,
                                            isFocused: _whatsappFocus.hasFocus,
                                            hintText: 'Number*',
                                            keyboardType: TextInputType.phone,
                                            onChanged: (value) => context
                                                .read<ProfileCompletionBloc>()
                                                .add(
                                                    ProfileWhatsAppNumberChanged(
                                                        value)),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty)
                                                return 'Number required';
                                              if (!RegExp(r'^[0-9]{7,15}$')
                                                  .hasMatch(value))
                                                return 'Invalid number';
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StaggeredEntranceAnimation(
                                    delay: initialDelay +
                                        staggerStep * staggerIndex++,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: TextButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Send Code (Not Implemented)')));
                                          },
                                          child: const Text(
                                              'Send Code to WhatsApp'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  StaggeredEntranceAnimation(
                                    delay: initialDelay +
                                        staggerStep * staggerIndex++,
                                    child: CustomTextFormField(
                                      controller: _addressController,
                                      focusNode: _addressFocus,
                                      isFocused: _addressFocus.hasFocus,
                                      hintText: 'Shop Address*',
                                      prefixIcon: Icons.location_on_outlined,
                                      maxLines: 3,
                                      onChanged: (value) => context
                                          .read<ProfileCompletionBloc>()
                                          .add(
                                              ProfileShopAddressChanged(value)),
                                      validator: (value) =>
                                          (value == null || value.isEmpty)
                                              ? 'Shop address is required'
                                              : null,
                                    ),
                                  ),
                                  StaggeredEntranceAnimation(
                                    delay: initialDelay +
                                        staggerStep * staggerIndex++,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: TextButton.icon(
                                          icon: const Icon(Icons.map_outlined,
                                              size: 18),
                                          label: const Text('Select from Map'),
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Select from Map (Not Implemented)')));
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  StaggeredEntranceAnimation(
                                    delay: initialDelay +
                                        staggerStep * staggerIndex++,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: CustomElevatedButton(
                                        text: 'Submit Profile',
                                        isLoading: profileState.status ==
                                            ProfileCompletionStatus.submitting,
                                        onPressed: profileState.status ==
                                                ProfileCompletionStatus
                                                    .submitting
                                            ? null
                                            : _submitProfile,
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
      },
    );
  }
}
