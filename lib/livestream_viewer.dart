import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class LivestreamViewer extends StatefulWidget {
  final String liveUrl; // Facebook live URL
  final String videoId; // Facebook video ID
  final String accessToken; // Facebook access token

  LivestreamViewer({
    required this.liveUrl,
    required this.videoId,
    required this.accessToken,
  });

  @override
  _LivestreamViewerState createState() => _LivestreamViewerState();
}

class _LivestreamViewerState extends State<LivestreamViewer> {
  late final String embedUrl;
  List<dynamic> comments = [];
  bool isLoadingComments = true;
  late Timer _timer;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Construct Facebook embed URL
    embedUrl =
    'https://www.facebook.com/plugins/video.php?href=${Uri.encodeComponent(widget.liveUrl)}&show_text=0&autoplay=1&mute=0';

    // Start fetching comments every 10 seconds
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchComments();
    });

    // Initial fetch of comments
    fetchComments();
  }

  @override
  void dispose() {
    _timer.cancel();
    commentController.dispose();
    super.dispose();
  }

  Future<void> fetchComments() async {
    final url =
        'https://graph.facebook.com/v21.0/${widget.videoId}/comments?fields=from,message,created_time&access_token=${widget.accessToken}';

    print('Fetching comments from: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed Response: $data');
        setState(() {
          comments = data['data'] ?? [];
          isLoadingComments = false;
        });
      } else {
        print('Failed with status: ${response.statusCode}');
        print('Error Body: ${response.body}');
        setState(() {
          isLoadingComments = false;
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoadingComments = false;
      });
    }
  }

  Future<void> postComment(String message) async {
    final url =
        'https://graph.facebook.com/v21.0/${widget.videoId}/comments?message=$message&access_token=${widget.accessToken}';

    print('Posting comment to: $url');

    try {
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        print('Comment posted successfully');
        fetchComments(); // Refresh comments after posting
      } else {
        print('Failed to post comment: ${response.statusCode}');
        print('Error Body: ${response.body}');
      }
    } catch (error) {
      print('Error posting comment: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Livestream Viewer'),
        backgroundColor: Colors.blueGrey[800],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Video Player
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              child: WebView(
                initialUrl: embedUrl,
                javascriptMode: JavascriptMode.unrestricted,
                gestureNavigationEnabled: true,
                onWebViewCreated: (controller) {
                  print('WebView created');
                },
                onPageStarted: (url) {
                  print('WebView started loading: $url');
                },
                onPageFinished: (url) {
                  print('WebView finished loading: $url');
                },
                onWebResourceError: (error) {
                  print('WebView error: ${error.description}');
                },
              ),
            ),
          ),
          // Comment Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Write a comment...',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (commentController.text.isNotEmpty) {
                      postComment(commentController.text);
                      commentController.clear();
                    }
                  },
                  child: Text('Post'),
                ),
              ],
            ),
          ),
          // Real-time Comments Section
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Live Comments',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: isLoadingComments
                        ? Center(child: CircularProgressIndicator())
                        : comments.isEmpty
                        ? Center(
                      child: Text(
                        'No comments available.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                        : ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final commenterName =
                            comment['from']?['name'] ?? 'Unknown User';
                        final commentMessage =
                            comment['message'] ?? 'No message';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              commenterName[0],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(commenterName),
                          subtitle: Text(commentMessage),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
