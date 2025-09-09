import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/models/playlist.dart';
import 'package:mvskoke_hymnal/services/navigation_helper.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/utilities/utils.dart';
import 'package:mvskoke_hymnal/ui/playlist/playlist_options_sheet.dart';

class PlaylistsList extends StatelessWidget {
  final List<Playlist> playlists;
  const PlaylistsList({super.key, required this.playlists});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: Dimens.marginShort / 2,
            horizontal: Dimens.marginLarge,
          ),
          title: Text(playlist.name, style: const TextStyle(fontSize: 20)),
          leading: Column(
            children: [
              const Text(
                'Songs',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                playlist.songs.length.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          subtitle: Text('Updated: ${Utils.humanize(playlist.modifiedAt)}'),
          trailing: SizedBox(
            height: 30,
            width: 30,
            child: IconButton(
              onPressed: () => openPlaylistOptions(
                context,
                playlist,
                fromPlaylistScreen: false,
              ),
              icon: const Icon(Icons.more_vert),
            ),
          ),
          onTap: () {
            NavigationHelper.router.go(
              '${NavigationHelper.playlistPath}/${playlist.id}',
            );
          },
        );
      },
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
