import 'package:get/get.dart';
import 'package:muzikk/services/music_service.dart';

class NowPlayingController extends GetxController {
  MusicService musicService = MusicService.instance;


  NowPlayingController();
  // Future<void> initNowPlaying() async {
  //   musicService.lis();
  // }

  // load(){
  //   _displayTitle = widget.video.title.contains('|')
  //       ? widget.video.title.split('|')[0].trim()
  //       : widget.video.title;
  // }

  Future<void> pauseOrResume() async {
    if (musicService.isPlaying.value) {
      await musicService.pause();
    } else {
      await musicService.resume();
    }
  }

  Future<void> updatePosition(Duration newPosition) async {
    musicService.updatePosition(newPosition);
    musicService.position.value = newPosition;
  }

  /// Stop playback and reset the controller
  Future<void> stop() async {
    await musicService.stop();
    musicService.isPlaying.value = false;
    musicService.position.value = Duration.zero;
    musicService.duration.value = Duration.zero;
  }

  @override
  void onInit() {
    // initNowPlaying();
    super.onInit();
  }

  @override
  void onClose() {
    // musicService.stop();
    super.onClose();
  }
}
