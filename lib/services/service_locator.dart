import 'package:get_it/get_it.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/services/config_service.dart';

final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  sl.registerSingleton<ConfigService>(ConfigService());

  // managers
  sl.registerLazySingleton(() => SongManager());
}
