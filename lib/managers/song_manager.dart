import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/services/config_service.dart';
import 'package:mvskoke_hymnal/services/songs_service.dart';

import 'package:mvskoke_hymnal/models/song_model.dart';

import '../services/service_locator.dart';

SongsService _songsService = SongsService();

class SongManager {
  List<SongModel> _songs = [];
  final filteredResult = ValueNotifier<List<SongModel>>([]);
  final sortType = ValueNotifier<SortType>(SortType.alphabetical);

  final searchTerm = ValueNotifier<String?>(null);

  List<SongModel> get songs => _songs;

  void setSortType(SortType type) {
    sortType.value = type;
    _sortSongs();
  }

  bool get showEnglishLyrics {
    return sl<ConfigService>().showEnglishLyrics;
  }

  Future<void> getSongs({bool forced = false}) async {
    log('get songs !!!!!!!! $forced');
    _songs = await _songsService.getSongs(forced: forced);
    filteredResult.value = List.from(_songs);
    _sortSongs();
  }

  Future<void> getCachedSongs() async {
    _songs = await _songsService.getSongsFromCache();
    filteredResult.value = List.from(_songs);
    _sortSongs();
  }

  _sortSongs() {
  }

  SongModel? getSongById(String id) {
    return _songs.where((element) => element.id == id).firstOrNull;
  }

  filterSongs(String? filter) {
    if (filter == null || filter.trim() == '') {
      searchTerm.value = null;
      filteredResult.value = List<SongModel>.from(_songs);
      _sortSongs();
    } else {
      _sortSongs();

      final isANumber = int.tryParse(filter.trim());

      if (isANumber != null) {
        final filteredSearchBySongNumber = filteredResult.value.where(
          (SongModel song) => song.songNumber == isANumber,
        );

        filteredResult.value = filteredSearchBySongNumber.toList();
        searchTerm.value = filter;
        return;
      }

      List<SongModel> filteredSearchByName = filteredResult.value
          .where(
            (SongModel song) => song.titles[0]
                .toLowerCase()
                .contains(filter.trim().toLowerCase()),
          )
          .toList();

      List<SongModel> filteredSearch = filteredSearchByName;

      searchTerm.value = filter;
      filteredSearch = filteredSearch.toSet().toList();
      filteredResult.value = filteredSearch;
    }
  }

  Future<void> updateAllSongs() async {
    // await _songsService.updateSong('songs');
    // await _songsService.updateSong('bhajan');
    // await _songsService.updateSong('chorus');
    // await _songsService.updateSong('kids');
  }
}
