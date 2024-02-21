import 'dart:async';

import 'package:mvskoke_hymnal/bootstrap.dart';
import 'app.dart';

Future<void> main() async {
  bootstrap(
    () async {
      return const MyApp();
    },
  );
}
