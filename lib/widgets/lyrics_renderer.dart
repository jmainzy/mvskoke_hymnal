import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';

class LyricsRenderer extends StatelessWidget {
  final List<dynamic> musLyrics;
  final List<dynamic> enLyrics;
  final bool showEnglish;
  final String title;
  final String subtitle;
  final Widget? footer;

  const LyricsRenderer({
    super.key,
    required this.title,
    required this.subtitle,
    required this.showEnglish,
    required this.musLyrics,
    required this.enLyrics,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final musStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        );
    final enStyle = Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.italic,
          fontSize: 16.0,
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
                    Padding(
                        padding: const EdgeInsets.fromLTRB(
                            Dimens.marginLarge,
                            Dimens.marginLarge,
                            Dimens.marginLarge,
                            Dimens.marginShort),
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.start,
                        )),
                    showEnglish
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimens.marginLarge),
                            child: Text(
                              subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(color: Colors.grey),
                              textAlign: TextAlign.start,
                            ))
                        : Container(),
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
    List<Widget> textLines = [];

    int i = 0;
    for (String line in musLyrics) {
      textLines.add(Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimens.marginLarge, Dimens.marginShort, Dimens.marginLarge, 0),
          child: Text(
            line,
            style: musStyle,
          )));
      if (showEnglish) {
        textLines.add(Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimens.marginLarge, Dimens.marginShort, Dimens.marginLarge, 0),
            child: Text(
              enLyrics[i],
              style: enStyle,
            )));
      }
      i += 1;
    }
    return textLines;
  }
}
