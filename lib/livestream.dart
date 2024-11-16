import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'livestream_viewer.dart';

class LivestreamPage extends StatefulWidget {
  @override
  _LivestreamPageState createState() => _LivestreamPageState();
}

class _LivestreamPageState extends State<LivestreamPage> {
  DatabaseReference? _churchStatusRef;
  bool _isAnyChurchLive = false;
  Map<dynamic, dynamic>? _statusData;

  final Map<String, String> _scheduledTimes = {
    'ARAYAT': '10:00 AM',
    'CANDABA': '12:00 PM',
    'SAN LUIS': '3:00 PM',
  };

  final Map<String, String> _churchImages = {
    'STA ANA': 'assets/sa.jpg',
    'ARAYAT': 'assets/ar.jpg',
    'MEXICO': 'assets/mex.jpg',
    'CANDABA': 'assets/background02.jpg',
    'SAN LUIS': 'assets/luis.jpg',
    'SanctiSync': 'assets/sf-img.jpg',
  };

  final List<String> _churchOrder = [
    'SAN LUIS',
    'CANDABA',
    'MEXICO',
    'STA ANA',
    'ARAYAT',
    'SanctiSync',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      _churchStatusRef = FirebaseDatabase.instance.ref().child('churchStatus');
      _listenToChurchStatus();
    } catch (e) {
      print("Error initializing Firebase: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error initializing Firebase. Please try again later."),
          ),
        );
      }
    }
  }

  void _listenToChurchStatus() {
    if (_churchStatusRef != null) {
      _churchStatusRef!.onValue.listen(
            (event) {
          try {
            final statusData = event.snapshot.value as Map<dynamic, dynamic>?;
            setState(() {
              _statusData = statusData;
              _isAnyChurchLive = statusData != null &&
                  statusData.values.any((status) => status == true);
            });
          } catch (e) {
            print("Error parsing church status: $e");
          }
        },
        onError: (error) {
          print("Error listening to church status: $error");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Error fetching church status. Please try again later."),
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Church Livestream"),
        backgroundColor: Colors.grey[850],
        centerTitle: true,
        elevation: 4.0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: _isAnyChurchLive ? Colors.red : Colors.white,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isAnyChurchLive
                      ? "A church is live now!"
                      : "No church is live at the moment."),
                ),
              );
            },
          ),
        ],
      ),
      body: _statusData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: _churchOrder.map((churchName) {
            bool isLive = _statusData?[churchName] == true;
            return _buildChurchCard(churchName, isLive);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChurchCard(String churchName, bool isLive) {
    return GestureDetector(
      onTap: () => _showChurchOptions(context, churchName, isLive),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.asset(
              _churchImages[churchName] ?? 'assets/default.jpg',
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
                isLive
                    ? 'Live Now'
                    : 'Next Mass at ${_scheduledTimes[churchName] ?? 'N/A'}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
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

  void _showChurchOptions(BuildContext context, String churchName, bool isLive) {
    final liveUrl = _getLiveViewUrlForChurch(churchName);

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
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.play_circle_outline, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LivestreamViewer(liveUrl: liveUrl),
                    ),
                  );
                },
                label: Text('Watch Livestream'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLiveViewUrlForChurch(String churchName) {
    switch (churchName) {
      case 'MEXICO':
        return 'https://www.facebook.com/stamonicademexicopampanga/videos/1248162299839570';
      case 'ARAYAT':
        return 'https://www.facebook.com/ApungTali1590/videos/3493001484342749';
      case 'STA ANA':
        return 'https://www.facebook.com/parokyanang.santaana/videos/1358592665112173';
      case 'SAN LUIS':
        return 'https://www.facebook.com/SanLuisGonzaga1734/videos/2030145657470471';
      case 'CANDABA':
        return 'https://www.facebook.com/SanAndresCandaba/videos/414698628346062';
      case 'SanctiSync':
        return 'https://www.facebook.com/sanctisync/videos/sample-live-video';
      default:
        return '';
    }
  }
}
