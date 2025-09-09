import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/managers/glossary_manager.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';

class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final terms = sl<GlossaryManager>().glossary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glossary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: terms.length,
          itemBuilder: (context, index) {
            String key = terms.keys.elementAt(index);
            final definition = terms[key]!;
            return GlossaryItem(
              key,
              definition,
            );
          },
        ),
      ),
    );
  }
}

class GlossaryItem extends StatelessWidget {
  final String term;
  final String definition;

  const GlossaryItem(
    this.term,
    this.definition, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            term,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            definition,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
