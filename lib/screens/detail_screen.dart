import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SongDetailScreen extends StatefulWidget {
  final Map<String, dynamic> track;

  SongDetailScreen({required this.track});

  @override
  _SongDetailScreenState createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  Future<void> _playPreview() async {
    String? previewUrl = widget.track['preview_url'];
    
    if (previewUrl == null || previewUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No preview available for this track')),
      );
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(previewUrl));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing preview: $e')),
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String trackName = widget.track['name'];
    final String artistName = widget.track['artists'][0]['name'];
    final String albumName = widget.track['album']['name'];
    final int trackDuration = widget.track['duration_ms'];
    final int trackPopularity = widget.track['popularity'];
    final String? albumImageUrl = widget.track['album']['images'].isNotEmpty 
        ? widget.track['album']['images'][0]['url'] 
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Song Details'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: albumImageUrl != null
                  ? Image.network(
                      albumImageUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.music_note, size: 200),
            ),
            SizedBox(height: 20),
            Text(
              trackName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Artist: $artistName',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Album: $albumName',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black45,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Duration: ${(trackDuration / 60000).floor()}:${((trackDuration % 60000) / 1000).floor().toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black45,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Popularity: $trackPopularity',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black45,
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: widget.track['preview_url'] != null ? _playPreview : null,
                icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                label: Text(_isPlaying ? 'Stop Preview' : 'Play Preview'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
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
                Navigator.pushNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}