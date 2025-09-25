import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/models/enums.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';

class SongSubtitle extends StatelessWidget {
  final SongModel song;
  final String? artist;
  final bool showIcons;
  final bool isHorizontal;
  final SortType sortType;

  const SongSubtitle({
    required this.song,
    required this.sortType,
    this.artist,
    this.isHorizontal = true,
    this.showIcons = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge!.copyWith(
          color: Colors.black54,
          fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
        );

    // if we're sorting by English, don't show the English subtitle
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
            ? Text(
                subtitle,
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : song.firstLine != null
                ? Text(
                    song.firstLine!,
                    style: style.copyWith(fontStyle: FontStyle.italic),
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
