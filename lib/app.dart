import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/services/navigation_helper.dart';

Logger log = Logger();

class MyApp extends StatefulWidget {
  /// Indicates if the app is running in `device_preview` mode
  final bool isPreviewMode;

  const MyApp({super.key, this.isPreviewMode = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mvskoke Hymnal',
      theme: theme,
      debugShowCheckedModeBanner: false,
      routerConfig: NavigationHelper.router,
    );
  }
}

final theme = ThemeData(
    useMaterial3: true,

    // Define the default brightness and colors.
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 193, 153, 52),
      brightness: Brightness.light,
    ),
    textTheme: Typography.blackHelsinki);
