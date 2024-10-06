import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194), // Replace with your coordinates
          zoom: 10,
        ),
        markers: {
          Marker(
            markerId: MarkerId('location'),
            position: LatLng(37.7749, -122.4194), // Replace with your coordinates
          ),
        },
      ),
    );
  }
}
