import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart'; // 추가

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Number Classifier',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  final String apiUrl = "http://YOUR_API_URL/photo/classify/";

  Future<void> _captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    // ✅ 파일의 확장자 기반으로 MIME 타입 설정
    String mimeType = "image/jpeg"; // 기본값
    if (pickedFile.path.endsWith(".png")) {
      mimeType = "image/png";
    }

    // 📌 FastAPI 서버에 이미지 전송
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType.parse(mimeType), // ✅ MIME 타입 명시적으로 지정
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      print(jsonResponse);
      // 📌 서버에서 받은 예측된 숫자
      int predictedClass = jsonResponse["data"]["predicted_class"];

      // 📌 결과 페이지로 이동
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(predictedClass: predictedClass),
        ),
      );
    } else {
      print("분류 실패: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Number Classifier")),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _captureImage,
          icon: const Icon(Icons.camera_alt),
          label: const Text("사진 촬영"),
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int predictedClass;

  const ResultScreen({super.key, required this.predictedClass});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Prediction Result")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("예측된 숫자:", style: TextStyle(fontSize: 20)),
            Text(
              "$predictedClass",
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text("다시 촬영"),
            ),
          ],
        ),
      ),
    );
  }
}
