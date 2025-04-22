import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/managers/playlist_manager.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';

class NewPlaylistBottomsheet extends StatefulWidget {
  final void Function(String playlistId)? onPlaylistCreated;
  const NewPlaylistBottomsheet({super.key, this.onPlaylistCreated});

  @override
  State<NewPlaylistBottomsheet> createState() => _NewPlaylistBottomsheetState();
}

class _NewPlaylistBottomsheetState extends State<NewPlaylistBottomsheet> {
  final formKey = GlobalKey<FormState>();
  String name = "";
  final focusNode = FocusNode();

  bool savingPlaylist = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.marginLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add new collection', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            TextFormField(
              focusNode: focusNode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Collection Name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Collection Name is required';
                }
                return null;
              },
              onChanged: (text) => name = text,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: savingPlaylist
                    ? null
                    : () async {
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }

                        setState(() {
                          savingPlaylist = true;
                        });

                        final playlistId = await sl<PlaylistManager>()
                            .addNewPlaylist(name.trim());
                        widget.onPlaylistCreated?.call(playlistId);

                        if (!context.mounted) return;

                        setState(() {
                          savingPlaylist = false;
                        });

                        Navigator.of(context).pop();
                      },
                child: savingPlaylist
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Add'),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    focusNode.requestFocus();
  }
}
