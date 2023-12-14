import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:only_plants/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLogin = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _validateLoginFields() {
    if (_isLogin) {
      if (_emailController.text.isEmpty && _passwordController.text.isEmpty) {
        _showErrorDialog('Please fill in email and password fields.');
        return false;
      }
      if (_emailController.text.isEmpty) {
        _showErrorDialog('Please fill in email field.');
        return false;
      }
      if (_passwordController.text.isEmpty) {
        _showErrorDialog('Please fill in password field.');
        return false;
      }
    }
    if (!_isLogin) {
      if (_emailController.text.isEmpty &&
          (_passwordController.text.isEmpty ||
              _confirmPasswordController.text.isEmpty)) {
        _showErrorDialog('Please fill in email and password fields.');
        return false;
      }
      if (_emailController.text.isEmpty) {
        _showErrorDialog('Please fill in email field.');
        return false;
      }
      if (_passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        _showErrorDialog('Please fill in both password fields.');
        return false;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showErrorDialog('The passwords do not match.');
        return false;
      }
    }
    return true;
  }

  String _getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'The email address is not valid. Please enter a valid email address.';
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'The login credentials are not correct. Please try again.';
      case 'weak-password':
        return 'The password must be at least 6 characters long. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Please login or use a different email.';
      default:
        return errorCode;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _register() async {
    if (!_validateLoginFields()) {
      return;
    }

    // Sign out the current user if there is any
    await FirebaseAuth.instance.signOut();

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Clear email and password fields after successful registration
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      // Show a success message
      _showSuccessDialog('Successfully registered!');
    } on FirebaseAuthException catch (e) {
      // Check if the email is already in use
      if (e.code == 'email-already-in-use') {
        // If it is, don't show an error dialog and handle it appropriately
        // You can navigate the user to the login page or display a different message
        print('Email is already registered. Redirecting to login...');
        return;
      }

      // If it's another error, show the error dialog
      _showErrorDialog(_getFirebaseAuthErrorMessage(e.code));
    }
  }

  Future<void> _login() async {
    if (!_validateLoginFields()) {
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Clear email and password fields after successful login
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();

      // Navigate to the main page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(_getFirebaseAuthErrorMessage(e.code));
    }
  }

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                 Text(
                  "Welcome To OnlyPlants",
                   style: GoogleFonts.getFont(
                'Lobster',
                textStyle: Theme.of(context).textTheme.headline5,
                fontSize: 40.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 10),
                if (_isLogin) ...[
                  _passwordField(
                      label: "Password", controller: _passwordController),
                  const SizedBox(height: 20),
                  _forgotPasswordButton(),
                ] else ...[
                  _passwordField(
                      label: "Create Password",
                      controller: _passwordController),
                  const SizedBox(height: 10),
                  _passwordField(
                      label: "Confirm Password",
                      controller: _confirmPasswordController),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_isLogin) {
                      _login();
                    } else {
                      _register();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    _isLogin ? "Login" : "Register",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _toggleForm,
                  child: Text(
                    _isLogin ? "Register" : "Login",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 59, 138, 61),
    );
  }

  // ignore: unused_element
  TextFormField _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
    TextInputAction inputAction = TextInputAction.done,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: _buildInputDecoration(label),
      keyboardType: inputType,
      textInputAction: inputAction,
      obscureText: obscureText,
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
    );
  }

  TextFormField _passwordField(
      {String label = "Password", required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
    );
  }

  void _showResetPasswordConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content:
              Text('Send password reset email to ${_emailController.text}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Back'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Send'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetPassword(_emailController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSuccessDialog('Password reset email has been sent to $email.');
    } on FirebaseAuthException catch (e) {
      _showErrorDialog('An error occurred: ${e.message}');
    }
  }

  TextButton _forgotPasswordButton() {
    return TextButton(
      onPressed: () {
        final email = _emailController.text;
        if (email.isNotEmpty) {
          _showResetPasswordConfirmationDialog(); // Show the confirmation dialog
        } else {
          _showErrorDialog('Please enter your email address.');
        }
      },
      child: const Text(
        "Forgot Password?",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
