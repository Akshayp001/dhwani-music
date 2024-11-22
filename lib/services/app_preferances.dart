import 'package:shared_preferences/shared_preferences.dart';

class AppPreferances {
  static const String lastPlayedSongKey = 'lastPlayedSong';

  static final AppPreferances instance = AppPreferances._privateConstructor();
  AppPreferances._privateConstructor();

  getLastPlayedSong() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(lastPlayedSongKey) ??
        'https://www.youtube.com/watch?v=nwFIp_gaACg';
  }

  setLastPlayedSong(String song) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(lastPlayedSongKey, song);
  }
}
