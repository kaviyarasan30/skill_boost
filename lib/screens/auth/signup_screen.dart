import 'package:flutter/material.dart';
import 'package:skill_boost/screens/auth/login_screen.dart';
import 'package:skill_boost/screens/home/main_screen.dart';
import 'package:skill_boost/utils/button_style.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Image.asset(
                              'assets/logo.png',
                              width: constraints.maxWidth * 0.8,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLabeledTextField(
                                label: 'Full Name',
                                controller: _fullNameController,
                                hintText: 'Enter your full name',
                                icon: Icons.person,
                              ),
                              const SizedBox(height: 16),
                              _buildLabeledTextField(
                                label: 'Email',
                                controller: _emailController,
                                hintText: 'Enter your email',
                                icon: Icons.email,
                                errorText: _emailError,
                                onChanged: (_) =>
                                    setState(() => _emailError = null),
                              ),
                              const SizedBox(height: 16),
                              _buildLabeledTextField(
                                label: 'Password',
                                controller: _passwordController,
                                hintText: 'Enter your password',
                                obscureText: !_passwordVisible,
                                icon: Icons.lock,
                                errorText: _passwordError,
                                onChanged: (_) =>
                                    setState(() => _passwordError = null),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () => setState(() =>
                                      _passwordVisible = !_passwordVisible),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildLabeledTextField(
                                label: 'Confirm Password',
                                controller: _confirmPasswordController,
                                hintText: 'Re-enter your password',
                                obscureText: !_confirmPasswordVisible,
                                icon: Icons.lock,
                                errorText: _confirmPasswordError,
                                onChanged: (_) => setState(
                                    () => _confirmPasswordError = null),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _confirmPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey[600],
                                  ),
                                  onPressed: () => setState(() =>
                                      _confirmPasswordVisible =
                                          !_confirmPasswordVisible),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _handleSignUp,
                                style: globalButtonStyle,
                                child: const Text('Sign Up'),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()),
                                  );
                                },
                                child: const Text('Back to Login'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    IconData? icon,
    Widget? suffixIcon,
    String? errorText,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey[100],
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            errorText: errorText,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    bool isValid = true;

    // Validate email
    if (!_isValidEmail(_emailController.text)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
      isValid = false;
    }

    // Validate password
    if (_passwordController.text.length < 8) {
      setState(() {
        _passwordError = 'Password must be at least 8 characters long';
      });
      isValid = false;
    }

    // Validate confirm password
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      isValid = false;
    }

    if (isValid) {
      // API call for sign up
      final response = await http.post(
        Uri.parse(
            'https://c48b-2409-40f4-40c0-2e6c-a989-9319-7944-9135.ngrok-free.app/api/user/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': _fullNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'confirm_password': _confirmPasswordController.text,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Store token in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']); // Store the token

        // Navigate to the main screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorData['error'] ?? 'Registration failed')),
        );
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(email);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
