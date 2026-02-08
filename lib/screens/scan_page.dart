import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../nav.dart';
import '../widgets/camera_viewfinder.dart';
import '../widgets/scan_line.dart';

enum ScanPhase { camera, captured, processing }

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _permissionDenied = false;
  ScanPhase _phase = ScanPhase.camera;
  bool _showFlash = false;
  String? _previewImagePath;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }
  
  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _permissionDenied = true;
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _pickImageFromGallery();
      return;
    }

    setState(() {
      _showFlash = true;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      
      setState(() {
        _previewImagePath = photo.path;
        _phase = ScanPhase.captured;
        _showFlash = false;
      });

      // Brief pause to show captured image
      await Future.delayed(const Duration(milliseconds: 600));
      
      setState(() {
        _phase = ScanPhase.processing;
      });

      // Store image and analyze
      if (mounted) {
        context.read<AppState>().setImage(photo);
        await context.read<AppState>().analyzeReceipt();
        
        if (mounted) {
          context.go(AppRoutes.results);
        }
      }
    } catch (e) {
      setState(() {
        _showFlash = false;
        _phase = ScanPhase.camera;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          _showFlash = true;
        });
        
        await Future.delayed(const Duration(milliseconds: 250));
        
        setState(() {
          _previewImagePath = image.path;
          _phase = ScanPhase.captured;
          _showFlash = false;
        });
        
        await Future.delayed(const Duration(milliseconds: 600));
        
        setState(() {
          _phase = ScanPhase.processing;
        });
        
        context.read<AppState>().setImage(image);
        await context.read<AppState>().analyzeReceipt();
        
        if (mounted) {
          context.go(AppRoutes.results);
        }
      }
    } catch (e) {
      setState(() {
        _showFlash = false;
        _phase = ScanPhase.camera;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Camera feed or captured image
          Positioned.fill(
            child: _buildCameraView(),
          ),
          
          // Flash overlay
          if (_showFlash)
            Positioned.fill(
              child: Container(
                color: Colors.white,
              ).animate().fade(duration: 250.ms),
            ),
          
          // Vignette overlay
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  colors: [Colors.transparent, Colors.black54],
                  stops: [0.5, 1.0],
                ),
              ),
            ),
          ),
          
          // UI Overlay
          Positioned.fill(
            child: SafeArea(
              child: _buildUIOverlay(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (_phase == ScanPhase.camera) {
      if (_permissionDenied) {
        return Container(
          color: Colors.black,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 64, color: Colors.white54),
                SizedBox(height: 16),
                Text(
                  'Camera permission denied',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Please enable camera access in settings',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }
      
      if (!_isCameraInitialized) {
        return Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }
      
      return CameraPreview(_cameraController!);
    }
    
    // Show captured/processing image
    if (_previewImagePath != null) {
      return Stack(
        children: [
          Positioned.fill(
            child: _buildImagePreview(_previewImagePath!),
          ),
          if (_phase == ScanPhase.processing)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const ScanLine(isActive: true),
              ).animate().fade(duration: 300.ms, delay: 150.ms),
            ),
        ],
      );
    }
    
    return Container(color: Colors.black);
  }

  Widget _buildImagePreview(String imagePath) {
    try {
      final file = File(imagePath);
      
      // Validate file exists
      if (!file.existsSync()) {
        return _buildErrorContainer('Image file not found');
      }

      // Validate file size (prevent memory issues with very large files)
      final fileSizeBytes = file.lengthSync();
      const maxFileSizeBytes = 50 * 1024 * 1024; // 50MB limit
      
      if (fileSizeBytes > maxFileSizeBytes) {
        return _buildErrorContainer('Image file too large');
      }

      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorContainer('Failed to load image');
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: frame == null ? 0 : 1,
            child: child,
          );
        },
      );
    } catch (e) {
      return _buildErrorContainer('Error accessing image');
    }
  }

  Widget _buildErrorContainer(String message) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported,
              color: Colors.white54,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Image Error',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUIOverlay() {
    if (_phase == ScanPhase.camera) {
      final screenSize = MediaQuery.of(context).size;
      final safeArea = MediaQuery.of(context).padding;
      
      // Calculate responsive dimensions
      final availableHeight = screenSize.height - safeArea.top - safeArea.bottom;
      final availableWidth = screenSize.width;
      
      // Responsive viewfinder size (max 300x450, but scales down if needed)
      final maxViewfinderWidth = (availableWidth * 0.75).clamp(200.0, 300.0);
      final maxViewfinderHeight = (availableHeight * 0.55).clamp(300.0, 450.0);
      
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: availableHeight,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Top spacing - responsive to screen height
              SizedBox(height: availableHeight * 0.05),
              
              Text(
                'ALIGN RECEIPT TO SCAN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                  color: Colors.white.withOpacity(0.3),
                ),
              ).animate().fade(delay: 500.ms),
              
              // Responsive spacing
              SizedBox(height: availableHeight * 0.04),
              
              // Camera Viewfinder - Responsive size
              SizedBox(
                width: maxViewfinderWidth,
                height: maxViewfinderHeight,
                child: const CameraViewfinder(),
              ),
              
              // Flexible spacer
              SizedBox(height: availableHeight * 0.08),
              
              // Camera controls
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (availableWidth * 0.1).clamp(20.0, 40.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Upload button
                    GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: const Icon(
                              Icons.upload,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'UPLOAD',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                              color: Colors.white.withOpacity(0.4),
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Capture button
                    GestureDetector(
                      onTap: _capturePhoto,
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
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Spacer for alignment
                    const SizedBox(width: 44),
                  ],
                ),
              ),
              
              // Bottom spacing - responsive to screen height
              SizedBox(height: availableHeight * 0.06),
            ],
          ),
        ),
      );
    }
    
    if (_phase == ScanPhase.processing) {
      final screenSize = MediaQuery.of(context).size;
      final safeArea = MediaQuery.of(context).padding;
      final availableHeight = screenSize.height - safeArea.top - safeArea.bottom;
      
      return Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: availableHeight * 0.15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ).animate(onPlay: (controller) => controller.repeat()).fade(
                duration: 1200.ms,
                curve: Curves.easeInOut,
              ),
              
              const SizedBox(width: 10),
              
              Text(
                'ANALYZING RECEIPT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ).animate().fade(delay: 500.ms, duration: 400.ms),
        ),
      );
    }
    
    return const SizedBox();
  }
}

class ScanReceiptPage extends ScanPage {
  const ScanReceiptPage({super.key});
}
