import 'package:hive/hive.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/models/song_details.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/services/store_service.dart';
import 'package:song_manager/models/media_item.dart';
import 'package:song_manager/models/serializer.dart';
import 'package:song_manager/models/song_details.dart';
import 'package:song_manager/models/song_metadata.dart';
import 'package:song_manager/services/songs_service.dart';
import 'package:song_manager/services/store_service.dart';
import 'package:song_manager/services/web_service.dart';

class MockSongManager extends MusSongManager {
  static const exampleEnLyrics = 'God dwells, He created all things,';
  static const exampleMusLyrics = 'Hesaketvmese likes, Nak omvlkvn hahicevtet,';

  MockSongManager({required super.songsService, required super.languageConfig});
  @override
  SongModel? getSongById(String id) {
    if (id == 'invalid-id') return null;
    return SongModel(
      id: id,
      songNumber: '1',
      titles: {
        'en': 'Test Song (English)',
        'mus': 'Test Song (Mvskoke)',
      },
      tags: [],
      related: [],
      lyricsMap: {
        'en': exampleEnLyrics,
        'mus': exampleMusLyrics,
      },
    );
  }

  @override
  Future<SongDetails?> getSongDetails(String id) async {
    final details = SongDetails(
      songId: id,
    );
    return details;
  }

  @override
  Future<List<MediaItem>> getMediaItems(String id) async {
    return [
      MediaItem(
        id: 1,
        title: 'Test Audio',
        songId: id,
        filename: 'test.mp3',
        copyright: '© 2025',
        lastUpdate: null,
        performer: 'Cher',
      ),
    ];
  }
}

class MockSongsService implements SongsService {
  @override
  Future<List<MediaItemBase>> getMediaItems() async => [];
  Future<SongDetailsBase?> getSongDetails(String id) async => null;
  @override
  Future<List<SongMetadataBase>> getSongs() async => [];
  Future<void> init() async {}
  @override
  late Serializer<SongDetailsBase> detailsSerializer;
  @override
  late Serializer<MediaItemBase> mediaSerializer;
  @override
  late Serializer<SongMetadataBase> metadataSerializer;
  @override
  late StoreServiceBase storeService;
  @override
  WebServiceBase? webService;
  @override
  Future<void> deleteAll() {
    throw UnimplementedError();
  }

  @override
  Future<bool> fetch() {
    throw UnimplementedError();
  }

  @override
  Future<String?> findInAssets(MediaItemBase item) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> getCacheStrings() {
    throw UnimplementedError();
  }

  @override
  Future<List<SongDetailsBase>> getDetails() {
    throw UnimplementedError();
  }

  @override
  List<SongMetadataBase>? getSongsFromLocal() {
    throw UnimplementedError();
  }

  @override
  Uri getAudioUrl(MediaItemBase item) {
    return Uri.parse('https://example.com/${item.filename}');
  }
}

class MockStoreService implements MusStoreService {
  @override
  late Box box;

  @override
  double get fontSize => 18.0;
  @override
  T? get<T>(String key) {
    if (key == 'show_chords') return true as T;
    if (key == 'font_size') return 18.0 as T;
    return true as T;
  }

  @override
  Future<void> put(dynamic key, dynamic value) async {}
  @override
  Future<void> setFontSize(double size) async {}
  @override
  bool containsKey(dynamic key) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(key) {
    throw UnimplementedError();
  }

  @override
  Future<DateTime> getLastModified() async {
    return DateTime.now().subtract(const Duration(days: 1));
  }

  @override
  Future<void> setLastModified(DateTime dateTime) {
    return Future.value();
  }
}
