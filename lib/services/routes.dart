import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvskoke_hymnal/ui/song/song_screen.dart';

import '../ui/home/home_screen.dart';

final routes = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  errorPageBuilder: (context, state) {
    return MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.error.toString(),
              ),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text(
                  'Go to Home page',
                ),
              )
            ],
          ),
        ),
      ),
    );
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'songs/:songId',
          pageBuilder: (context, state) {
            final id = state.pathParameters['songId'];
            if (id == null) {
              throw Exception('Invalid entity id');
            }
            return MaterialPage(
              key: state.pageKey,
              child: SongScreen(
                songId: id,
              ),
            );
          },
        ),
      ],
    ),
  ],
);
