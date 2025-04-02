import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/models/playlist.dart';
import 'package:mvskoke_hymnal/services/playlist_service.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:uuid/uuid.dart';

Logger log = Logger();

class PlaylistManager {
  final playlists = ValueNotifier<List<Playlist>>([]);
  final service = sl<PlaylistService>();

  List<Playlist> get ownPlaylists {
    return playlists.value
        .where((playlist) => playlist.isOwnPlaylist(loggedInUser))
        .toList();
  }

  String? loggedInUser;

  Future<void> updatePlaylists(
    PlaylistSong song,
    List<String> selectedPlaylists,
  ) async {
    final initialPlaylistsSet = getSongPlaylists(song.id).toSet();
    final selectedPlaylistsSet = selectedPlaylists.toSet();

    // Removed playlists
    final removedPlaylists = initialPlaylistsSet.difference(
      selectedPlaylistsSet,
    );
    for (final playlist in removedPlaylists) {
      log.i('removing song from playlist: $playlist');
      await removeSong(playlist, song);
    }

    // added playlists
    final addedPlaylists = selectedPlaylistsSet.difference(initialPlaylistsSet);
    for (final playlist in addedPlaylists) {
      log.i('adding song to playlist: $playlist');
      await addSong(playlist, song);
    }
  }

  Future<void> removeSong(String playlistId, PlaylistSong playlistSong) async {
    final playlist = playlists.value.firstWhereOrNull(
      (element) => element.id == playlistId,
    );

    if (playlist == null) return;

    final songs = playlist.songs
        .where((element) => element.id != playlistSong.id)
        .toList();

    updatePlaylist(playlist.copyWith(songs: songs));
  }

  Future<void> addSong(String playlistId, PlaylistSong playlistSong) async {
    var playlist = playlists.value.firstWhereOrNull(
      (element) => element.id == playlistId,
    );

    if (playlist == null) return;

    final songs = {...playlist.songs, playlistSong}.toList();

    updatePlaylist(playlist.copyWith(songs: songs));
  }

  Future<void> clearPlaylist(String playlistId) async {
    final playlist = playlists.value.firstWhereOrNull(
      (element) => element.id == playlistId,
    );

    if (playlist == null) return;

    updatePlaylist(playlist.copyWith(songs: []));
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    await service.updatePlaylist(playlist);
    fetchPlaylists();
  }

  List<String> getSongPlaylists(String songId) {
    return playlists.value
        .where((playlist) => playlist.songs.any((song) => song.id == songId))
        .map((playlist) => playlist.id)
        .toList();
  }

  bool isFavorite(String songId) {
    return ownPlaylists.any((e) => e.songs.any((song) => song.id == songId));
  }

  Future<String> addNewPlaylist(String name) async {
    final playlistId = const Uuid().v4();
    final playlist = Playlist(
      id: playlistId,
      name: name,
      songs: [],
      createdAt: DateTime.now().toUtc(),
      sharedTo: [],
      modifiedAt: DateTime.now().toUtc(),
      ownerId: loggedInUser,
    );

    playlists.value = [playlist, ...playlists.value];

    await service.updatePlaylist(playlist);

    return playlistId;
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    await _removePlaylistFromCache(playlist);

    await service.deletePlaylist(playlist);
    await fetchPlaylists();
  }

  Future<void> _removePlaylistFromCache(Playlist playlist) async {
    log.i('removing from cache: ${playlist.name}');
    playlists.value =
        playlists.value.where((e) => e.id != playlist.id).toList();

    await service.savePlaylists(playlists.value);
  }

  Future<void> deleteAllPlaylists() async {
    await service.deleteAll();
  }

  Future<void> fetchPlaylists() async {
    final playListFromStore = await service.loadPlaylists();

    playListFromStore.sort(
      (a, b) => b.modifiedAt.difference(a.modifiedAt).inSeconds,
    );
    playlists.value = playListFromStore;

    log.i('fetched playlists: ${playListFromStore.length}');

    if (loggedInUser == null) {
      // make favorites playlist
      if (playListFromStore.isEmpty) {
        final favoritePlaylist = Playlist(
          id: const Uuid().v4(),
          name: 'Favorites',
          songs: [],
          createdAt: DateTime.now().toUtc(),
          sharedTo: [],
          modifiedAt: DateTime.now().toUtc(),
          ownerId: loggedInUser,
        );

        playListFromStore.add(favoritePlaylist);

        playlists.value = playListFromStore;

        service.updatePlaylist(favoritePlaylist);
        return;
      }
    }
  }

  Future<void> removeCachedPlaylists() async {
    for (final playlist in playlists.value) {
      await _removePlaylistFromCache(playlist);
    }
  }

  Playlist? getCachedPlaylistByShortId(String shortId) {
    return playlists.value.firstWhere((e) => e.shortId == shortId);
  }

  List<Playlist> getOwnerSortedPlaylist(String? userId) {
    final sortedPlaylists = [...playlists.value];
    sortedPlaylists.sort((a, b) {
      if (a.isOwnPlaylist(userId) && !b.isOwnPlaylist(userId)) {
        return -1;
      } else if (!a.isOwnPlaylist(userId) && b.isOwnPlaylist(userId)) {
        return 1;
      }

      return 0;
    });

    return sortedPlaylists;
  }
}
