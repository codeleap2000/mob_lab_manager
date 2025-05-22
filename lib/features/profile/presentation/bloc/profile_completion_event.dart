part of 'profile_completion_bloc.dart';

abstract class ProfileCompletionEvent extends Equatable {
  const ProfileCompletionEvent();

  @override
  List<Object?> get props => [];
}

class ProfileCompletionLoadInitial extends ProfileCompletionEvent {
  final String email; // Email passed from OTP/Signup screen
  final String userId; // User ID from auth system (placeholder for now)
  const ProfileCompletionLoadInitial(
      {required this.email, required this.userId});

  @override
  List<Object?> get props => [email, userId];
}

class ProfilePhotoChanged extends ProfileCompletionEvent {
  final File? photo;
  const ProfilePhotoChanged(this.photo);

  @override
  List<Object?> get props => [photo];
}

class ProfileFullNameChanged extends ProfileCompletionEvent {
  final String fullName;
  const ProfileFullNameChanged(this.fullName);
  @override
  List<Object?> get props => [fullName];
}

class ProfileShopNameChanged extends ProfileCompletionEvent {
  final String shopName;
  const ProfileShopNameChanged(this.shopName);
  @override
  List<Object?> get props => [shopName];
}

class ProfileCountryChanged extends ProfileCompletionEvent {
  final String countryCode;
  final String dialCode;
  const ProfileCountryChanged(
      {required this.countryCode, required this.dialCode});
  @override
  List<Object?> get props => [countryCode, dialCode];
}

class ProfileWhatsAppNumberChanged extends ProfileCompletionEvent {
  final String whatsappNumber;
  const ProfileWhatsAppNumberChanged(this.whatsappNumber);
  @override
  List<Object?> get props => [whatsappNumber];
}

class ProfileShopAddressChanged extends ProfileCompletionEvent {
  final String shopAddress;
  const ProfileShopAddressChanged(this.shopAddress);
  @override
  List<Object?> get props => [shopAddress];
}

// class ProfileLocationSelected extends ProfileCompletionEvent {
//   final LatLng location; // Placeholder for map data
//   const ProfileLocationSelected(this.location);
//   @override
//   List<Object?> get props => [location];
// }

class ProfileSubmitted extends ProfileCompletionEvent {}
