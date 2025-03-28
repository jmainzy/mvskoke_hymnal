import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:mvskoke_hymnal/managers/song_manager.dart';
import 'package:mvskoke_hymnal/models/song_model.dart';
import 'package:mvskoke_hymnal/services/config_service.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/widgets/song_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool loading = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Nak-cokv Esyvhiketv',
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : HomeContent(),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    loading = true;
    _initApp();
  }

  Future<void> _initApp() async {
    // load cached data
    var cachedFuture = <Future>[
      sl<SongManager>().getCachedSongs(),
    ];
    await Future.wait(cachedFuture);
    loading = false;
    setState(() {});

    final service = sl<ConfigService>();
    await service.initConfig();

    if (!mounted) return;

    _getServerSongs();
  }

  Future<void> _getServerSongs() async {
    var futures = <Future>[
      sl<SongManager>().getSongs(),
    ];
    await Future.wait(futures);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class HomeContent extends StatelessWidget with GetItMixin {
  HomeContent({super.key});

  final songManager = sl<SongManager>();

  @override
  Widget build(BuildContext context) {
    final filteredSongs = watchX((SongManager m) => m.filteredResult);

    final songs = filteredSongs.toList();

    final child = Column(
      children: [
        Flexible(
          child: songs.isNotEmpty
              ? ListView.builder(
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    SongModel song = songs[index];
                    return InkWell(
                      child: SongTile(
                        song: song,
                        subtitle: "subtitle",
                      ),
                    );
                  },
                )
              : const Center(
                  child: Column(
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
                ),
        )
      ],
    );

    return child;
  }
}
