import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/managers/audio_manager.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/notifiers/play_button_notifier.dart';
import 'package:mvskoke_hymnal/notifiers/progress_notifier.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:marquee/marquee.dart';
import 'package:mvskoke_hymnal/ui/song/media_selector_widget.dart';
import 'package:song_manager/models/enums.dart';

class AudioPlayerWidget extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final String songId;
  final VoidCallback? onClose;

  const AudioPlayerWidget({
    required this.mediaItems,
    required this.songId,
    this.onClose,
    super.key,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  Logger logger = Logger();

  late Future<void> initAudioFuture;
  late MediaItem currentMedia;

  @override
  void initState() {
    super.initState();
    currentMedia = widget.mediaItems.first;
    initAudioFuture = initializeAudio();
  }

  Future<void> initializeAudio() async {
    var (Uri uri, AssetLocation location) =
        await sl<MusSongManager>().getAudioUri(currentMedia);
    logger.i("uri = $uri, location = $location");
    if (!mounted) return;
    await sl<AudioManager>().setMedia(
      uri,
      location: location,
      id: currentMedia.id,
      title: currentMedia.title ?? '',
      album: 'Nak-cokv Esyvhiketv',
    );
    logger.i('set media');
    sl<AudioManager>().play();
    return;
  }

  @override
  Widget build(BuildContext context) {
    // final dm = sl<DownloadManager>();
    // final filename = widget.mediaItem?.filename;

    return Material(
        child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: FutureBuilder<void>(
                future: initAudioFuture,
                builder: (context, snapshot) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: Dimens.marginShort),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: _openAudioSelector,
                                icon: const Icon(Icons.expand_less_rounded),
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.sizeOf(context).width / 1.6,
                                ),
                                child: _PlayerTitle(
                                  title: currentMedia.title ?? '',
                                  subtitle: currentMedia.performer,
                                ),
                              ),
                              // if (filename != null)
                              //   AnimatedBuilder(
                              //     animation: dm,
                              //     builder: (context, _) {
                              //       final task = dm.getTask(filename);
                              //       switch (task.state) {
                              //         case DownloadState.downloaded:
                              //           return IconButton(
                              //             icon: const Icon(
                              //               Icons.delete,
                              //               color: Colors.red,
                              //             ),
                              //             tooltip: 'Delete downloaded file',
                              //             onPressed: () => dm.deleteFile(filename),
                              //           );
                              //         case DownloadState.downloading:
                              //           return CircularProgressIndicator(
                              //             value: task.progress,
                              //           );
                              //         case DownloadState.failed:
                              //           return IconButton(
                              //             icon: const Icon(
                              //               Icons.error,
                              //               color: Colors.red,
                              //             ),
                              //             onPressed: () => dm.downloadFile(filename),
                              //           );
                              //         case DownloadState.notDownloaded:
                              //           return IconButton(
                              //             icon: const Icon(Icons.download),
                              //             onPressed: () => dm.downloadFile(filename),
                              //           );
                              //       }
                              //     },
                              //   ),

                              IconButton(
                                onPressed: widget.onClose,
                                icon: const Icon(Icons.close,
                                    color: Colors.black54),
                              ),
                            ],
                          ),
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
                      ));
                })));
  }

  @override
  void dispose() {
    sl<AudioManager>().stop();
    super.dispose();
  }

  void _openAudioSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => MediaSelectorWidget(
        mediaItems: widget.mediaItems,
        onSelect: (item) {
          Navigator.pop(context);
          _selectMedia(item);
        },
      ),
    );
  }

  void _selectMedia(MediaItem item) {
    logger.i('Selected media item: ${item.id}');
    if (item.id == currentMedia.id) {
      return;
    } else {
      logger.i('Selecting new media item: ${item.id}');
      setState(() {
        currentMedia = item;
      });
      initAudioFuture = initializeAudio();
    }
  }
}

class _PlayerTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _PlayerTitle({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimens.marginShort),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            title,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.start,
            minFontSize: Theme.of(context).textTheme.titleSmall!.fontSize! - 2,
            overflowReplacement: SizedBox(
              height: 50,
              child: Marquee(
                text: title,
                style: Theme.of(context).textTheme.titleSmall,
                scrollAxis: Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.start,
                blankSpace: Dimens.marginLarge * 2,
                pauseAfterRound: const Duration(seconds: 1),
                startPadding: Dimens.marginShort,
              ),
            ),
          ),
          subtitle != null
              ? AutoSizeText(
                  subtitle!,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontFamily: 'Noto',
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall!.color!.withAlpha(120),
                      ),
                )
              : Container(),
        ],
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.marginShort),
      child: LinearProgressIndicator(),
    );
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
            const SizedBox(width: Dimens.marginLarge),
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
            const SizedBox(width: Dimens.marginLarge),
          ],
        );
      },
    );
  }
}
