import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        song.subtitle != null &&
                song.subtitle!.isNotEmpty &&
                song.subtitle != song.title
            ? Row(
                children: [
                  Text(
                    song.subtitle!,
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
