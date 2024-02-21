import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chord/flutter_chord.dart';
import 'package:flutter_guitar_tabs/flutter_guitar_tabs.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:mvskoke_hymnal/models/enums.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/utilities/extensions.dart';
import 'package:mvskoke_hymnal/utilities/utils.dart';
import 'package:mvskoke_hymnal/widgets/bottom_action_bar.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';

enum LyricsLanguage { roman, nepali }

class SongScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  final String songId;
  final String? playlistId;

  SongScreen({
    Key? key,
    required this.songId,
    this.playlistId,
  }) : super(key: key);

  @override
  SongScreenState createState() => SongScreenState();
}

class SongScreenState extends State<SongScreen> with GetItStateMixin {
  bool showEnglish = true;

  int transposeIncrement = 0;
  double scrollSpeed = 10;
  bool scrollEnabled = false;

  PageController? _pageController;
  SongModel? currentSong;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    showEnglish = sl<SongManager>().showEnglishLyrics;
    currentSong = sl<SongManager>().getSongById(widget.songId);

    if (currentSong == null) {
      loading = true;
      setState(() {});
      await Future.delayed(const Duration(seconds: 5));
      log('after 5 seconds');
      currentSong = sl<SongManager>().getSongById(widget.songId);
      loading = false;
      setState(() {});
    }

    if (currentSong == null) return;

    // WakelockPlus.enable();
  }

  @override
  void dispose() {
    // WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (currentSong == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Song not found'),
              ElevatedButton(
                onPressed: () async {
                  await initialize();
                  setState(() {});
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final lyrics = getLyrics(currentSong!);
    Widget body = getBody(lyrics, "L.M. Prayer Hymn");

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          // title:Text.rich(
          //   TextSpan(text: currentSong?.titles[0] ?? ''),
          //   style: Theme.of(context)
          //       .textTheme
          //       .headlineMedium!
          //       .copyWith(color: Theme.of(context).colorScheme.onPrimary)
          //       .apply(fontWeightDelta: 2),
          //   textScaleFactor: 0.5,
          // ),
          ),
      body: body,
      bottomNavigationBar: BottomActionBar(
        scrollSpeed: scrollSpeed,
        scrollEnabled: scrollEnabled,
        onEnableAutoScroll: (enabled) {
          setState(() {
            scrollEnabled = enabled;
          });
        },
        onChangeAutoScroll: (speed) {
          scrollSpeed = speed;
          setState(() {});
        },
        song: currentSong!,
      ),
    );
  }

  void _onChangeTranspose(Direction direction) {
    transposeIncrement += direction == Direction.up ? 1 : -1;
    setState(() {});
  }

  String getLyrics(SongModel song) {
    return song.mus_lyrics ?? '';
  }

  Widget getBody(
    String? lyrics,
    String? description,
  ) {
    double fontSize = 16.0;
    return (lyrics == null)
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.marginLarge, 0, Dimens.marginLarge, 0),
            child: LyricsRenderer(
              lyrics: lyrics,
              textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Roboto',
                    fontSize: (fontSize + (showEnglish ? 8 : 0)).toDouble(),
                  ),
              chordStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: (fontSize - 3).toDouble(),
                  color: Theme.of(context).colorScheme.primary),
              onTapChord: _showChordImage,
              scrollSpeed: scrollEnabled ? scrollSpeed.toInt() : 0,
              transposeIncrement: transposeIncrement,
              widgetPadding: 24,
              horizontalAlignment: CrossAxisAlignment.start,
              trailingWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description != null && description.isNotEmpty)
                    Container(
                      child: Text(description,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey)),
                    ),
                  SizedBox(height: 245 + context.padding.bottom)
                ],
              ),
              leadingWidget: Column(
                children: [
                  const SizedBox(
                    height: Dimens.marginLarge,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(
                              currentSong?.titles[0],
                              style: Theme.of(context).textTheme.headlineSmall!,
                            ),
                            Text(
                              currentSong?.titles[1],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.grey),
                            ),
                            const SizedBox(
                              height: Dimens.marginShort,
                            ),
                            Text(
                              currentSong?.songNumber ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.grey),
                            ),
                          ])),
                      const SizedBox(width: 20),
                      const SizedBox(width: Dimens.marginLarge),
                    ],
                  ),
                  const SizedBox(
                    height: Dimens.marginLarge,
                  ),
                  const Divider(),
                ],
              ),
              lineHeight: 0,
            ));
  }

  void _showChordImage(String chord) {
    final regex = RegExp(
      r'\b([CDEFGAB](?:b|bb)*(?:#|##|sus|maj|m|aug)*[\d\/]*(?:[CDEFGAB](?:b|bb)*(?:#|##|sus|maj|min|aug)*[\d\/]*)*)(?=\s|$)(?! \w)',
    );
    // if regex matches
    if (!regex.hasMatch(chord.split('/')[0])) {
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        enableDrag: false,
        builder: (context) {
          Widget child = getChordWidget(chord);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: child),
          );
        },
      ),
    );
  }

  Widget getChordWidget(String chord) {
    final height = MediaQuery.of(context).size.height;
    final isSmall = height < 800;
    final chordList = chord.split('/');
    if (chordList.length == 1) {
      final tabs = Utils.getChordTabs(chord);
      if (tabs == null) {
        return Text(
          'Chord not found: ${chordList[0]}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      }

      return Transform.scale(
        scale: isSmall ? 1 : 2,
        child: FlutterGuitarTab(
          name: chordList[0],
          tab: tabs,
          showStartFretNumber: true,
          color: Theme.of(context).colorScheme.primary,
          size: 10,
        ),
      );
    }

    return Wrap(
      children: chordList.map((e) {
        final tabs = Utils.getChordTabs(e);
        if (tabs == null) {
          return Text(
            'Chord not found: $e',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        return FlutterGuitarTab(
          name: e,
          tab: tabs,
          showStartFretNumber: true,
          color: Theme.of(context).colorScheme.primary,
          size: isSmall ? 8 : 10,
        );
      }).toList(),
    );
  }
}
