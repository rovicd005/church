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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoginMode = true;
  bool _isLoading = false;

  // Show a SnackBar for messages
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Input validation
  bool _validateInputs() {
    if (!_isLoginMode && _emailController.text.trim().isEmpty) {
      _showMessage("Email cannot be empty.", isError: true);
      return false;
    }
    if (_usernameController.text.trim().isEmpty) {
      _showMessage(
          _isLoginMode ? "Email cannot be empty." : "Username cannot be empty.",
          isError: true);
      return false;
    }
    if (_passwordController.text.trim().isEmpty) {
      _showMessage("Password cannot be empty.", isError: true);
      return false;
    }
    return true;
  }

  // Login function
  Future<void> _login() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://sanctisync.site/database/login.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'api_request': 'true',
          'email': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoadingScreen()),
        );
      } else {
        _showMessage(data['message'] ?? 'Login failed.', isError: true);
      }
    } catch (e) {
      _showMessage('An error occurred. Please try again later.', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Register function
  Future<void> _register() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://sanctisync.site/database/register.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        _showMessage('Registration successful. Please log in.');
        setState(() {
          _isLoginMode = true;
        });
      } else {
        _showMessage(data['message'] ?? 'Registration failed.', isError: true);
      }
    } catch (e) {
      _showMessage('An error occurred. Please try again later.', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
            child: SingleChildScrollView(
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
                    if (!_isLoginMode)
                      TextField(
                        controller: _emailController,
                        decoration: _buildInputDecoration('Email', Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: [AutofillHints.email],
                      ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: _buildInputDecoration(
                        _isLoginMode ? 'Email' : 'Username',
                        _isLoginMode ? Icons.email : Icons.person,
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: _buildInputDecoration('Password', Icons.lock)
                          .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.orangeAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      autofillHints: [AutofillHints.password],
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _isLoginMode
                          ? _login
                          : _register,
                      style: ElevatedButton.styleFrom(
                        padding:
                        EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        _isLoginMode ? 'Login' : 'Register',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLoginMode = !_isLoginMode;
                          _emailController.clear();
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
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.orangeAccent),
      filled: true,
      fillColor: Colors.white24,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      prefixIcon: Icon(icon, color: Colors.orangeAccent),
    );
  }
}
