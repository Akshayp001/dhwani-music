import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:muzikk/widgets/scrolling_text.dart';
import '../controller/now_playing_controller.dart';

import '../widgets/songs_queue_widget.dart';

class NowPlayingScreen extends StatelessWidget {
  final NowPlayingController _controller = Get.put(NowPlayingController());

  NowPlayingScreen({super.key});

  void _showQueueBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        builder: (context, scrollController) => QueueBottomSheet(
          queue: _controller.musicService.getSuggestedQueue(),
          onReorder: (oldIndex, newIndex) {
            _controller.musicService.reorderQueue(oldIndex, newIndex);
          },
          onRemove: (index) {
            _controller.musicService.removeFromQueue(index);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 66, 2, 25),
              Color.fromARGB(255, 47, 2, 49)
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display Song Thumbnail
              Obx(
                () => SizedBox(
                  width: Get.height * 0.35,
                  height: Get.height * 0.35,
                  child: _controller.musicService.currentSong != null
                      ? Image.network(
                          _controller.musicService.currentSong!.albumPic,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.asset('assets/images/logo.png'),
                ),
              ),
              const SizedBox(height: 20),

              // Song Info Row with Like Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        // Display Song Title
                        Obx(
                          () => ScrollingText(
                            text: _controller.musicService.currentSong?.title ??
                                "Title",
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Display Song Artist
                        Obx(
                          () => Text(
                            _controller.musicService.currentSong?.artist ??
                                "Artist",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white60,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  LikeButton(
                    size: 30,
                    circleColor: const CircleColor(
                      start: Color(0xff00ddff),
                      end: Color(0xff0099cc),
                    ),
                    bubblesColor: const BubblesColor(
                      dotPrimaryColor: Color(0xff33b5e5),
                      dotSecondaryColor: Color(0xff0099cc),
                    ),
                    likeBuilder: (bool isLiked) {
                      return Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white70,
                        size: 30,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Timeline Slider
              Obx(
                () => _controller.musicService.duration.value.inSeconds <=
                        _controller.musicService.position.value.inSeconds
                    ? const CircularProgressIndicator(
                        color: Colors.white60,
                      )
                    : Slider(
                        min: 0,
                        max: _controller.musicService.duration.value.inSeconds
                            .toDouble(),
                        value: _controller.musicService.position.value.inSeconds
                            .toDouble(),
                        onChanged: (value) {
                          final newPosition = Duration(seconds: value.toInt());
                          _controller.updatePosition(newPosition);
                        },
                      ),
              ),

              // Display Current Time and Total Duration
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatDuration(_controller.musicService.position.value),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      formatDuration(_controller.musicService.duration.value),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Control Buttons Row
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      shape: const CircleBorder(),
                      color: Colors.white38,
                      elevation: 17,
                      child: IconButton(
                        icon: const Icon(Icons.skip_previous, size: 30),
                        onPressed: _controller.pauseOrResume,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Material(
                      shape: const CircleBorder(),
                      color: Colors.white54,
                      elevation: 20,
                      child: IconButton(
                        icon: Icon(
                          _controller.musicService.isPlaying.value
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 60,
                        ),
                        onPressed: _controller.pauseOrResume,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Material(
                      shape: const CircleBorder(),
                      color: Colors.white38,
                      elevation: 17,
                      child: IconButton(
                        icon: const Icon(Icons.skip_next, size: 30),
                        onPressed: () => _controller.musicService.playNext(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Queue Button
              Material(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white24,
                child: InkWell(
                  onTap: () => _showQueueBottomSheet(context),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.queue_music,
                          color: Colors.white70,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Queue',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
