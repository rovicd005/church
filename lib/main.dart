import 'package:flutter/material.dart';
import 'log_in.dart';
import 'map.dart';
import 'livestream.dart';
import 'schedule.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // Ensure you have this file generated by Firebase CLI

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: firebaseOptionsAndroid);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: firebaseOptionsAndroid);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    requestNotificationPermission();
    initializeFirebaseMessaging(); // Initialize foreground message handling
    subscribeToTopic(); // Subscribe to topic for live notifications

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Function to request notification permissions
void requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

// Function to subscribe to a topic (e.g., "livestream")
void subscribeToTopic() {
  FirebaseMessaging.instance.subscribeToTopic('livestream');
  print('Subscribed to livestream topic');
}

// Function to handle incoming notifications in the foreground
void initializeFirebaseMessaging() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Message received in foreground: ${message.notification?.title}');
    // Optional: Show a local notification or update UI here
  });
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
            onPressed: _logOut,
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
