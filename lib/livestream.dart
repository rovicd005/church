import 'package:flutter/material.dart';
import 'livestream_viewer.dart';
import 'package:url_launcher/url_launcher.dart';

class LivestreamPage extends StatefulWidget {
  @override
  _LivestreamPageState createState() => _LivestreamPageState();
}

class _LivestreamPageState extends State<LivestreamPage> {
  final Map<String, bool> _churchStatus = {
    'SAN LUIS': false,
    'CANDABA': false,
    'MEXICO': true,
    'STA ANA': true,
    'ARAYAT': false,
  };

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
  };

  final List<String> _churchOrder = [
    'SAN LUIS',
    'CANDABA',
    'MEXICO',
    'STA ANA',
    'ARAYAT'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Church Livestream"),
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
          children: _churchOrder.map((churchName) {
            bool isLive = _churchStatus[churchName] ?? false;
            return _buildChurchCard(churchName, isLive);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChurchCard(String churchName, bool isLive) {
    return GestureDetector(
      onTap: () {
        _showStreamingOptions(context, churchName);
      },
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
                isLive ? 'Live Now' : 'Next Mass at ${_scheduledTimes[churchName] ?? 'N/A'}',
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

  void _showStreamingOptions(BuildContext context, String churchName) {
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
                  if (churchName == 'STA ANA' || churchName == 'ARAYAT') {
                    // Attempt to open external browser for restricted videos
                    _launchExternalBrowser(liveUrl);
                  } else {
                    // Open in WebView
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LivestreamViewer(liveUrl: liveUrl),
                      ),
                    );
                  }
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
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.stop, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                  _stopLiveStream();
                },
                label: Text('Stop Viewing'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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

  void _launchExternalBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open the livestream. Please check your URL or internet connection.")),
      );
    }
  }

  void _stopLiveStream() {
    print("Stopped viewing livestream.");
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
      default:
        return 'https://www.facebook.com/live';
    }
  }
}
