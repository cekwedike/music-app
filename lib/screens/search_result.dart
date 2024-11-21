// search_result.dart

import 'package:flutter/material.dart';
import 'package:music/screens/favorite.dart';

class SearchResultScreen extends StatefulWidget {
  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  List<Map<String, dynamic>> _favoriteTracks = [];

  @override
  void initState() {
    super.initState();
    _getFavoriteTracks();
  }

  void _getFavoriteTracks() {
    setState(() {
      _favoriteTracks = FavoriteScreen.of(context)?.favoriteTracks ?? [];
    });
  }

  void _toggleFavorite(Map<String, dynamic> track) {
    setState(() {
      if (_favoriteTracks.any((favTrack) => favTrack['id'] == track['id'])) {
        _favoriteTracks.removeWhere((favTrack) => favTrack['id'] == track['id']);
        FavoriteScreen.of(context)?.removeFromFavorites(track);
      } else {
        _favoriteTracks.add(track);
        FavoriteScreen.of(context)?.addToFavorites(track);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> tracks = ModalRoute.of(context)!.settings.arguments as List<dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: ListView.builder(
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          final String trackName = track['name'];
          final String artistName = track['artists'][0]['name'];
          final String? albumImageUrl = track['album']['images'].isNotEmpty ? track['album']['images'][0]['url'] : null;
          final bool isFavorite = _favoriteTracks.any((favTrack) => favTrack['id'] == track['id']);

          return ListTile(
            leading: albumImageUrl != null
                ? Image.network(
                    albumImageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.music_note),
            title: Text(trackName),
            subtitle: Text(artistName),
            trailing: IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () => _toggleFavorite(track),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/detail',
                arguments: track,
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                Navigator.pushNamed(context, '/favorite');
              },
            ),
          ],
        ),
      ),
    );
  }
}