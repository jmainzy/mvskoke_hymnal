import 'package:song_manager/models/language_config.dart';

/// Languages available for the app.  Not a service, just a list.
/// For the state, use `LanguageState`.
class LanguageConfig extends LanguageConfigBase {
  @override
  Map<String, String> get codeMap => {
        "mus": "Mvskoke",
        "en": "English",
      };
}
