import 'dart:convert';

import 'package:flutter/foundation.dart';

List<Playlist> playlistsFromString(String? string) {
  if (string == null) return [];
  return json
          .decode(string)
          ?.map<Playlist>((item) => Playlist.fromJson(item))
          ?.toList() ??
      [];
}

String playlistsToString(List<Playlist>? index) {
  return json.encode(index!);
}

class Playlist {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<PlaylistSong> songs;
  final String? ownerId;
  final String? shortId;
  final DateTime modifiedAt;
  final List<String> sharedTo;
  Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.songs,
    this.ownerId,
    this.shortId,
    required this.modifiedAt,
    required this.sharedTo,
  });

  Playlist copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<PlaylistSong>? songs,
    String? ownerId,
    String? shortId,
    DateTime? modifiedAt,
    List<String>? sharedTo,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      songs: songs ?? this.songs,
      ownerId: ownerId ?? this.ownerId,
      shortId: shortId ?? this.shortId,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      sharedTo: sharedTo ?? this.sharedTo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'songs': songs.map((x) => x.toMap()).toList(),
      'ownerId': ownerId,
      'shortId': shortId,
      'modifiedAt': modifiedAt.toIso8601String(),
      'sharedTo': sharedTo,
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map) {
    final created = map['createdAt'];
    late DateTime createdTime;
    // this is required for migration from old version
    if (created is int) {
      createdTime = DateTime.fromMillisecondsSinceEpoch(created).toUtc();
    } else {
      createdTime =
          DateTime.parse(created.endsWith('Z') ? created : created + 'Z');
    }

    late DateTime modifiedTime;
    String? modified = map['modifiedAt'];
    if (modified == null || modified.trim().isEmpty) {
      modifiedTime = createdTime;
    } else {
      modifiedTime =
          DateTime.parse(modified.endsWith('Z') ? modified : '${modified}Z');
    }

    List<PlaylistSong> songs = [];
    final songsList = map['songs'];
    songsList?.forEach(
      (x) {
        // this is required to migrate from old version
        if (x is String) {
          songs.add(
            PlaylistSong(
              id: x,
              transpose: 0,
              order: songsList!.indexOf(x),
            ),
          );
          return;
        }

        songs.add(PlaylistSong.fromMap(x));
      },
    );
    return Playlist(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      createdAt: createdTime,
      songs: songs,
      ownerId: map['ownerId'],
      shortId: map['shortId'],
      modifiedAt: modifiedTime,
      sharedTo: List<String>.from(map['sharedTo'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory Playlist.fromJson(String source) =>
      Playlist.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Playlist(id: $id, name: $name, createdAt: $createdAt, '
        'songs: $songs, ownerId: $ownerId, shortId: $shortId, '
        'modifiedAt: $modifiedAt, sharedTo: $sharedTo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Playlist &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt &&
        listEquals(other.songs, songs) &&
        other.ownerId == ownerId &&
        other.shortId == shortId &&
        other.modifiedAt == modifiedAt &&
        listEquals(other.sharedTo, sharedTo);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        createdAt.hashCode ^
        songs.hashCode ^
        ownerId.hashCode ^
        shortId.hashCode ^
        modifiedAt.hashCode ^
        sharedTo.hashCode;
  }

  bool isOwnPlaylist(String? userId) {
    if (userId == null) {
      return sharedTo.isEmpty;
    }

    return userId == ownerId;
  }

  bool containsSong(String songId) {
    return songs.any((element) => element.id == songId);
  }
}

class PlaylistSong {
  final String id;
  final int transpose;
  final int order;
  PlaylistSong({
    required this.id,
    required this.transpose,
    required this.order,
  });

  PlaylistSong copyWith({
    String? id,
    int? transpose,
    int? order,
  }) {
    return PlaylistSong(
      id: id ?? this.id,
      transpose: transpose ?? this.transpose,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transpose': transpose,
      'order': order,
    };
  }

  factory PlaylistSong.fromMap(Map<String, dynamic> map) {
    return PlaylistSong(
      id: map['id'] ?? '',
      transpose: map['transpose']?.toInt() ?? 0,
      order: map['order']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlaylistSong.fromJson(String source) =>
      PlaylistSong.fromMap(json.decode(source));

  @override
  String toString() =>
      'PlaylistSong(id: $id, transpose: $transpose, order: $order)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlaylistSong &&
        other.id == id &&
        other.transpose == transpose &&
        other.order == order;
  }

  @override
  int get hashCode => id.hashCode ^ transpose.hashCode ^ order.hashCode;
}
