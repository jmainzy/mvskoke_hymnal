import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/services/navigation_helper.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/services/store_service.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';

Logger log = Logger();

class SongHeader extends StatelessWidget {
  final SongModel? currentSong;
  final Function(String) addToPlaylist;

  const SongHeader({
    super.key,
    required this.currentSong,
    required this.addToPlaylist,
  });

  String? getTags() {
    if (currentSong != null &&
        currentSong?.tags != null &&
        currentSong!.tags.isNotEmpty) {
      var t = [];
      for (var tag in currentSong!.tags) {
        // clean up tags
        tag = tag.trim();
        t.add(tag);
      }
      return t.join(', ');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double fontScale = sl<MusStoreService>().fontSize / 18;
    TextStyle labelStyle = Theme.of(context).textTheme.displayMedium!.copyWith(
        color: Colors.black54,
        fontSize:
            Theme.of(context).textTheme.labelMedium!.fontSize! * fontScale);
    final tags = getTags();
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
          currentSong!.titleEn != null && currentSong!.titleMus != null
              ? Text(
                  currentSong!.titleEn!,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize:
                            Theme.of(context).textTheme.titleSmall!.fontSize! *
                                fontScale,
                      ),
                )
              : Container(),
          tags != null
              ? Padding(
                  padding: const EdgeInsets.only(top: Dimens.marginShort),
                  child: Text(
                    tags,
                    style: labelStyle,
                  ))
              : Container(),
          currentSong != null &&
                  currentSong?.related != null &&
                  currentSong!.related.isNotEmpty
              ? ListRow(
                  currentSong!.related,
                  style: labelStyle,
                  onTap: (songId) {
                    final history = NavigationHelper
                        .router.routerDelegate.currentConfiguration.matches
                        .map(
                          (e) => e.matchedLocation,
                        )
                        .toList();
                    // pop last element of history
                    history.removeLast();
                    final songRoute = '${NavigationHelper.songsPath}/$songId';
                    if (history.contains(songRoute)) {
                      // pop all routes until we reach the song route
                      NavigationHelper.router.pop();
                    } else {
                      NavigationHelper.router.push(
                        '${NavigationHelper.songsPath}/$songId',
                      );
                    }
                  },
                )
              : Container(),
          Row(children: [
            Expanded(child: Text('Hymn ${currentSong?.id}', style: labelStyle)),
            IconButton(
              onPressed: () => addToPlaylist(currentSong!.id),
              icon: const Icon(
                Icons.playlist_add,
              ),
            ),
          ]),
          const SizedBox(height: Dimens.marginShort),
          const Divider(),
        ],
      ),
    );
  }
}

class ListRow extends StatelessWidget {
  // Display items as a row
  final List<String> items;
  final TextStyle? style;
  final Function(String)? onTap;

  const ListRow(
    this.items, {
    super.key,
    this.style,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final comma = Text(', ', style: style);
    return Padding(
        padding: const EdgeInsets.only(top: Dimens.marginShort + 5),
        child: Row(
            children: <Widget>[
                  Text('Related: ', style: style),
                ] +
                items.map((item) {
                  return Row(children: [
                    InkWell(
                      onTap: () => onTap!(item.trim()),
                      child: Text(
                        item,
                        style: style?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        softWrap: true,
                      ),
                    ),
                    item != items.last ? comma : const SizedBox()
                  ]);
                }).toList()));
  }
}
