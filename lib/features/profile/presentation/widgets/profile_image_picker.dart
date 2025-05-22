import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mob_lab_manger/app/bloc/theme_bloc.dart';
import 'package:mob_lab_manger/features/profile/presentation/bloc/profile_completion_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart'; // Added for refined permission handling

class ProfileImagePicker extends StatelessWidget {
  final File? localPhotoFile;
  final String? existingPhotoUrl;
  final double radius;
  final IconData placeholderIcon;

  const ProfileImagePicker({
    super.key,
    this.localPhotoFile,
    this.existingPhotoUrl,
    this.radius = 60.0,
    this.placeholderIcon = Icons.person_outline_rounded,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          status = await Permission.photos.request();
        } else {
          status =
              await Permission.storage.request(); // For older Android versions
        }
      } else {
        // iOS or other platforms
        status = await Permission.photos.request();
      }
    }

    if (status.isGranted) {
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          imageQuality: 70,
          maxWidth: 800,
        );
        if (pickedFile != null && context.mounted) {
          context
              .read<ProfileCompletionBloc>()
              .add(ProfilePhotoChanged(File(pickedFile.path)));
        }
      } catch (e) {
        debugPrint("Error picking image: $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error picking image: ${e.toString()}')),
          );
        }
      }
    } else if (status.isPermanentlyDenied ||
        status.isDenied && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(source == ImageSource.camera
              ? 'Camera permission denied. Please enable it in settings.'
              : 'Storage permission denied. Please enable it in settings.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pick from Gallery'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _pickImage(context, ImageSource.camera);
                },
              ),
              if (localPhotoFile != null ||
                  (existingPhotoUrl != null && existingPhotoUrl!.isNotEmpty))
                ListTile(
                  leading: Icon(Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error),
                  title: Text('Remove Photo',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error)),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    context
                        .read<ProfileCompletionBloc>()
                        .add(const ProfilePhotoChanged(null));
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode =
        context.watch<ThemeBloc>().state.themeMode == ThemeMode.dark;

    Widget imageWidget;
    if (localPhotoFile != null) {
      imageWidget = ClipOval(
        child: Image.file(
          localPhotoFile!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
        ),
      );
    } else if (existingPhotoUrl != null && existingPhotoUrl!.isNotEmpty) {
      imageWidget = ClipOval(
        child: Image.network(
          existingPhotoUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Icon(placeholderIcon, size: radius, color: colorScheme.primary),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    } else {
      // Corrected: Replaced withOpacity with withAlpha
      imageWidget = Icon(placeholderIcon,
          size: radius,
          color: colorScheme.primary.withAlpha((0.7 * 255).round()));
    }

    return Column(
      children: [
        InkWell(
          onTap: () => _showImageSourceActionSheet(context),
          customBorder: const CircleBorder(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: radius,
                backgroundColor:
                    isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                child: imageWidget,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.cardColor, width: 2)),
                  child: Icon(Icons.edit_outlined,
                      color: colorScheme.onPrimary, size: radius * 0.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
