// lib/screens/camera_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../models/media_file.dart';
import '../services/media_service.dart';
import 'save_media_dialog.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isTakingPhoto = false;
  bool _isVideoMode = false;
  int _selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.auto;
  String? _capturedPath;
  bool _isPreview = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
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
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(cameraIndex: _selectedCameraIndex);
    }
  }

  Future<void> _initializeCamera({int cameraIndex = 0}) async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final controller = CameraController(
        _cameras[cameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
      );
      _controller = controller;
      await controller.initialize();
      await controller.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _selectedCameraIndex = cameraIndex;
        });
      }
    } catch (e) {
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_isTakingPhoto) return;

    setState(() => _isTakingPhoto = true);
    try {
      final file = await _controller!.takePicture();
      setState(() {
        _capturedPath = file.path;
        _isPreview = true;
        _isTakingPhoto = false;
      });
    } catch (e) {
      debugPrint('Take picture error: $e');
      setState(() => _isTakingPhoto = false);
    }
  }

  Future<void> _toggleRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    if (_isRecording) {
      final file = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _capturedPath = file.path;
        _isPreview = true;
      });
    } else {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    final newIndex = (_selectedCameraIndex + 1) % _cameras.length;
    setState(() => _isInitialized = false);
    await _controller?.dispose();
    await _initializeCamera(cameraIndex: newIndex);
  }

  Future<void> _cycleFlash() async {
    if (_controller == null) return;
    final modes = [FlashMode.auto, FlashMode.always, FlashMode.off];
    final nextIdx = (modes.indexOf(_flashMode) + 1) % modes.length;
    _flashMode = modes[nextIdx];
    await _controller!.setFlashMode(_flashMode);
    setState(() {});
  }

  IconData get _flashIcon {
    switch (_flashMode) {
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      default:
        return Icons.flash_auto;
    }
  }

  void _discardCapture() {
    if (_capturedPath != null) {
      File(_capturedPath!).deleteSync();
    }
    setState(() {
      _capturedPath = null;
      _isPreview = false;
    });
  }

  void _saveCapture() async {
    if (_capturedPath == null) return;

    final type = _isVideoMode ? MediaType.video : MediaType.image;
    // Obtenemos MediaService antes de abrir el dialog para evitar
    // el ProviderNotFoundException dentro del builder del showDialog
    final mediaService = context.read<MediaService>();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => SaveMediaDialog(
        filePath: _capturedPath!,
        type: type,
        mediaService: mediaService,
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _capturedPath = null;
        _isPreview = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Archivo guardado correctamente'),
          backgroundColor: Color(0xFF1B5E20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isPreview && _capturedPath != null
          ? _buildPreview()
          : _buildCameraView(),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        if (_isInitialized && _controller != null)
          CameraPreview(_controller!)
        else
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text('Iniciando cámara...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),

        // Header bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'CÁMARA HOTEL',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(_flashIcon, color: Colors.white),
                    onPressed: _cycleFlash,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mode toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ModeButton(
                          label: 'FOTO',
                          icon: Icons.camera_alt,
                          isSelected: !_isVideoMode,
                          onTap: () => setState(() => _isVideoMode = false),
                        ),
                        _ModeButton(
                          label: 'VIDEO',
                          icon: Icons.videocam,
                          isSelected: _isVideoMode,
                          onTap: () => setState(() => _isVideoMode = true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Capture controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery button placeholder
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
                        onPressed: () => Navigator.pop(context),
                      ),

                      // Main capture button
                      GestureDetector(
                        onTap: _isVideoMode ? _toggleRecording : _takePicture,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isRecording ? Colors.red : Colors.white,
                              width: 4,
                            ),
                          ),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _isRecording ? 30 : 60,
                              height: _isRecording ? 30 : 60,
                              decoration: BoxDecoration(
                                color: _isRecording ? Colors.red : Colors.white,
                                borderRadius: _isRecording
                                    ? BorderRadius.circular(6)
                                    : BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Switch camera
                      IconButton(
                        icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 32),
                        onPressed: _cameras.length > 1 ? _switchCamera : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Recording indicator
        if (_isRecording)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                    SizedBox(width: 8),
                    Text('GRABANDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Preview
        _isVideoMode
            ? Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(Icons.play_circle_fill, size: 80, color: Colors.white54),
                ),
              )
            : Image.file(File(_capturedPath!), fit: BoxFit.contain),

        // Header
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _isVideoMode ? 'Vista previa del video' : 'Vista previa de la foto',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // Action buttons
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('Descartar', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _discardCapture,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B6914),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _saveCapture,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.black : Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}