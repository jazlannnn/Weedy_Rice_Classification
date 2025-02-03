import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScanPage extends StatefulWidget {
  final Interpreter interpreter;

  const ScanPage({Key? key, required this.interpreter}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // Request permissions
  Future<void> requestPermissions() async {
    if (await Permission.camera.isDenied) await Permission.camera.request();
    if (await Permission.storage.isDenied) await Permission.storage.request();
  }

  // Softmax function
  List<double> softmax(List<double> logits) {
    final maxLogit = logits.reduce(max);
    final exps = logits.map((logit) => exp(logit - maxLogit)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }

  // Preprocess image to match TFLite model input
  Future<List<List<List<List<double>>>>> preprocessImage(File imageFile) async {
    final bytes = imageFile.readAsBytesSync();
    img.Image? oriImage = img.decodeImage(bytes);
    if (oriImage == null) throw Exception("Failed to decode the image.");

    // Resize to 224x224
    img.Image resizedImage = img.copyResize(oriImage, width: 224, height: 224);

    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    List<List<List<double>>> channels = List.generate(3, (c) {
      return List.generate(224, (y) {
        return List.generate(224, (x) {
          final pixel = resizedImage.getPixel(x, y);
          double value = 0.0;

          if (c == 0) value = img.getRed(pixel) / 255.0;
          if (c == 1) value = img.getGreen(pixel) / 255.0;
          if (c == 2) value = img.getBlue(pixel) / 255.0;

          return (value - mean[c]) / std[c];
        });
      });
    });

    return [channels];
  }

  // Classify image and return result
  Future<Map<String, String>> classifyImage(File image) async {
    final inputTensor = await preprocessImage(image);
    final output = List.filled(1 * 2, 0.0).reshape([1, 2]);

    widget.interpreter.run(inputTensor, output);
    final probabilities = softmax(output[0]);

    int predictedIndex = probabilities.indexOf(probabilities.reduce(max));
    double confidence = probabilities[predictedIndex] * 100;

    String className =
    predictedIndex == 0 ? "Cultivated Rice" : "Weedy Rice";

    // Save result to Firestore
    await FirebaseFirestore.instance.collection('results').add({
      'imagePath': image.path,
      'result': className,
      'accuracy': "${confidence.toStringAsFixed(2)}%",
      'timestamp': DateTime.now(),
    });

    print('Result saved to Firestore');

    return {
      'imagePath': image.path,
      'result': className,
      'accuracy': "${confidence.toStringAsFixed(2)}%",
    };
  }

  // Scan using Camera
  Future<void> scanUsingCamera() async {
    await requestPermissions();

    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      final imagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPreviewScreen(camera: firstCamera),
        ),
      );

      if (imagePath != null) {
        final resultData = await classifyImage(File(imagePath));
        Navigator.pop(context, resultData); // Pass result back
      }
    } catch (e) {
      print("Error opening camera: $e");
    }
  }

  // Upload from Gallery
  Future<void> uploadFromGallery() async {
    await requestPermissions();

    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final resultData = await classifyImage(File(image.path));
      Navigator.pop(context, resultData); // Pass result back
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Constants.primaryColor.withOpacity(.15),
                    ),
                    child: Icon(Icons.close, color: Constants.primaryColor),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 100,
            right: 20,
            left: 20,
            child: Container(
              width: size.width * .8,
              height: size.height * .8,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: scanUsingCamera,
                      child: Column(
                        children: [
                          Image.asset('assets/images/code-scan.png', height: 120),
                          const SizedBox(height: 20),
                          Text(
                            'Scan using Camera',
                            style: TextStyle(
                              color: Constants.primaryColor.withOpacity(.80),
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120),
                    GestureDetector(
                      onTap: uploadFromGallery,
                      child: Column(
                        children: [
                          Image.asset('assets/images/gallery-icon.png', height: 120),
                          const SizedBox(height: 20),
                          Text(
                            'Upload from Gallery',
                            style: TextStyle(
                              color: Constants.primaryColor.withOpacity(.80),
                              fontWeight: FontWeight.w500,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Camera Preview Screen
class CameraPreviewScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraPreviewScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraPreviewScreenState createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    await _initializeControllerFuture;
    final image = await _controller.takePicture();
    Navigator.pop(context, image.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Camera Preview
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                return snapshot.connectionState == ConnectionState.done
                    ? CameraPreview(_controller)
                    : const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          // Camera Button outside the preview
          Container(
            padding: const EdgeInsets.all(20.0),
            alignment: Alignment.center,
            color: Colors.white, // Optional background color for the button area
            child: FloatingActionButton(
              onPressed: takePicture,
              backgroundColor: Color(0xFFBDBDBD), // Hex color for the button
              foregroundColor: Colors.black, // Set the icon color explicitly to black
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }

}
