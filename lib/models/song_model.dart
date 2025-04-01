import 'dart:convert';

import 'package:mvskoke_hymnal/utilities/timestamp.dart';
import 'package:mvskoke_hymnal/utilities/utils.dart';

enum SortType {
  alphabetical,
  songNumber,
}

List<SongModel> songModelsFromString(String? string) {
  if (string == null) return [];
  return json
          .decode(string)
          ?.map<SongModel>((item) => item is String
              ? SongModel.fromJson(item)
              : SongModel.fromMap(item))
          ?.toList() ??
      [];
}

String songModelsToString(List<SongModel>? index) {
  return json.encode(index!);
}

class SongModel {
  final String id;
  final List<dynamic> titles;
  final List<dynamic> lyrics;
  final List<dynamic> lyricsEn;
  final Timestamp? lastUpdate;
  final String? audioUrl;

  SongModel({
    required this.id,
    required this.titles,
    required this.lyrics,
    required this.lyricsEn,
    required this.lastUpdate,
    this.audioUrl,
  });

  bool get hasAudio {
    return audioUrl != null && audioUrl!.isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titles': titles,
      'lyrics': lyrics,
      'lyrics_en': lyricsEn,
      'lastUpdate': lastUpdate.toString(),
      'audioUrl': audioUrl,
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    final lastUpdate = Utils.getFormattedDate(map['lastUpdate']);

    return SongModel(
      id: map['id'],
      titles: map['titles'],
      lyrics: map['lyrics'],
      lyricsEn: map['lyrics_en'],
      lastUpdate: lastUpdate,
      audioUrl: map['audioUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SongModel.fromJson(String source) =>
      SongModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SongModel(id: $id, titles: $titles, $lastUpdate)';
  }
}
