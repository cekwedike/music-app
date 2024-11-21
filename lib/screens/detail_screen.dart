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
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _fetchLyrics();
  }

  void _setupAudioPlayer() {
    // Listen to audio duration changes
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() => _duration = duration);
    });

    // Listen to audio position changes
    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() => _position = position);
    });

    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });

    // Listen to player completion
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
      try {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.play(UrlSource(previewUrl));
          await _audioPlayer.setVolume(_volume);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing preview: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No preview available for this track')),
      );
    }
  }

  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> _setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
    setState(() => _volume = volume);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
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
            // Album art and basic info
            Center(
              child: Hero(
                tag: 'album-art-${track['id']}',
                child: albumImageUrl != null
                    ? Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            albumImageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Icon(Icons.music_note, size: 250),
              ),
            ),
            SizedBox(height: 24),
            
            // Track title and artist
            Center(
              child: Column(
                children: [
                  Text(
                    trackName,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    artistName,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    albumName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Audio Player Controls
            if (previewUrl != null) ...[
              // Progress bar
              Column(
                children: [
                  Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      _seekTo(Duration(seconds: value.toInt()));
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(_position)),
                        Text(_formatDuration(_duration)),
                      ],
                    ),
                  ),
                ],
              ),

              // Play button and volume control
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volume_down),
                  Expanded(
                    child: Slider(
                      value: _volume,
                      min: 0,
                      max: 1,
                      onChanged: _setVolume,
                      activeColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  Icon(Icons.volume_up),
                ],
              ),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _playPreview,
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(_isPlaying ? 'Pause' : 'Play Preview'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            ],
            SizedBox(height: 24),

            // Track Information
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Track Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Divider(),
                    _buildInfoRow('Duration', _formatDuration(Duration(milliseconds: trackDuration))),
                    _buildInfoRow('Popularity', '$trackPopularity/100'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Lyrics Section
            if (_lyrics.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lyrics',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Divider(),
                      Text(
                        _lyrics,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}