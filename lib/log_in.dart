import 'package:flutter/material.dart';
import 'loading_screen.dart'; // Import the loading screen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false; // Add a variable to track password visibility

  void _login() {
    // Replace with actual authentication logic
    if (_usernameController.text == 'user' && _passwordController.text == '123') {
      // Navigate to the LoadingScreen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoadingScreen()), // Navigate to the LoadingScreen
      );
    } else {
      // Show an error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/background456.jpg', // Path to your image
              fit: BoxFit.cover, // Ensures the image covers the entire screen
            ),
          ),
          // Semi-transparent overlay to improve readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5), // Darken the background
            ),
          ),
          // Content on top of the background
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App title or logo
                  Text(
                    'Sanc✞iSync',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  // Username input
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.orangeAccent),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.orangeAccent),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  // Password input with show/hide functionality
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible, // Toggle the obscureText property
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.orangeAccent),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.orangeAccent),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.orangeAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible; // Toggle password visibility
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 50),
                  // Login button with hover effect
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                      backgroundColor: Colors.orangeAccent, // Button background color
                      foregroundColor: Colors.white, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5, // Elevation for depth
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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