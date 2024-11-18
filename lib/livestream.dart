import 'package:flutter/material.dart';
import 'livestream_viewer.dart';

class LivestreamPage extends StatelessWidget {
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
    'SanctiSync': 'https://www.facebook.com/100083499875388/videos/576448868105685',
  };

  final Map<String, String> _accessTokens = {
    'SanctiSync':
    'EAAY86FkaOWQBO9rDrjP2GmuoFYxLCLeHpVjpJHzUnqc1dk98lsPMZCs4MsSXTDYgcJG3WTATbWu6QyereV8w8ZAiPriUyvXrQTDBj8F38ISnaQ1ZB4BR5CduUTwzUmKg56rNI34apcj8qyZCSOnwwidPNZAQx82ZAMm8cJSGnN6KrfdZCT2ZBd26Fp7gskb2VcYZD',
  };

  final Map<String, String> _videoIds = {
      'SanctiSync': '576448868105685',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Church Livestreams"),
        backgroundColor: Colors.blueGrey[800],
        centerTitle: true,
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildChurchCard(
      BuildContext context, String churchName, String imageUrl, String liveUrl) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            width: 50,
            height: 50,
          ),
        ),
        title: Text(churchName),
        trailing: ElevatedButton(
          onPressed: () {
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
          },
          child: Text('Watch'),
        ),
      ),
    );
  }
}
