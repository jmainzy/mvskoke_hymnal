import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/managers/audio_manager.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/notifiers/play_button_notifier.dart';
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
                    mediaItems: mediaItems,
                    songId: widget.song.id,
                    onClose: _closeAudio,
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
          SizedBox(
            width: 100,
            child: IconButton(
                onPressed: widget.showSettings,
                icon: const Icon(Icons.format_size)),
          ),
          _isPlayingAudio
              ? PlayButton()
              : IconButton(
                  onPressed: mediaItems.isEmpty ? null : _playAudio,
                  disabledColor: Colors.grey,
                  icon: Icon(
                    Icons.play_arrow,
                  )),
          SizedBox(
              width: 100,
              child: TextButton(
                  onPressed: () => {widget.onToggleEnglish(!showEnglish)},
                  child: Text(
                    showEnglish ? "Hide English" : "Show English",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: Colors.black),
                  ))),
        ],
      ),
    );
  }

  BoxDecoration get decoration {
    return BoxDecoration(
      color: Colors.grey.shade800.withAlpha(90),
      borderRadius: BorderRadius.circular(10),
    );
  }

  void _playAudio() {
    setState(() {
      _isPlayingAudio = true;
    });
  }

  void _closeAudio() {
    setState(() {
      _isPlayingAudio = false;
    });
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});
  @override
  Widget build(BuildContext context) {
    final pageManager = sl<AudioManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.playingLoading:
          case ButtonState.pausedLoading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: const CircularProgressIndicator(),
            );
          case ButtonState.completed:
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(Icons.pause),
              onPressed: pageManager.pause,
            );
        }
      },
    );
  }
}
