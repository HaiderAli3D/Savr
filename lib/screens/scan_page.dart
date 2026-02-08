import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/camera_viewfinder.dart';
import '../widgets/scan_line.dart';
import '../widgets/shutter_flash.dart';

enum ScanPhase { camera, captured, processing }

class ScanReceiptPage extends StatefulWidget {
  const ScanReceiptPage({super.key});

  @override
  State<ScanReceiptPage> createState() => _ScanReceiptPageState();
}

class _ScanReceiptPageState extends State<ScanReceiptPage> {
  ScanPhase _phase = ScanPhase.camera;
  bool _showFlash = false;
  XFile? _capturedImage;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main camera/image view
          Positioned.fill(
            child: _buildCameraView(context, appState),
          ),

          // Shutter flash effect
          Positioned.fill(
            child: ShutterFlash(visible: _showFlash),
          ),

          // Vignette overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Camera UI overlay
          if (_phase == ScanPhase.camera) _buildCameraUI(context),

          // Processing overlay
          if (_phase == ScanPhase.processing) _buildProcessingUI(context),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildCameraView(BuildContext context, AppState appState) {
    if (_capturedImage != null || appState.selectedImage != null) {
      final image = _capturedImage ?? appState.selectedImage!;
      return kIsWeb
          ? Image.network(image.path, fit: BoxFit.cover)
          : Image.file(File(image.path), fit: BoxFit.cover);
    }

    // Placeholder for camera (in real app, would show camera feed)
    return Container(
      color: AppColors.background,
      child: Center(
        child: Icon(
          Icons.camera_alt,
          size: 100,
          color: AppColors.mutedForeground.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildCameraUI(BuildContext context) {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Instruction text
          Text(
            'ALIGN RECEIPT TO SCAN',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textTertiary,
                ),
          ),
          const SizedBox(height: 40),
          
          // Viewfinder frame
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.75,
            height: MediaQuery.of(context).size.width * 0.75 * 1.5,
            child: Stack(
              children: [
                const CameraViewfinder(),
                const ScanLine(isActive: true),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Camera controls
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Upload button
                _buildControlButton(
                  icon: Icons.upload_rounded,
                  label: 'Upload',
                  onTap: () => _pickImage(context, ImageSource.gallery),
                ),
                const SizedBox(width: 40),
                
                // Capture button
                GestureDetector(
                  onTap: () => _handleCapture(context),
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 40),
                // Spacer to balance layout
                const SizedBox(width: 44),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingUI(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Full-screen scan line
          const ScanLine(isActive: true),
          
          // Status text
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ANALYZING RECEIPT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCapture(BuildContext context) async {
    setState(() {
      _showFlash = true;
    });

    await Future.delayed(const Duration(milliseconds: 250));
    setState(() {
      _showFlash = false;
    });

    // Try to get image from camera
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null && mounted) {
        setState(() {
          _capturedImage = image;
          _phase = ScanPhase.captured;
        });

        // Brief pause to show captured image
        await Future.delayed(const Duration(milliseconds: 600));

        // Start processing
        setState(() {
          _phase = ScanPhase.processing;
        });

        // Save to state and navigate
        if (mounted) {
          context.read<AppState>().setImage(image);
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            context.push('/preferences');
          }
        }
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      if (mounted) {
        setState(() {
          _phase = ScanPhase.camera;
        });
      }
    }
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    try {
      setState(() {
        _showFlash = true;
      });

      final XFile? image = await picker.pickImage(source: source);
      
      setState(() {
        _showFlash = false;
      });

      if (image != null && mounted) {
        setState(() {
          _capturedImage = image;
          _phase = ScanPhase.captured;
        });

        await Future.delayed(const Duration(milliseconds: 600));

        setState(() {
          _phase = ScanPhase.processing;
        });

        context.read<AppState>().setImage(image);
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          context.push('/preferences');
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        setState(() {
          _phase = ScanPhase.camera;
        });
      }
    }
  }
}
