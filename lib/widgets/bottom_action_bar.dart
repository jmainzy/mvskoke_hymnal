import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/models/enums.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/utilities/extensions.dart';
import 'package:mvskoke_hymnal/widgets/audio_player.dart';

class BottomActionBar extends StatefulWidget {
  final double scrollSpeed;
  final bool scrollEnabled;
  final Function(bool enabled) onEnableAutoScroll;
  final Function(double speed) onChangeAutoScroll;
  final SongModel song;

  const BottomActionBar({
    required this.scrollSpeed,
    required this.scrollEnabled,
    required this.onChangeAutoScroll,
    required this.onEnableAutoScroll,
    required this.song,
    Key? key,
  }) : super(key: key);

  @override
  _BottomActionBarState createState() => _BottomActionBarState();
}

class _BottomActionBarState extends State<BottomActionBar> {
  Logger logger = Logger();
  bool _isBusy = false;
  bool _isPlayingVideo = false;
  bool _isPlayingAudio = false;
  bool _showSpeedControl = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _isPlayingAudio ? _audioPlayer : Container(),
            _showSpeedControl ? _openMenu : Container(),
            _closedMenu,
          ],
        )
    );
    // return
  }

  bool get isPlaying => _isPlayingVideo || _isPlayingAudio;

  double get height {
    final baseHeight = 60.0;
    final audioHeight = 96.0;
    final speedHeight = 80;

    double height = 0;

    if (_isPlayingAudio) {
      height = height + audioHeight;
    }

    if (_showSpeedControl) {
      height = height + speedHeight;
    }

    if (_isPlayingVideo) {
      return min(width * (9 / 16) + 40, 300);
    }

    return baseHeight + height;
  }

  double get width {
    return min(context.width - 32, 300 * (16 / 9) - 72);
  }


  Widget get _closedMenu {
    return Container(
      height: 60,
        child: Material(
        elevation: 3,
        child: Ink(
          padding: EdgeInsets.symmetric(vertical: Dimens.marginShort),
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
              IconButton(
                  onPressed: () =>
                      {widget.onEnableAutoScroll(!widget.scrollEnabled)},
                  icon: Icon(
                    Icons.text_rotate_vertical,
                    color: widget.scrollEnabled
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  )),
              IconButton(
                  onPressed: () => _toggleSpeedMenu(),
                  icon: Icon(
                    Icons.speed,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
            ],
          ),
        )));
  }

  _toggleSpeedMenu() {
    setState(() {
      _showSpeedControl = !_showSpeedControl;
    });
  }

  Widget get _openMenu {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    'Auto Scroll Speed',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                      value: widget.scrollSpeed / 100,
                      onChanged: (value) =>
                          widget.onChangeAutoScroll(value * 100)),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 0,
          top: 0,
          child: SizedBox(
            height: 36,
            width: 36,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: _toggleSpeedMenu,
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ],
    );
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
