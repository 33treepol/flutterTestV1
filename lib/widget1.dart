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
  // This will hold the GoogleMapController once the map is initialized
  // GoogleMapController? mapController;
  late GoogleMapController mapController;

  // Default location (Coordinates for New York City)
   LatLng _initialPosition = const LatLng(0, 0);

   

  // Set of markers on the map
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // Add a red marker at the initial position
    // _markers.add(
    //   Marker(
    //     markerId: MarkerId('red_marker'),  // Unique ID for the marker
    //     position: _initialPosition,        // Position of the marker
    //     infoWindow: InfoWindow(title: 'Red Marker'),  // Info window for the marker
    //     icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),  // Red marker color
    //   ),
    // );
  }

  Future<void> _getCurrentLocation() async {
    var permissionStatus = await Permission.location.request();
    LocationPermission permission = await Geolocator.checkPermission();
    print('Permission: $permission');
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

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      print(
          'Current Position: Lat: ${position.latitude}, Long: ${position.longitude}');

      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _markers.add(
          Marker(
            markerId: MarkerId('current_location'),
            position: _initialPosition,
            infoWindow: InfoWindow(title: 'Your Location'),
          ),
        );
      });
      _moveCameraToPosition(_initialPosition);
    } else {
      // Handle permission denial
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
        title: Text('Google Map Example with Red Marker humYawJung'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 14.0,
        ),
        markers: _markers,
        myLocationEnabled: true, // Show the blue dot for the user's location
        myLocationButtonEnabled: true, // Enable the "My Location" button
      ),
    );
  }
}
