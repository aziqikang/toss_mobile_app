class ImageAnalyzer {
    Future<String> analyzeImage(File image) async {
    const String url = 'http://10.186.26.44:5000/analyze-image';    # use wifi ip address

    try {
        var request = http.MultipartRequest('POST', Uri.parse(url));
        request.files.add(await http.MultipartFile.fromPath('image', image.path));

        var response = await request.send();
        if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        return jsonResponse['message']; // Handle the message returned from the backend
        } else {
        throw Exception(
            'Failed to analyze image. Status Code: ${response.statusCode}, Error: ${response.reasonPhrase}',
        );
        }
    } catch (e) {
        debugPrint('Error in analyzeImage: $e');
        rethrow;
    }
    }

}
