import 'dart:async';
import 'dart:convert'; // For jsonEncode
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:http/http.dart' as http; // HTTP package

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Your RDP server's base URL for OTP operations
  final String _otpServerBaseUrl = "http://56.228.16.166:3000/api/otp";
  // For Android emulator, if server is on host: "http://10.0.2.2:3000/api/otp";

  AuthBloc() : super(const AuthState()) {
    on<SignupWithFirebaseRequested>(_onSignupWithFirebaseRequested);
    on<SendCustomOtpAfterFirebaseSuccess>(_onSendCustomOtpAfterFirebaseSuccess);
    on<VerifyCustomOtpSubmitted>(_onVerifyCustomOtpSubmitted);
    // Add handlers for LoginRequested and LogoutRequested later
  }

  Future<void> _onSignupWithFirebaseRequested(
    SignupWithFirebaseRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));
    try {
      debugPrint(
          '[AuthBloc] Attempting Firebase user creation for: ${event.email}');
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password:
            event.password, // Password validation should happen in UI/Form
      );
      debugPrint(
          '[AuthBloc] Firebase user created: ${userCredential.user?.uid}');

      if (userCredential.user != null) {
        // Firebase user created, now emit state to trigger custom OTP sending
        emit(state.copyWith(
            status: AuthStatus.firebaseSignupSuccess, // Intermediate state
            firebaseUser: userCredential.user,
            emailForOtpScreen: event.email.trim()));
        // Add new event to actually send OTP via your server
        add(SendCustomOtpAfterFirebaseSuccess(
            email: event.email.trim(),
            firebaseUserId: userCredential.user!.uid));
      } else {
        emit(state.copyWith(
            status: AuthStatus.failure,
            errorMessage: 'Firebase user not created.'));
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
          '[AuthBloc] Firebase Signup FirebaseAuthException: ${e.message} (Code: ${e.code})');
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.message ?? 'Signup failed.'));
    } catch (e) {
      debugPrint('[AuthBloc] Firebase Signup General Exception: $e');
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'An unexpected error occurred during signup.'));
    }
  }

  Future<void> _onSendCustomOtpAfterFirebaseSuccess(
    SendCustomOtpAfterFirebaseSuccess event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
        status: AuthStatus.customOtpSending, clearErrorMessage: true));
    try {
      debugPrint(
          '[AuthBloc] Requesting OTP from RDP server for: ${event.email}');
      final response = await http
          .post(
            Uri.parse('$_otpServerBaseUrl/send-verification-otp'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8'
            },
            body: jsonEncode(<String, String>{'email': event.email}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint(
          '[AuthBloc] Send OTP Server Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(state.copyWith(
            status: AuthStatus.customOtpSent,
            emailForOtpScreen:
                event.email // Ensure email is passed for OTP screen
            ));
      } else {
        String errMsg =
            "Failed to send OTP. Server responded with ${response.statusCode}";
        try {
          errMsg = jsonDecode(response.body)['message'] ?? errMsg;
        } catch (_) {}
        emit(state.copyWith(status: AuthStatus.failure, errorMessage: errMsg));
      }
    } catch (e) {
      debugPrint('[AuthBloc] Send OTP Exception: $e');
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Failed to send OTP. Check connection or server.'));
    }
  }

  Future<void> _onVerifyCustomOtpSubmitted(
    VerifyCustomOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
        status: AuthStatus.otpVerificationInProgress, clearErrorMessage: true));
    try {
      debugPrint(
          '[AuthBloc] Verifying OTP with RDP server for: ${event.email}, OTP: ${event.otp}');
      final response = await http
          .post(
            Uri.parse('$_otpServerBaseUrl/verify-otp'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8'
            },
            body: jsonEncode(
                <String, String>{'email': event.email, 'otp': event.otp}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint(
          '[AuthBloc] Verify OTP Server Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        // OTP Verified by your server.
        // You might want to reload the Firebase user if your server updated Firebase (e.g., emailVerified flag via Admin SDK)
        // For now, we assume custom verification is enough to proceed.
        // await state.firebaseUser?.reload();
        // final refreshedUser = _firebaseAuth.currentUser;
        emit(state.copyWith(
          status: AuthStatus.otpVerifiedSuccessfully,
          // firebaseUser: refreshedUser ?? state.firebaseUser // Update user if reloaded
        ));
      } else {
        String errMsg =
            "Invalid or expired OTP. Server responded: ${response.statusCode}";
        try {
          errMsg = jsonDecode(response.body)['message'] ?? errMsg;
        } catch (_) {}
        emit(state.copyWith(status: AuthStatus.failure, errorMessage: errMsg));
      }
    } catch (e) {
      debugPrint('[AuthBloc] Verify OTP Exception: $e');
      emit(state.copyWith(
          status: AuthStatus.failure,
          errorMessage:
              'OTP verification failed. Check connection or server.'));
    }
  }
}
