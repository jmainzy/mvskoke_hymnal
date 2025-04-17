import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/utilities/timestamp.dart';
import 'package:mvskoke_hymnal/utilities/utils.dart';
import 'package:song_manager/models/song_metadata.dart';
import 'package:song_manager/models/serializer.dart';

Logger logger = Logger();

/// Language-agnostic metadata for a song
/// Language-specific details are in SongDetails
class SongModel extends SongMetadataBase {
  final Map<String, dynamic> titles;
  final Timestamp? lastUpdate;
  final String? audioUrl;
  final String? note;
  final Map<String, String> lyricsMap;

  SongModel({
    required super.id,
    required super.songNumber,
    required this.titles,
    required this.lyricsMap,
    required this.lastUpdate,
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
    return 'SongModel(id: $id, titles: $titles, $lastUpdate)';
  }
}

class MetadataSerializer extends Serializer<SongModel> {
  @override
  SongModel fromMap(Map<String, dynamic> map) {
    final lastUpdate = Utils.getFormattedDate(map['lastUpdate']);

    final titles = <String, String>{};
    if (map['title'] != null) {
      titles['mus'] = map['title'];
    }
    if (map['title_en'] != null) {
      titles['en'] = map['title_en'];
    }

    final lyrics = <String, String>{};
    if (map["lyrics"] != null) {
      lyrics['mus'] = map["lyrics"];
    }
    if (map["lyrics_en"] != null) {
      lyrics['en'] = map['lyrics_en'];
    }

    return SongModel(
      id: map['id'],
      titles: titles,
      lyricsMap: lyrics,
      lastUpdate: lastUpdate,
      songNumber: map['id'].toString().padLeft(3, '0'),
      audioUrl: map['audioUrl'],
      note: map['note'],
    );
  }

  @override
  Map<String, dynamic> toMap(SongModel metadata) {
    return {
      'id': metadata.id,
      'titles': metadata.titles,
      'lyrics': metadata.lyricsMap,
      'lastUpdate': metadata.lastUpdate.toString(),
      'song_number': metadata.songNumber,
      'audioUrl': metadata.audioUrl,
      'note': metadata.note,
    };
  }
}
