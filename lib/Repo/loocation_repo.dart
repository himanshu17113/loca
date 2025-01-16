import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:loca/latlng.dart';

class LocationRepository {
  Future<bool> checkLocationServices() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermissions() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermissions() async {
    return await Geolocator.requestPermission();
  }

  Stream<Latlng> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
        // timeLimit: Duration(seconds: 10),
      ),
    ).map((event) => Latlng(longitude: event.longitude, latitude: event.latitude));
  }

 
}
