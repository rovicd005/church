import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

// Custom AppBar Widget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios), // Custom back button icon
        color: Colors.white, // Set the color of the back button icon
        onPressed: () => Navigator.pop(context), // Back button action
      ),
      backgroundColor: Colors.transparent, // Transparent to show gradient
      elevation: 4.0, // Elevation for shadow effect
      shadowColor: Colors.black.withOpacity(0.5), // Customize shadow color
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black87, Colors.black54],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

// Main MapScreen Widget
class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Define a GoogleMapController to control the map
  GoogleMapController? _mapController;

  // Define the initial camera position
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // Default location (San Francisco)
    zoom: 10,
  );

  // Function to move the map to the selected location
  void _goToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 14), // Zoom in on the location
      ),
    );
  }

  // Function to launch a URL in the device's browser
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Map'), // Using custom AppBar
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/mapbackground.jpg', // Ensure the image path is correct
              fit: BoxFit.cover, // Make sure the image covers the entire background
            ),
          ),
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: {
              Marker(markerId: MarkerId('STA ANA'), position: LatLng(15.0942, 120.7689)),
              Marker(markerId: MarkerId('CANDABA'), position: LatLng(15.0971, 120.8266)),
              Marker(markerId: MarkerId('ARAYAT'), position: LatLng(15.1505, 120.7696)),
              Marker(markerId: MarkerId('MEXICO'), position: LatLng(15.0646, 120.7199)),
              Marker(markerId: MarkerId('SAN LUIS'), position: LatLng(15.0383, 120.7897)),
            },
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            left: 70, // Adjust according to your design
            top: 210, // Adjust according to your design
            child: IconButton(
              onPressed: () {
                _launchURL("https://maps.app.goo.gl/ZMpSpT7tfqkRKSL3A"); // STA ANA link
              },
              icon: Icon(Icons.location_on, color: Colors.red, size: 100), // Larger Pin icon
            ),
          ),
          Positioned(
            left: 110, // Adjust according to your design
            top: 120, // Adjust according to your design
            child: IconButton(
              onPressed: () {
                _launchURL("https://maps.app.goo.gl/tknGGKbpG2qmdFXY9"); // ARAYAT link
              },
              icon: Icon(Icons.location_on, color: Colors.red, size: 100), // Larger Pin icon
            ),
          ),
          Positioned(
            left: -10, // Adjust according to your design
            top: 190, // Adjust according to your design
            child: IconButton(
              onPressed: () {
                _launchURL("https://maps.app.goo.gl/Ev2L7UvbnNKJNmhX6"); // MEXICO link
              },
              icon: Icon(Icons.location_on, color: Colors.red, size: 100), // Larger Pin icon
            ),
          ),
          Positioned(
            left: 250, // Adjust according to your design
            top: 200, // Adjust according to your design
            child: IconButton(
              onPressed: () {
                _launchURL("https://maps.app.goo.gl/fkGc5XRdfvRhygd7A"); // CANDABA link
              },
              icon: Icon(Icons.location_on, color: Colors.red, size: 100), // Larger Pin icon
            ),
          ),
          Positioned(
            left: 150, // Moved more to the right from 180 to 185
            top: 300, // Adjust according to your design (moved lower)
            child: IconButton(
              onPressed: () {
                _launchURL("https://maps.app.goo.gl/MDXcHhCz7Zb32iS96"); // SAN LUIS link
              },
              icon: Icon(Icons.location_on, color: Colors.red, size: 100), // Larger Pin icon
            ),
          ),
        ],
      ),
    );
  }
}

