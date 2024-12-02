import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'livestream_viewer.dart';

class LivestreamPage extends StatefulWidget {
  @override
  _LivestreamPageState createState() => _LivestreamPageState();
}

class _LivestreamPageState extends State<LivestreamPage> {
  final Map<String, String> _churchImages = {
    'STA ANA': 'assets/sa.jpg',
    'ARAYAT': 'assets/ar.jpg',
    'MEXICO': 'assets/mex.jpg',
    'CANDABA': 'assets/background02.jpg',
    'SAN LUIS': 'assets/luis.jpg',
    'SanctiSync': 'assets/sf-img.jpg',
  };

  final Map<String, String> _churchLiveUrls = {
    'MEXICO': 'https://www.facebook.com/stamonicademexicopampanga/videos/1248162299839570',
    'ARAYAT': 'https://www.facebook.com/ApungTali1590/videos/3493001484342749',
    'STA ANA': 'https://www.facebook.com/parokyanang.santaana/videos/1358592665112173',
    'SAN LUIS': 'https://www.facebook.com/SanLuisGonzaga1734/videos/2030145657470471',
    'CANDABA': 'https://www.facebook.com/SanAndresCandaba/videos/414698628346062',
    'SanctiSync': 'https://www.facebook.com/100083499875388/videos/1248699369710214',
  };

  final Map<String, String> _accessTokens = {
    'SanctiSync':
    'EAAY86FkaOWQBO9rDrjP2GmuoFYxLCLeHpVjpJHzUnqc1dk98lsPMZCs4MsSXTDYgcJG3WTATbWu6QyereV8w8ZAiPriUyvXrQTDBj8F38ISnaQ1ZB4BR5CduUTwzUmKg56rNI34apcj8qyZCSOnwwidPNZZD',
  };

  final Map<String, String> _videoIds = {
    'SanctiSync': '1248699369710214',
  };

  final Map<String, bool> _churchLiveStatus = {};
  List<String> _liveNotifications = [];
  late Timer _timer;
  FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _checkLiveStatus();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _checkLiveStatus();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initializeNotifications() {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = IOSInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: iOS);
    _notificationsPlugin.initialize(settings);
  }

  Future<void> _showNotification(String churchName) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iOSDetails = IOSNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iOSDetails);
    await _notificationsPlugin.show(
      0,
      '$churchName is Live!',
      'Click to watch the livestream.',
      details,
    );

    if (!_liveNotifications.contains(churchName)) {
      setState(() {
        _liveNotifications.add(churchName);
      });
    }
  }

  Future<void> _checkLiveStatus() async {
    for (var church in _churchLiveUrls.keys) {
      final accessToken = _accessTokens[church];
      final videoId = _videoIds[church];
      if (accessToken != null && videoId != null) {
        final url =
            'https://graph.facebook.com/v21.0/$videoId?fields=live_status&access_token=$accessToken';

        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final isLive = data['live_status'] == 'LIVE';

            if (_churchLiveStatus[church] != true && isLive) {
              _showNotification(church);
            }

            setState(() {
              _churchLiveStatus[church] = isLive;
            });
          } else {
            print('Failed to fetch live status for $church: ${response.statusCode}');
          }
        } catch (e) {
          print('Error fetching live status for $church: $e');
        }
      }
    }
  }

  void _showLiveNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Live Notifications"),
          content: _liveNotifications.isEmpty
              ? Text("No churches are live at the moment.")
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: _liveNotifications.map((name) {
              return ListTile(
                title: Text(name),
                onTap: () {
                  final liveUrl = _churchLiveUrls[name]!;
                  final accessToken = _accessTokens[name] ?? '';
                  final videoId = _videoIds[name] ?? '';

                  Navigator.pop(context); // Close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LivestreamViewer(
                        liveUrl: liveUrl,
                        accessToken: accessToken,
                        videoId: videoId,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Church Livestreams"),
        backgroundColor: Colors.blueGrey[800],
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications),
                if (_liveNotifications.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${_liveNotifications.length}',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _showLiveNotificationDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: _churchLiveUrls.length,
          itemBuilder: (context, index) {
            final churchName = _churchLiveUrls.keys.elementAt(index);
            return _buildChurchCard(
              context,
              churchName,
              _churchImages[churchName] ?? 'assets/default.jpg',
              _churchLiveUrls[churchName]!,
              _churchLiveStatus[churchName] == true,
            );
          },
        ),
      ),
    );
  }

  Widget _buildChurchCard(
      BuildContext context, String churchName, String imageUrl, String liveUrl, bool isLive) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Stack(
            children: [
              Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                width: 50,
                height: 50,
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  color: isLive ? Colors.red : Colors.grey,
                  child: Text(
                    isLive ? 'Live Now' : 'Not Available',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(churchName),
        trailing: ElevatedButton(
          onPressed: isLive
              ? () {
            final accessToken = _accessTokens[churchName] ?? '';
            final videoId = _videoIds[churchName] ?? '';

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LivestreamViewer(
                  liveUrl: liveUrl,
                  accessToken: accessToken,
                  videoId: videoId,
                ),
              ),
            );
          }
              : null,
          child: Text('Watch'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isLive ? Colors.blue : Colors.grey,
          ),
        ),
      ),
    );
  }
}
