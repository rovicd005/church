import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'livestream_viewer.dart';
import 'package:flutter/services.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class LivestreamPage extends StatefulWidget {
  @override
  _LivestreamPageState createState() => _LivestreamPageState();
}

class _LivestreamPageState extends State<LivestreamPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("churchStatus");
  List<String> _notifiedChurches = []; // Track churches that have been notified

  Map<String, dynamic> _churchData = {
    'ARAYAT': {'isLive': false, 'liveUrl': '', 'imagePath': 'assets/ar.jpg'},
    'CANDABA': {'isLive': false, 'liveUrl': '', 'imagePath': 'assets/background02.jpg'},
    'MEXICO': {'isLive': false, 'liveUrl': '', 'imagePath': 'assets/mex.jpg'},
    'SAN LUIS': {'isLive': false, 'liveUrl': '', 'imagePath': 'assets/luis.jpg'},
    'STA ANA': {'isLive': false, 'liveUrl': '', 'imagePath': 'assets/sa.jpg'},
    'Sanctisync': {'isLive': false, 'liveUrl': ''}
  };

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _listenToFirebaseUpdates();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        String? payload = notificationResponse.payload;
        if (payload != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LivestreamViewer(liveUrl: _churchData[payload]!['liveUrl'])),
          );
        }
      },
    );
  }

  void _showLiveNotification(String churchName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'church_livestream_channel',
      'Church Livestream',
      channelDescription: 'Notifications for live church streams',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Live Now: $churchName',
      '$churchName is now streaming live. Tap to view.',
      platformChannelSpecifics,
      payload: churchName, // Pass church name as payload
    );
  }

  void _listenToFirebaseUpdates() {
    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      print("Received data from Firebase: $data");  // Log received data for debugging

      setState(() {
        _churchData = data.map((key, value) => MapEntry(
            key.toString(),
            value as Map<String, dynamic>
        ));
      });

      // Check for live status and send notification if Sanctisync goes live
      if (_churchData['Sanctisync']?['isLive'] == true && !_notifiedChurches.contains('Sanctisync')) {
        _showLiveNotification("Sanctisync");
        print("Notification sent for Sanctisync going live.");  // Debugging line
        _notifiedChurches.add('Sanctisync');
      } else if (_churchData['Sanctisync']?['isLive'] == false) {
        _notifiedChurches.remove('Sanctisync'); // Reset if Sanctisync goes offline
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Church Livestream",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[850],
        centerTitle: true,
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: _churchData.keys.map((churchName) {
            bool isLive = _churchData[churchName]['isLive'];
            return _buildChurchCard(churchName, isLive);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChurchCard(String churchName, bool isLive) {
    final String? imagePath = _churchData[churchName]?['imagePath'];
    print("Loading image for $churchName: $imagePath"); // Log to verify each path

    return GestureDetector(
      onTap: () => _showStreamingOptions(context, churchName),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              imagePath ?? 'assets/default.jpg',  // Default image path if null
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLive ? Colors.red : Colors.grey[700],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isLive ? 'Live Now' : 'Offline',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Center(
              child: Text(
                churchName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStreamingOptions(BuildContext context, String churchName) {
    final liveUrl = _churchData[churchName]['liveUrl'] ?? '';

    if (liveUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$churchName is not currently live.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$churchName Livestream',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.play_circle_outline, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LivestreamViewer(liveUrl: liveUrl)),
                  );
                },
                label: Text('Watch Livestream'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
