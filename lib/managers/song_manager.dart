import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/models/enums.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/models/song_details.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:song_manager/managers/song_manager.dart';

/// Custom TSongManager class with our custom models
/// This is just here so that we have access to our model types at compile time.

Logger log = Logger();

class MusSongManager extends SongManager<SongModel, SongDetails, MediaItem> {
  final sortedSongs = ValueNotifier<List<SongModel>>([]);

  final sortType = ValueNotifier<SortType>(SortType.songNumber);

  MusSongManager({required super.songsService, required super.languageConfig}) {
    filteredResult.addListener(() {
      sortedSongs.value = filteredResult.value;
      _sort();
    });
  }

  _sort() {
    // defaulst is sort songs by song number
    var songs = List<SongModel>.from(filteredResult.value);
    if (sortType.value == SortType.englishTitle) {
      songs.sort(
          (a, b) => (a.subtitle ?? a.title).compareTo(b.subtitle ?? b.title));
    } else if (sortType.value == SortType.mvskokeTitle) {
      songs.sort((a, b) => (a.title).compareTo(b.title));
    } else {
      songs.sort(
          (a, b) => (a.songNumber ?? a.id).compareTo(b.songNumber ?? b.id));
    }
    log.i('songs are sorted');
    sortedSongs.value = songs;
    // sortedSongs.notifyListeners();
  }

  setSortType(SortType type) {
    log.i('Setting sort type to $type');
    sortType.value = type;
    _sort();
  }
}
