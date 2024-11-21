import 'package:flutter/material.dart';

class SearchResultScreen extends StatelessWidget {
  final List<dynamic> searchResults;

  SearchResultScreen({required this.searchResults});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final track = searchResults[index];
          return ListTile(
            leading: track['album']['images'].isNotEmpty
                ? Image.network(
                    track['album']['images'][0]['url'],
                    width: 50,
                    height: 50,
                  )
                : Icon(Icons.music_note, size: 50),
            title: Text(track['name']),
            subtitle: Text(track['artists'][0]['name']),
            trailing: Icon(Icons.play_arrow, color: Colors.orangeAccent),
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
                Navigator.pushNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}