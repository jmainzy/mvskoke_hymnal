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

  String? get lyrics => lyricsMap['mus'];
  String? get lyricsEn => lyricsMap['en'];

  String get title {
    const langugage = 'mus'; // default language
    if (titles[langugage] != null) {
      return titles[langugage];
    } else {
      return titles.isNotEmpty ? titles.values.first : '';
    }
  }

  String? get subtitle {
    // returns english or null
    return titles['en'];
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
