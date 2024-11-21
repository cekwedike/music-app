import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchResultScreen extends StatefulWidget {
  final List<dynamic> searchResults;

  const SearchResultScreen({Key? key, required this.searchResults}) : super(key: key);

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<dynamic> tracks = [];
  String? accessToken;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the arguments passed from home screen
    final Map<String, dynamic> args = 
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    tracks = args['tracks'] ?? [];
    accessToken = args['accessToken'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: tracks.isEmpty
          ? _buildEmptyState()
          : _buildResultsList(),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                HapticFeedback.lightImpact();
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

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _animation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            final String trackName = track['name'];
            final String artistName = track['artists'][0]['name'];
            final String? albumImageUrl = track['album']['images'].isNotEmpty 
                ? track['album']['images'][0]['url'] 
                : null;
            final String previewUrl = track['preview_url'] ?? '';

            // Calculate staggered animation delay
            final itemAnimation = Tween<Offset>(
              begin: Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  (index / tracks.length) * 0.5,
                  ((index + 1) / tracks.length) * 0.5 + 0.5,
                  curve: Curves.easeOut,
                ),
              ),
            );

            return SlideTransition(
              position: itemAnimation,
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: {
                        'track': track,
                        'accessToken': accessToken,
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Album Art
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: albumImageUrl != null
                                ? Image.network(
                                    albumImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Theme.of(context).colorScheme.secondary,
                                        child: Icon(
                                          Icons.music_note,
                                          color: Theme.of(context).colorScheme.surface,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Theme.of(context).colorScheme.secondary,
                                    child: Icon(
                                      Icons.music_note,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Track Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trackName,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                artistName,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.album,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      track['album']['name'],
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Preview Indicator and Play Button
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              previewUrl.isNotEmpty ? Icons.headphones : Icons.headset_off,
                              color: previewUrl.isNotEmpty 
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                              size: 16,
                            ),
                            SizedBox(height: 4),
                            Icon(
                              Icons.play_circle_filled,
                              color: Theme.of(context).colorScheme.primary,
                              size: 32,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}