import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/search_result.dart';
import 'screens/detail_screen.dart';
import 'screens/splash_screen.dart';
import 'providers/spotify_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SpotifyProvider(),
      child: MusicSearchApp(),
    ),
  );
}

class MusicSearchApp extends StatelessWidget {
  // Define our custom colors
  static const primaryDark = Color(0xFF1E1E1E);
  static const secondaryDark = Color(0xFF2A2A2A);
  static const accentPurple = Color(0xFF9C27B0);
  static const accentTeal = Color(0xFF1DE9B6);
  static const textLight = Color(0xFFF5F5F5);
  static const textGrey = Color(0xFFB3B3B3);

  const MusicSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Search App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: primaryDark,
        primaryColor: accentPurple,
        colorScheme: const ColorScheme.dark(
          primary: accentPurple,
          secondary: accentTeal,
          surface: secondaryDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: secondaryDark,
          elevation: 0,
        ),
        bottomAppBarTheme: const BottomAppBarTheme(
          color: secondaryDark,
        ),
        cardTheme: const CardTheme(
          color: secondaryDark,
          elevation: 4,
        ),
        textTheme: const TextTheme(
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
          hintStyle: const TextStyle(color: textGrey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentPurple,
            foregroundColor: textLight,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: accentTeal,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/searchResult': (context) => const SearchResultScreen(searchResults: []),
        '/detail': (context) => SongDetailScreen(),
      },
    );
  }
}