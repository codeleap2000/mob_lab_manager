import 'package:equatable/equatable.dart';

// This class now represents an immutable rule definition.
// The actual validation (true/false) will be determined at the time of use.
class PasswordValidationRule extends Equatable {
  final String description;
  final bool Function(String)
      validator; // The function that performs the validation

  const PasswordValidationRule({
    // Changed to const constructor
    required this.description,
    required this.validator,
  });

  @override
  List<Object?> get props =>
      [description, validator]; // validator included for equality if needed
}
