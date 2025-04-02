import 'dart:math';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/utilities/extensions.dart';

class BottomActionBar extends StatefulWidget {
  final double scrollSpeed;
  final bool scrollEnabled;
  final Function(bool enabled) onEnableAutoScroll;
  final Function(double speed) onChangeAutoScroll;
  final List<MediaItem>? mediaItems;
  final String songId;

  const BottomActionBar({
    required this.scrollSpeed,
    required this.scrollEnabled,
    required this.onChangeAutoScroll,
    required this.onEnableAutoScroll,
    required this.mediaItems,
    required this.songId,
    super.key,
  });

  @override
  BottomActionBarState createState() => BottomActionBarState();
}

class BottomActionBarState extends State<BottomActionBar> {
  Logger logger = Logger();
  final bool _isPlayingVideo = false;
  bool _isPlayingAudio = false;
  bool _showSpeedControl = false;
  MediaItem? selectedMedia;

  @override
  void initState() {
    _getdefaultMediaItem();
    super.initState();
  }

  void _getdefaultMediaItem() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      selectedMedia = widget.mediaItems!.firstOrNull;
      setState(() {});
    });
  }

  void _selectMedia(MediaItem item) {
    logger.i('Selected media item: ${item.id}');
    if (item.id == selectedMedia!.id) {
      return;
    } else {
      selectedMedia = item;
      logger.i('Selecting new media item: ${item.id}');
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          _showSpeedControl ? _openMenu : Container(),
          _bottomBar,
        ],
      ),
    );
    // return
  }

  bool get isPlaying => _isPlayingVideo || _isPlayingAudio;

  double get width {
    return min(context.width - 32, 300 * (16 / 9) - 72);
  }

  Widget get _bottomBar {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Ink(
          padding: EdgeInsets.fromLTRB(
            0,
            Dimens.marginShort,
            0,
            MediaQuery.of(context).padding.bottom + Dimens.marginShort,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // IconButton(
              //   onPressed:
              //       widget.mediaItems != null && widget.mediaItems!.isNotEmpty
              //           ? (isPlaying ? _closeAudio : _playAudio)
              //           : null,
              //   color: Theme.of(context).colorScheme.onSurface,
              //   disabledColor: Theme.of(
              //     context,
              //   ).colorScheme.onSurface.withAlpha((255 / 3).toInt()),
              //   icon: const Icon(Icons.play_circle),
              // ),
              IconButton(
                onPressed: () =>
                    {widget.onEnableAutoScroll(!widget.scrollEnabled)},
                icon: Icon(
                  Icons.text_rotate_vertical,
                  color: widget.scrollEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                onPressed: () => _toggleSpeedMenu(),
                icon: Icon(
                  Icons.speed,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
                  Padding(
                    padding: const EdgeInsets.only(top: Dimens.marginShort),
                    child: Text(
                      'Auto Scroll Speed',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Slider(
                    value: widget.scrollSpeed / 100,
                    onChanged: (value) =>
                        widget.onChangeAutoScroll(value * 100),
                  ),
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

  BoxDecoration get decoration {
    return BoxDecoration(
      color: Colors.black87,
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
