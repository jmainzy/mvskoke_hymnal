import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chord/flutter_chord.dart';
import 'package:flutter_guitar_tabs/flutter_guitar_tabs.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/services/store_service.dart';
import 'package:mvskoke_hymnal/widgets/settings_sheet.dart';
import 'package:mvskoke_hymnal/widgets/song_footer.dart';
import 'package:mvskoke_hymnal/widgets/song_header.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/utilities/utils.dart';
import 'package:mvskoke_hymnal/widgets/bottom_action_bar.dart';

Logger logger = Logger();

class SongScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  final String songId;
  final String? playlistId;

  SongScreen({super.key, required this.songId, this.playlistId});

  @override
  SongScreenState createState() => SongScreenState();
}

class SongScreenState extends State<SongScreen> with GetItStateMixin {
  bool showNepali = true;

  int transposeIncrement = 0;
  double scrollSpeed = 10;
  bool scrollEnabled = false;
  late Future<void> _loadingFuture;
  late bool showEnglish;

  SongModel? currentSong;
  List<MediaItem>? mediaItems;

  double fontSize = sl<MusStoreService>().fontSize;
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
    mediaItems = await songManager.getMediaItems(widget.songId);
    showEnglish = sl<MusStoreService>().get<bool>('show_english') ?? true;
    logger.i('media items for song ${widget.songId}: $mediaItems');

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
        return Container();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentSong == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Song not found'),
              ElevatedButton(
                onPressed: () async {
                  await initialize();
                  setState(() {});
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    int buffer = (Dimens.marginLarge * 2 * fontSize / 16).toInt();

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text.rich(
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            TextSpan(
              text: currentSong?.titles.values.first,
            ),
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  height: 2,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(
                        (min((max(scrollPosition - 3, 0) / 10).toInt() * 255,
                            255)),
                      ),
                ),
          ),
          surfaceTintColor: Theme.of(context).colorScheme.primary,
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.settings),
          //     onPressed: () => showSettings(context),
          //   ),
          // ],
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
                      lyrics: currentSong!.lyrics?.trim() ??
                          currentSong!.lyricsEn?.trim() ??
                          'Error getting lyrics',
                      additionalLyrics:
                          showEnglish && currentSong!.lyricsEn?.trim() != null
                              ? [currentSong!.lyricsEn!.trim()]
                              : null,
                      textStyle: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.copyWith(fontSize: fontSize),
                      headerStyle:
                          Theme.of(context).textTheme.labelSmall!.copyWith(
                                fontSize: (fontSize * 0.6).toDouble(),
                                height: fontSize / 20 * 0.1,
                                color: Colors.black54,
                              ),
                      additionalTextStyle:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: (fontSize * 0.8).toDouble(),
                                color: Colors.black54,
                              ),
                      chordStyle:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                                fontSize: (fontSize * 0.75).toDouble(),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      onTapChord: _showChordImage,
                      scrollSpeed: scrollEnabled ? scrollSpeed.toInt() : 0,
                      showChord: showChords,
                      transposeIncrement: transposeIncrement,
                      widgetPadding: buffer,
                      horizontalAlignment: CrossAxisAlignment.start,
                      scrollController: _scrollController,
                      lineHeight: 8.0,
                      trailingWidget: (currentSong != null)
                          ? SongFooter(
                              metadata: currentSong!,
                            )
                          : Container(),
                      leadingWidget: SongHeader(
                        currentSong: currentSong,
                        addToPlaylist: (songId) => showPlaylistSheet(songId),
                      ),
                      breakingCharacters: const [' ', '་'],
                    ));
              }
            }),
        bottomNavigationBar: BottomActionBar(
          showSettings: () => showSettings(context),
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
              setState(() {
                fontSize = value;
              });
            }),
          ),
        );
      },
    );
  }

  void _showChordImage(String chord) {
    final regex = RegExp(
      r'\b([CDEFGAB](?:b|bb)*(?:#|##|sus|maj|m|aug)*[\d\/]*(?:[CDEFGAB](?:b|bb)*(?:#|##|sus|maj|min|aug)*[\d\/]*)*)(?=\s|$)(?! \w)',
    );
    // if regex matches
    if (!regex.hasMatch(chord.split('/')[0])) {
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        enableDrag: false,
        builder: (context) {
          Widget child = getChordWidget(chord);

          return Padding(
            padding: const EdgeInsets.all(Dimens.marginLarge),
            child: Center(child: child),
          );
        },
      ),
    );
  }

  Widget getChordWidget(String chord) {
    final height = MediaQuery.of(context).size.height;
    final isSmall = height < 800;
    final chordList = chord.split('/');
    if (chordList.length == 1) {
      final tabs = Utils.getChordTabs(chord);
      if (tabs == null) {
        return Text(
          'Chord not found: ${chordList[0]}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      }

      return Transform.scale(
        scale: isSmall ? 1 : 2,
        child: FlutterGuitarTab(
          name: chordList[0],
          tab: tabs,
          showStartFretNumber: true,
          color: Theme.of(context).colorScheme.primary,
          size: 10,
        ),
      );
    }

    return Wrap(
      children: chordList.map((e) {
        final tabs = Utils.getChordTabs(e);
        if (tabs == null) {
          return Text(
            'Chord not found: $e',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        return FlutterGuitarTab(
          name: e,
          tab: tabs,
          showStartFretNumber: true,
          color: Theme.of(context).colorScheme.primary,
          size: isSmall ? 8 : 10,
        );
      }).toList(),
    );
  }
}
