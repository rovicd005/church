import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:url_launcher/url_launcher.dart';

class LivestreamPage extends StatefulWidget {
  @override
  _LivestreamPageState createState() => _LivestreamPageState();
}

class _LivestreamPageState extends State<LivestreamPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  // Default RTMP URL, dynamically updated based on the selected church
  String _rtmpUrl = 'rtmp://live-api-s.facebook.com:80/rtmp/FB-1273380167409610-0-AbzuijAMsG1WLlLi';

  // URL for the live view on the streaming platform
  String _liveViewUrl = 'https://www.facebook.com/live/producer'; // Replace with the specific live page URL

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
  }

  @override
  void dispose() {
    _localStream?.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  Future<void> _initializeRenderer() async {
    try {
      await _localRenderer.initialize();
    } catch (e) {
      print('Error initializing renderer: $e');
    }
  }

  Future<void> _startLiveStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {'facingMode': 'user'}
    };

    try {
      MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      setState(() {
        _localStream = stream;
        _localRenderer.srcObject = stream;
      });

      String command = [
        '-f', 'lavfi', '-i', 'anullsrc', // Dummy audio input for RTMP
        '-f', 'v4l2', '-i', '/dev/video0', // Video input (adjust if necessary for your device)
        '-vcodec', 'libx264', // Video codec
        '-preset', 'ultrafast', // Encoding speed
        '-f', 'flv', _rtmpUrl // RTMP URL for the specific church
      ].join(' ');

      _ffmpeg.execute(command).then((rc) {
        print("FFmpeg process exited with rc $rc");
        if (rc == 0) {
          print("Stream started successfully");
          _openLiveStreamPage(); // Open the live stream page after starting the stream
        } else {
          print("Error occurred during streaming: $rc");
        }
      });
    } catch (e) {
      print('Error getting user media: $e');
    }
  }

  Future<void> _stopLiveStream() async {
    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        track.stop();
      }
      setState(() {
        _localStream = null;
        _localRenderer.srcObject = null;
      });

      _ffmpeg.cancel();
      print("Stream stopped");
    }
  }

  Future<void> _openLiveStreamPage() async {
    if (await canLaunch(_liveViewUrl)) {
      await launch(_liveViewUrl);
    } else {
      print("Could not open the live stream page.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Church Livestream'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Replace with your background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStyledButton('STA ANA'),
                SizedBox(height: 20),
                _buildStyledButton('ARAYAT'),
                SizedBox(height: 20),
                _buildStyledButton('MEXICO'),
                SizedBox(height: 20),
                _buildStyledButton('CANDABA'),
                SizedBox(height: 20),
                _buildStyledButton('SAN LUIS'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledButton(String title) {
    return GestureDetector(
      onTap: () {
        _showStreamingOptions(title);
      },
      child: Container(
        width: 200,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 10.0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  void _showStreamingOptions(String churchName) {
    // Dynamically set RTMP URL based on the church name
    setState(() {
      _rtmpUrl = _getRtmpUrlForChurch(churchName);
      _liveViewUrl = 'https://www.facebook.com/live/producer'; // Replace with actual live view URL if needed
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$churchName Livestream Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startLiveStream();
                },
                child: Text('Start Streaming'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _stopLiveStream();
                },
                child: Text('Stop Streaming'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getRtmpUrlForChurch(String churchName) {
    // Return a unique RTMP URL for each church
    switch (churchName) {
      case 'STA ANA':
        return 'rtmp://live-api-s.facebook.com:80/rtmp/FB-STA-ANA';
      case 'ARAYAT':
        return 'rtmp://live-api-s.facebook.com:80/rtmp/FB-ARAYAT';
      case 'MEXICO':
        return 'rtmp://live-api-s.facebook.com:80/rtmp/FB-MEXICO';
      case 'CANDABA':
        return 'rtmp://live-api-s.facebook.com:80/rtmp/FB-CANDABA';
      case 'SAN LUIS':
        return 'rtmp://live-api-s.facebook.com:80/rtmp/FB-SAN-LUIS';
      default:
        return _rtmpUrl; // Default to the initial RTMP URL if no match
    }
  }
}
