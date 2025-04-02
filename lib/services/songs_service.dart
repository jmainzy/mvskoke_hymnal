import 'package:song_manager/services/songs_service.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/models/song_details.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';

/// Custom SongService class with our custom models
class MusSongService extends SongsService<SongModel, SongDetails, MediaItem> {
  MusSongService({required super.storeService, required super.webService})
      : super(
          metadataSerializer: MetadataSerializer(),
          detailsSerializer: DetailsSerializer(),
          mediaSerializer: MediaSerializer(),
        );
}
