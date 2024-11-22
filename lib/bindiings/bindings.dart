import 'package:get/get.dart';
import 'package:muzikk/controller/now_playing_controller.dart';
import 'package:muzikk/services/music_service.dart';

import '../controller/music_main_controller.dart';

class NowPlayingBinding extends Bindings {
  @override
  void dependencies() {
    // Ensuring the MusicController is available
    Get.lazyPut(() => MusicController());

    // Bind NowPlayingController
    Get.lazyPut(
      () => NowPlayingController(),
    );
  }
}
