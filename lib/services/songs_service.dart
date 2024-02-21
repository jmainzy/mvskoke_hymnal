import 'package:flutter/services.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';

class SongsService {
  Future<List<SongModel>> getSongs({bool forced = false}) async {
    return _getSongsFromAssets();
  }


  Future<List<SongModel>> getSongsFromCache() async {
    // TODO: Not yet implemented
    return _getSongsFromAssets();
  }

  Future<List<SongModel>> _getSongsFromAssets() async {
    print('Fetching song from assets');

    final songs = songModelsFromString(
      await rootBundle.loadString('backend/songs.json'),
    );
    final songsFromAssets = [...songs];

    _saveSongsToLocal(songsFromAssets);
    return songsFromAssets;
  }

  Future<void> _saveSongsToLocal(List<SongModel> songs) async {
    // print('Saving song to local');
    // final store = sl<StoreService>().box;
    // final songsString = songModelsToString(songs);
    // await store.put('songs', songsString);
  }
}
