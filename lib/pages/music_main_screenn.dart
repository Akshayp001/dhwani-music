import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/music_main_controller.dart';
import '../widgets/music_tile.dart';
import 'now_playing_screen.dart';

class MusicPlayerScreen extends StatelessWidget {
  final MusicController _controller = Get.put(MusicController());

  MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController urlController = TextEditingController();
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Dhwani Music',
          style: GoogleFonts.sacramento(fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                  labelText: 'Search Songs',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40)),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: InkWell(
                      onTap: () {
                        _controller.searchSongs(searchController.text);
                      },
                      child: const Icon(CupertinoIcons.search),
                    ),
                  )),
              onSubmitted: (query) {
                _controller.searchSongs(query);
              },
            ),
            const SizedBox(height: 10),

            // Display Search Results
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: _controller.searchResults.length,
                  itemBuilder: (context, index) {
                    final video = _controller.searchResults[index];
                    return MusicTile(
                      video: video,
                      onPlayNext: () {
                        _controller.musicService.pushFrontSong(video);
                        Get.snackbar(video.title, 'Song Added On Top Of Queue');
                      },
                      onAddToQueue: () {
                        _controller.musicService.enqueueSong(video);
                        Get.snackbar(video.title, 'Song Added To Queue');
                      },
                      onTap: () {
                        _controller.playSong(video.url);
                        Get.to(() => NowPlayingScreen());
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
