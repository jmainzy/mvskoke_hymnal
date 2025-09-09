import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';

class SongFooter extends StatelessWidget {
  final SongModel metadata;

  const SongFooter({super.key, required this.metadata});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Colors.grey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Dimens.marginLarge),
        metadata.note != null
            ? Text(metadata.note!, style: textStyle)
            : Container(),
        const SizedBox(height: Dimens.marginLarge),
      ],
    );
  }
}
