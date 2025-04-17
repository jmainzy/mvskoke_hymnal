import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/models/enums.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/services/store_service.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';

class LyricsRenderer extends StatelessWidget {
  final String lyrics;
  final String? additionalLyrics;
  final bool showEnglish;
  final Widget? header;
  final Widget? footer;

  const LyricsRenderer({
    super.key,
    required this.showEnglish,
    required this.lyrics,
    required this.additionalLyrics,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final musStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: sl<MusStoreService>().fontSize * 0.75,
        );
    final enStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.italic,
          fontSize: sl<MusStoreService>().fontSize * 0.75,
        );

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
                minWidth: viewportConstraints.maxWidth,
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    header != null ? header! : Container(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: getLyrics(musStyle, enStyle),
                    ),
                    footer != null ? footer! : Container(),
                  ])));
    });
  }

  List<Widget> getLyrics(
    TextStyle musStyle,
    TextStyle enStyle,
  ) {
    List<Line> lyrics = LyricsProcessor.processLyrics(this.lyrics);
    List<Line>? additionalLyrics = LyricsProcessor.processLyrics(
        this.additionalLyrics ?? '',
        defaultType: LineType.extra);
    List<Widget> lines = [];

    int i = 0;
    for (Line line in lyrics) {
      lines.add(Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.marginLarge, Dimens.marginShort, Dimens.marginLarge, 0),
          child: Text(
            line.text,
            style: musStyle,
          )));
      if (showEnglish && i < additionalLyrics.length) {
        if (additionalLyrics[i].lineType != LineType.header) {
          lines.add(Padding(
              padding: const EdgeInsets.fromLTRB(Dimens.marginLarge,
                  Dimens.marginShort, Dimens.marginLarge, 0),
              child: Text(
                additionalLyrics[i].text,
                style: enStyle,
              )));
        }
      }
      i += 1;
    }
    return lines;
  }
}

class LyricsProcessor {
  static List<Line> processLyrics(String lyrics,
      {LineType defaultType = LineType.main}) {
    final List<Line> lines = [];
    // Process the lyrics to remove unwanted characters or format them
    for (var line in lyrics.split('\n')) {
      final lineType = _getLineType(line, defaultType);
      if (lineType == LineType.metadata) {
        // Skip metadata lines
        continue;
      } else if (lineType == LineType.header) {
        // format header
        line = line.replaceAll(
            RegExp(r'{start_of_chorus}|{start_of_verse: |}'), '');
      }
      lines.add(Line(line, lineType));
    }
    return lines;
  }

  static LineType _getLineType(String line, LineType defaultType) {
    if (line.contains("{start_of_chorus}")) {
      return LineType.header;
    } else if (line.contains("{end_of_chorus}") ||
        line.contains("{end_of_verse}")) {
      return LineType.metadata;
    } else if (line.contains("{start_of_verse:")) {
      return LineType.header;
    } else if (line.contains("{comment:")) {
      return LineType.comment;
    }
    return defaultType;
  }
}

class Line {
  final String text;
  final LineType lineType;

  Line(this.text, this.lineType);
}
