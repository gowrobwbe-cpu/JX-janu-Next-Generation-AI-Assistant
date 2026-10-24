import 'dart:convert';
import 'package:camera/camera.dart';

class CameraVisionModule {
  CameraController? _cameraController;
  bool isInitialized = false;

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          ),
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        isInitialized = true;
      }
    } catch (e) {
      isInitialized = false;
    }
  }

  Future<String?> captureFrameAsBase64() async {
    if (!isInitialized || _cameraController == null) return null;
    try {
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _cameraController?.dispose();
  }
}
