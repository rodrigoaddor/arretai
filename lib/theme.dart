import 'package:flutter/material.dart';

ThemeData theme() {
  final base = ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: Colors.grey[200],
  );
}
