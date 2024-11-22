import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muzikk/pages/favorite_screen.dart';
import 'package:muzikk/pages/music_main_screenn.dart';
import 'package:muzikk/pages/settings_screen.dart';
import 'package:muzikk/services/music_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/song.dart';

class HomeController extends GetxController {
  final MusicService musicService =
      MusicService.instance; // Use the singleton instance

  final List<Widget> widgetOptions = <Widget>[
    MusicPlayerScreen(),
    const FavoriteScreen(),
    const SettingsScreen(),
  ];

  final RxInt selectedIndexOfPage = 0.obs;

  changeSelectedPage(int index) {
    selectedIndexOfPage.value = index;
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    musicService.dispose();
    super.onClose();
  }
}
