import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muzikk/controller/home_controller.dart';
import 'package:muzikk/widgets/custom_navbar.dart';
import 'package:muzikk/widgets/music_fab.dart';

class HomeScreen extends StatelessWidget {
  final HomeController _controller = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() =>
          _controller.widgetOptions[_controller.selectedIndexOfPage.value]),
      bottomNavigationBar: CustomNavbar(
        homeController: _controller,
      ),
      floatingActionButton: Obx(
        () => Visibility(
            visible: _controller.selectedIndexOfPage.value != 2,
            child: MusicFAB(
              musicService: _controller.musicService,
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
