import 'package:mvskoke_hymnal/utilities/timestamp.dart';
import 'package:mvskoke_hymnal/utilities/utils.dart';
import 'package:song_manager/models/serializer.dart';
import 'package:song_manager/models/media_item.dart';

class MediaItem extends MediaItemBase {
  final int id;
  final String? title;
  final String? performer;
  final String copyright;
  final Timestamp? lastUpdate;

  MediaItem({
    required this.id,
    required super.songId,
    required this.title,
    required super.filename,
    required this.performer,
    required this.copyright,
    required this.lastUpdate,
  });

  @override
  String toString() {
    return '''
    MediaItem(id: $id, 
      songId: $songId, 
      title: $title, 
      filename: $filename, 
      performer: $performer,
      copyright: $copyright,
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
      songId: map['song_id'].toString(),
      title: map['title'],
      filename: map['filename'],
      performer: map['performer'],
      copyright: map['copyright'],
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
      'performer': object.performer,
      'copyright': object.copyright,
      'lastUpdate': object.lastUpdate.toString(),
    };
  }
}
