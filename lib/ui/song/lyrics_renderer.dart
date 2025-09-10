import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/models/enums.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/services/store_service.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';

const headerRegex =
    r'^\(.+\)$'; // Matches lines that start and end with parentheses

class LyricsRenderer extends StatelessWidget {
  final String lyrics;
  final String? additionalLyrics;
  final bool showEnglish;
  final Widget? header;
  final Widget? footer;
  final ScrollController? scrollController;

  const LyricsRenderer({
    super.key,
    required this.showEnglish,
    required this.lyrics,
    required this.additionalLyrics,
    this.header,
    this.footer,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final musStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: sl<MusStoreService>().fontSize * 0.75,
        );
    final enStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
        fontWeight: FontWeight.normal,
        fontStyle: FontStyle.italic,
        fontSize: sl<MusStoreService>().fontSize * 0.75,
        color: Colors.black54);
    final headerStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: sl<MusStoreService>().fontSize * 0.75,
          color: Theme.of(context).colorScheme.primary,
        );

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return SingleChildScrollView(
          controller: scrollController,
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
                      children: getLyrics(musStyle, enStyle, headerStyle),
                    ),
                    footer != null ? footer! : Container(),
                  ])));
    });
  }

  List<Widget> getLyrics(
    TextStyle musStyle,
    TextStyle enStyle,
    TextStyle headerStyle,
  ) {
    List<Line> lyrics = LyricsProcessor.processLyrics(this.lyrics);
    List<Line>? additionalLyrics = LyricsProcessor.processLyrics(
        this.additionalLyrics ?? '',
        defaultType: LineType.extra);
    List<Widget> lines = [];

    int i = 0;
    while (i < lyrics.length) {
      final line = lyrics[i];
      const leadingMargin = Dimens.marginLarge * 2.5;
      if (line.lineType == LineType.header && line.text.length < 3) {
        final nextLine = lyrics[i + 1];
        lines.add(
            // Header row
            Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${line.text}.", style: headerStyle),
            SizedBox(
              width: leadingMargin - headerStyle.fontSize! + 2,
            ),
            Flexible(
                child: Text(
              nextLine.text,
              style: musStyle,
            )),
          ],
        ));
        i += 1; // Skip the next line as it's part of the header
      } else {
        lines.add(Padding(
            padding: EdgeInsets.only(
                left: line.lineType == LineType.header ? 0 : leadingMargin),
            child: Text(
              line.text,
              style: line.lineType == LineType.header ? headerStyle : musStyle,
            )));
      }

      if (showEnglish && i < additionalLyrics.length) {
        if (additionalLyrics[i].lineType != LineType.header &&
            additionalLyrics[i].text.isNotEmpty) {
          // English line
          lines.add(Padding(
              padding: const EdgeInsets.only(left: leadingMargin),
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
        line = line.replaceAll(RegExp(r'{start_of_chorus}'), 'Chorus:');
        line = line.replaceAll(RegExp(r'{start_of_verse: |}'), '');
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
    } else if (line.contains("{start_of_verse:") ||
        line.contains(RegExp(headerRegex))) {
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
