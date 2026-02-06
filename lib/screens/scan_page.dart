import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../nav.dart';

class ScanReceiptPage extends StatelessWidget {
  const ScanReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access state
    final appState = context.watch<AppState>();
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary, // Dark background for scan page
      appBar: AppBar(
        title: const Text('Scan Your Receipt'),
        // No back button on first page, but if pushed:
        leading: context.canPop() ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ) : null,
      ),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          // Receipt Preview / Camera Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (appState.selectedImage != null)
                     kIsWeb 
                      ? Image.network(
                          appState.selectedImage!.path,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(appState.selectedImage!.path),
                          fit: BoxFit.cover,
                        )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No receipt selected',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  
                  // Scanning Overlay (Decorative)
                  if (appState.selectedImage == null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      color: Colors.white.withValues(alpha: 0.9),
                      child: Text(
                        'Snap a photo of your receipt to get started.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Action Buttons
          if (appState.selectedImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: ElevatedButton(
                onPressed: () => _pickImage(context, ImageSource.camera),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B), // Darker slate
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Retake or Confirm >'),
              ),
            )
          else 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(context, ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),

          SizedBox(height: AppSpacing.md),
          
          if (appState.selectedImage == null)
            TextButton(
              onPressed: () => _pickImage(context, ImageSource.gallery),
              child: const Text(
                'Upload from Gallery',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            
          const SizedBox(height: AppSpacing.xl),

          // Next Button
          if (appState.selectedImage != null)
             Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl, left: AppSpacing.lg, right: AppSpacing.lg),
              child: TextButton(
                onPressed: () {
                  context.push('/preferences');
                },
                child: const Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null && context.mounted) {
        context.read<AppState>().setImage(image);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }
}
