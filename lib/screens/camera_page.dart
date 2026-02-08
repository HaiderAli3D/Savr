import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/camera_viewfinder.dart';
import '../widgets/scan_line.dart';
import '../widgets/shutter_flash.dart';
import '../widgets/ocr_scan_effect.dart';
import '../widgets/animated_bottom_nav.dart';
import 'package:go_router/go_router.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _showFlash = false;
  
  // Camera phase states
  CameraPhase _phase = CameraPhase.camera;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        return;
      }

      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _phase != CameraPhase.camera) {
      return;
    }

    // Show flash
    setState(() {
      _showFlash = true;
    });

    await Future.delayed(const Duration(milliseconds: 250));

    setState(() {
      _showFlash = false;
    });

    try {
      final image = await _controller!.takePicture();
      
      setState(() {
        _capturedImagePath = image.path;
        _phase = CameraPhase.captured;
      });

      // Briefly show captured image, then process
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _phase = CameraPhase.processing;
      });

      // Simulate processing
      await Future.delayed(const Duration(milliseconds: 2800));

      if (mounted) {
        context.read<AppState>().setImage(XFile(image.path));
        context.go('/scan'); // Navigate back with the captured image
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      setState(() {
        _phase = CameraPhase.camera;
        _capturedImagePath = null;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null && mounted) {
        setState(() {
          _showFlash = true;
        });

        await Future.delayed(const Duration(milliseconds: 250));

        setState(() {
          _showFlash = false;
          _capturedImagePath = image.path;
          _phase = CameraPhase.processing;
        });

        await Future.delayed(const Duration(milliseconds: 2800));

        if (mounted) {
          context.read<AppState>().setImage(image);
          context.go('/scan');
        }
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview or captured image
          if (_phase == CameraPhase.camera && _isInitialized && _controller != null)
            Center(
              child: CameraPreview(_controller!),
            )
          else if ((_phase == CameraPhase.captured || _phase == CameraPhase.processing) && 
                   _capturedImagePath != null)
            Image.file(
              File(_capturedImagePath!),
              fit: BoxFit.cover,
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),

          // Shutter flash
          Positioned.fill(
            child: ShutterFlash(visible: _showFlash),
          ),

          // OCR scan effect (only during processing)
          if (_phase == CameraPhase.processing)
            const Positioned.fill(
              child: OcrScanEffect(),
            ),

          // Vignette overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.75),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),

          // Camera UI overlay (only in camera phase)
          if (_phase == CameraPhase.camera && _isInitialized)
            _buildCameraUI(),

          // Processing UI overlay
          if (_phase == CameraPhase.processing)
            _buildProcessingUI(),

          // Back button
          if (_phase == CameraPhase.camera)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraUI() {
    return Stack(
      children: [
        // Viewfinder
        const Positioned.fill(
          child: CameraViewfinder(),
        ),

        // Scan line
        const Positioned.fill(
          child: ScanLine(active: true),
        ),

        // Top status text
        Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'ALIGN RECEIPT TO SCAN',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 80,
          left: 0,
          right: 0,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Upload button
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _pickFromGallery,
                          icon: const Icon(
                            Icons.upload,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'UPLOAD',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 80),

                  // Capture button
                  GestureDetector(
                    onTap: _takePicture,
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
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 124), // Spacer for symmetry
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingUI() {
    return Stack(
      children: [
        // Full-screen scan line
        const Positioned.fill(
          child: ScanLine(active: true),
        ),

        // Status text
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 120,
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
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ANALYZING RECEIPT',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum CameraPhase {
  camera,
  captured,
  processing,
}
