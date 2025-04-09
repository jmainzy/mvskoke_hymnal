import 'dart:convert';

import 'package:flutter/services.dart';

class GlossaryManager {
  final Map<String, String> glossary = {};

  Future<GlossaryManager> init() async {
    final data = await getFileData();
    final lines = const LineSplitter().convert(data);
    for (var l in lines) {
      glossary[l.split('\t')[0]] = l.split('\t')[1];
    }
    return this;
  }

  Future<String> getFileData() async {
    var path = 'assets/db/glossary.tsv';
    return await rootBundle.loadString(path);
  }
}
