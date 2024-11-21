import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TrackPlayerWidget extends StatefulWidget {
  final String? previewUrl;
  final Function(bool) onPlayingStateChanged;

  const TrackPlayerWidget({
    Key? key,
    required this.previewUrl,
    required this.onPlayingStateChanged,
  }) : super(key: key);

  @override
  _TrackPlayerWidgetState createState() => _TrackPlayerWidgetState();
}

class _TrackPlayerWidgetState extends State<TrackPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() => _duration = duration);
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() => _position = position);
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
        widget.onPlayingStateChanged(_isPlaying);
      });
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlaying = false;
        _position = Duration.zero;
        widget.onPlayingStateChanged(false);
      });
    });
  }

  Future<void> _playPause() async {
    if (widget.previewUrl == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(widget.previewUrl!));
        await _audioPlayer.setVolume(_volume);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing preview: $e')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.previewUrl == null) {
      return Center(
        child: Text(
          'No preview available',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: [
        // Progress bar
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.0,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.0),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
          ),
          child: Slider(
            value: _position.inSeconds.toDouble(),
            max: _duration.inSeconds.toDouble(),
            onChanged: (value) {
              _audioPlayer.seek(Duration(seconds: value.toInt()));
            },
            activeColor: Theme.of(context).colorScheme.primary,
            inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),

        // Duration labels
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                _formatDuration(_duration),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        SizedBox(height: 8),

        // Volume control
        Row(
          children: [
            IconButton(
              icon: Icon(
                _volume == 0 ? Icons.volume_off : Icons.volume_down,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _volume = _volume == 0 ? 1.0 : 0.0;
                  _audioPlayer.setVolume(_volume);
                });
              },
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3.0,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5.0),
                  overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
                ),
                child: Slider(
                  value: _volume,
                  min: 0,
                  max: 1,
                  onChanged: (value) {
                    setState(() => _volume = value);
                    _audioPlayer.setVolume(value);
                  },
                  activeColor: Theme.of(context).colorScheme.secondary,
                  inactiveColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.volume_up,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _volume = 1.0;
                  _audioPlayer.setVolume(_volume);
                });
              },
            ),
          ],
        ),

        // Play/Pause button
        ElevatedButton.icon(
          onPressed: _playPause,
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          label: Text(_isPlaying ? 'Pause' : 'Play Preview'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}