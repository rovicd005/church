import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
        icon: Icon(Icons.arrow_back_ios),
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.transparent,
      elevation: 4.0,
      shadowColor: Colors.black.withOpacity(0.5),
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

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(15.0942, 120.7689), // Initial location set to Sta Ana
    zoom: 10,
  );

  void _goToLocation(LatLng location) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 14),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Map'),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/mapbackground.jpg',
              fit: BoxFit.cover,
            ),
          ),
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _createMarkers(),
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _mapController = controller;
              });
            },
          ),
          _buildLocationButton(90, 230, "https://maps.app.goo.gl/ZMpSpT7tfqkRKSL3A"),
          _buildLocationButton(120, 130, "https://maps.app.goo.gl/tknGGKbpG2qmdFXY9"),
          _buildLocationButton(5, 210, "https://maps.app.goo.gl/Ev2L7UvbnNKJNmhX6"),
          _buildLocationButton(280, 230, "https://maps.app.goo.gl/fkGc5XRdfvRhygd7A"),
          _buildLocationButton(180, 320, "https://maps.app.goo.gl/MDXcHhCz7Zb32iS96"),
        ],
      ),
    );
  }

  Set<Marker> _createMarkers() {
    return {
      Marker(markerId: MarkerId('STA ANA'), position: LatLng(15.0942, 120.7689)),
      Marker(markerId: MarkerId('CANDABA'), position: LatLng(15.0971, 120.8266)),
      Marker(markerId: MarkerId('ARAYAT'), position: LatLng(15.1505, 120.7696)),
      Marker(markerId: MarkerId('MEXICO'), position: LatLng(15.0646, 120.7199)),
      Marker(markerId: MarkerId('SAN LUIS'), position: LatLng(15.0383, 120.7897)),
    };
  }

  Widget _buildLocationButton(double left, double top, String url) {
    return Positioned(
      left: left,
      top: top,
      child: IconButton(
        onPressed: () async {
          try {
            await _launchURL(url);
          } catch (e) {
            print(e);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch URL')),
            );
          }
        },
        icon: Icon(Icons.location_on, color: Colors.red, size: 40), // Adjusted size for better fit
      ),
    );
  }
}
