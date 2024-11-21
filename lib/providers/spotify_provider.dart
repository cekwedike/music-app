import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/spotify_models.dart';

class SpotifyProvider with ChangeNotifier {
  String? _accessToken;
  bool _isLoading = false;
  String? _error;
  List<dynamic> _searchResults = [];
  ArtistInfo? _currentArtist;
  List<TrackInfo> _topTracks = [];

  // Getters
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get searchResults => _searchResults;
  ArtistInfo? get currentArtist => _currentArtist;
  List<TrackInfo> get topTracks => _topTracks;

  // Constructor with initialization
  SpotifyProvider() {
    _getAccessToken();
  }

  Future<void> _getAccessToken() async {
    const String clientId = 'edf71530ea9242e7ad70adaedbded238';
    const String clientSecret = '737fe2303ac84d83af8acfcdc71093ff';

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        },
        body: {'grant_type': 'client_credentials'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
      } else {
        _error = 'Failed to get access token';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchTracks(String query) async {
    if (_accessToken == null) {
      await _getAccessToken();
      if (_accessToken == null) return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/search?q=$query&type=track'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _searchResults = data['tracks']['items'];
      } else if (response.statusCode == 401) {
        // Token expired, get new token and retry
        await _getAccessToken();
        return searchTracks(query);
      } else {
        _error = 'Failed to search tracks';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchArtistDetails(String artistId) async {
    if (_accessToken == null) {
      await _getAccessToken();
      if (_accessToken == null) return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Fetch artist info
      final artistResponse = await http.get(
        Uri.parse('https://api.spotify.com/v1/artists/$artistId'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (artistResponse.statusCode == 200) {
        final artistData = jsonDecode(artistResponse.body);
        _currentArtist = ArtistInfo.fromJson(artistData);

        // Fetch top tracks
        final topTracksResponse = await http.get(
          Uri.parse('https://api.spotify.com/v1/artists/$artistId/top-tracks?market=US'),
          headers: {'Authorization': 'Bearer $_accessToken'},
        );

        if (topTracksResponse.statusCode == 200) {
          final topTracksData = jsonDecode(topTracksResponse.body);
          _topTracks = (topTracksData['tracks'] as List)
              .map((track) => TrackInfo.fromJson(track))
              .toList();
        }
      } else if (artistResponse.statusCode == 401) {
        await _getAccessToken();
        return fetchArtistDetails(artistId);
      } else {
        _error = 'Failed to fetch artist details';
      }
    } catch (e) {
      _error = 'Network error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}