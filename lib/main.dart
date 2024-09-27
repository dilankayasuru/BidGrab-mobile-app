import 'package:bidgrab/models/UserProvider.dart';
import 'package:bidgrab/models/theme.dart';
import 'package:bidgrab/screens/mainLayout.dart';
import 'package:bidgrab/screens/products/productView.dart';
import 'package:bidgrab/screens/profile/profile.dart';
import 'package:bidgrab/screens/signin/SignIn.dart';
import 'package:bidgrab/screens/signup/SignUp.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isSystemDarkMode =
      WidgetsBinding.instance.window.platformBrightness == Brightness.dark;

  runApp(
    // MultiProvider allows multiple providers
    // to be created and accessed down the widget tree.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(
            darkModeEnabled:
                isSystemDarkMode, // Initialize with system dark mode setting.
          ),
        ),
        // ChangeNotifierProvider for Userprovider to manage user login state.
        ChangeNotifierProvider(
          create: (context) => Userprovider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Consumer widget to listen to changes in ThemeProvider.
    return Consumer<ThemeProvider>(
      builder: (context, value, child) => MaterialApp(
        // Disable the debug banner in the top right corner.
        debugShowCheckedModeBanner: false,
        // Title of the application.
        title: "BidGarb",
        // Initial route of the application.
        initialRoute: '/',
        // Define the routes for the application.
        routes: {
          '/': (context) => const MainLayOut(), // Main layout route (Home page).
          Signup.id: (context) => const Signup(), // Signup screen route.
          Signin.id: (context) => const Signin(), // Signin screen route.
          Productview.id: (context) => const Productview(), // Product view screen route.
          Profile.id: (context) => const Profile(), // Profile screen route.
        },
        // Set the theme mode based on the current theme.
        themeMode: value.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
        // Define the light theme.
        theme: ThemeData(
          fontFamily: "Inter", // Set the default font family.
          useMaterial3: true, // Use Material 3 design.
          colorSchemeSeed: Colors.blue, // Seed color for the color scheme.
        ),
        // Define the dark theme.
        darkTheme: ThemeData(
          useMaterial3: true, // Use Material 3 design.
          brightness: Brightness.dark, // Set the brightness to dark.
          colorSchemeSeed: Colors.blue, // Seed color for the color scheme.
        ),
      ),
    );
  }
}
