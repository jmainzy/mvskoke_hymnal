import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/widgets/song_subtitle.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final String subtitle;

  const SongTile({
    super.key,
    required this.song,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context.push('/songs/${song.id}');
      },
      contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
      tileColor: Theme.of(context).colorScheme.surface,
      title: Text(
        song.titles[0],
        style: Theme.of(context).textTheme.titleLarge,
      ),
      subtitle: SongSubtitle(
        song: song,
        artist: subtitle,
      ),
      trailing: SizedBox(
        width: 40,
        child: Text(
          song.songNumber ?? '',
          softWrap: true,
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
