import 'dart:developer';

import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/timestamp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  bool shouldUpdateSong = false;
  late SharedPreferences prefs;

  bool get showEnglishLyrics =>
      prefs.getBool(
        'showEnglishLyrics',
      ) ??
      false;

  Future<void> setShowEnglishLyrics(bool value) =>
      prefs.setBool('showEnglishLyrics', value);

  Future<void> initConfig() async {
    prefs = await SharedPreferences.getInstance();
    // String time = prefs.getString('songLastUpdated') ?? '';
    // if (time.isEmpty) {
    //   prefs.setString(
    //       'songLastUpdated', DateTime.timestamp().toIso8601String());
    // }

    return;
  }

  Future<void> updateLastUpdateSongLocal() async {
    await prefs.setString('songLastUpdated', Timestamp.now().toString());
  }
}
