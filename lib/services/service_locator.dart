import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/managers/glossary_manager.dart';
import 'package:mvskoke_hymnal/managers/playlist_manager.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/language_config.dart';
import 'package:mvskoke_hymnal/services/config_service.dart';
import 'package:mvskoke_hymnal/services/playlist_service.dart';
import 'package:mvskoke_hymnal/services/songs_service.dart';

import 'store_service.dart';

final sl = GetIt.instance;

Logger log = Logger();

Future<void> setupServiceLocator({required Box box}) async {
  // declare
  final storeService = MusStoreService(box);
  final songService = MusSongService(
    storeService: storeService,
    webService: null,
  );

  // services
  sl.registerSingleton<MusStoreService>(storeService);
  sl.registerSingleton<ConfigService>(ConfigService());
  sl.registerSingleton<MusSongService>(songService);
  sl.registerSingleton<PlaylistService>(PlaylistService());

  // managers
  sl.registerSingleton<MusSongManager>(
    MusSongManager(songsService: songService, languageConfig: LanguageConfig()),
  );
  sl.registerSingleton<PlaylistManager>(PlaylistManager());
  sl.registerSingletonAsync(() => GlossaryManager().init());
}
