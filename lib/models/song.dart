import 'dart:convert';

class Song {
  final String title;
  final String artist;
  final Duration duration;
  final String filePath;
  final String albumPic;

  Song({
    required this.title,
    required this.artist,
    required this.duration,
    required this.filePath,
    required this.albumPic,
  });

  set value(Null value) {}

  /// Converts a `Song` instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'albumPic': albumPic,
      'artist': artist,
      'duration': duration.inMilliseconds, // Serialize Duration as milliseconds
      'filePath': filePath,
    };
  }

  /// Creates a `Song` instance from a JSON map.
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
        title: json['title'],
        artist: json['artist'],
        duration: Duration(
            milliseconds: json['duration']), // Deserialize from milliseconds
        filePath: json['filePath'],
        albumPic: json['albumPic']);
  }
}
