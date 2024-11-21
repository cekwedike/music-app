import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class SongDetailScreen extends StatefulWidget {
  @override
  _SongDetailScreenState createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  String _lyrics = '';
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _fetchLyrics();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _fetchLyrics() async {
    final Map<String, dynamic> track = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String trackId = track['id'];

    final response = await http.get(Uri.parse('https://api.spotify.com/v1/tracks/$trackId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String lyrics = data['lyrics'] ?? 'No lyrics available.';
      setState(() {
        _lyrics = lyrics;
      });
    } else {
      print('Failed to fetch lyrics. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> _playPreview() async {
    final Map<String, dynamic> track = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String? previewUrl = track['preview_url'];

    if (previewUrl != null) {
      if (_isPlaying) {
        await _audioPlayer.stop();
      } else {
        await _audioPlayer.play(UrlSource(previewUrl));
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> track = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String trackName = track['name'];
    final String artistName = track['artists'][0]['name'];
    final String albumName = track['album']['name'];
    final int trackDuration = track['duration_ms'];
    final int trackPopularity = track['popularity'];
    final String? albumImageUrl = track['album']['images'].isNotEmpty ? track['album']['images'][0]['url'] : null;
    final String? previewUrl = track['preview_url'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Song Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            albumImageUrl != null
                ? Image.network(
                    albumImageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.music_note, size: 200),
            SizedBox(height: 16.0),
            Text(
              trackName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Artist: $artistName',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8.0),
            Text(
              'Album: $albumName',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8.0),
            Text(
              'Duration: ${_formatDuration(trackDuration)}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8.0),
            Text(
              'Popularity: $trackPopularity',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: previewUrl != null ? _playPreview : null,
              child: Text(_isPlaying ? 'Stop Preview' : 'Play Preview'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Lyrics:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(_lyrics),
          ],
        ),
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

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}