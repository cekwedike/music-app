// main.dart

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/search_result.dart';
import 'screens/detail_screen.dart';
import 'screens/favorite.dart';

void main() {
  runApp(MusicSearchApp());
}

class MusicSearchApp extends StatefulWidget {
  @override
  _MusicSearchAppState createState() => _MusicSearchAppState();
}

class _MusicSearchAppState extends State<MusicSearchApp> {
  List<Map<String, dynamic>> _favoriteTracks = [];

  void addToFavorites(Map<String, dynamic> track) {
    setState(() {
      _favoriteTracks.add(track);
    });
  }

  void removeFromFavorites(Map<String, dynamic> track) {
    setState(() {
      _favoriteTracks.removeWhere((favTrack) => favTrack['id'] == track['id']);
    });
  }

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
        '/searchResult': (context) => SearchResultScreen(),
        '/detail': (context) => SongDetailScreen(),
        '/favorite': (context) => FavoriteScreen(
              favoriteTracks: _favoriteTracks,
              addToFavorites: addToFavorites,
              removeFromFavorites: removeFromFavorites,
            ),
      },
    );
  }
}