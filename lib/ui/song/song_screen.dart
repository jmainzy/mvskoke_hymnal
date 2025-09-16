import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/services/navigation_helper.dart';
import 'package:mvskoke_hymnal/services/store_service.dart';
import 'package:mvskoke_hymnal/ui/song/lyrics_renderer.dart';
import 'package:mvskoke_hymnal/ui/playlist/add_to_playlist_sheet.dart';
import 'package:mvskoke_hymnal/ui/song/settings_sheet.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/ui/song/bottom_action_bar.dart';
import 'package:mvskoke_hymnal/ui/song/song_header.dart';
import 'package:watch_it/watch_it.dart' hide sl;

Logger log = Logger();

class SongScreen extends WatchingStatefulWidget {
  final String songId;
  final String? playlistId;

  const SongScreen({super.key, required this.songId, this.playlistId});

  @override
  SongScreenState createState() => SongScreenState();
}

class SongScreenState extends State<SongScreen> {
  int transposeIncrement = 0;
  double scrollSpeed = 10;
  bool scrollEnabled = false;
  late Future<void> _loadingFuture;
  late bool showEnglish;

  SongModel? currentSong;
  List<MediaItem>? mediaItems;
  double fontScale = sl<MusStoreService>().fontScale;

  bool showChords = sl<MusStoreService>().get<bool>('show_chords') ?? true;

  late final ScrollController _scrollController;
  double scrollPosition = 0;

  @override
  void initState() {
    super.initState();
    _loadingFuture = initialize();
    _scrollController = ScrollController();
    log.i('init state song screen');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // executes after build
      _scrollController.addListener(() {
        setState(() {
          // scroll position as a percentage of the total scroll length
          scrollPosition = _scrollController.offset /
              _scrollController.position.maxScrollExtent *
              100;
        });
      });
    });
  }

  Future<void> initialize() async {
    final songManager = sl<MusSongManager>();
    currentSong = songManager.getSongById(widget.songId);
    showEnglish = sl<MusStoreService>().get<bool>('show_english') ?? true;

    if (currentSong == null) return;

    // WakelockPlus.enable();
  }

  @override
  void dispose() {
    // WakelockPlus.disable();
    super.dispose();
  }

  void showPlaylistSheet(String songId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return AddToPlaylistSheet(
          songId: songId,
          transposeIncrement: transposeIncrement,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentSong == null) {
      log.e('Didn\'t find song with id ${widget.songId}');
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(child: Text('Song not found')),
              ElevatedButton(
                onPressed: () async {
                  NavigationHelper.router.pop();
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    double getTitleOpacity(double scrollPosition) {
      const double fadeStart = 5;
      const double fadeEnd = 15;

      if (scrollPosition <= fadeStart) {
        return 0.0;
      } else if (scrollPosition >= fadeEnd) {
        return 1.0;
      } else {
        return (scrollPosition - fadeStart) / (fadeEnd - fadeStart);
      }
    }

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Opacity(
              opacity: getTitleOpacity(scrollPosition),
              child: Text.rich(
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                TextSpan(
                  text: currentSong?.title,
                ),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      height: 2,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              )),
          surfaceTintColor: Theme.of(context).colorScheme.primary,
          actions: [
            IconButton(
                onPressed: () => showSettings(context),
                icon: Icon(Icons.format_size)),
            IconButton(
                icon: const Icon(Icons.playlist_add),
                onPressed: () => showPlaylistSheet(widget.songId)),
          ],
        ),
        body: FutureBuilder(
            future: _loadingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        key: Key('error-loading-song'),
                        'Error loading song',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              } else {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimens.marginLarge),
                    child: LyricsRenderer(
                      header: SongHeader(
                        currentSong: currentSong,
                        fontScale: fontScale,
                        addToPlaylist: (songId) => showPlaylistSheet(songId),
                      ),
                      showEnglish: showEnglish,
                      lyrics: currentSong!.lyrics ??
                          currentSong!.lyricsEn ??
                          'Error getting lyrics',
                      additionalLyrics: currentSong!.lyrics != null
                          ? currentSong!.lyricsEn
                          : null,
                      scrollController: _scrollController,
                      footer: const SizedBox(
                        height: Dimens.marginLarge,

                        /// TODO: add page numbers
                      ),
                      fontScale: fontScale,
                    ));
              }
            }),
        bottomNavigationBar: BottomActionBar(
          onToggleEnglish: (enabled) {
            setState(() {
              showEnglish = enabled;
            });
            sl<MusStoreService>().put('show_english', enabled);
          },
          song: currentSong!,
        ));
  }

  void showSettings(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.2,
          ),
          child: SettingsSheet(
            onChangeFontSize: (value) => setState(() {
              fontScale = sl<MusStoreService>().fontScale;
            }),
          ),
        );
      },
    );
  }
}
