import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/animated_bottom_nav.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class ScanReceiptPage extends StatelessWidget {
  const ScanReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: Center(
                child: appState.selectedImage != null
                    ? _buildImagePreview(context, appState)
                    : _buildEmptyState(context),
              ),
            ),

            // Bottom Navigation
            const AnimatedBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context, AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Image preview
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 500),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Stack(
                children: [
                  kIsWeb
                      ? Image.network(
                          appState.selectedImage!.path,
                          fit: BoxFit.contain,
                        )
                      : Image.file(
                          File(appState.selectedImage!.path),
                          fit: BoxFit.contain,
                        ),
                  
                  // Retake button overlay
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        color: AppColors.textPrimary,
                        onPressed: () => context.push('/camera'),
                        tooltip: 'Retake',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Continue Button
          PrimaryButton(
            label: 'Continue',
            icon: Icons.arrow_forward,
            fullWidth: true,
            onPressed: () => context.push('/preferences'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty icon
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.primary.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 32),

          Text(
            'No receipt scanned yet',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          Text(
            'Take a photo or upload an image to get started',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Camera Button
          PrimaryButton(
            label: 'Take Photo',
            icon: Icons.camera_alt,
            fullWidth: true,
            onPressed: () => context.push('/camera'),
          ),

          const SizedBox(height: 16),

          // Gallery Button
          SecondaryButton(
            label: 'Upload from Gallery',
            icon: Icons.photo_library_outlined,
            fullWidth: true,
            onPressed: () => _pickImage(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null && context.mounted) {
        context.read<AppState>().setImage(image);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
