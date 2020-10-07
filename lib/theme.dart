import 'package:flutter/material.dart';

ThemeData theme() {
  final base = ThemeData.from(
    colorScheme: ColorScheme.light(
      primary: Colors.green[600],
    ),
  );
  return base.copyWith(
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: Colors.green[600],
      textTheme: ButtonTextTheme.primary
    ),
  );
}
