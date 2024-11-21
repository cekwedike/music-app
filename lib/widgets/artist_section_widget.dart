import 'package:flutter/material.dart';
import '../models/spotify_models.dart';

class ArtistSectionWidget extends StatelessWidget {
  final ArtistInfo artistInfo;
  final List<TrackInfo> topTracks;
  final VoidCallback onRetryPressed;
  final bool isLoading;
  final bool hasError;

  const ArtistSectionWidget({
    Key? key,
    required this.artistInfo,
    required this.topTracks,
    required this.onRetryPressed,
    this.isLoading = false,
    this.hasError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              onPressed: onRetryPressed,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Artist Image and Info
        if (artistInfo.imageUrl != null)
          Container(
            height: 200,
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(artistInfo.imageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),

        // Artist Details
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About the Artist',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              _buildInfoRow(
                context,
                'Genres',
                artistInfo.genres.isEmpty
                    ? 'Not available'
                    : artistInfo.genres.join(', '),
              ),
              _buildInfoRow(
                context,
                'Followers',
                _formatNumber(artistInfo.followers),
              ),
              _buildInfoRow(
                context,
                'Popularity',
                '${artistInfo.popularity}/100',
              ),
            ],
          ),
        ),

        // Top Tracks
        if (topTracks.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Top Tracks',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topTracks.length,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final track = topTracks[index];
                return Container(
                  width: 160,
                  margin: EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (track.albumImageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            track.albumImageUrl!,
                            height: 120,
                            width: 160,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 8),
                      Text(
                        track.name,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        track.albumName,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}