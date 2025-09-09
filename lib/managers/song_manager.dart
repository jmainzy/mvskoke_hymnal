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
    // default is sort songs by song number
    var songs = List<SongModel>.from(filteredResult.value);
    if (sortType.value == SortType.englishTitle) {
      songs.sort((a, b) => (a.titles['en'] != null && a.titles['en']!.isNotEmpty
              ? a.titles['en']
              : 'zzz')
          .compareTo(b.titles['en'] != null && b.titles['en']!.isNotEmpty
              ? b.titles['en']
              : 'zzz'));
    } else if (sortType.value == SortType.mvskokeTitle) {
      songs.sort((a, b) =>
          (a.titles['mus'] != null && a.titles['mus']!.isNotEmpty
                  ? a.titles['mus']
                  : 'zzz')
              .compareTo(b.titles['mus'] != null && b.titles['mus']!.isNotEmpty
                  ? b.titles['mus']
                  : 'zzz'));
    } else {
      songs.sort(
          (a, b) => int.parse(a.songNumber).compareTo(int.parse(b.songNumber)));
    }
    sortedSongs.value = songs;
  }

  setSortType(SortType type) {
    sortType.value = type;
    _sort();
  }
}
