import 'package:flutter/material.dart';
import 'main.dart'; // Import your next screen

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Simulate a delay and then navigate to the main screen
  void _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3)); // Simulate loading time
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MapAndLivestreamScreen()), // Navigate to your home screen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/backgroundscreen.jpg', // Path to your background image
              fit: BoxFit.cover,
            ),
          ),
          // Main content with loading line animation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 150.0), // Adjusted to raise the animation higher
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(seconds: 3),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Stack(
                        alignment: Alignment.center, // Center elements within the Stack
                        children: [
                          // The loading bar
                          SizedBox(
                            width: 300, // Width of the loading line
                            child: Container(
                              width: double.infinity,
                              height: 8, // Height of the loading line
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orangeAccent.withOpacity(0.8),
                                    Colors.orangeAccent.withOpacity(0.3),
                                  ],
                                  stops: [value, value],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                border: Border.all(
                                  color: Colors.orangeAccent, // Outline color
                                  width: 1, // Outline width
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orangeAccent.withOpacity(0.5),
                                    blurRadius: 10, // Blur radius for shadow
                                    spreadRadius: 2, // Spread radius for shadow
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // The percentage text inside the loading bar
                          Positioned(
                            child: Text(
                              '${(value * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: Colors.white, // Change color to white
                                fontSize: 18, // Font size for percentage text
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8), // Outline color
                                    offset: Offset(1, 1), // Offset for outline
                                    blurRadius: 2, // Blur radius for outline
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: 10), // Adjust spacing between loading line and text
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white, // Color for "Loading..." text
                    fontSize: 22, // Font size for "Loading..." text
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.8), // Outline color
                        offset: Offset(1, 1), // Offset for outline
                        blurRadius: 1, // Blur radius for outline
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Footer for branding or additional info
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Powered by Sanc✞iSync',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 16,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8), // Outline color
                      offset: Offset(1, 1), // Offset for outline
                      blurRadius: 1, // Blur radius for outline
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
