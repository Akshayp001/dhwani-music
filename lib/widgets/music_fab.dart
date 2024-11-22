import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:muzikk/pages/now_playing_screen.dart';
import 'dart:math' as math;

import '../services/music_service.dart';

class MusicFAB extends StatefulWidget {
  final MusicService musicService;
  final double size;

  const MusicFAB({
    super.key,
    required this.musicService,
    this.size = 80.0, // Increased default size
  });

  @override
  State<MusicFAB> createState() => _MusicFABState();
}

class _MusicFABState extends State<MusicFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    widget.musicService.isPlaying.listen((playing) {
      if (playing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSong = widget.musicService.currentSong;
      final isPlaying = widget.musicService.isPlaying.value;
      final position = widget.musicService.position.value;
      final duration = widget.musicService.duration.value;

      return InkWell(
        onLongPress: () {
          Get.to(NowPlayingScreen());
        },
        child: SizedBox(
          width: widget.size + 40, // Extra space for the progress ring
          height: widget.size + 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size + 40, widget.size + 40),
                painter: CircularProgressPainter(
                  progress: duration.inSeconds > 0
                      ? position.inSeconds / duration.inSeconds
                      : 0.0,
                  strokeWidth: 8.0,
                ),
              ),
              // Main FAB with animations
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Container(
                        width: widget.size,
                        height: widget.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              if (isPlaying) {
                                widget.musicService.pause();
                              } else {
                                widget.musicService.resume();
                              }
                            },
                            child: ClipOval(
                              child: Stack(
                                children: [
                                  // Song poster
                                  if (currentSong != null)
                                    CachedNetworkImage(
                                        imageUrl: currentSong.albumPic,
                                        fit: BoxFit.cover,
                                        width: widget.size,
                                        height: widget.size,
                                        placeholder: (context, url) =>
                                            Container(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Image.asset(
                                                'assets/images/logo.png'))
                                  else
                                    // Container(
                                    //   color: Theme.of(context).primaryColor,
                                    //   child: const Icon(
                                    //     Icons.music_note,
                                    //     color: Colors.white,
                                    //     size: 48,
                                    //   ),
                                    // ),
                                    // Play/Pause overlay
                                    Container(
                                      color: Colors.black12,
                                      child: Center(
                                        child: Icon(
                                          isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          color: Colors.white,
                                          size: widget.size * 0.4,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Duration text
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_formatDuration(position)} / ${_formatDuration(duration)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Custom painter for circular progress
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
