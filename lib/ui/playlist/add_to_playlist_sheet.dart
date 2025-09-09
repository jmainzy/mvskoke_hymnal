import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/managers/playlist_manager.dart';
import 'package:mvskoke_hymnal/models/playlist.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/ui/playlist/new_playlist_sheet.dart';

Logger log = Logger();

class AddToPlaylistSheet extends StatefulWidget {
  final String songId;
  final int transposeIncrement;
  const AddToPlaylistSheet({
    super.key,
    required this.songId,
    required this.transposeIncrement,
  });

  @override
  State<AddToPlaylistSheet> createState() => _AddToPlaylistBottomSheetState();
}

class _AddToPlaylistBottomSheetState extends State<AddToPlaylistSheet> {
  final playlistManager = sl<PlaylistManager>();
  bool hasMadeChange = false;
  final selectedPlaylist = <String>[];
  var playlists = <Playlist>[];

  @override
  initState() {
    super.initState();
    fetch();
    selectedPlaylist.addAll(playlistManager.getSongPlaylists(widget.songId));
  }

  fetch() async {
    // get playlists
    await playlistManager.fetchPlaylists();
    playlists = playlistManager.playlists.value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.marginLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add to Collection',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: Dimens.marginLarge),
          SingleChildScrollView(
            child: Column(
              children: playlists.map((playlist) {
                final isSelected = selectedPlaylist.contains(playlist.id);
                return ListTile(
                  onTap: () {
                    _onSelected(
                      isSelected: isSelected,
                      playlistId: playlist.id,
                    );
                  },
                  title: Text(
                    playlist.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  trailing: Checkbox(
                    onChanged: (value) => _onSelected(
                      isSelected: isSelected,
                      playlistId: playlist.id,
                    ),
                    value: isSelected,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasMadeChange
                  ? () {
                      final playlistSong = PlaylistSong(
                        id: widget.songId,
                        transpose: widget.transposeIncrement,
                        order: 0,
                      );
                      playlistManager.updatePlaylists(
                        playlistSong,
                        selectedPlaylist,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Collection updated'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  : null,
              child: const Text('Save'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: TextButton(
              onPressed: () => _addPlaylist(context),
              child: const Text('Create new collection'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPlaylist(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return NewPlaylistBottomsheet(
          onPlaylistCreated: (playlistId) {
            _onSelected(isSelected: false, playlistId: playlistId);
          },
        );
      },
    );

    setState(() {});
  }

  void _onSelected({required bool isSelected, required String playlistId}) {
    if (isSelected) {
      selectedPlaylist.remove(playlistId);
    } else {
      selectedPlaylist.add(playlistId);
    }
    hasMadeChange = true;
    setState(() {});
  }
}
