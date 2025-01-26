import 'package:flutter/material.dart';
import 'camera_screen.dart'; // Import Camera Screen
import 'package:camera/camera.dart';

/// HomeScreen is the first screen that appears when the app launches.
/// It contains a big red button that navigates to the Camera Screen.
class HomeScreen extends StatelessWidget {

  final List<CameraDescription> cameras;
  const HomeScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title
      appBar: AppBar(
        title: const Text('Home Screen'),
        centerTitle: true,
      ),
      // Centered button in the body
      body: Center(
        child: ElevatedButton(
          // Styling the button
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Red background
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            textStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Action to perform when the button is pressed
          onPressed: () {
            // Navigate to Camera Screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CameraScreen(cameras: cameras)),
            );
          },
          // Button label
          child: const Text('Go to Camera'),
        ),
      ),
    );
  }
}
