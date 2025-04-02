import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:logger/logger.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/services/config_service.dart';
import 'package:mvskoke_hymnal/services/navigation_helper.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';
import 'package:mvskoke_hymnal/widgets/song_tile.dart';

Logger log = Logger();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late Future<void> _loadingFuture;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    _loadingFuture = _init();
  }

  Future<void> _init() async {
    await sl.allReady();
    await sl<ConfigService>().initConfig();
    await sl<MusSongManager>().init();
    if (!mounted) return;
  }

  Future<void> fetch() async {
    // get songs again
    final songManager = sl<MusSongManager>();
    await songManager.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Nak-cokv Esyvhiketv'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          kDebugMode
              ? IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {});
                    _loadingFuture = fetch();
                  },
                )
              : Container(),
          kDebugMode
              ? IconButton(
                  onPressed: () {
                    sl<MusSongManager>().writeCache();
                  },
                  icon: const Icon(Icons.save),
                )
              : Container(),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            log.e('Error loading songs: ${snapshot.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Error loading songs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _init();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return HomeContent();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class HomeContent extends StatefulWidget with GetItStatefulWidgetMixin {
  HomeContent({super.key});

  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> with GetItStateMixin {
  HomeContentState();

  final songService = sl<MusSongManager>();
  final SearchController controller = SearchController();
  var isSearching = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  void search(String searchString) {
    songService.filterSongs(searchString);
    setState(() {
      isSearching = searchString.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<SongModel> filteredSongs = watchX(
      (MusSongManager m) => m.filteredResult,
    );

    return Column(
      children: [
        SearchAnchor(
          searchController: controller,
          builder: (BuildContext context, SearchController controller) {
            return Padding(
              padding: const EdgeInsets.all(Dimens.marginShort),
              child: SearchBar(
                controller: controller,
                padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0),
                ),
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  controller.openView();
                },
                leading: const Icon(Icons.search),
                trailing: controller.text.isNotEmpty
                    ? [
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.text = '';
                            search('');
                          },
                        ),
                      ]
                    : [],
                backgroundColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.surface,
                ),
              ),
            );
          },
          viewPadding: const EdgeInsets.all(Dimens.marginShort),
          viewBarPadding: const EdgeInsets.all(Dimens.marginShort),
          viewBackgroundColor: Theme.of(context).colorScheme.surface,
          viewOnSubmitted: (value) {
            search(value);
            controller.closeView(value);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              FocusScope.of(context).unfocus();
            });
          },
          suggestionsBuilder: (
            BuildContext context,
            SearchController controller,
          ) {
            return songService.getSuggestions(controller.text).map((song) {
              return ListTile(
                title: Text(song.title),
                onTap: () {
                  controller.text = song.title;
                  search(song.title);
                  controller.closeView(song.title);
                },
              );
            });
          },
        ),
        Flexible(
          child: filteredSongs.isNotEmpty
              ? ListView.builder(
                  itemCount: filteredSongs.length,
                  itemBuilder: (context, index) {
                    SongModel song = filteredSongs[index];
                    return InkWell(
                      child: SongTile(
                        song: song,
                        subtitle: "subtitle",
                        onTap: (songId) {
                          log.i(
                              'Navigating to song ${NavigationHelper.songsPath}/$songId');
                          NavigationHelper.router.go(
                            '${NavigationHelper.songsPath}/$songId',
                          );
                        },
                      ),
                    );
                  },
                )
              : isSearching
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Not found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
