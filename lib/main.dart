import 'src/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    // Handle camera initialization errors here
    debugPrint('Error initializing cameras: $e');
  }

  runApp(const TossApp());
}

/// TossApp is the Main Application.
class TossApp extends StatelessWidget {
  /// Default Constructor
  const TossApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(cameras: cameras),
    );
  }
}
