import 'package:song_manager/models/serializer.dart';
import 'package:song_manager/models/song_details.dart';

/// Language-specific details for a song.
/// Not used for now.
class SongDetails extends SongDetailsBase {
  SongDetails({required super.songId});

  @override
  String toString() {
    return '''SongDetails(id: $songId)''';
  }
}

class DetailsSerializer extends Serializer<SongDetails> {
  @override
  SongDetails fromMap(Map<String, dynamic> map) {
    return SongDetails(songId: map['id']);
  }

  @override
  Map<String, dynamic> toMap(SongDetails object) {
    return {
      'id': object.songId,
    };
  }
}
