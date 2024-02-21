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
  final List<dynamic> mus_lyrics;
  final List<dynamic> en_lyrics;
  final Timestamp? lastUpdate;
  final String? songNumber;
  final String? audioUrl;

  SongModel({
    required this.id,
    required this.titles,
    required this.mus_lyrics,
    required this.en_lyrics,
    required this.lastUpdate,
    this.songNumber,
    this.audioUrl,
  });

  bool get hasAudio {
    return audioUrl != null && audioUrl!.isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titles': titles,
      'mus_lyrics': mus_lyrics,
      'en_lyrics': en_lyrics,
      'lastUpdate': lastUpdate.toString(),
      'song_number': songNumber,
      'audioUrl': audioUrl,
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    final lastUpdate = Utils.getFormattedDate(map['lastUpdate']);

    return SongModel(
      id: map['id'],
      titles: map['titles'],
      mus_lyrics: map['mus_lyrics'],
      en_lyrics: map['en_lyrics'],
      lastUpdate: lastUpdate,
      songNumber: map['song_number'],
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
