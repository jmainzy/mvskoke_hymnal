import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/models/enums.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/ui/home/song_subtitle.dart';

class SongTile extends StatefulWidget {
  final SongModel song;
  final String subtitle;
  final Function(String) onTap;
  final bool hasAudio;
  final SortType sortType;

  const SongTile({
    super.key,
    required this.song,
    required this.hasAudio,
    required this.subtitle,
    required this.onTap,
    required this.sortType,
  });

  @override
  SongTileState createState() => SongTileState();
}

class SongTileState extends State<SongTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => widget.onTap(widget.song.id),
      contentPadding: const EdgeInsets.symmetric(
          vertical: 2.0, horizontal: Dimens.marginLarge),
      tileColor: Theme.of(context).colorScheme.surface,
      title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: Text(
                  widget.sortType == SortType.englishTitle
                      ? widget.song.titleEn ?? widget.song.title
                      : widget.song.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                )),
            Spacer(),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              widget.hasAudio
                  ? Padding(
                      padding: const EdgeInsets.only(
                          top: Dimens.marginShort, right: Dimens.marginShort),
                      child: Icon(
                        Icons.volume_up,
                      ))
                  : Container(),
              Padding(
                padding: const EdgeInsets.only(top: Dimens.marginShort),
                child: Text(
                  widget.song.songNumber,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Colors.black54,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall!.fontSize,
                      ),
                ),
              )
            ])
          ]),
      subtitle: SongSubtitle(
        song: widget.song,
        sortType: widget.sortType,
        artist: widget.subtitle,
      ),
      titleAlignment: ListTileTitleAlignment.top,
      // trailing: Padding(
      //   padding: const EdgeInsets.only(right: Dimens.marginShort),
      //   child: Container(
      //     color: Colors.red,
      //     child: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [

      //       ],
      //     ),
      //   ),
    );
  }
}
