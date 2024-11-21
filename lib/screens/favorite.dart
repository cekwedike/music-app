// favorite.dart

import 'package:flutter/material.dart';

class FavoriteScreen extends StatefulWidget {
  final List<Map<String, dynamic>> favoriteTracks;
  final Function(Map<String, dynamic>) addToFavorites;
  final Function(Map<String, dynamic>) removeFromFavorites;

  const FavoriteScreen({
    Key? key,
    required this.favoriteTracks,
    required this.addToFavorites,
    required this.removeFromFavorites,
  }) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();

  static of(BuildContext context) {}
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: widget.favoriteTracks.isEmpty
          ? Center(
              child: Text('No favorite tracks yet.'),
            )
          : ListView.builder(
              itemCount: widget.favoriteTracks.length,
              itemBuilder: (context, index) {
                final track = widget.favoriteTracks[index];
                final String trackName = track['name'];
                final String artistName = track['artists'][0]['name'];
                final String? albumImageUrl = track['album']['images'].isNotEmpty ? track['album']['images'][0]['url'] : null;

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
                    icon: Icon(Icons.favorite),
                    onPressed: () => widget.removeFromFavorites(track),
                  ),
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
                // Do nothing, already on the favorites screen
              },
            ),
          ],
        ),
      ),
    );
  }
}