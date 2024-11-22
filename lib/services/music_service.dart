import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/song.dart';
import '../services/app_preferances.dart';
import '../services/audio_handler.dart';

class MusicService {
  // Singleton instance
  static final MusicService instance = MusicService._privateConstructor();

  // Dependencies
  final _appPrefs = AppPreferances.instance;
  final _yt = YoutubeExplode();
  final MyAudioHandler _audioHandler;
  final AudioPlayer audioPlayer;
  RxBool isPlaying = false.obs;

  // Observables
  final _currentSong = Rx<Song?>(null);
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;

  // Private properties
  final List<Video> _suggestedQueue = [];
  File? _audioFile;

  // Getters
  Song? get currentSong => _currentSong.value;

  // Private constructor
  MusicService._privateConstructor()
      : _audioHandler = MyAudioHandler(),
        audioPlayer = AudioPlayer() {
    setupPositionListeners();
  }

  /// Play a song from YouTube URL
  Future<void> playSong(String videoUrl) async {
    try {
      _resetSongData();
      final videoId = VideoId(videoUrl);
      _appPrefs.setLastPlayedSong(videoUrl);

      final video = await _yt.videos.get(videoId);
      final song = _createSongFromVideo(video);
      _currentSong.value = song;

      await _playVideoAudio(videoId, video);
      await _fetchSuggestedSongs(videoId);
    } catch (e) {
      _handlePlaybackError(e);
    }
  }

  void _resetSongData() {
    stop();
    _currentSong.value = null;
    duration.value = Duration.zero;
    position.value = Duration.zero;
  }

  Song _createSongFromVideo(Video video) {
    return Song(
      albumPic: video.thumbnails.highResUrl,
      title: video.title,
      artist: video.author,
      duration: video.duration ?? Duration.zero,
      filePath: '',
    );
  }

  Future<void> _playVideoAudio(VideoId videoId, Video video) async {
    final manifest = await _yt.videos.streamsClient.getManifest(videoId);
    final audioStreamUrl = _selectAudioStream(manifest);

    await _audioHandler.loadAndPlay(
      audioStreamUrl,
      _createMediaItem(videoId, video),
    );
  }

  String _selectAudioStream(StreamManifest manifest) {
    return manifest.audioOnly
        .firstWhere(
          (stream) => stream.codec.mimeType == 'audio/mp4',
          orElse: () => manifest.audioOnly.withHighestBitrate(),
        )
        .url
        .toString();
  }

  MediaItem _createMediaItem(VideoId videoId, Video video) {
    return MediaItem(
      id: videoId.value,
      title: video.title,
      artist: video.author,
      artUri: Uri.parse(video.thumbnails.highResUrl),
      duration: video.duration,
    );
  }

  /// Playback control methods
  Future<void> pause() async => await _audioHandler.pause();
  Future<void> resume() async => await _audioHandler.play();
  Future<void> stop() async => await _audioHandler.stop();

  Future<void> playNext() async {
    if (_suggestedQueue.isNotEmpty) {
      await playSong(_suggestedQueue[0].url);
      _suggestedQueue.removeAt(0);
    }
  }

  /////////////////////////////////////////////////
  /////////////////////////////////////////////////
  // Queue Functionality

  void enqueueSong(Video song) {
    _suggestedQueue.add(song);
  }

  void pushFrontSong(Video song) {
    _suggestedQueue.insert(0, song);
  }

  void updatePosition(Duration position) {
    _audioHandler.updateMediaItemDuration(position);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final Video item = _suggestedQueue.removeAt(oldIndex);
    _suggestedQueue.insert(newIndex, item);
  }

  void removeFromQueue(int index) {
    if (index >= 0 && index < _suggestedQueue.length) {
      _suggestedQueue.removeAt(index);
    }
  }

  /////////////////////////////////////////////////
  /////////////////////////////////////////////////

  /// Fetch suggested songs
  Future<void> _fetchSuggestedSongs(VideoId videoId) async {
    try {
      final video = await _yt.videos.get(videoId);
      final suggestions = await _yt.videos.getRelatedVideos(video);

      _suggestedQueue
        ..clear()
        ..addAll(suggestions!.where((video) {
          if (video.duration == null) return false;
          return video.duration! >= const Duration(minutes: 2) &&
              video.duration! <= const Duration(minutes: 7);
        }).take(3));
    } catch (e) {
      _handleFetchSuggestedSongsError(e);
    }
  }

  /// Search and recommendation methods
  Future<List<Video>> searchSongs(String query) async {
    try {
      final searchResults = await _yt.search.getVideos(query);
      return searchResults
          .where((video) {
            if (video.duration == null) return false;
            return video.duration! >= const Duration(minutes: 2) &&
                video.duration! <= const Duration(minutes: 7);
          })
          .take(10)
          .toList();
    } catch (e) {
      _handleSearchError(e);
      return [];
    }
  }

  List<Video> getSuggestedQueue() => _suggestedQueue;

  Future<List<Video>> fetchRelatedSongs() async {
    try {
      final videoUrl = await _appPrefs.getLastPlayedSong();
      final video = await _yt.videos.get(VideoId(videoUrl));
      final recResults = await _yt.videos.getRelatedVideos(video);

      final filteredResults = recResults!.where((video) {
        if (video.duration == null) return false;
        return video.duration! >= const Duration(minutes: 2) &&
            video.duration! <= const Duration(minutes: 7);
      });

      return filteredResults.take(25).toList();
    } catch (e) {
      _handleRelatedSongsError(e);
      return [];
    }
  }

  /// Position and state listeners
  void setupPositionListeners() {
    _audioHandler.playbackState.listen((state) async {
      if (state.processingState == AudioProcessingState.completed) {
        isPlaying.value = false;
        await playNext();
      }
      position.value = state.position;
      isPlaying.value = state.playing;
      if (_currentSong.value != null) {
        duration.value = _currentSong.value!.duration;
      }
    });
  }

  void _handlePlayerStateChange(PlayerState state) {
    if (!state.playing && state.processingState == ProcessingState.completed) {
      _currentSong.value = null;
    }
  }

  /// Error handling methods
  void _handlePlaybackError(dynamic e) {
    print('Error while playing song: $e');
    // Add more robust error handling as needed
  }

  void _handleFetchSuggestedSongsError(dynamic e) {
    print('Error fetching suggested songs: $e');
  }

  void _handleSearchError(dynamic e) {
    print('Error searching songs: $e');
  }

  void _handleRelatedSongsError(dynamic e) {
    print('Error fetching related songs: $e');
  }

  /// Resource cleanup
  void dispose() {
    audioPlayer.dispose();
    _yt.close();
    _audioFile?.deleteSync();
  }
}
