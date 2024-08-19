import 'package:flutter/material.dart';
import 'map.dart'; // Import the map.dart file
import 'livestream.dart'; // Import the livestream.dart file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MapAndLivestreamScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapAndLivestreamScreen extends StatefulWidget {
  @override
  _MapAndLivestreamScreenState createState() => _MapAndLivestreamScreenState();
}

class _MapAndLivestreamScreenState extends State<MapAndLivestreamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[800]!, Colors.grey[600]!], // Grey gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map, size: 28, color: Colors.white),
            SizedBox(width: 8.0), // Space between icon and title
            Text(
              'SantiSync', // Updated title
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background5.jpg', // Path to your background image
              fit: BoxFit.cover, // Ensure the image covers the entire background
            ),
          ),
          // Foreground content
          Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Spacer(), // Takes up available space in the middle
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: _buildButton(
                              label: 'Map',
                              color: Colors.grey[700]!, // Grey color for the button
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MapScreen(), // Navigate to MapScreen in map.dart
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 16.0), // Space between buttons
                          Expanded(
                            child: _buildButton(
                              label: 'Livestream',
                              color: Colors.grey[700]!, // Grey color for the button
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LivestreamScreen(), // Navigate to LivestreamScreen in livestream.dart
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Function to build buttons with enhanced styling
  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 5.0, // Add elevation for a more pronounced button effect
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 20, // Increase font size for better visibility
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2, // Add letter spacing for improved readability
          ),
        ),
      ),
    );
  }
}
