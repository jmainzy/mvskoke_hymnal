import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/widgets/bottom_action_bar.dart';
import 'package:mvskoke_hymnal/widgets/lyrics_renderer.dart';
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (currentSong == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
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
      body: LyricsRenderer(
          title: currentSong!.titles[0],
          subtitle: currentSong!.titles[1],
          musLyrics: currentSong!.lyrics,
          enLyrics: currentSong!.lyricsEn,
          showEnglish: showEnglish,
          footer: const Padding(
              padding: EdgeInsets.all(Dimens.marginLarge),
              child: Text("L.M. Prayer Hymn"))),
      bottomNavigationBar: BottomActionBar(
        onToggleEnglish: (value) {
          sl<SongManager>().setShowEnglishLyrics(value);
          setState(() {
            showEnglish = value;
          });
        },
        song: currentSong!,
        showEnglish: showEnglish,
      ),
    );
  }
}
