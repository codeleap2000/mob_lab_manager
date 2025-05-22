part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

// Event triggered when user presses "Sign Up" button
class SignupWithFirebaseRequested extends AuthEvent {
  final String email;
  final String password;
  const SignupWithFirebaseRequested(
      {required this.email, required this.password});
  @override
  List<Object> get props => [email, password];
}

// Internal event triggered after Firebase user creation is successful
// This will then trigger the call to your custom OTP server
class SendCustomOtpAfterFirebaseSuccess extends AuthEvent {
  final String email;
  final String firebaseUserId; // Pass UID to potentially link on your server
  const SendCustomOtpAfterFirebaseSuccess(
      {required this.email, required this.firebaseUserId});
  @override
  List<Object> get props => [email, firebaseUserId];
}

// Event triggered when user submits OTP on OTP screen
class VerifyCustomOtpSubmitted extends AuthEvent {
  final String email;
  final String otp;
  final String
      firebaseUserId; // Needed if you want to link verification to Firebase user
  const VerifyCustomOtpSubmitted(
      {required this.email, required this.otp, required this.firebaseUserId});
  @override
  List<Object> get props => [email, otp, firebaseUserId];
}

// --- We will add Login and Logout events later ---
// class LoginWithEmailPasswordRequested extends AuthEvent {
//   final String email;
//   final String password;
//   const LoginWithEmailPasswordRequested({required this.email, required this.password});
//   @override
//   List<Object> get props => [email, password];
// }

// class LogoutRequested extends AuthEvent {}
