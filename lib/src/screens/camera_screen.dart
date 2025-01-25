// lib/src/screens/camera_screen.dart

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// CameraScreen is responsible for displaying the camera preview and handling camera functionalities.
class CameraScreen extends StatefulWidget {
  /// List of available cameras.
  final List<CameraDescription> cameras;

  /// Constructor accepting the list of cameras.
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.max,
      );

      _initializeControllerFuture = _controller.initialize().catchError((e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              // Handle access errors here.
              debugPrint('User denied camera access.');
              break;
            default:
              // Handle other errors here.
              debugPrint('Error initializing camera: ${e.description}');
              break;
          }
        }
      });
    } else {
      debugPrint('No cameras available.');
    }
  }

  @override
  void dispose() {
    if (widget.cameras.isNotEmpty) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera')),
        body: const Center(child: Text('No camera available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Camera Preview')),
      // Wait until the controller is initialized before displaying the preview
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview
            return CameraPreview(_controller);
          } else if (snapshot.hasError) {
            // If there's an error during initialization
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Otherwise, display a loading indicator
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            // Ensure that the camera is initialized
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            final image = await _controller.takePicture();

            // If the picture was taken, display it on a new screen
            if (!mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(imagePath: image.path),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console
            debugPrint('Error taking picture: $e');
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
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
      body: Image.file(File(imagePath)),
    );
  }
}
