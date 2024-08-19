import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LivestreamScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livestream'),
      ),
      body: WebView(
        initialUrl: 'https://example.com', // Replace with your livestream URL
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
