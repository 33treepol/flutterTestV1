// code กูกับGPT

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
  // This will hold the GoogleMapController once the map is initialized
  GoogleMapController? _mapController;

  final LatLng _initialPosition =
      LatLng(40.7128, -74.0060); // Default position (New York City)
  LatLng _currentPosition =
      LatLng(13.742909, 99.328493); // Will hold the user's current location

  // Circle
  final Set<Circle> _circles = Set.from([
    Circle(
      circleId: CircleId('specific_location_circle'),
      center: LatLng(13.8140406, 100.7094749), // Center of the circle
      radius: 500, // Radius in meters (1 km)
      fillColor: Colors.red.withOpacity(0.3), // Circle color with transparency
      strokeColor: Colors.blue, // Border color
      strokeWidth: 2, // Border width
    ),
  ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map Example'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _initialPosition, // The initial position of the map
              zoom: 12.0,
            ),
            circles: _circles, // Add circles to the map
            mapType: MapType.normal,
            myLocationEnabled:
                true, // Enable showing the user's current location
            zoomControlsEnabled: true,
          ),
          Positioned(
            bottom: 150,
            right: 20,
            child: FloatingActionButton(
              onPressed:
                  _goToCurrentLocation, // Trigger the function to find the user's location
              child: Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  // Method to get the user's current location
  Future<void> _goToCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, show a dialog to the user.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Location services are disabled. Please enable them.')),
      );
      return;
    }

    // Check for permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, show a message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Location permissions are permanently denied. We cannot request permissions.')),
      );
      return;
    }

    // If permissions are granted, get the user's location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(
          position.latitude, position.longitude); // Update the current position
    });

    // Move the map camera to the user's location
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: _currentPosition,
            zoom: 15), // Zoom into the user's location
      ),
    );
  }
}
