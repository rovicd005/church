import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class LivestreamPage extends StatefulWidget {
  @override
  _LivestreamPageState createState() => _LivestreamPageState();
}

class _LivestreamPageState extends State<LivestreamPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  final String _rtmpUrl = 'rtmp://live-api-s.facebook.com:80/rtmp/FB-1273380167409610-0-AbzuijAMsG1WLlLi';

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

      String command = ['-f', 'lavfi', '-i', 'anullsrc', '-f', 'v4l2', '-i', '/dev/video0', '-vcodec', 'libx264', '-preset', 'ultrafast', '-f', 'flv', _rtmpUrl].join(' ');
      _ffmpeg.execute(command).then((rc) => print("FFmpeg process exited with rc $rc"));
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Church Livestream'),
      ),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(
              _localRenderer,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
            ),
          ),
          ElevatedButton(
            onPressed: _startLiveStream,
            child: Text('Start Stream'),
          ),
          ElevatedButton(
            onPressed: _stopLiveStream,
            child: Text('Stop Stream'),
          ),
          Center(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildButton('STA ANA'),
                _buildButton('ARAYAT'),
                _buildButton('MEXICO'),
                _buildButton('CANDABA'),
                _buildButton('SAN LUIS'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String title) {
    return ElevatedButton(
      onPressed: () {}, // Customize with actual function
      child: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue, // Button color
        foregroundColor: Colors.white, // Text color, replaces onPrimary
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded corners
        ),
      ),
    );
  }

}
