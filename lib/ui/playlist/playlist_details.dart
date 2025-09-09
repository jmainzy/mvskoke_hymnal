import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/managers/playlist_manager.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/playlist.dart';
import 'package:mvskoke_hymnal/services/navigation_helper.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/ui/playlist/confirm_bottom_sheet.dart';
import 'package:mvskoke_hymnal/ui/playlist/playlist_options_sheet.dart';
import 'package:watch_it/watch_it.dart' hide sl;

Logger log = Logger();

class PlaylistDetails extends StatelessWidget with WatchItMixin {
  final String playlistId;
  PlaylistDetails({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final playlists = watchValue((PlaylistManager p) => p.playlists);
    final playlist = playlists.firstWhereOrNull((p) => p.id == playlistId);

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist?.name ?? ''),
        actions: playlist != null
            ? [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => openPlaylistOptions(
                    context,
                    playlist,
                    fromPlaylistScreen: true,
                  ),
                ),
              ]
            : [],
      ),
      body: Container(
        child: () {
          if (playlist == null) {
            return NotFoundPlaylist(playlistId: playlistId);
          } else if (playlist.songs.isEmpty) {
            return EmptyPlaylist(playlist: playlist);
          } else {
            return PlaylistBody(playlist: playlist);
          }
        }(),
      ),
    );
  }

  Future<void> openPlaylistOptions(
    BuildContext context,
    Playlist playlist, {
    required bool fromPlaylistScreen,
  }) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return PlaylistOptionsBottomSheet(
          playlist: playlist,
          fromPlaylistScreen: fromPlaylistScreen,
        );
      },
    );
  }
}

class NotFoundPlaylist extends StatelessWidget {
  const NotFoundPlaylist({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context) {
    log.e('Collection $playlistId not found');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.black54),
          Text('Collection $playlistId not found'),
        ],
      ),
    );
  }
}

class EmptyPlaylist extends StatelessWidget {
  const EmptyPlaylist({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.marginLarge),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, color: Colors.grey),
            const SizedBox(height: Dimens.marginLarge),
            Text(
              '${playlist.name} is empty!\nAdd songs to this collection for them to appear here.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistBody extends StatelessWidget {
  const PlaylistBody({
    super.key,
    required this.playlist,
    // required this.isOwnPlaylist,
  });

  final Playlist playlist;
  // final bool isOwnPlaylist;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: true,
      itemCount: playlist.songs.length,
      onReorder: (int oldIndex, int newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final songs = playlist.songs;
        songs.insert(newIndex, songs.removeAt(oldIndex));
        playlist.copyWith(songs: songs);
        // sl<PlaylistManager>().managePlaylist(playlist);
      },
      itemBuilder: (context, index) {
        final playlistSong = playlist.songs[index];
        final song = sl<MusSongManager>().songsNotifier.value.firstWhereOrNull(
              (e) => e.id == playlistSong.id,
            );

        if (song == null) {
          return SizedBox.shrink(key: Key('$index'));
        }

        return ListTile(
          key: Key('$index'),
          onTap: () {
            log.i('Navigating to song ${song.id}');
            log.i(
              'GoRouter routes available: ${NavigationHelper.router.routeInformationParser}',
            );
            NavigationHelper.router.go(
              '${NavigationHelper.playlistPath}/${playlist.id}${NavigationHelper.songsPath}/${song.id}',
            );
          },
          title: Text(song.title),
          // subtitle: Text(
          //   'Transpose: ${playlistSong.transpose}',
          // ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => ConfirmBottomSheet(
                  title: 'Remove Song',
                  description:
                      'Are you sure you want to remove \'${song.title}\' from the collection?',
                  confirmText: 'Remove',
                  cancelText: 'Cancel',
                  onConfirm: () => {
                    sl<PlaylistManager>().removeSong(
                      playlist.id,
                      playlistSong,
                    ),
                  },
                  onCancel: () => {Navigator.of(context).pop()},
                  isDistruptive: true,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
