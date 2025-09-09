import 'package:logger/logger.dart';
import 'package:song_manager/models/song_metadata.dart';
import 'package:song_manager/models/serializer.dart';

Logger logger = Logger();

/// Language-agnostic metadata for a song
/// Language-specific details are in SongDetails
class SongModel extends SongMetadataBase {
  final Map<String, dynamic> titles;
  final List<String> tags;
  final List<String> related;
  final String? audioUrl;
  final String? note;
  final Map<String, String> lyricsMap;

  SongModel({
    required super.id,
    required super.songNumber,
    required this.titles,
    required this.tags,
    required this.related,
    required this.lyricsMap,
    this.audioUrl,
    this.note,
  });

  bool get hasAudio {
    return audioUrl != null && audioUrl!.isNotEmpty;
  }

  String? get lyrics => lyricsMap['mus'] != null && lyricsMap['mus']!.isNotEmpty
      ? lyricsMap['mus']
      : null;
  String? get lyricsEn => lyricsMap['en'];

  String get title {
    // returns the first non-null title
    if (titles['mus'] != null && titles['mus']!.isNotEmpty) {
      return titles['mus'];
    } else if (titles['en'] != null && titles['en']!.isNotEmpty) {
      return titles['en'];
    } else {
      return titles.isNotEmpty ? titles.values.first : '';
    }
  }

  String? get titleEn {
    // returns english or null
    return titles['en'] != null && titles['en']!.isNotEmpty
        ? titles['en']
        : null;
  }

  String? get titleMus {
    // returns muscogee or null
    return titles['mus'] != null && titles['mus']!.isNotEmpty
        ? titles['mus']
        : null;
  }

  String? get firstLine {
    // returns the first line of the lyrics
    final lyrics = lyricsMap['mus'] != null && lyricsMap['mus']!.isNotEmpty
        ? lyricsMap['mus']
        : lyricsMap['en'];
    if (lyrics != null && lyrics.isNotEmpty) {
      final lines = lyrics.trim().split('\n');
      var firstLines = '';
      var i = 0;
      while (firstLines.length < 20 && lines.isNotEmpty) {
        final line = lines[i];
        if (line.isNotEmpty && !line.startsWith('{')) {
          if (firstLines.isNotEmpty) {
            firstLines += ' ';
          }
          firstLines += line.trim();
        }
        i++;
      }
      // trim trailing comma
      if (firstLines.endsWith(',')) {
        firstLines = firstLines.substring(0, firstLines.length - 1);
      }
      // Trim headers
      if (firstLines.startsWith('Chorus:')) {
        firstLines = firstLines.substring(7);
      } else if (firstLines.startsWith(RegExp(r'\d+'))) {
        firstLines = firstLines.substring(2);
      }
      return '${firstLines.trim()}...';
    }
    return null;
  }

  @override
  String getTitle(String languageCode) {
    return titles.isNotEmpty ? titles[languageCode] ?? titles.values.first : '';
  }

  @override
  String toString() {
    return 'SongModel(id: $id, titles: $titles)';
  }
}

class MetadataSerializer extends Serializer<SongModel> {
  @override
  SongModel fromMap(Map<String, dynamic> map) {
    final titles = <String, String>{};
    final lyrics = <String, String>{};
    try {
      // if there's a 'title_en' field, parse title columns
      // This is how it's stored in the sqlite database
      if (map.containsKey('title_en')) {
        if (map['title'] != null) {
          titles['mus'] = map['title'];
        }
        if (map['title_en'] != null) {
          titles['en'] = map['title_en'];
        }
      } else if (map.containsKey('titles')) {
        // if there's a 'titles' field, parse it as a map
        // this is how it's stored in the local cache (box)
        map['titles'].forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            titles[key] = value.toString();
          }
        });
      }
    } catch (e) {
      logger.e('Error parsing titles from map: ${map['title']}\n$e');
    }
    try {
      if (map.containsKey('lyrics_en')) {
        // if there's a 'lyrics_en' field, parse it as a string
        if (map["lyrics"] != null) {
          lyrics['mus'] = map["lyrics"].toString();
        }
        if (map["lyrics_en"] != null) {
          lyrics['en'] = map['lyrics_en'].toString();
        }
      } else if (map.containsKey('lyrics')) {
        // parse as map
        map['lyrics'].forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            lyrics[key] = value.toString();
          }
        });
      }
    } catch (e) {
      logger.e('Error parsing lyrics from map: ${map['lyrics']}\n$e');
    }

    try {
      return SongModel(
        id: map['id'].toString(),
        titles: titles,
        tags: _parseList(map, 'tags'),
        related: _parseList(map, 'related'),
        lyricsMap: lyrics,
        songNumber: map['number'].toString(),
        audioUrl: map['audioUrl'],
        note: map['note'],
      );
    } catch (e) {
      logger.e(
          'Error deserializing song id=${map['id']} title=${titles['mus']}: $e');
      rethrow;
    }
  }

  _parseList(Map<String, dynamic> map, String key) {
    if (map.containsKey(key) && map[key] != null && map[key].isNotEmpty) {
      if (map[key] is String) {
        // strip [] if present
        String listString = map[key];
        listString = listString.replaceAll('[', '').replaceAll(']', '');
        return List<String>.from(listString.split(','));
      } else if (map[key] is List) {
        return List<String>.from(map[key]);
      }
    }
    return <String>[];
  }

  @override
  Map<String, dynamic> toMap(SongModel metadata) {
    return {
      'id': metadata.id,
      'titles': metadata.titles,
      'tags': metadata.tags,
      'related': metadata.related,
      'lyrics': metadata.lyricsMap,
      'number': metadata.songNumber,
      'audioUrl': metadata.audioUrl,
      'note': metadata.note,
    };
  }

  /// prints a map in a readable format for debugging
  /// Do not use in production, as it may print large values
  String printMap(Map<String, dynamic> map) {
    final buffer = StringBuffer();
    map.forEach((key, value) {
      buffer.writeln(
          '$key: ${value.toString().substring(0, value.toString().length > 50 ? 50 : value.toString().length)}');
      buffer.writeln('valueType: ${value.runtimeType}');
    });
    return buffer.toString();
  }
}
