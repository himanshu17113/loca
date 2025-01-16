import 'dart:async';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:loca/Repo/loocation_repo.dart';
import 'package:loca/latlng.dart';
import 'package:permission_handler/permission_handler.dart' as p;

/// Represents possible location-related errors
enum LocationError {
  granted,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unknown,
  backgroundModeFailed
}

/// Extension on LocationError to provide user-friendly error messages
extension LocationErrorExtension on LocationError {
  String get message {
    switch (this) {
      case LocationError.serviceDisabled:
        return "Location services are disabled.";
      case LocationError.permissionDenied:
        return "Location permissions are denied.";
      case LocationError.permissionDeniedForever:
        return "Location permissions are permanently denied.";
      case LocationError.backgroundModeFailed:
        return "Failed to enable background location mode.";
      case LocationError.unknown:
      default:
        return "An unknown error occurred.";
    }
  }
}

/// Abstract class defining the contract for location services
abstract class LocationService {
  /// Gets a stream of location updates
  Future<Stream<Latlng>> getPositionStream();

  /// Checks and requests necessary permissions
  Future<LocationError> checkAndRequestPermissions();

  /// Enables background location updates
  Future<LocationError> enableBackgroundMode();
}

/// Implementation using the Geolocator package
class GeoLocationServiceImpl implements LocationService {
  final LocationRepository _locationRepository;

  GeoLocationServiceImpl({LocationRepository? locationRepository})
      : _locationRepository = locationRepository ?? LocationRepository();

  @override
  Future<Stream<Latlng>> getPositionStream() async {
    final serviceError = await _checkLocationServices();
    if (serviceError != LocationError.granted) {
      throw LocationException(serviceError);
    }

    final permissionError = await checkAndRequestPermissions();
    if (permissionError != LocationError.granted) {
      throw LocationException(permissionError);
    }

    return _locationRepository.getPositionStream();
  }

  @override
  Future<LocationError> checkAndRequestPermissions() async {
    try {
      var permission = await _locationRepository.checkPermissions();

      if (permission == LocationPermission.denied) {
        permission = await _locationRepository.requestPermissions();
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

  Future<LocationError> _checkLocationServices() async {
    try {
      final serviceEnabled = await _locationRepository.checkLocationServices();
      return serviceEnabled ? LocationError.granted : LocationError.serviceDisabled;
    } catch (e) {
      log('Location service check failed: $e');
      return LocationError.unknown;
    }
  }

  @override
  Future<LocationError> enableBackgroundMode() async {
    // Geolocator doesn't require explicit background mode enabling
    return LocationError.granted;
  }
}

/// Implementation using the Location package
class LocationX implements LocationService {
  final Location _location;

  LocationX({Location? location}) : _location = location ?? Location();

  @override
  Future<Stream<Latlng>> getPositionStream() async {
    final permissionError = await checkAndRequestPermissions();
    if (permissionError != LocationError.granted) {
      throw LocationException(permissionError);
    }

    final backgroundError = await enableBackgroundMode();
    if (backgroundError != LocationError.granted) {
      throw LocationException(backgroundError);
    }

    return _location.onLocationChanged
        .where((event) => event.latitude != null && event.longitude != null)
        .map((event) => Latlng(latitude: event.latitude!, longitude: event.longitude!));
  }

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
}

/// Custom exception for location-related errors
class LocationException implements Exception {
  final LocationError error;

  LocationException(this.error);

  @override
  String toString() => 'LocationException: ${error.message}';
}
