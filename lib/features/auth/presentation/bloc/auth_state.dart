part of 'auth_bloc.dart';

enum AuthStatus {
  initial, // Initial state
  loading, // General loading for any auth operation (Firebase or custom OTP)

  firebaseSignupSuccess, // Firebase user created, waiting to trigger custom OTP send
  customOtpSending, // Calling your RDP server to send OTP
  customOtpSent, // OTP successfully sent by your server, ready to navigate to OTP screen

  otpVerificationInProgress, // Verifying OTP with your RDP server
  otpVerifiedSuccessfully, // OTP verified by your RDP server, ready for next step (e.g., profile)

  // loginSuccess, // For login later
  // unauthenticated, // For logout or initial state if no user later

  failure // Any auth-related operation failed
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? firebaseUser; // firebase_auth.User object
  final String? emailForOtpScreen; // Email to pass to OTP screen
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.firebaseUser,
    this.emailForOtpScreen,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? firebaseUser,
    bool clearFirebaseUser = false,
    String? emailForOtpScreen,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      firebaseUser:
          clearFirebaseUser ? null : firebaseUser ?? this.firebaseUser,
      emailForOtpScreen: emailForOtpScreen ?? this.emailForOtpScreen,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, firebaseUser, emailForOtpScreen, errorMessage];
}
