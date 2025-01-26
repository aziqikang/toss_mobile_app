import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart'; // Import for geolocation
import 'package:toss_mobile_app/src/screens/result_screen.dart';
import 'package:toss_mobile_app/src/services/openai_service.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(
        widget.cameras[0], // Use the first available camera
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _controller.initialize();
    } else {
      print('No cameras available');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Captures a photo, gets user location, and sends both to the backend
Future<void> _takePicture() async {
  try {
    // Ensure the camera is initialized
    await _initializeControllerFuture;

    // Attempt to take a picture and get the file `image`
    final XFile image = await _controller.takePicture();

    // If the picture was taken, send it to the backend
    if (!mounted) return;

    // Get user location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Send the image to the backend and parse the result
    Map<String, dynamic> backendResponse = await OpenAIService().sendPhoto(File(image.path), position);

    // Print the response in the console (for debugging purposes)
    print('Backend Response: $backendResponse');

    // Navigate to the ResultScreen with the backendResponse
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultScreen(resultData: backendResponse),
      ),
    );
  } catch (e) {
    // Handle errors
    print('Error in _takePicture: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera Screen')),
        body: const Center(child: Text('No camera available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Camera Screen')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the camera preview
            return CameraPreview(_controller);
          } else if (snapshot.hasError) {
            // If there's an error during initialization, display it
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Otherwise, display a loading indicator
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture, // Call the _takePicture method when pressed
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
