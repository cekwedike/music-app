import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/search_result.dart';
import 'screens/detail_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(MusicSearchApp());
}

class MusicSearchApp extends StatelessWidget {
  // Define our custom colors
  static const primaryDark = Color(0xFF1E1E1E);  // Dark background
  static const secondaryDark = Color(0xFF2A2A2A); // Slightly lighter dark for cards
  static const accentPurple = Color(0xFF9C27B0);  // Vibrant purple for primary actions
  static const accentTeal = Color(0xFF1DE9B6);    // Teal for secondary actions
  static const textLight = Color(0xFFF5F5F5);     // Light text
  static const textGrey = Color(0xFFB3B3B3);      // Grey text for subtitles

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Search App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: primaryDark,
        primaryColor: accentPurple,
        colorScheme: ColorScheme.dark(
          primary: accentPurple,
          secondary: accentTeal,
          background: primaryDark,
          surface: secondaryDark,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: secondaryDark,
          elevation: 0,
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          color: secondaryDark,
        ),
        cardTheme: CardTheme(
          color: secondaryDark,
          elevation: 4,
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: textLight, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: textLight),
          bodyLarge: TextStyle(color: textLight),
          bodyMedium: TextStyle(color: textGrey),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: secondaryDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: textGrey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentPurple,
            foregroundColor: textLight,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: accentTeal,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/searchResult': (context) => SearchResultScreen(searchResults: []),
        '/detail': (context) => SongDetailScreen(),
      },
    );
  }
}