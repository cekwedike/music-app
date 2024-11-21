import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/search_result.dart';
import 'screens/detail_screen.dart';

void main() {
  runApp(MusicSearchApp());
}

class MusicSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Search App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/searchResult': (context) => SearchResultScreen(searchResults: []),
        '/detail': (context) => SongDetailScreen(track: {}),
      },
    );
  }
}