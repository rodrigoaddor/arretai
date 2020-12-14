import 'package:arretai/page/bluetooth.dart';
import 'package:arretai/page/help.dart';
import 'package:arretai/page/home.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => HomePage(),
  '/bluetooth': (context) => BluetoothPage(),
  '/help': (context) => HelpPage(),
};
