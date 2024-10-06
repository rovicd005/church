import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class LivestreamPage extends StatefulWidget {
  @override
  _LivestreamPageState createState() => _LivestreamPageState();
}

class _LivestreamPageState extends State<LivestreamPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();  // Create instance of RTCVideoRenderer
  MediaStream? _localStream;
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();

  // Set the RTMP URL for Facebook Live
  final String _rtmpUrl = 'rtmp://live-api-s.facebook.com:80/rtmp/FB-1273380167409610-0-AbzuijAMsG1WLlLi';

  @override
  void initState() {
    super.initState();
    _initializeRenderer();
  }

  @override
  void dispose() {
    _localStream?.dispose(); // Dispose stream safely
    _localRenderer.dispose(); // Dispose renderer properly
    super.dispose();
  }

  Future<void> _initializeRenderer() async {
    try {
      await _localRenderer.initialize(); // Initialize the renderer before use
    } catch (e) {
      print('Error initializing renderer: $e');
    }
  }

  Future<void> _startLiveStream() async {
    // Get user media (camera and microphone)
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };

    try {
      // Obtain the media stream from the user's device
      MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      setState(() {
        _localStream = stream;
        _localRenderer.srcObject = stream; // Set the renderer's source to the media stream
      });

      // Command to start streaming to Facebook using FFmpeg
      String command = [
        '-f', 'lavfi', '-i', 'anullsrc',        // Handle no audio track in case there's none
        '-f', 'v4l2', '-i', '/dev/video0',      // Video input (make sure the input matches)
        '-vcodec', 'libx264',                   // Set the video codec
        '-preset', 'ultrafast',                 // Set the encoding preset (quality vs speed)
        '-f', 'flv',                            // Set the output format to FLV for RTMP
        _rtmpUrl                                // Set the RTMP URL
      ].join(' ');

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

      // Cancel the FFmpeg command
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
        ],
      ),
    );
  }
}
