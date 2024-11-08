import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LivestreamViewer extends StatefulWidget {
  final String liveUrl;

  LivestreamViewer({required this.liveUrl});

  @override
  _LivestreamViewerState createState() => _LivestreamViewerState();
}

class _LivestreamViewerState extends State<LivestreamViewer> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Use the liveUrl passed from the LivestreamPage for the selected church
    String embedUrl = "https://www.facebook.com/plugins/video.php?href=${Uri.encodeComponent(widget.liveUrl)}";
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Livestream")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
