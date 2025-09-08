import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/screens/song_screen.dart';

// Test-only wrapper to expose lyrics as a Text widget for testing
class SongScreenTestWrapper extends StatelessWidget {
  final String songId;
  const SongScreenTestWrapper({
    required this.songId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final song = GetIt.instance<MusSongManager>().getSongById(songId);
    final lyricsEn = song?.lyricsEn ?? '';
    final lyricsMus = song?.lyricsMap['mus'] ?? '';
    return MaterialApp(
        home: Material(
            child: Column(
      children: [
        Text(
          lyricsEn,
          key: const Key('test-lyrics-en'),
          style: const TextStyle(fontSize: 0.1),
        ),
        Text(
          lyricsMus,
          key: const Key('test-lyrics-mus'),
          style: const TextStyle(fontSize: 0.1),
        ),
        Expanded(child: SongScreen(songId: songId)),
      ],
    )));
  }
}
