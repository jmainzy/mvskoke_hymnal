import 'dart:math';

import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  Size get size => MediaQuery.of(this).size;
  double get width => size.width;
  double get height => size.height;
  bool get isLargeWidth => width > 600;

  bool get isSmallScreen => width <= 320 || height < 680;

  EdgeInsets get padding => MediaQuery.of(this).padding;
  double get viewportHeight => height - padding.top - padding.bottom;
}

extension StringX on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

extension RandomListItem<T> on List<T> {
  T get randomItem {
    return this[Random().nextInt(length)];
  }
}

extension GlobalFormKeyX on GlobalKey<FormState> {
  bool get isValid {
    return currentState?.validate() ?? false;
  }
}
