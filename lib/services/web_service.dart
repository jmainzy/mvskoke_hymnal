import 'dart:io';

import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/models/song_details.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:song_manager/services/web_service.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

class WebService extends WebServiceBase {
  final String baseUrl = 'https://esyvhiketv.sfo3.digitaloceanspaces.com';
  Logger logger = Logger();
  String dbPath = '';

  Future<String> downloadSongs() async {
    logger.i('Downloading songs from $baseUrl');
    String songsUrl = '$baseUrl/songs.db';
    final directory = await getApplicationDocumentsDirectory();
    dbPath = '${directory.path}/songs.db';

    try {
      final response = await http.get(Uri.parse(songsUrl));
      if (response.statusCode == 200) {
        File(dbPath).writeAsBytesSync(response.bodyBytes);
        logger.i('Songs downloaded successfully to $dbPath');
      } else {
        logger.e('Failed to download songs: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error downloading songs: $e');
    }
    return dbPath;
  }

  @override
  Future<List<SongModel>> getSongs() async {
    logger.i('Fetching songs from $baseUrl');
    String path = await downloadSongs();
    if (path.isEmpty) {
      logger.e('Failed to download songs, returning empty list');
      return [];
    } else {
      // read songs from sqlite database
      List<SongModel> songs = await readSongsFromDatabase(path);
      return songs;
    }
  }

  static Future<List<SongModel>> readSongsFromDatabase(String path) async {
    final db = await openDatabase(path);
    final List<Map<String, dynamic>> songMaps = await db.query('songs');
    MetadataSerializer serializer = MetadataSerializer();
    return songMaps.map((map) => serializer.fromMap(map)).toList();
  }

  static Future<List<MediaItem>> readMediaFromDatabase(String path) async {
    final db = await openDatabase(path);
    final List<Map<String, dynamic>> mediaMaps = await db.query('media');
    MediaSerializer serializer = MediaSerializer();
    return mediaMaps.map((map) => serializer.fromMap(map)).toList();
  }

  @override
  Future<List<SongDetails>> getLanguageDetails() async {
    // Not used in this app, for now.
    return [];
  }

  @override
  Future<List<MediaItem>> getMedia() async {
    // read from downloaded songs.db
    return await readMediaFromDatabase(dbPath);
  }

  @override
  Uri getAudioUrl(String filename) {
    return Uri.parse('$baseUrl/$filename');
  }

  @override
  Future<DateTime?> getLastModified() async {
    try {
      final response = await http.head(Uri.parse('$baseUrl/songs.db'));
      if (response.statusCode == 200) {
        String? lastModified = response.headers['last-modified'];
        if (lastModified != null) {
          return HttpDate.parse(lastModified);
        } else {
          logger.e(
              'last-modified header not found in headers ${response.headers}');
        }
      } else {
        logger.e('Failed to fetch last modified date: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching last modified date: $e');
    }
    return null;
  }
}
