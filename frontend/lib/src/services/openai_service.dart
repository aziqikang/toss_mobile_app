import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class OpenAIService {
  // Use the backend URL that you have configured in your Flutter app.
  // Replace with your backend's IP address or domain name.
  final String backendUrl = 'http://10.186.26.44:5000/analyze-image';

  /// Sends an image and user location to the Flask backend for processing and returns the response.
  Future<Map<String, dynamic>> sendPhoto(File image, Position position) async {
    
    var request = http.MultipartRequest('POST', Uri.parse(backendUrl));
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody); // Return the parsed JSON response
    } else {
      throw Exception("Failed to analyze image. Status Code: ${response.statusCode}");
    }
  }


}
