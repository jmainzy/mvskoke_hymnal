import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/language_config.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/services/store_service.dart';
import 'package:mvskoke_hymnal/ui/home/song_subtitle.dart';
import 'package:mvskoke_hymnal/ui/home/song_tile.dart';

import 'song_screen_mocks.dart';

void main() {
  setUp(() {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<MusSongManager>()) {
      getIt.registerSingleton<MusSongManager>(
        MockSongManager(
          songsService: MockSongsService(),
          languageConfig: LanguageConfig(),
        ),
      );
    }
    if (!getIt.isRegistered<MusStoreService>()) {
      getIt.registerSingleton<MusStoreService>(MockStoreService());
    }
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    GetIt.instance.reset();
  });
  testWidgets('SongTile displays song title and metadata', (
    WidgetTester tester,
  ) async {
    String? tappedId;
    final song = SongModel(
      id: '123',
      songNumber: '1',
      titles: {
        "mus": "Esyvhiketv",
        "en": "Test Title",
      },
      audioUrl: "test.mp3",
      tags: [],
      related: [],
      lyricsMap: {},
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.light(),
          textTheme: TextTheme(
            bodyLarge: TextStyle(),
            bodySmall: TextStyle(fontFamily: 'Noto'),
          ),
        ),
        home: Material(
          child: SongTile(
            song: song,
            subtitle: 'Test Subtitle',
            onTap: (String id) {
              tappedId = id;
            },
          ),
        ),
      ),
    );

    expect(find.byType(SongTile), findsOneWidget);

    // Verify primary song title is displayed
    expect(find.text('Esyvhiketv'), findsOneWidget);

    // Verify song number
    expect(find.text('1'), findsOneWidget);

    // Find SongSubtitle
    final songSubtitleFinder = find.byType(SongSubtitle);
    expect(songSubtitleFinder, findsOneWidget);

    // Verify audio icon is present when audioUrl is set
    // expect(find.byIcon(Icons.music_note), findsOneWidget);

    // Tap the tile and verify callback
    await tester.tap(find.byType(SongTile));
    expect(tappedId, equals('123'));
  });
}
