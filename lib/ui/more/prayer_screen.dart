import 'package:flutter/material.dart';

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
      body:
          Padding(padding: const EdgeInsets.all(16.0), child: Text('$prayer')),
    );
  }
}

const String prayer = '''
Pucase Em Mekusapkv
Lord's Prayer
Matthew 6:9-13

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
