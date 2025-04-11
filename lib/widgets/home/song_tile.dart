import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/widgets/home/song_subtitle.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final String subtitle;
  final Function(String) onTap;

  const SongTile({
    super.key,
    required this.song,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(song.id),
      contentPadding: const EdgeInsets.symmetric(
          vertical: 2.0, horizontal: Dimens.marginLarge),
      tileColor: Theme.of(context).colorScheme.surface,
      title: Text(
        song.title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      subtitle: SongSubtitle(
        song: song,
        artist: subtitle,
      ),
      trailing: Padding(
          padding: const EdgeInsets.only(right: Dimens.marginShort),
          child: Text(
            song.id,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Colors.black54,
                ),
          )),
    );
  }
}
