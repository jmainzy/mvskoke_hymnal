import 'package:mvskoke_hymnal/utilities/timestamp.dart';
import 'package:mvskoke_hymnal/utilities/utils.dart';
import 'package:song_manager/models/serializer.dart';
import 'package:song_manager/models/media_item.dart';

class MediaItem extends MediaItemBase {
  final int id;
  final String? title;
  final Timestamp? lastUpdate;

  MediaItem({
    required super.songId,
    required super.filename,
    required this.id,
    required this.title,
    required this.lastUpdate,
  });

  @override
  String toString() {
    return '''
    MediaItem(id: $id, 
      songId: $songId, 
      title: $title, 
      filename: $filename, 
      lastUpdate: $lastUpdate)
    ''';
  }
}

class MediaSerializer extends Serializer<MediaItem> {
  @override
  MediaItem fromMap(Map<String, dynamic> map) {
    final lastUpdate = Utils.getFormattedDate(map['created_at']);
    return MediaItem(
      id: map['id'],
      songId: map['song_id'] ?? '',
      title: map['title'],
      filename: map['filename'],
      lastUpdate: lastUpdate,
    );
  }

  @override
  Map<String, dynamic> toMap(MediaItem object) {
    return {
      'id': object.id,
      'song_id': object.songId,
      'title': object.title,
      'filename': object.filename,
      'lastUpdate': object.lastUpdate.toString(),
    };
  }
}
