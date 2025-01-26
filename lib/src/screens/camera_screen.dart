// lib/src/screens/camera_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

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

  /// Method to capture a photo
  Future<void> _takePicture() async {
    try {
      // Ensure the camera is initialized
      await _initializeControllerFuture;

      // Attempt to take a picture and get the file `image`
      final XFile image = await _controller.takePicture();

      // If the picture was taken, navigate to DisplayPictureScreen to show the image
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      // If an error occurs, log the error to the console
      print('Error taking picture: $e');
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Position the FAB at the center bottom
    );
  }
}

/// DisplayPictureScreen displays the taken picture.
class DisplayPictureScreen extends StatelessWidget {
  /// Path of the taken picture.
  final String imagePath;

  /// Constructor accepting the image path.
  const DisplayPictureScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display Picture')),
      body: Image.file(File(imagePath)), // Display the captured image
    );
  }
}
