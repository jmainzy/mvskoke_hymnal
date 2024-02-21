import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

enum AudioPlayerState { loading, playing, paused, completed }

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  const AudioPlayerWidget({required this.audioUrl, Key? key}) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  Logger logger = Logger();
  Duration? _duration;
  Duration? _position;
  AudioPlayerState _playerState = AudioPlayerState.loading;

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    initializeAudio();
    logger.i("build audio player, url = ${widget.audioUrl}");
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          child: IconButton(
            icon: _playerState == AudioPlayerState.loading && _duration == null
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(),
                  )
                : Icon(
                    _playIcon,
                  ),
            onPressed: _handleAudioPlaying,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(_position?.toString().substring(2, 7) ?? '00.00'),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              thumbColor: Colors.white,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.black,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 5,
              ),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: (_position != null
                      ? _position!.inMilliseconds /
                          (_duration?.inMilliseconds ?? 0)
                      : 0.0)
                  .clamp(0.0, 1.0),
              onChanged: _seek,
            ),
          ),
        ),
        Text(_duration?.toString().substring(2, 7) ?? ''),
        const SizedBox(width: 12),
      ],
    );
  }

  Future<void> initializeAudio() async {
    _duration = await player.setUrl(widget.audioUrl);
    _playerState = AudioPlayerState.paused;
    _play();
    setState(() {});

    player.positionStream.listen((event) {
      _position = event;
      if (!mounted) return;
      setState(() {});
    });

    player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        _playerState = AudioPlayerState.completed;
        return;
      }
      if (event.playing) {
        _playerState = AudioPlayerState.playing;
        return;
      }

      switch (event.processingState) {
        case ProcessingState.idle:
          _playerState = AudioPlayerState.loading;
          break;
        case ProcessingState.loading:
          _playerState = AudioPlayerState.loading;
          break;
        case ProcessingState.buffering:
          _playerState = AudioPlayerState.loading;
          break;
        case ProcessingState.ready:
          _playerState = AudioPlayerState.paused;
          break;
        case ProcessingState.completed:
          _playerState = AudioPlayerState.completed;
          break;
      }
    });
  }

  IconData get _playIcon {
    if (_playerState == AudioPlayerState.playing) {
      return Icons.pause;
    }
    if (_playerState == AudioPlayerState.completed) {
      return Icons.refresh;
    }
    return Icons.play_arrow;
  }

  void _handleAudioPlaying() async {
    if (_playerState == AudioPlayerState.paused) {
      _play();
      return;
    }
    if (_playerState == AudioPlayerState.playing) {
      _pause();
      return;
    }
    if (_playerState == AudioPlayerState.completed) {
      await player.seek(const Duration());
      _play();
    }
  }

  _play() {
    player.play();
  }

  _pause() {
    player.pause();
  }

  _seek(double value) {
    final seekPosition = value * (_duration?.inMilliseconds ?? 0.0);
    player.seek(Duration(milliseconds: seekPosition.toInt()));
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }
}
