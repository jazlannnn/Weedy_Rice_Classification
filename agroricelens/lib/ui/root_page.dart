import 'package:agroricelens/ui/screens/faq_page.dart';
import 'package:agroricelens/ui/screens/home_page.dart';
import 'package:agroricelens/ui/screens/location_page.dart';
import 'package:agroricelens/ui/screens/result_page.dart';
import 'package:agroricelens/ui/screens/scan_page.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'package:agroricelens/constants.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _bottomNavIndex = 0;

  late Interpreter _interpreter;
  bool _isModelLoaded = false;

  // Dynamic imagePath and result for ResultPage
  String _imagePath = '';
  String _result = 'No Classification Yet';
  String _accuracy = 'N/A';

  // Pages
  List<Widget> get pages => [
    const HomePage(),
    const LocationPage(),
    ResultPage(imagePath: _imagePath, result: _result, accuracy: _accuracy,),
    const FaqPage(),
  ];

  List<IconData> iconList = [
    Icons.home,
    Icons.location_on,
    Icons.assessment,
    Icons.question_mark,
  ];

  List<String> titleList = ['Home', 'Location', 'Result', 'FAQ'];

  // Load TFLite Model
  Future<void> loadModel() async {
    try {
      final customModel = await FirebaseModelDownloader.instance.getModel(
        "image_classifier",
        FirebaseModelDownloadType.latestModel,
        FirebaseModelDownloadConditions(
          iosAllowsCellularAccess: true,
          androidChargingRequired: false,
        ),
      );

      final modelPath = customModel.file.path;
      _interpreter = await Interpreter.fromFile(File(modelPath));
      setState(() {
        _isModelLoaded = true;
      });
      print("Model loaded successfully: $modelPath");
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleList[_bottomNavIndex],
          style: TextStyle(
            color: Constants.blackColor,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: _isModelLoaded
          ? IndexedStack(index: _bottomNavIndex, children: pages)
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_isModelLoaded) {
            final resultData = await Navigator.push(
              context,
              PageTransition(
                child: ScanPage(interpreter: _interpreter),
                type: PageTransitionType.bottomToTop,
              ),
            );

            if (resultData != null && resultData is Map<String, String>) {
              setState(() {
                // Update the result and switch to Result tab
                _imagePath = resultData['imagePath']!;
                _result = resultData['result']!;
                _accuracy = resultData['accuracy']!;
                _bottomNavIndex = 2; // Index for the "Result" tab
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Model is still loading, please wait...")),
            );
          }
        },
        child: Image.asset('assets/images/code-scan-two.png', height: 30.0),
        backgroundColor: Constants.primaryColor,
      ),


      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        splashColor: Constants.primaryColor,
        activeColor: Constants.primaryColor,
        inactiveColor: Colors.black.withOpacity(.5),
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
    );
  }
}
