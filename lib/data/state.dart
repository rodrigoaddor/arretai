import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _getPrefs = SharedPreferences.getInstance;

class AppState with ChangeNotifier {
  int _time;

  AppState({int time}) : _time = time;

  factory AppState.fromSharedPrefs(SharedPreferences prefs) => AppState(
        time: prefs.getInt('time'),
      );

  int get time => _time;
  set time(int value) {
    _time = value;
    notifyListeners();
    _getPrefs().then((prefs) => prefs.setInt('time', _time));
  }
}
