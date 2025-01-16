import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:loca/data/location.dart';
import 'package:loca/error.dart';
import 'data/location_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<void> _startTracking() async {
    final LocationService locationService = LocationX();
   //  final LocationService locationService = Geolocation();
    try {
      final permissionError = await locationService.checkAndRequestPermissions();
      if (permissionError != LocationError.granted) {
        _handleError(permissionError);
        return;
      }

      final backgroundError = await locationService.enableBackgroundMode();
      if (backgroundError != LocationError.granted) {
        _handleError(backgroundError);
        return;
      }

      final locationStream = locationService.getPositionStream();
      locationStream.listen(
        (location) {
          log('Location: ${location.latitude}, ${location.longitude}');
        },
        onError: (error) {
          if (error is LocationException) {
            _handleError(error.error);
          } else {
            _handleError(LocationError.unknown);
          }
        },
      );
    } catch (e) {
      _handleError(LocationError.unknown);
    }
  }

  void _handleError(LocationError error) {
    log('Error: ${error.message}');
  }

  @override
  void initState() {
    _startTracking();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Position Stream Example'),
      ),
      body: Center(
          child: Column(
        children: [],
      )),
    );
  }
}
