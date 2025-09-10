import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/ui/more/about_screen.dart';
import 'package:mvskoke_hymnal/ui/more/alphabet_screen.dart';
import 'package:mvskoke_hymnal/ui/more/glossary_screen.dart';
import 'package:mvskoke_hymnal/ui/home/home_screen.dart';
import 'package:mvskoke_hymnal/ui/more/more_screen.dart';
import 'package:mvskoke_hymnal/ui/more/prayer_screen.dart';
import 'package:mvskoke_hymnal/ui/playlist/playlist_details.dart';
import 'package:mvskoke_hymnal/ui/playlist/playlist_screen.dart';
import 'package:mvskoke_hymnal/ui/song/song_screen.dart';

Logger log = Logger();

class NavigationHelper {
  static final NavigationHelper _instance = NavigationHelper._internal();

  static late final GoRouter router;

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> homeTabNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> playlistTabNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> moreTabNavigatorKey =
      GlobalKey<NavigatorState>();

  BuildContext get context =>
      router.routerDelegate.navigatorKey.currentContext!;

  GoRouterDelegate get routerDelegate => router.routerDelegate;

  GoRouteInformationParser get routeInformationParser =>
      router.routeInformationParser;

  static const String homePath = '/';
  static const String playlistPath = '/playlist';
  static const String songsPath = '/songs';
  static const String aboutPath = 'about';
  static const String morePath = '/more';
  static const String glossaryPath = 'glossary';
  static const String alphabetPath = 'appendix';
  static const String prayerPath = 'prayer';

  static NavigationHelper get instance => _instance;
  factory NavigationHelper() {
    return _instance;
  }

  NavigationHelper._internal() {
    final routes = [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        branches: [
          StatefulShellBranch(
            navigatorKey: homeTabNavigatorKey,
            routes: [
              GoRoute(
                path: homePath,
                pageBuilder: (context, state) {
                  return MaterialPage(
                    key: state.pageKey,
                    child: const HomeScreen(),
                  );
                },
                routes: [
                  GoRoute(
                    path: '$songsPath/:songId',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['songId'];
                      if (id == null) {
                        throw Exception('Invalid entity id');
                      } else {
                        log.i('navvy song id: $id');
                      }
                      return MaterialPage(
                        key: state.pageKey,
                        child: SongScreen(songId: id),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: '$songsPath/:songId',
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final id = state.pathParameters['songId'];
                          if (id == null) {
                            throw Exception('Invalid entity id');
                          } else {
                            log.i('navvy song id: $id');
                          }
                          return MaterialPage(
                            key: state.pageKey,
                            child: SongScreen(songId: id),
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: playlistTabNavigatorKey,
            routes: [
              GoRoute(
                path: playlistPath,
                pageBuilder: (context, state) {
                  return MaterialPage(
                    key: state.pageKey,
                    child: const PlaylistScreen(),
                  );
                },
                routes: [
                  GoRoute(
                    path: '/:playlistId',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['playlistId'];
                      if (id == null) {
                        throw Exception('Invalid playlist id');
                      }
                      return MaterialPage(
                        key: state.pageKey,
                        child: PlaylistDetails(playlistId: id),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: 'accept',
                        pageBuilder: (context, state) {
                          final id = state.pathParameters['playlistId'];
                          if (id == null) {
                            throw Exception('Invalid short id');
                          }
                          return MaterialPage(
                            key: state.pageKey,
                            child: const PlaylistScreen(
                                // shortId: id,
                                ),
                          );
                        },
                      ),
                      GoRoute(
                        path: '$songsPath/:songId',
                        parentNavigatorKey: rootNavigatorKey,
                        pageBuilder: (context, state) {
                          final songId = state.pathParameters['songId'];
                          final playlistId = state.pathParameters['playlistId'];
                          if (songId == null) {
                            throw Exception('Invalid song id');
                          }
                          return MaterialPage(
                            key: state.pageKey,
                            child: SongScreen(
                              playlistId: playlistId,
                              songId: songId,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: moreTabNavigatorKey,
            routes: [
              GoRoute(
                  path: morePath,
                  pageBuilder: (context, state) {
                    return MaterialPage(
                      child: const MoreScreen(),
                      key: state.pageKey,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: aboutPath,
                      pageBuilder: (context, state) {
                        return MaterialPage(
                          child: const AboutScreen(),
                          key: state.pageKey,
                        );
                      },
                    ),
                    GoRoute(
                      path: glossaryPath,
                      pageBuilder: (context, state) {
                        return MaterialPage(
                          child: const GlossaryScreen(),
                          key: state.pageKey,
                        );
                      },
                    ),
                    GoRoute(
                      path: alphabetPath,
                      pageBuilder: (context, state) {
                        return MaterialPage(
                          child: AlphabetScreen(),
                          key: state.pageKey,
                        );
                      },
                    ),
                    GoRoute(
                      path: prayerPath,
                      pageBuilder: (context, state) {
                        return MaterialPage(
                          child: PrayerScreen(),
                          key: state.pageKey,
                        );
                      },
                    ),
                  ]),
            ],
          ),
        ],
        pageBuilder: (context, state, navigationShell) {
          return MaterialPage(
            child: NavigationPage(child: navigationShell),
            key: state.pageKey,
          );
        },
      ),
    ];

    router = GoRouter(
      debugLogDiagnostics: true,
      initialLocation: homePath,
      navigatorKey: rootNavigatorKey,
      errorPageBuilder: (context, state) {
        return MaterialPage(
          key: state.pageKey,
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error.toString()),
                  TextButton(
                    onPressed: () => context.go(homePath),
                    child: const Text('Go to Home page'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      routes: routes,
    );
  }
}

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key, required this.child});

  final StatefulNavigationShell child;

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          widget.child.goBranch(
            index,
            initialLocation: index == widget.child.currentIndex,
          );
          setState(() {});
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        selectedIndex: widget.child.currentIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.list), label: 'Collections'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'About'),
        ],
      ),
      body: widget.child,
    );
  }
}
