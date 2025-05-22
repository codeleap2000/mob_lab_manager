part of 'profile_completion_bloc.dart';

enum ProfileCompletionStatus {
  initial,
  loading,
  loaded,
  submitting,
  success,
  failure
}

class ProfileCompletionState extends Equatable {
  final UserProfile userProfile;
  final ProfileCompletionStatus status;
  final String? errorMessage;
  final GlobalKey<FormState> formKey; // To manage form validation

  const ProfileCompletionState({
    required this.userProfile,
    this.status = ProfileCompletionStatus.initial,
    this.errorMessage,
    required this.formKey,
  });

  // Initial state factory
  factory ProfileCompletionState.initial(String email, String userId) {
    return ProfileCompletionState(
      userProfile: UserProfile(email: email, id: userId),
      formKey: GlobalKey<FormState>(), // Initialize form key
      status: ProfileCompletionStatus.initial, // Explicitly set initial status
    );
  }

  ProfileCompletionState copyWith({
    UserProfile? userProfile,
    ProfileCompletionStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
    // GlobalKey<FormState> formKey, // FormKey should not be copied this way, it's tied to the state instance
  }) {
    return ProfileCompletionState(
      userProfile: userProfile ?? this.userProfile,
      status: status ?? this.status,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      formKey: this.formKey, // Keep the existing formKey
    );
  }

  @override
  List<Object?> get props => [userProfile, status, errorMessage, formKey];
}
