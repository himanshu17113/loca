

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


/// Custom exception for location-related errors
class LocationException implements Exception {
  final LocationError error;

  LocationException(this.error);

  @override
  String toString() => 'LocationException: ${error.message}';
}
