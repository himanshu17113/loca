import '../model/latlng.dart';
import '../error.dart';

/// Abstract class defining the contract for location services
abstract interface class LocationService {
  /// Gets a stream of location updates
Stream<Latlng> getPositionStream();

  /// Checks and requests necessary permissions
  Future<LocationError> checkAndRequestPermissions();

  /// Enables background location updates
  Future<LocationError> enableBackgroundMode();
}
