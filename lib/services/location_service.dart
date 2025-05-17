import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<String> getCountryFromCoordinates(
  double latitude,
  double longitude,
) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );
    if (placemarks.isNotEmpty) {
      return placemarks.first.locality ??
          placemarks.first.subLocality ??
          placemarks.first.country ??
          '';
    }
    return '';
  } catch (e) {
    if (kDebugMode) {
      print("Error: $e");
    }
    return '';
  }
}

class LocationService {
  static Future<String> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'Location services are disabled.';
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Location permissions are permanently denied, we cannot request permissions.';
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition();

    // Get the placemarks from the coordinates
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks[0];

    // Return the city and country
    return '${place.locality}, ${place.country}';
  }
}
