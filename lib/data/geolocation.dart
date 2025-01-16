import 'dart:async';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:loca/model/latlng.dart';
import 'package:loca/error.dart';

import 'location_service.dart';

class Geolocation implements LocationService {
  @override
  Future<LocationError> checkAndRequestPermissions() async {
    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return LocationError.permissionDenied;
      }

      return LocationError.granted;
    } catch (e) {
      log('Permission check failed: $e');
      return LocationError.unknown;
    }
  }

  @override
  Future<LocationError> enableBackgroundMode() async {
    // Geolocator doesn't require   background mode enabling
    return LocationError.granted;
  }

  @override
  Stream<Latlng> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.reduced,
     
        // timeLimit: Duration(seconds: 10),
      ),
    ).map((event) => Latlng(longitude: event.longitude, latitude: event.latitude));
  }
}
