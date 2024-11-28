import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:muzikk/controller/home_controller.dart';

class CustomNavbar extends StatelessWidget {
  HomeController homeController;

  CustomNavbar({required this.homeController, super.key});
  final primaryColor = const Color.fromARGB(255, 41, 2, 63);
  final secondaryColor = const Color.fromARGB(255, 97, 8, 123);
  final accentColor = const Color(0xffffffff);
  final backgroundColor = const Color(0xffffffff);
  final errorColor = const Color(0xffEF4444);
  final circleRadius = const Radius.circular(50);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: EdgeInsets.zero,
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: circleRadius, topRight: circleRadius),
            gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft)),
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBottomBar(
                    text: "Home",
                    icon: CupertinoIcons.home,
                    selected: homeController.selectedIndexOfPage.value == 0,
                    onPressed: () => homeController.changeSelectedPage(0)),
                IconBottomBar(
                    text: "Favorites",
                    icon: CupertinoIcons.heart,
                    selected: homeController.selectedIndexOfPage.value == 1,
                    onPressed: () => homeController.changeSelectedPage(1)),
                IconBottomBar(
                    text: "Settings",
                    icon: CupertinoIcons.settings,
                    selected: homeController.selectedIndexOfPage.value == 2,
                    onPressed: () => homeController.changeSelectedPage(2))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IconBottomBar extends StatelessWidget {
  const IconBottomBar(
      {super.key,
      required this.text,
      required this.icon,
      required this.selected,
      required this.onPressed});
  final String text;
  final IconData icon;
  final bool selected;
  final Function() onPressed;

  final primaryColor = const Color(0xff4338CA);
  final accentColor = const Color(0xffffffff);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPressed,
          icon:
              Icon(icon, size: 32, color: selected ? accentColor : Colors.grey),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            text,
            style: TextStyle(
                fontSize: 14,
                height: .1,
                color: selected ? accentColor : Colors.grey),
          ),
        )
      ],
    );
  }
}
