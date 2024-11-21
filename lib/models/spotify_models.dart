// ignore: unused_import
import 'package:flutter/material.dart';

class ArtistInfo {
  final String id;
  final String name;
  final List<String> genres;
  final int followers;
  final int popularity;
  final String? imageUrl;
  final List<String> relatedArtists;
  final List<TrackInfo> topTracks;

  ArtistInfo({
    required this.id,
    required this.name,
    required this.genres,
    required this.followers,
    required this.popularity,
    this.imageUrl,
    this.relatedArtists = const [],
    this.topTracks = const [],
  });

  factory ArtistInfo.fromJson(Map<String, dynamic> json) {
    return ArtistInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      followers: json['followers']?['total'] ?? 0,
      popularity: json['popularity'] ?? 0,
      imageUrl: json['images'] != null && json['images'].isNotEmpty 
          ? json['images'][0]['url'] 
          : null,
    );
  }
}

class TrackInfo {
  final String id;
  final String name;
  final String artistName;
  final String albumName;
  final String? albumImageUrl;
  final String? previewUrl;
  final int durationMs;
  final int popularity;

  TrackInfo({
    required this.id,
    required this.name,
    required this.artistName,
    required this.albumName,
    this.albumImageUrl,
    this.previewUrl,
    required this.durationMs,
    required this.popularity,
  });

  factory TrackInfo.fromJson(Map<String, dynamic> json) {
    return TrackInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      artistName: json['artists']?[0]?['name'] ?? '',
      albumName: json['album']?['name'] ?? '',
      albumImageUrl: json['album']?['images']?[0]?['url'],
      previewUrl: json['preview_url'],
      durationMs: json['duration_ms'] ?? 0,
      popularity: json['popularity'] ?? 0,
    );
  }
}