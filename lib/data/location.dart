import 'dart:developer';

import 'package:loca/model/latlng.dart';
import 'package:permission_handler/permission_handler.dart' as p;
import 'package:loca/error.dart';
import 'package:location/location.dart';

import 'location_service.dart';

class LocationX implements LocationService {
  final Location _location = Location();
  @override
  Future<LocationError> checkAndRequestPermissions() async {
    try {
      final serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        final requested = await _location.requestService();
        if (!requested) {
          return LocationError.serviceDisabled;
        }
      }

      final permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        final requested = await _location.requestPermission();
        if (requested != PermissionStatus.granted) {
          return LocationError.permissionDenied;
        }
      }

      return LocationError.granted;
    } catch (e) {
      log('Permission check failed: $e');
      return LocationError.unknown;
    }
  }

  @override
  Future<LocationError> enableBackgroundMode() async {
    try {
      final bgModeEnabled = await _location.isBackgroundModeEnabled();
      if (bgModeEnabled) {
        return LocationError.granted;
      }
      final backgroundStatus = await p.Permission.locationAlways.status;
      if (!backgroundStatus.isGranted) {
        final result = await p.Permission.locationAlways.request();
        if (!result.isGranted) {
          return LocationError.backgroundModeFailed;
        }
      }
      final enabled = await _location.enableBackgroundMode();
      return enabled ? LocationError.granted : LocationError.backgroundModeFailed;
    } catch (e) {
      log('Failed to enable background mode: $e');
      return LocationError.backgroundModeFailed;
    }
  }

  @override
  Stream<Latlng> getPositionStream() => _location.onLocationChanged
      .where((event) => event.latitude != null && event.longitude != null)
      .map((event) => Latlng(latitude: event.latitude!, longitude: event.longitude!));
}
