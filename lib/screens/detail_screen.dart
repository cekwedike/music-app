import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/track_player_widget.dart';
import '../widgets/artist_section_widget.dart';
import '../models/spotify_models.dart';

class SongDetailScreen extends StatefulWidget {
  @override
  _SongDetailScreenState createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends State<SongDetailScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  bool _hasError = false;
  ArtistInfo? _artistInfo;
  List<TrackInfo> _topTracks = [];
  // ignore: unused_field
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    Future.delayed(Duration.zero, () {
      _fetchArtistData();
    });

    _animationController.forward();
  }

  Future<void> _fetchArtistData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final Map<String, dynamic> args = 
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final track = args['track'];
      final String accessToken = args['accessToken'];
      final String artistId = track['artists'][0]['id'];

      // Fetch artist info
      final artistResponse = await http.get(
        Uri.parse('https://api.spotify.com/v1/artists/$artistId'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (artistResponse.statusCode != 200) throw Exception('Failed to load artist');

      final artistData = jsonDecode(artistResponse.body);
      _artistInfo = ArtistInfo.fromJson(artistData);

      // Fetch top tracks
      final topTracksResponse = await http.get(
        Uri.parse('https://api.spotify.com/v1/artists/$artistId/top-tracks?market=US'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (topTracksResponse.statusCode == 200) {
        final topTracksData = jsonDecode(topTracksResponse.body);
        _topTracks = (topTracksData['tracks'] as List)
            .map((track) => TrackInfo.fromJson(track))
            .toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching artist data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = 
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final track = args['track'];
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(track),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTrackSection(track),
                  _buildPlayerSection(track),
                  _buildArtistSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Map<String, dynamic> track) {
    final String? albumImageUrl = track['album']['images'].isNotEmpty 
        ? track['album']['images'][0]['url'] 
        : null;

    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          track['name'],
          style: TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (albumImageUrl != null)
              Image.network(
                albumImageUrl,
                fit: BoxFit.cover,
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackSection(Map<String, dynamic> track) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            track['artists'][0]['name'],
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            'Album: ${track['album']['name']}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.music_note,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                _formatDuration(track['duration_ms']),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(width: 24),
              Icon(
                Icons.bar_chart,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Popularity: ${track['popularity']}/100',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSection(Map<String, dynamic> track) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            TrackPlayerWidget(
              previewUrl: track['preview_url'],
              onPlayingStateChanged: (isPlaying) {
                setState(() => _isPlaying = isPlaying);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistSection() {
    if (_artistInfo == null) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _hasError
                ? Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load artist information',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _fetchArtistData,
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
      );
    }

    return ArtistSectionWidget(
      artistInfo: _artistInfo!,
      topTracks: _topTracks,
      onRetryPressed: _fetchArtistData,
      isLoading: _isLoading,
      hasError: _hasError,
    );
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}