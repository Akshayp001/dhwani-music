import 'dart:async';
import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;

  const ScrollingText({required this.text, super.key});

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final Timer _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Start a periodic timer to scroll the text every 2.5 seconds.
    _scrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_scrollController.hasClients) return;

      // Scroll logic: Scroll to the start or end alternately.
      if (_scrollController.offset <
          _scrollController.position.maxScrollExtent) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 3500),
          curve: Curves.easeInOut,
        );
      } else {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 3500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40, // Ensure enough height for one line of text
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        children: [
          Text(
            widget.text,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 20), // Space between loops
        ],
      ),
    );
  }
}
