import 'package:flutter/material.dart';
import 'package:mvskoke_hymnal/managers/glossary_manager.dart';
import 'package:mvskoke_hymnal/services/service_locator.dart';
import 'package:mvskoke_hymnal/utilities/dimens.dart';

class GlossaryScreen extends StatelessWidget {
  const GlossaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final terms = sl<GlossaryManager>().glossary;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Glossary'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(Dimens.marginLarge),
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
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            definition,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
