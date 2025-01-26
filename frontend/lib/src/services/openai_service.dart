import 'dart:io';
import 'package:http/http.dart' as http;

class OpenAIService {
  // Use the backend URL that you have configured in your Flutter app.
  // Replace with your backend's IP address or domain name.
  final String _backendUrl = 'http://10.186.26.44:5000/analyze-image';

  /// Sends an image to the Flask backend for processing and returns the response.
  Future<String> sendPhoto(File image) async {
    // Check if the image exists
    if (!image.existsSync()) {
      throw Exception('Image file does not exist.');
    }

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.parse(_backendUrl));

    // Attach the image as a file
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      // Send the request and wait for the response
      var response = await request.send();

      // Read the response
      var responseBody = await response.stream.bytesToString();

      // Check for success (status code 200)
      if (response.statusCode == 200) {
        return responseBody; // Response from Flask backend (Gemini output)
      } else {
        throw Exception(
            'Failed to analyze image. Status Code: ${response.statusCode}, Response: $responseBody');
      }
    } catch (e) {
      // Handle errors
      throw Exception('Error communicating with backend: $e');
    }
  }
}
