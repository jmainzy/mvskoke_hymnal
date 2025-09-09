import 'dart:io';

import 'package:flutter/services.dart';
import 'package:mvskoke_hymnal/services/web_service.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:song_manager/services/songs_service.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/models/song_details.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';

/// Custom SongService class with our custom models
class MusSongService
    extends SongServiceBase<SongModel, SongDetails, MediaItem> {
  MusSongService({required super.storeService, required super.webService})
      : super(
          metadataSerializer: MetadataSerializer(),
          detailsSerializer: DetailsSerializer(),
          mediaSerializer: MediaSerializer(),
        );

  Future<String> get assetDbFilePath async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, "asset_database.db");
  }

  Future<void> copyDb() async {
    // Load database from asset and copy
    ByteData data = await rootBundle.load('assets/db/songs.db');
    List<int> bytes =
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Save copied asset to documents
    await File(await assetDbFilePath).writeAsBytes(bytes);
  }

  @override
  Future<List<SongModel>> getSongsFromAssets() async {
    await copyDb();
    return WebService.readSongsFromDatabase(await assetDbFilePath);
  }

  @override
  Future<List<SongDetails>> getDetailsFromAssets() async {
    return [];
  }

  @override
  Future<List<MediaItem>> getMediaFromAssets() async {
    return WebService.readMediaFromDatabase(await assetDbFilePath);
  }
}
