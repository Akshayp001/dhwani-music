import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muzikk/firebase_options.dart';
import 'package:muzikk/pages/homescreen.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Dhwani Music',
      theme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        appBarTheme: AppBarTheme(
            backgroundColor: const Color.fromARGB(255, 53, 5, 85),
            centerTitle: true,
            titleTextStyle:
                TextStyle(fontFamily: GoogleFonts.poppins().fontFamily)),
      ),
      home: HomeScreen(),
    );
  }
}
