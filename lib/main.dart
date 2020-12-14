import 'package:arretai/data/state.dart';
import 'package:arretai/router.dart';
import 'package:arretai/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  
  await prefs.clear();

  final state = AppState.fromSharedPrefs(prefs);

  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: ArretaiApp(),
    ),
  );
}

class ArretaiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arretai',
      routes: routes,
      theme: theme(),
    );
  }
}
