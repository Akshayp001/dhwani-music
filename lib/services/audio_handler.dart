import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _queue = <MediaItem>[].obs;
  MediaItem _mediaItem = MediaItem(
    id: '',
    title: 'Unknown',
    artist: 'Unknown',
    artUri: Uri.parse('https://via.placeholder.com/150'),
  );

  MyAudioHandler() {
    _setupPlayerListeners();
  }

  void _setupPlayerListeners() {
    // Listen to player state changes
    _player.playerStateStream.listen((playerState) {
      _broadcastState(playerState);
    });

    // Listen to position updates
    _player.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: position,
      ));
    });

    // Listen to buffered position
    _player.bufferedPositionStream.listen((bufferedPosition) {
      playbackState.add(playbackState.value.copyWith(
        bufferedPosition: bufferedPosition,
      ));
    });

    // Listen to duration changes
    _player.durationStream.listen((duration) {
      if (duration != null && mediaItem.value != null) {
        mediaItem.add(mediaItem.value!.copyWith(duration: duration));
      }
    });

    // Listen to sequence state
    _player.sequenceStateStream.listen((sequenceState) {
      if (sequenceState?.currentSource != null) {
        final index = sequenceState!.currentIndex;
        if (index < _queue.length) {
          mediaItem.add(_queue[index]);
        }
      }
    });
  }

  void _broadcastState(PlayerState playerState) {
    final isBuffering =
        playerState.processingState == ProcessingState.buffering;
    final isLoading = playerState.processingState == ProcessingState.loading;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        playerState.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: isBuffering || isLoading
          ? AudioProcessingState.loading
          : playerState.processingState == ProcessingState.completed
              ? AudioProcessingState.completed
              : AudioProcessingState.ready,
      playing: playerState.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
    ));
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> seekBackward(bool begin) async {
    const skipInterval = Duration(seconds: 10);
    var newPosition = _player.position - skipInterval;
    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    }
    await _player.seek(newPosition);
  }

  @override
  Future<void> seekForward(bool begin) async {
    const skipInterval = Duration(seconds: 10);
    var newPosition = _player.position + skipInterval;
    if (newPosition > (_player.duration ?? Duration.zero)) {
      newPosition = _player.duration ?? Duration.zero;
    }
    await _player.seek(newPosition);
  }

  // Load a URL and play
  Future<void> loadAndPlay(String url, MediaItem item) async {
    try {
      _mediaItem = item.copyWith(id: url);
      mediaItem.add(_mediaItem);

      await _player.setUrl(url);
      await _player.load(); // Ensure audio is loaded
      await play();
    } catch (e) {
      print('Error in loadAndPlay: $e');
    }
  }

  // Get current position
  Future<Duration> getPosition() async {
    return _player.position;
  }

  // Get current duration
  Future<Duration?> getDuration() async {
    return _player.duration;
  }

  // Update media item duration
  void updateMediaItemDuration(Duration duration) {
    if (mediaItem.value != null) {
      _player.seek(duration);
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> addQueueItem(MediaItem item) async {
    _queue.add(item);
    if (_queue.length == 1) {
      await _playQueueItem(item);
    }
  }

  @override
  Future<void> addQueueItems(List<MediaItem> items) async {
    _queue.addAll(items);
    if (_player.currentIndex == null) {
      await _playQueueItem(_queue.first);
    }
  }

  Future<void> _playQueueItem(MediaItem item) async {
    try {
      await _player.setUrl(item.id);
      mediaItem.add(item);
      await play();
    } catch (e) {
      print('Error in _playQueueItem: $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    final currentIndex = _player.currentIndex ?? 0;
    if (currentIndex + 1 < _queue.length) {
      await _playQueueItem(_queue[currentIndex + 1]);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    final currentIndex = _player.currentIndex ?? 0;
    if (currentIndex > 0) {
      await _playQueueItem(_queue[currentIndex - 1]);
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
