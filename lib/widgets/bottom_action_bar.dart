import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/models/enums.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/utilities/extensions.dart';
import 'package:mvskoke_hymnal/widgets/audio_player.dart';

class BottomActionBar extends StatefulWidget {
  final Function(bool enabled) onToggleEnglish;
  final SongModel song;
  final bool showEnglish;

  const BottomActionBar({
    required this.onToggleEnglish,
    required this.song,
    required this.showEnglish,
    Key? key,
  }) : super(key: key);

  @override
  _BottomActionBarState createState() => _BottomActionBarState();
}

class _BottomActionBarState extends State<BottomActionBar> {
  Logger logger = Logger();
  bool _isPlayingAudio = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _isPlayingAudio ? _audioPlayer : Container(),
            _closedMenu,
          ],
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

  Widget get _closedMenu {
    return SizedBox(
        height: 60,
        child: Material(
            elevation: 3,
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: Dimens.marginShort),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: _playAudio,
                      icon: Icon(
                        Icons.play_circle,
                        color: Theme.of(context).colorScheme.onSurface,
                      )),
                  TextButton(
                      onPressed: () =>
                          {widget.onToggleEnglish(!widget.showEnglish)},
                      child: Text(
                        widget.showEnglish ? "Hide English" : "Show English",
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(color: Colors.black),
                      )),
                ],
              ),
            )));
  }

  Widget get _audioPlayer {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: AudioPlayerWidget(audioUrl: widget.song.audioUrl!),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: SizedBox(
            height: 36,
            width: 36,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: _closeAudio,
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration get decoration {
    return BoxDecoration(
      color: Colors.grey.shade800.withOpacity(0.9),
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
