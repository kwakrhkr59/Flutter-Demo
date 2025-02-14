import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:mime/mime.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 8.0;
  final Dio _dio = Dio();
  final String _baseUrl = "http://192.168.219.104:8000/photo";

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium, enableAudio: false);
    _controller.initialize().then((_) async {
      if (!mounted) return;
      await _controller.setFlashMode(FlashMode.off);  // 플래시 비활성화 추가
      _minZoom = await _controller.getMinZoomLevel();
      _maxZoom = await _controller.getMaxZoomLevel();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomCamera(double zoom) async {
    setState(() {
      _currentZoom = zoom.clamp(_minZoom, _maxZoom);
    });
    _controller.setZoomLevel(_currentZoom);
  }

  Future<void> _uploadAndProcessImage(String imagePath) async {
    try {
      File imageFile = File(imagePath);
      String fileName = imageFile.path.split('/').last;
      String? mimeType = lookupMimeType(imageFile.path) ?? "image/jpeg";

      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      var classifyResponse = await _dio.post("$_baseUrl/classify/", data: formData);
      print("Classify Response: ${classifyResponse.data}");
      print(classifyResponse.data["message"]);

      int predictedClass = classifyResponse.data["data"]["predicted_class"];
      print("Predicted Class: $predictedClass");

      String imageUrl = classifyResponse.data["data"]["image_url"];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(
            imageUrl: imageUrl,
            predictedClass: predictedClass,
          ),
        ),
      );
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Art Teller", style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.orange),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(_controller),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, color: Colors.orange),
                  onPressed: () => _zoomCamera(_currentZoom - 0.1),
                ),
                Expanded(
                  child: Slider(
                    activeColor: Colors.orange,
                    min: _minZoom,
                    max: _maxZoom,
                    value: _currentZoom,
                    onChanged: (value) => _zoomCamera(value),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.orange),
                  onPressed: () => _zoomCamera(_currentZoom + 0.1),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () async {
                try {
                  final image = await _controller.takePicture();
                  if (!mounted) return;
                  _uploadAndProcessImage(image.path);
                } catch (e) {
                  print("Error taking picture: $e");
                }
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imageUrl;
  final int predictedClass;

  const DisplayPictureScreen({
    Key? key,
    required this.imageUrl,
    required this.predictedClass,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captured Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(imageUrl),
            SizedBox(height: 20),
            Text('Predicted Class: $predictedClass', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
