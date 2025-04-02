import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';

class SongHeader extends StatelessWidget {
  final SongModel? currentSong;
  final Function(String) addToPlaylist;

  const SongHeader({
    super.key,
    required this.currentSong,
    required this.addToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.marginLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  currentSong?.titles.values.first,
                  style: Theme.of(context).textTheme.titleLarge!,
                ),
              ),
              const SizedBox(width: Dimens.marginShort),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentSong?.songNumber ?? '',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.grey,
                      fontFamily: 'Noto',
                    ),
              ),
              IconButton(
                onPressed: () => addToPlaylist(currentSong!.id),
                icon: const Icon(Icons.playlist_add),
              ),
            ],
          ),
          const SizedBox(height: Dimens.marginShort),
          const Divider(),
        ],
      ),
    );
  }
}
