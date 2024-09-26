// Code หนุ่ยที่ มัน marker มันเดินตามได้แล้ว



import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

  LatLng _initialPosition = LatLng(13.813857609529645, 100.70723205738318);
  Set<Marker> _markers = {};
  Circle _circle = Circle(
    circleId: CircleId('current_location'),
    center: LatLng(13.814532219972365, 100.70733077474796),
    radius: 4, // Increased for better testing range
    fillColor: Colors.blue.withOpacity(0.1),
    strokeWidth: 1,
    strokeColor: Colors.blue,
  );

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _subscribeToLocationChanges();
  }

  // Request location permission and get the current location
  Future<void> _requestPermission() async {
    var permissionStatus = await Permission.location.request();
    if (permissionStatus.isDenied || permissionStatus.isPermanentlyDenied) {
      permissionStatus = await Permission.location.request();
    }
  }

  // Subscribe to real-time location updates
  void _subscribeToLocationChanges() {
    Geolocator.getPositionStream().listen((Position position) {
      print('Current Position: Lat: ${position.latitude}, Long: ${position.longitude}');

      LatLng currentPosition = LatLng(position.latitude, position.longitude);
      
      // Update marker position
      setState(() {
        _initialPosition = currentPosition;
        _markers.add(
          Marker(
            markerId: MarkerId('current_location'),
            position: _initialPosition,
            infoWindow: InfoWindow(title: 'Your Location'),
          ),
        );
      });

      // Check if inside or outside the circle
      double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        _circle.center.latitude,
        _circle.center.longitude,
      );

      if (distance > _circle.radius) {
        print('Outside the circle');
        setState(() {
          _circle = _circle.copyWith(
            fillColorParam: Colors.red.withOpacity(0.3),
          );
        });
      } else {
        print('Inside the circle');
        setState(() {
          _circle = _circle.copyWith(
            fillColorParam: Colors.green.withOpacity(0.3),
          );
        });
      }

      // Move the camera to the new position
      _moveCameraToPosition(currentPosition);
    });
  }

  // Move camera to the current location
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
        title: Text('Google Map - Current Location'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 14.0,
        ),
        circles: Set.from([_circle]),
        markers: _markers,
        myLocationEnabled: true, // Show the blue dot for the user's location
        myLocationButtonEnabled: true, // Enable the "My Location" button
      ),
    );
  }
}
