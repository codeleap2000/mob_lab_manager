import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // For GlobalKey & debugPrint
import 'package:mob_lab_manger/features/profile/domain/entities/user_profile.dart';
import 'package:image_picker/image_picker.dart';

part 'profile_completion_event.dart';
part 'profile_completion_state.dart';

class ProfileCompletionBloc
    extends Bloc<ProfileCompletionEvent, ProfileCompletionState> {
  final ImagePicker _imagePicker = ImagePicker();

  ProfileCompletionBloc() : super(ProfileCompletionState.initial('', '')) {
    // Dummy initial values
    on<ProfileCompletionLoadInitial>(_onLoadInitial);
    on<ProfilePhotoChanged>(_onPhotoChanged);
    on<ProfileFullNameChanged>(_onFullNameChanged);
    on<ProfileShopNameChanged>(_onShopNameChanged);
    on<ProfileCountryChanged>(_onCountryChanged);
    on<ProfileWhatsAppNumberChanged>(_onWhatsAppNumberChanged);
    on<ProfileShopAddressChanged>(_onShopAddressChanged);
    on<ProfileSubmitted>(_onProfileSubmitted);
  }

  void _onLoadInitial(ProfileCompletionLoadInitial event,
      Emitter<ProfileCompletionState> emit) {
    debugPrint(
        "[ProfileBloc] Loading initial profile with email: ${event.email}, userId: ${event.userId}");
    emit(ProfileCompletionState.initial(event.email, event.userId)
        .copyWith(status: ProfileCompletionStatus.loaded));
  }

  Future<void> _onPhotoChanged(
      ProfilePhotoChanged event, Emitter<ProfileCompletionState> emit) async {
    // This event is now primarily for when the user *initiates* a photo change.
    // The actual file selection happens in the UI.
    // If a file is passed (e.g. from UI after picking), update the state.
    if (event.photo != null) {
      emit(state.copyWith(
        userProfile: state.userProfile.copyWith(localPhotoFile: event.photo),
        status: ProfileCompletionStatus.loaded,
      ));
    } else {
      // Logic to pick image if event.photo is null (meaning user wants to pick)
      // This is better handled in the UI layer which then dispatches ProfilePhotoChanged with the File.
      // For now, if photo is null, we assume it's to clear it.
      emit(state.copyWith(
        userProfile: state.userProfile
            .copyWith(clearLocalPhoto: true), // Clears localPhotoFile
        status: ProfileCompletionStatus.loaded,
      ));
    }
  }

  void _onFullNameChanged(
      ProfileFullNameChanged event, Emitter<ProfileCompletionState> emit) {
    emit(state.copyWith(
        userProfile: state.userProfile.copyWith(fullName: event.fullName)));
  }

  void _onShopNameChanged(
      ProfileShopNameChanged event, Emitter<ProfileCompletionState> emit) {
    emit(state.copyWith(
        userProfile: state.userProfile.copyWith(shopName: event.shopName)));
  }

  void _onCountryChanged(
      ProfileCountryChanged event, Emitter<ProfileCompletionState> emit) {
    emit(state.copyWith(
      userProfile: state.userProfile.copyWith(
        countryCode: event.countryCode,
        dialCode: event.dialCode,
      ),
    ));
  }

  void _onWhatsAppNumberChanged(ProfileWhatsAppNumberChanged event,
      Emitter<ProfileCompletionState> emit) {
    emit(state.copyWith(
        userProfile:
            state.userProfile.copyWith(whatsappNumber: event.whatsappNumber)));
  }

  void _onShopAddressChanged(
      ProfileShopAddressChanged event, Emitter<ProfileCompletionState> emit) {
    emit(state.copyWith(
        userProfile:
            state.userProfile.copyWith(shopAddress: event.shopAddress)));
  }

  Future<void> _onProfileSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileCompletionState> emit,
  ) async {
    if (state.formKey.currentState?.validate() ?? false) {
      emit(state.copyWith(status: ProfileCompletionStatus.submitting));
      debugPrint(
          "[ProfileBloc] Profile Data to be Submitted: ${state.userProfile}");

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implement actual data submission to backend/database
      // 1. If state.userProfile.localPhotoFile is not null, upload it and get the URL.
      //    Update userProfile.photoUrl with the new URL.
      // 2. Save all profile data (state.userProfile) to your backend.

      // For now, simulate success
      // In a real app, you'd get the updated profile (e.g., with photoUrl) from the backend.
      emit(state.copyWith(
        status: ProfileCompletionStatus.success,
        // userProfile: state.userProfile.copyWith(photoUrl: "simulated_uploaded_url.jpg") // Example
      ));
      debugPrint("[ProfileBloc] Profile Submission Success (Simulated)");
    } else {
      debugPrint(
          "[ProfileBloc] Profile Submission Failed: Form validation errors.");
      emit(state.copyWith(
          status: ProfileCompletionStatus.failure,
          errorMessage: "Please fill all required fields correctly."));
      await Future.delayed(const Duration(seconds: 3));
      if (!isClosed && state.status == ProfileCompletionStatus.failure) {
        emit(state.copyWith(
            clearErrorMessage: true,
            status: ProfileCompletionStatus.loaded)); // Reset status to loaded
      }
    }
  }

  // Helper method to be called from UI to pick image
  Future<File?> pickProfileImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70, // Adjust quality
        maxWidth: 800, // Adjust max width
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      debugPrint("[ProfileBloc] Error picking image: $e");
      // Could emit a state with an error message for the UI to display
    }
    return null;
  }
}
