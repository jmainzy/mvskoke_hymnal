import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mvskoke_hymnal/services/config_service.dart';
import 'package:mvskoke_hymnal/services/routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.isPreviewMode = false,
  });

  /// Indicates if the app is running in `device_preview` mode
  final bool isPreviewMode;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider(
            create: (context) => ConfigService(),
          ),
        ],
        child: MaterialApp.router(
          title: 'Nak-cokv Esyvhiketv',
          theme: ThemeData(colorScheme: lightTheme),
          debugShowCheckedModeBanner: false,
          routeInformationProvider: routes.routeInformationProvider,
          routeInformationParser: routes.routeInformationParser,
          routerDelegate: routes.routerDelegate,
        ));
  }
}

const lightTheme = ColorScheme.light(
  primary: Colors.green,
  background: Color(0xfff9f9f9),
  surface: Colors.white,
  onBackground: Colors.black87,
  onSurface: Colors.black87,
);
