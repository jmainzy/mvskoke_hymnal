import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/services/store_service.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/utilities/extensions.dart';
import 'package:mvskoke_hymnal/widgets/audio_player_widget.dart';

class BottomActionBar extends StatefulWidget {
  final Function(bool enabled) onToggleEnglish;
  final Function() showSettings;
  final SongModel song;

  const BottomActionBar({
    required this.onToggleEnglish,
    required this.showSettings,
    required this.song,
    super.key,
  });

  @override
  BottomActionBarState createState() => BottomActionBarState();
}

class BottomActionBarState extends State<BottomActionBar> {
  Logger logger = Logger();
  bool _isPlayingAudio = false;
  bool showEnglish = true;
  List<MediaItem> mediaItems = [];

  @override
  void initState() {
    sl<MusSongManager>()
        .getMediaItems(int.parse(widget.song.songNumber).toString())
        .then((items) {
      logger.i("media items: $items");
      setState(() {
        mediaItems = items;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    showEnglish = sl<MusStoreService>().get<bool>('show_english') ?? true;
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Material(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _isPlayingAudio
                ? AudioPlayerWidget(
                    mediaItem: mediaItems.isNotEmpty ? mediaItems.first : null,
                    songId: widget.song.id,
                    onClose: _closeAudio,
                    openAudioSelector: _openAudioSelector,
                  )
                : Container(),
            _bottomBar
          ]),
        ));
    // return
  }

  bool get isPlaying => _isPlayingAudio;

  double get height {
    const baseHeight = 60.0;
    const audioHeight = 96.0;

    double height = 0;

    if (_isPlayingAudio) {
      height = height + audioHeight;
    }

    return baseHeight + height;
  }

  double get width {
    return min(context.width - 32, 300 * (16 / 9) - 72);
  }

  Widget get _bottomBar {
    return Ink(
      padding: const EdgeInsets.symmetric(vertical: Dimens.marginShort),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              onPressed: widget.showSettings,
              icon: const Icon(Icons.format_size)),
          IconButton(
              onPressed: _playAudio,
              icon: Icon(
                Icons.play_circle,
                color: Theme.of(context).colorScheme.onSurface,
              )),
          TextButton(
              onPressed: () => {widget.onToggleEnglish(!showEnglish)},
              child: Text(
                showEnglish ? "Hide English" : "Show English",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: Colors.black),
              )),
        ],
      ),
    );
  }

  VoidCallback get _openAudioSelector {
    return () {
      // Show audio selection dialog
    };
  }

  BoxDecoration get decoration {
    return BoxDecoration(
      color: Colors.grey.shade800.withAlpha(90),
      borderRadius: BorderRadius.circular(10),
    );
  }

  void _playAudio() {
    _isPlayingAudio = true;
    logger.i("open audio");
    setState(() {});
  }

  void _closeAudio() {
    _isPlayingAudio = false;
    setState(() {});
  }
}
