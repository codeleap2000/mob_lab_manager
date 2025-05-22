import 'package:equatable/equatable.dart';
import 'dart:io'; // For File type

class UserProfile extends Equatable {
  final String id; // User ID from auth
  final String? photoUrl; // URL if already uploaded, or null
  final File? localPhotoFile; // Local file picked by user
  final String fullName;
  final String shopName;
  final String email; // Fetched from previous screen, non-editable here
  final String countryCode;
  final String dialCode;
  final String whatsappNumber; // Just the number part, without country code
  final String shopAddress;
  // final LatLng? shopLocation; // For map data later

  const UserProfile({
    required this.id,
    this.photoUrl,
    this.localPhotoFile,
    this.fullName = '',
    this.shopName = '',
    required this.email,
    this.countryCode = 'PK', // Default country code
    this.dialCode = '+92', // Default dial code
    this.whatsappNumber = '',
    this.shopAddress = '',
    // this.shopLocation,
  });

  UserProfile copyWith({
    String? id,
    String? photoUrl,
    File? localPhotoFile,
    bool clearLocalPhoto = false, // To explicitly clear local photo
    String? fullName,
    String? shopName,
    String? email,
    String? countryCode,
    String? dialCode,
    String? whatsappNumber,
    String? shopAddress,
  }) {
    return UserProfile(
      id: id ?? this.id,
      photoUrl: photoUrl ?? this.photoUrl,
      localPhotoFile:
          clearLocalPhoto ? null : localPhotoFile ?? this.localPhotoFile,
      fullName: fullName ?? this.fullName,
      shopName: shopName ?? this.shopName,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      dialCode: dialCode ?? this.dialCode,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      shopAddress: shopAddress ?? this.shopAddress,
    );
  }

  String get fullWhatsAppNumber => '$dialCode$whatsappNumber';

  @override
  List<Object?> get props => [
        id,
        photoUrl,
        localPhotoFile,
        fullName,
        shopName,
        email,
        countryCode,
        dialCode,
        whatsappNumber,
        shopAddress,
      ];
}
