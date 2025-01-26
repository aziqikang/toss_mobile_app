import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Fetches the user's current location (latitude and longitude).
  Future<Position> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Location permissions are permanently denied. Enable them in settings.");
    }

    return await Geolocator.getCurrentPosition();
  }
}
