import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/models/playlist.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/services/store_service.dart';

/// Service to read and write playlists
/// Should only access through PlaylistManager

Logger log = Logger();

class PlaylistService {
  final store = sl<MusStoreService>();

  Future<List<Playlist>> loadPlaylists() async {
    final playlistsString = await store.get('playlists');
    return playlistsString == null ? [] : playlistsFromString(playlistsString);
  }

  Future<void> savePlaylists(List<Playlist> playlists) {
    return store.put('playlists', playlistsToString(playlists));
  }

  Future<void> deleteAll() {
    return store.delete('playlists');
  }

  Future<void> updatePlaylist(Playlist playlist) async {
    // update modified date
    final date = DateTime.now().toUtc();
    playlist = playlist.copyWith(modifiedAt: date);

    // read playlists
    final playlists = await loadPlaylists();
    log.i('loaded playlists: $playlists');
    final index = playlists.indexWhere((p) => p.id == playlist.id);
    if (index == -1) {
      // make new playlist
      playlists.add(playlist);
    } else {
      // update existing playlist
      playlists[index] = playlist;
    }
    return savePlaylists(playlists);
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    // read playlists
    final playlists = await loadPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlist.id);
    if (index != -1) {
      playlists.removeAt(index);
      savePlaylists(playlists);
    }
  }
}
