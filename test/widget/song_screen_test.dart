import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/language_config.dart';
import 'package:mvskoke_hymnal/ui/song/song_screen.dart';
import 'package:mvskoke_hymnal/services/store_service.dart';
import 'package:mvskoke_hymnal/ui/song/bottom_action_bar.dart';
import 'song_screen_mocks.dart';
import 'song_screen_test_helpers.dart';

void configureTestView(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() {
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<MusSongManager>()) {
      getIt.registerSingleton<MusSongManager>(
        MockSongManager(
          songsService: MockSongsService(
              storeService: MockStoreService(), webService: null),
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

  testWidgets('SongScreen displays song content', (WidgetTester tester) async {
    configureTestView(tester);
    await tester.pumpWidget(
      SongScreenTestWrapper(
        songId: '123',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Test Song (Mvskoke)'), findsWidgets);
    final lyricsText =
        tester.widget<Text>(find.byKey(const Key('test-lyrics-mus'))).data!;
    final lyricsTextEn =
        tester.widget<Text>(find.byKey(const Key('test-lyrics-en'))).data!;
    expect(lyricsText, contains(MockSongManager.exampleMusLyrics));
    expect(lyricsTextEn, contains(MockSongManager.exampleEnLyrics));
    expect(find.byType(BottomActionBar), findsOneWidget);
  });

  testWidgets('SongScreen handles scrolling behavior', (
    WidgetTester tester,
  ) async {
    configureTestView(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: SongScreen(songId: '123'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0.0, -300.0),
    );
    await tester.pumpAndSettle();
  });
}
