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
  final _emailController = TextEditingController(); // New controller for email
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoginMode = true;

  // Login function
  Future<void> _login() async {
    final url = Uri.parse('https://sanctisync.site/database/login.php'); // URL for login API
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded', // Correct content type
        },
        body: {
          'api_request': 'true', // Flag to indicate API request
          'email': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoadingScreen()),
          );
        } else {
          _showMessage(data['message'] ?? 'Login failed');
        }
      } else {
        _showMessage('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during login: $e');
      _showMessage('An error occurred. Please try again later.');
    }
  }

  // Register function
  Future<void> _register() async {
    final url = Uri.parse('https://sanctisync.site/database/register.php'); // URL for register API
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded', // Correct content type
        },
        body: {
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _showMessage('Registration successful. Please log in.');
          setState(() {
            _isLoginMode = true;
          });
        } else {
          _showMessage(data['message'] ?? 'Registration failed');
        }
      } else {
        _showMessage('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during registration: $e');
      _showMessage('An error occurred. Please try again later.');
    }
  }

  // Display message
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background456.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sanc✞iSync',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 50),
                  if (!_isLoginMode) // Show email field only for registration
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.orangeAccent),
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.orangeAccent),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: _isLoginMode ? 'Email' : 'Username', // Change label based on mode
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
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
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
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: _isLoginMode ? _login : _register,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      _isLoginMode ? 'Login' : 'Register',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode; // Toggle between login and register
                        if (_isLoginMode) {
                          _emailController.clear();
                        }
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
