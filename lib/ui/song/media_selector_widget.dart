import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/managers/audio_manager.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';

class MediaSelectorWidget extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final Function(MediaItem)? onSelect;

  const MediaSelectorWidget({
    required this.mediaItems,
    required this.onSelect,
    super.key,
  });

  @override
  State<MediaSelectorWidget> createState() => _MediaSelectorWidgetState();
}

class _MediaSelectorWidgetState extends State<MediaSelectorWidget> {
  Logger logger = Logger();
  String title = '';
  String language = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentMedia = sl<AudioManager>().currentMedia;
    final boldText = Theme.of(
      context,
    ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold);
    final bodyStyle = Theme.of(context).textTheme.bodyMedium;
    return SizedBox(
      //Todo: Resize based on the number of items
      height: 300,
      child: ListView.builder(
        padding: const EdgeInsets.all(Dimens.marginLarge),
        itemCount: widget.mediaItems.length,
        itemBuilder: (BuildContext context, int index) {
          bool selected = widget.mediaItems[index].id ==
              int.parse(currentMedia.value?.id ?? '-1');
          return ListTile(
            onTap: () => {
              if (widget.onSelect != null)
                widget.onSelect!(widget.mediaItems[index]),
            },
            minVerticalPadding: Dimens.marginShort * 2,
            leading:
                Text('${index + 1}', style: selected ? boldText : bodyStyle),
            title: Text(
              widget.mediaItems[index].title ?? '',
              style: selected ? boldText : bodyStyle,
            ),
            subtitle: _Subtitle(
              producer: widget.mediaItems[index].performer ?? '',
              album: widget.mediaItems[index].copyright,
              selected: selected,
            ),
          );
        },
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  final String producer;
  final String? album;
  final bool selected;
  const _Subtitle({
    required this.producer,
    required this.album,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Theme.of(context).textTheme.titleSmall!.color!.withAlpha(180),
          fontFamily: 'Noto',
          fontSize: 16,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          producer,
          maxLines: 2,
          style: selected
              ? subtitleStyle.copyWith(fontWeight: FontWeight.bold)
              : subtitleStyle,
        ),
        album != null && album!.isNotEmpty
            ? Text(
                album!,
                style: selected
                    ? subtitleStyle
                        .copyWith(fontWeight: FontWeight.bold)
                        .copyWith(fontStyle: FontStyle.italic)
                    : subtitleStyle.copyWith(fontStyle: FontStyle.italic),
              )
            : Container(),
      ],
    );
  }
}
