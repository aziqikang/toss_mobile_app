import 'src/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// import 'dart:developer' as developer;

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // developer.log('debug console working'); // remove; this is a test

  await dotenv.load(fileName: ".env");          // load .env variables into main

    // Debugging: Print the API key to verify loading
  // String? apiKey = dotenv.env['OPENAI_API_KEY'];
  // developer.log('Loaded OpenAI API Key: $apiKey'); // Remove or comment out in production

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    // handle camera initialization errors
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
