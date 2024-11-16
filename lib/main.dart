import 'package:flutter/material.dart';
import 'log_in.dart'; // Import the login screen
import 'map.dart'; // Import the map screen
import 'livestream.dart'; // Import the livestream screen
import 'schedule.dart'; // Import the schedule screen
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void main() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          color: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.grey[300]!),
          titleTextStyle: TextStyle(
            color: Colors.grey[300]!,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.grey[300]!,
          unselectedItemColor: Colors.grey[500]!,
          selectedIconTheme: IconThemeData(size: 30, color: Colors.grey[300]!),
          unselectedIconTheme: IconThemeData(size: 24, color: Colors.grey[500]!),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[300]!),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.grey[500]!),
        ),
      ),
      home: LoginScreen(), // Start with the LoginScreen
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapAndLivestreamScreen extends StatefulWidget {
  @override
  _MapAndLivestreamScreenState createState() => _MapAndLivestreamScreenState();
}

class _MapAndLivestreamScreenState extends State<MapAndLivestreamScreen> {
  int _selectedIndex = 0;

  final Map<int, String> _labels = {
    0: 'Map',
    1: 'Livestream',
    2: 'Schedule',
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You tapped: ${_labels[index]}',
          style: TextStyle(color: Colors.black),
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.grey[200]!,
      ),
    );

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LivestreamPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ScheduleScreen()),
        );
        break;
    }
  }

  void _logOut() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[800]!, Colors.grey[900]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        elevation: 0,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Sanc',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.grey[300]!,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
              TextSpan(
                text: '✞',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.orangeAccent,
                ),
              ),
              TextSpan(
                text: 'iSync',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.grey[300]!,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(3, 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.grey[300]),
            onPressed: _logOut, // Call the logout function
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background456.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Center(
                  // Additional content can be added here
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[800]!, Colors.grey[900]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.map, color: Colors.orangeAccent),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.live_tv, color: Colors.orangeAccent),
              label: 'Livestream',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule, color: Colors.orangeAccent),
              label: 'Schedule',
            ),
          ],
        ),
      ),
    );
  }
}