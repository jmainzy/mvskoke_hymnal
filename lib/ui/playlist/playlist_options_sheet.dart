import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/managers/playlist_manager.dart';
import 'package:mvskoke_hymnal/models/playlist.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/ui/song/confirm_bottom_sheet.dart';

class PlaylistOptionsBottomSheet extends StatefulWidget {
  final Playlist playlist;
  final bool fromPlaylistScreen;
  const PlaylistOptionsBottomSheet({
    super.key,
    required this.playlist,
    required this.fromPlaylistScreen,
  });

  @override
  State<PlaylistOptionsBottomSheet> createState() =>
      _PlaylistOptionsBottomSheetState();
}

class _PlaylistOptionsBottomSheetState
    extends State<PlaylistOptionsBottomSheet> {
  final formKey = GlobalKey<FormState>();
  late String playlistName;
  bool editing = false;
  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    // final userId = context.read<UserProvider>().signedInUser?.id;
    // final isOwn = widget.playlist.isOwnPlaylist(userId);
    // ignore: prefer_const_declarations
    final isOwn = true;

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.marginLarge),
        child: Column(
          children: [
            if (editing)
              ListTile(
                title: TextFormField(
                  focusNode: focusNode,
                  initialValue: widget.playlist.name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Collection Name',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Collection's name is required";
                    }
                    return null;
                  },
                  onChanged: (text) => playlistName = text,
                ),
                trailing: IconButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }

                    final newPlaylist = widget.playlist.copyWith(
                      name: playlistName,
                    );
                    sl<PlaylistManager>().updatePlaylist(newPlaylist);
                    setState(() {
                      editing = false;
                    });
                  },
                  icon: const Icon(Icons.check),
                ),
              )
            else
              ListTile(
                title: Text(playlistName, style: const TextStyle(fontSize: 24)),
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      editing = true;
                    });
                    focusNode.requestFocus();
                  },
                  icon: const Icon(Icons.edit),
                ),
              ),
            const Divider(),
            // Builder(builder: (context) {
            //   return ListTile(
            //       leading: const Icon(Icons.share),
            //       title: const Text('Share Collection'),
            //       onTap: () {});
            // }),
            if (isOwn)
              ListTile(
                iconColor: Colors.red,
                textColor: Colors.red,
                leading: const Icon(Icons.clear_all),
                title: const Text('Remove All Songs'),
                onTap: () {
                  showConfirmBottomSheet(
                    context,
                    title: 'Remove All Songs',
                    description:
                        'Are you sure you want to delete all songs from \'${widget.playlist.name}\'?',
                    confirmText: 'Clear',
                    onConfirm: () {
                      sl<PlaylistManager>().clearPlaylist(widget.playlist.id);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ListTile(
              iconColor: Colors.red,
              textColor: Colors.red,
              leading: const Icon(Icons.delete),
              // ignore: dead_code
              title: Text(isOwn ? 'Delete Collection' : 'Leave Collection'),
              onTap: () {
                showConfirmBottomSheet(
                  context,
                  // ignore: dead_code
                  title: isOwn ? 'Delete Collection' : 'Leave Collection',
                  description:
                      // ignore: dead_code
                      'Are you sure you want to ${isOwn ? 'delete' : 'leave'} \'${widget.playlist.name}\'?',
                  // ignore: dead_code
                  confirmText: isOwn ? 'Delete' : 'Leave',
                  isDistruptive: true,
                  onConfirm: () {
                    sl<PlaylistManager>().deletePlaylist(widget.playlist);
                    Navigator.of(context).pop();
                    if (widget.fromPlaylistScreen) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    playlistName = widget.playlist.name;
  }

  void showConfirmBottomSheet(
    BuildContext context, {
    required String title,
    String? description,
    required String? confirmText,
    String? cancelText,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    bool isDistruptive = true,
  }) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => ConfirmBottomSheet(
        title: title,
        description: description,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        isDistruptive: isDistruptive,
      ),
    );
  }
}

// void _sharePlaylist(BuildContext context, Playlist playlist) async {
//   final userId = context.read<UserProvider>().signedInUser?.id;

//   if (userId == null) {
//     await openLoginSuggestMenu(context, true);
//   }

//   if (!context.mounted) return;

//   final box = context.findRenderObject() as RenderBox?;

//   sl<PlaylistManager>().sharePlaylist(
//     playlist,
//     box!.localToGlobal(Offset.zero) & box.size,
//   );
// }
