import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/services/store_service.dart';
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
    double fontScale = sl<MusStoreService>().fontSize / 18;
    TextStyle labelStyle = Theme.of(context).textTheme.displayMedium!.copyWith(
        color: Colors.black54,
        fontSize:
            Theme.of(context).textTheme.labelMedium!.fontSize! * fontScale);
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
                  currentSong!.title,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize:
                            Theme.of(context).textTheme.titleLarge!.fontSize! *
                                fontScale,
                      ),
                ),
              ),
              const SizedBox(width: Dimens.marginShort),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: currentSong!.subtitle != currentSong!.title
                      ? Text(currentSong?.subtitle ?? '',
                          softWrap: true, style: labelStyle)
                      : Container()),
              IconButton(
                onPressed: () => addToPlaylist(currentSong!.id),
                icon: const Icon(Icons.playlist_add),
              ),
            ],
          ),
          Text('Hymn ${currentSong?.id}', style: labelStyle),
          const SizedBox(height: Dimens.marginShort),
          const Divider(),
        ],
      ),
    );
  }
}
