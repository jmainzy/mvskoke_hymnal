import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/managers/audio_manager.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/notifiers/progress_notifier.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/ui/song/bottom_action_bar.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:song_manager/models/enums.dart';

/// Displays inline audio player
class MiniAudioWidget extends StatefulWidget {
  final MediaItem mediaItem;

  const MiniAudioWidget({
    required this.mediaItem,
    super.key,
  });

  @override
  State<MiniAudioWidget> createState() => _MiniAudioWidgetState();
}

class _MiniAudioWidgetState extends State<MiniAudioWidget> {
  Logger logger = Logger();

  Future<void>? initAudioFuture;
  late MediaItem currentMedia;

  @override
  void initState() {
    super.initState();
    currentMedia = widget.mediaItem;
  }

  Future<void> initializeAudio() async {
    var (Uri uri, AssetLocation location) =
        await sl<MusSongManager>().getAudioUri(currentMedia);
    if (!mounted) return;
    initAudioFuture = sl<AudioManager>().setMedia(
      uri,
      location: location,
      id: currentMedia.id,
      title: currentMedia.title ?? '',
      album: 'Nak-cokv Esyvhiketv',
    );
    setState(() {});
    return;
  }

  @override
  Widget build(BuildContext context) {
    // final dm = sl<DownloadManager>();
    // final filename = widget.mediaItem?.filename;

    return Material(
        child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
                padding: EdgeInsetsGeometry.only(right: Dimens.marginShort),
                child: initAudioFuture != null
                    ? FutureBuilder<void>(
                        future: initAudioFuture,
                        builder: (context, snapshot) {
                          return Column(
                            children: [
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) ...[
                                const _LoadingWidget(),
                              ] else if (snapshot.hasError) ...[
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: Dimens.marginLarge),
                                      child: Icon(Icons.error),
                                    ),
                                  ],
                                )
                              ] else ...[
                                _PlayerControls(),
                              ],
                            ],
                          );
                        })
                    : _UnloadedWidget(onPressed: () {
                        initializeAudio();
                      }))));
  }

  @override
  void dispose() {
    sl<AudioManager>().stop();
    super.dispose();
  }
}

class _UnloadedWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const _UnloadedWidget({required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      IconButton(
          onPressed: () => onPressed.call(),
          icon: Icon(
            Icons.play_arrow,
          )),
      Expanded(child: LinearProgressIndicator(value: 0))
    ]);
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Padding(
          padding: EdgeInsetsGeometry.all(15.0),
          child: Icon(
            Icons.play_arrow,
            color: Colors.grey,
          )),
      Expanded(child: LinearProgressIndicator())
    ]);
  }
}

class _PlayerControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final audioManager = sl<AudioManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: audioManager.progressNotifier,
      builder: (context, value, child) {
        return Row(
          children: [
            PlayButton(),
            Expanded(
              child: ProgressBar(
                progress: value.current,
                buffered: value.buffered,
                total: value.total,
                onSeek: audioManager.seek,
                timeLabelLocation: TimeLabelLocation.sides,
                timeLabelTextStyle: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(fontFamily: 'Noto'),
              ),
            ),
          ],
        );
      },
    );
  }
}
