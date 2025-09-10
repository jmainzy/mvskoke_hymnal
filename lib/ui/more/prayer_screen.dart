import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:mvskoke_hymnal/models/media_item.dart';
import 'package:mvskoke_hymnal/ui/more/mini_audio.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';

/// Displays a formatted block of text
class PrayerScreen extends StatelessWidget {
  final String? name;
  const PrayerScreen({super.key, this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lord\'s Prayer'),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(Dimens.marginLarge),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                      padding:
                          EdgeInsetsGeometry.only(left: Dimens.marginLarge),
                      child: GptMarkdown(prayer)),
                  SizedBox(
                    height: Dimens.marginLarge,
                  ),
                  Row(children: [
                    SizedBox(
                      width: Dimens.marginShort,
                    ),
                    Expanded(
                        child: Text(
                      'Reading by Pastor Jimsey Harjo:',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.black54),
                    ))
                  ]),
                  MiniAudioWidget(
                      mediaItem: MediaItem(
                          id: 1,
                          songId: '',
                          title: 'Lord\'s Prayer',
                          filename: 'lords-prayer.mp3',
                          performer: '',
                          copyright: '',
                          lastUpdate: null)),
                ])),
      ),
    );
  }
}

const String prayer = '''
## Pucase Em Mekusapkv
### Lord's Prayer
### Maro 6:9-13

9. Pu'rke hvlwe liketskat, 
ce hocefkvt vcakekvs.
10. Cem ohmekketvt vlvkekvs. 
Mimv hvlwe nake kometske 
momat etvpomet yvmv 
ekvnvn oh momekvs.
11. Nettv vrahkv tvkliken
mucv-nettvn pu'mvs.
12. Momet pum ahuervn es pum 
wikvs, vhuericeyat es em 
wikakeyat, etvpomen.
13. Nake pu naorkepuece taye 
eskerretv 'sep oh ahyetskvs; 
momis holwakat a sepu'ssicvs. 
Ohmekketvt, yekcetvt, momen 
rakketvt cenake emunkvt omekv.
Emen.

''';
