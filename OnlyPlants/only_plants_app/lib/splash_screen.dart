import 'package:flutter/material.dart';

class CustomSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Customize background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(
              size: 100, // Customize logo size
            ),
            SizedBox(height: 20),
            Text(
              'My Awesome App',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white, // Customize text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
