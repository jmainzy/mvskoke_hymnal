import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/managers/playlist_manager.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/widgets/playlist/new_playlist_sheet.dart';
import 'package:mvskoke_hymnal/widgets/playlist/playlist_list.dart';
import 'package:watch_it/watch_it.dart' hide sl;

Logger log = Logger();

class PlaylistScreen extends WatchingStatefulWidget {
  final String? shortId;
  const PlaylistScreen({super.key, this.shortId});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  bool _fetchingSharedPlaylist = false;

  @override
  Widget build(BuildContext context) {
    final playlists = watchValue((PlaylistManager p) => p.playlists);
    log.i('playlists: $playlists');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlaylistsList(playlists: playlists),
                const SizedBox(height: 20),
                // const Text(
                //   'Playlists shared with you',
                //   style: TextStyle(
                //     fontSize: 20,
                //     color: Colors.green,
                //   ),
                // ),
                // PlaylistsList(playlists: shareAcceptedPlaylists),
                // SizedBox(height: 20),
              ],
            ),
          ),
          if (_fetchingSharedPlaylist)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchingSharedPlaylist ? null : () => _addPlaylist(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addPlaylist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return const NewPlaylistBottomsheet();
      },
    );
  }

  @override
  void initState() {
    sl<PlaylistManager>().fetchPlaylists();
    _acceptPlaylist();
    super.initState();
  }

  Future<void> _acceptPlaylist() async {
    if (widget.shortId == null) return;
    final manager = sl<PlaylistManager>();
    final playlistOrNull = manager.getCachedPlaylistByShortId(widget.shortId!);
    if (playlistOrNull != null) {
      if (!mounted) return;
      final snackBar = SnackBar(
        content: Text('You already have ${playlistOrNull.name}'),
        backgroundColor: Colors.orange,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    if (!mounted) return;

    // late final Playlist playlist;
    try {
      _fetchingSharedPlaylist = true;
      setState(() {});
      // playlist = await manager.getRemotePlaylistByShortId(widget.shortId!);
    } catch (e) {
      if (!mounted) return;
      const snackBar = SnackBar(
        content: Text('Collection not found'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _fetchingSharedPlaylist = false;
      setState(() {});
      return;
    }

    _fetchingSharedPlaylist = false;
    setState(() {});

    if (!mounted) return;

    // final userId = context.read<UserProvider>().signedInUser?.id;
    // if (userId == null) {
    //   await openLoginSuggestMenu(context, false);
    // }

    if (!mounted) return;
  }
}
