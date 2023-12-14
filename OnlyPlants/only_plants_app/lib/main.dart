import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:only_plants/pages/collection_page.dart';
import 'package:only_plants/pages/login_page.dart';
import 'package:only_plants/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:only_plants/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(MyApp());
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    // Return either the home page or the login page based on the authentication status
    if (user != null) {
      // User is authenticated, show the home page
      return MyHomePage();
    } else {
      // User is not authenticated, show the login page
      return LoginPage();
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // primarySwatch: Colors.green,
        scaffoldBackgroundColor: Color.fromARGB(255, 59, 138, 61),
        fontFamily: 'Roboto', // Change to your desired font
          colorScheme: const ColorScheme.light(
          primary: Color.fromARGB(255, 44, 73, 10), // The primary color for your app
          secondary: Color.fromARGB(
              255, 15, 73, 17), // The secondary color for your app
          background: Colors.white, // The background color for your app
        ),
      ),
      home: AuthenticationWrapper(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    // Specify the image asset path or URL
    String imageUrl =
        'assets/plantman.avif'; // Replace with your actual image path

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize:
            MainAxisSize.min, // Minimize the vertical space used by the column
        children: [
          // Title section
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Text(
              'Welcome to OnlyPlants',
              style: GoogleFonts.getFont(
                'Lobster',
                textStyle: Theme.of(context).textTheme.headline5,
                fontSize: 40.0,
              ),
            ),
          ),
          // Image section without Expanded
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),

          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 231, 252, 214),
              borderRadius: BorderRadius.circular(
                  15.0), // Increased the radius for more rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                      0.4), // Increased opacity for a darker shadow
                  spreadRadius:
                      2.5, // Increased spread radius for a wider shadow
                  blurRadius:
                      2, // Increased blur radius for a more blurred shadow
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Text(
              'This app aims to make finding care information about your plants easy. Search an extensive collection of plants and save them to your personal collection for quick and easy access.',
              style: TextStyle(fontSize: 19.0), // Increased font size
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 231, 252, 214),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite, // Plant icon
              color: Colors.black, // Set the color to white
            ),
             label: 'Plant Collection',
 
          ),
          BottomNavigationBarItem(
  icon: Icon(
    Icons.search,
    color: Colors.black, // Set the icon color to black
  ),
  label: 'Search',
  // Set the text style for the label
  
    // Use the primary text color from the current theme
),
      
        ],
        onTap: (index) {
          // Handle navigation to different pages based on the index
          if (index == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PlantCollectionPage(userId: user!.uid)));
            // Navigate to the page that holds the list of saved plants
            // Add your navigation logic here
          } else if (index == 1) {
            // Navigate to the plant search page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPage()),
            );
          } else if (index == 2) {
            // Navigate to the interactive calendar page
            // Add your navigation logic here
          }
        },
      ),
    );
  }
}
