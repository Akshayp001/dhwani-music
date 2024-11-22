import 'package:get/get.dart';
import 'package:muzikk/services/music_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/song.dart';

class MusicController extends GetxController {
  final MusicService musicService =
      MusicService.instance; // Use the singleton instance
  var isPlaying = false.obs;
  var currentSong = Rxn<Song>(); // Observable for the current song
  var suggestedQueue = <Video>[].obs;
  var searchResults = <Video>[].obs;

  /// Play a song using a YouTube URL
  Future<void> playSong(String videoUrl) async {
    await musicService.playSong(videoUrl);
  }

  /// Pause the currently playing song
  Future<void> pause() async {
    await musicService.pause();
    isPlaying.value = false;
  }

  /// Resume the currently paused song
  Future<void> resume() async {
    await musicService.resume();
    isPlaying.value = true;
  }

  /// Stop the current playback
  Future<void> stop() async {
    await musicService.stop();
    isPlaying.value = false;
    currentSong.value = null; // Clear the current song
  }

  /// Search for songs by keywords
  Future<void> searchSongs(String query) async {
    searchResults.clear();
    searchResults.value = await musicService.searchSongs(query);
  }


  getRelatedSongs() async {
    searchResults.value = await musicService.fetchRelatedSongs();
  }

  @override
  void onInit() {
    getRelatedSongs();
    super.onInit();
  }

  @override
  void onClose() {
    musicService.dispose();
    super.onClose();
  }
}
