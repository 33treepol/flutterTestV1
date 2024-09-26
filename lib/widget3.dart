// Code กูที่แบ่งหน้า Page แล้วแต่ marker ไม่เดินตามแล้วก็ มันไม่ Relocate เวลาเปิด App ครั้งใหม่

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;

  LatLng _initialPosition = const LatLng(13.7250481, 100.303445);
  Set<Marker> _markers = {};

  Circle _circle = Circle(
    circleId: CircleId('specific_location_circle'),
    center: LatLng(13.814568309082057, 100.70730974369243),
    radius: 100,
    fillColor: Colors.red.withOpacity(0.3),
    strokeColor: Colors.blue,
    strokeWidth: 2,
  );

  bool _isWithinCircle = false; // Tracks if user is inside the circle

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    var permissionStatus = await Permission.location.request();
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permissionStatus.isGranted) {
      bool isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        print('Location services are disabled.');
        return;
      }

      // Listen for location changes
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) {
        LatLng currentPosition = LatLng(position.latitude, position.longitude);

        setState(() {
          _initialPosition = currentPosition;
          _markers = {
            Marker(
              markerId: MarkerId('current_location'),
              position: _initialPosition,
              infoWindow: InfoWindow(title: 'Your Location'),
            ),
          };

          // Check if the user is within the circle
          double distance = Geolocator.distanceBetween(
            _initialPosition.latitude,
            _initialPosition.longitude,
            _circle.center.latitude,
            _circle.center.longitude,
          );

          if (distance <= _circle.radius) {
            _circle = _circle.copyWith(
              fillColorParam: Colors.green.withOpacity(0.3),
            );
            _isWithinCircle = true;
          } else {
            _circle = _circle.copyWith(
              fillColorParam: Colors.red.withOpacity(0.3),
            );
            _isWithinCircle = false;
          }

          // Move the camera to the updated position
          _moveCameraToPosition(_initialPosition);
        });
      });
    } else {
      print('Location permission denied');
    }
  }

  void _moveCameraToPosition(LatLng position) {
    mapController.animateCamera(CameraUpdate.newLatLng(position));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map Example with Circle Color Change'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2, // Takes up 2/3 of the screen
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              circles: Set.from([_circle]),
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Expanded(
            flex: 1, // Takes up 1/3 of the screen
            child: Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isWithinCircle
                          ? () {
                              // Navigate to another screen
                            }
                          : null, // Disable button if user is outside the circle
                      child: Text('Navigate to Another Screen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isWithinCircle
                            ? Colors.blue
                            : Colors.grey, // Change button color based on state
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Another action
                      },
                      child: Text('Another Action'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
