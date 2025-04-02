import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/models/song_details.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:song_manager/managers/song_manager.dart';

/// Custom TSongManager class with our custom models
/// This is just here so that we have access to our model types at compile time.

class MusSongManager extends SongManager<SongModel, SongDetails, MediaItem> {
  MusSongManager({required super.songsService, required super.languageConfig});
}
