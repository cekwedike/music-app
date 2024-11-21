import 'package:flutter/material.dart';

class SearchResultScreen extends StatelessWidget {
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
            trailing: Icon(Icons.play_arrow),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
          ],
        ),
      ),
    );
  }
}