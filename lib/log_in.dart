import 'package:flutter/material.dart';
import 'loading_screen.dart'; // Import the loading screen
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false; // Add a variable to track password visibility
  bool _isLoginMode = true; // Toggle between login and register modes

  void _login() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.68.130/db.php'), // Update with your server's IP or domain
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data['success']) {
            // Navigate to the LoadingScreen after successful login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoadingScreen()),
            );
          } else {
            // Show an error message if login fails
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'])),
            );
          }
        } catch (e) {
          print('JSON decoding error: $e');
          print('Server response: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred. Please try again later.')),
          );
        }
      } else {
        // Print the server response for debugging
        print('Server responded with status code: ${response.statusCode}');
        print('Server response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}. Please try again later.')),
        );
      }
    } catch (e) {
      // Print any error caught during the request
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
      );
    }
  }

  void _register() async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.68.130/church/register.php'), // Update with your server's IP or domain
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success']) {
          // Show a success message and switch to login mode
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful. Please log in.')),
          );
          setState(() {
            _isLoginMode = true;
          });
        } else {
          // Show an error message if registration fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'])),
          );
        }
      } else {
        // Print the server response for debugging
        print('Server responded with status code: ${response.statusCode}');
        print('Server response: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response.statusCode}. Please try again later.')),
        );
      }
    } catch (e) {
      // Print any error caught during the request
      print('Error during registration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again later.')),
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
                  // Login/Register button
                  ElevatedButton(
                    onPressed: _isLoginMode ? _login : _register,
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
                      _isLoginMode ? 'Login' : 'Register',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Toggle between login and register modes
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                      });
                    },
                    child: Text(
                      _isLoginMode
                          ? "Don't have an account? Register here"
                          : "Already have an account? Log in",
                      style: TextStyle(color: Colors.orangeAccent),
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
