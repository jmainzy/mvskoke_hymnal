import 'package:flutter/material.dart';

/// Displays a formatted block of text
class AlphabetScreen extends StatelessWidget {
  const AlphabetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alphabet'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0), child: Text('$alphabet')),
    );
  }
}

const String alphabet = '''
  Mvskoke Phonetic English Mvskoke
Alphabet Sound Example Example
1. A* āh farther afke, hominy grits
2. C ce such cesse, mouse
3. E* ē feed ecko, dried corn
ĕ fit ecke, mother
4. F fe as in English fuswv, bird
5. H he as in English hvse, sun
6. I* a hey ehiwv, his wife
7. K ke ski kapv, coat
8. L le as in English lucv, turtle
9. M me as in English meske, summer
10. N ne as in English nere, night
11. O* ō rode ofv, inside
ŏ wrote opv, owl
12. P pe pen penwv, turkey
13. R re athlete rvro, fish
14. S se as in English sukhv, hog
15. T te steam este, person
16. U* oo food fuswv, bird
17. V* v ago vce, corn
18. W we as in English wotko, raccoon
19. Y ye as in English yvnvsv, buffalo
Diphthongs
AE as in aeha EU as in cemeu
OU as in cukou UE as in uewv
* A, E, I, O; U, & V are vowels.
''';
