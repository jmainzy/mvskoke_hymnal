import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/enums.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';

class SongSubtitle extends StatelessWidget {
  final SongModel song;
  final String? artist;
  final bool showIcons;
  final bool isHorizontal;
  const SongSubtitle({
    required this.song,
    this.artist,
    this.isHorizontal = true,
    this.showIcons = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge!.copyWith(
          color: Colors.black54,
        );

    // if we're sorting by English, don't show the English subtitle
    final sortType = sl<MusSongManager>().sortType.value;
    final title = sortType == SortType.englishTitle
        ? song.titleEn ?? song.title
        : song.title;
    final subtitle = sortType == SortType.englishTitle
        ? song.titles['mus'] != null && song.titles['mus']!.isNotEmpty
            ? song.titles['mus']
            : null
        : song.titleEn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        subtitle != null && subtitle.isNotEmpty && subtitle != title
            ? Row(
                children: [
                  Text(
                    subtitle,
                    style: style,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              )
            : song.firstLine != null
                ? Text(
                    song.firstLine!,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(fontStyle: FontStyle.italic)
                        .copyWith(
                          color: Colors.black54,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Container(),
        Row(
          children: [
            if (song.hasAudio && !isHorizontal)
              const Icon(
                Icons.music_note,
                color: Colors.grey,
                size: 20,
              ),
          ],
        ),
      ],
    );
  }
}
