import 'package:flutter/material.dart';
import 'package:only_plants/pages/collection_page.dart';
import 'package:only_plants/pages/login_page.dart';
import 'package:only_plants/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:only_plants/splash_screen.dart';

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
        // Customize your theme here
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Color.fromARGB(255, 59, 138, 61),

        // accentColor: Colors.orange,
        fontFamily: 'Roboto', // Change to your desired font
        // Add more theme properties as needed
        colorScheme: ColorScheme.light(
          primary: Colors.green, // The primary color for your app
          secondary: const Color.fromARGB(
              255, 15, 73, 17), // The secondary color for your app
          background: Colors.white, // The background color for your app
          // Add more colors as needed
        ),
      ),
      home: CustomSplashScreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Theme.of(context)
            .scaffoldBackgroundColor, // Empty title to hide the default app bar title
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top section with centered title
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Text(
              'Welcome to OnlyPlants',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          // Bottom section with your app content
          Container(
            // Add your content here
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
              child: const Text('Go to Search Page'),
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite), // Plant icon
            label: 'Saved Plants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search), // Search icon
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today), // Calendar icon
            label: 'Calendar',
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
