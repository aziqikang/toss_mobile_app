import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart'; // Import for geolocation
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

      // Capture the photo
      final XFile image = await _controller.takePicture();

      // If the photo was successfully taken
      if (!mounted) return;

      // Get user location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Debugging: print the location
      print('User location: ${position.latitude}, ${position.longitude}');

      // Send the image and location to the backend
      final backendResponse = await OpenAIService().sendPhoto(
        File(image.path),
        position,
      );

      // Debugging: print the backend response
      print('Backend Response: $backendResponse');

      // Show a success message or navigate to another screen here, if needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo analyzed successfully!')),
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
