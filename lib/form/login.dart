import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fx_analysis/user_profile.dart';
import 'package:fx_analysis/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _usernameError = '';
  String _passwordError = '';
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedPassword = prefs.getString('password');

    if (savedUsername != null && savedPassword != null) {
      _usernameController.text = savedUsername;
      _passwordController.text = savedPassword;
      setState(() {
        _rememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Login'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              errorText: _usernameError.isEmpty ? null : _usernameError,
            ),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _passwordError.isEmpty ? null : _passwordError,
            ),
            obscureText: true,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (bool? value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              const Text('Remember Me'),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            _loginUser();
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 10),
          ),
          child: const Text('Login'),
        ),
      ],
    );
  }

  void _loginUser() async {
  final file = File('C:/Users/gonca/Documents/Projects/FXTM/lib/json/users.json');

  if (await file.exists()) {
    final String contents = await file.readAsString();
    final List<dynamic> users = jsonDecode(contents);

    User? authenticatedUser;

    for (var userData in users) {
      if (userData['username'] == _usernameController.text &&
          userData['password'] == _passwordController.text.codeUnits.toString()) {
        authenticatedUser = User.fromJson(userData);
        break;
      }
    }

    if (authenticatedUser != null) {
      if (_rememberMe) {
        _saveCredentials();
      } else {
        _clearCredentials();
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UserProfile(user: authenticatedUser!),
          ),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _usernameError = 'Invalid username or password';
          _passwordError = 'Invalid username or password';
        });
      }
    }
  } else {
    if (mounted) {
      setState(() {
        _usernameError = 'No user data found. Please register first.';
      });
    }
  }
}


  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('password', _passwordController.text);
  }

  Future<void> _clearCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
