import 'package:flutter/material.dart';

@immutable
class Latlng {
  /// Constructs an instance with the given values for testing. [Latlng]
  /// instances constructed this way won't actually reflect any real information
  /// from the platform, just whatever was passed in at construction time.
  const Latlng({
    required this.longitude,
    required this.latitude,
  });

  /// The latitude of this position in degrees normalized to the interval -90.0
  /// to +90.0 (both inclusive).
  final double latitude;

  /// The longitude of the position in degrees normalized to the interval -180
  /// (exclusive) to +180 (inclusive).
  final double longitude;
}
