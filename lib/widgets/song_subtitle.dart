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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            song.subtitle != null
                ? Text(
                    song.subtitle!,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Container(),
            if (song.hasAudio && isHorizontal)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.music_note,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
          ],
        ),
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
