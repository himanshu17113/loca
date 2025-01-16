import 'package:flutter/material.dart';

@immutable
class Latlng {
  const Latlng({
    required this.longitude,
    required this.latitude,
  });

  final double latitude;

  final double longitude;
}
