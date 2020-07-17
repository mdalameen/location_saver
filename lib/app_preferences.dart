import 'dart:convert';

import 'package:location_saver/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {
  static const _KEY_LOCATIONS = 'locations';
  SharedPreferences _pref;
  static AppPreference _instance = AppPreference._internal();
  factory AppPreference() => _instance;
  AppPreference._internal() {
    SharedPreferences.getInstance().then((value) => _pref = value);
  }

  List<Place> getLocations() {
    List<String> list = (_pref?.getStringList(_KEY_LOCATIONS)) ?? List();
    return List.generate(
        list.length, (index) => Place.fromJson(json.decode(list[index])));
  }

  setLocations(List<Place> list) {
    List<String> jsonList;
    if (list.isNotEmpty)
      jsonList = [for (Place p in list) json.encode(p.toJson())];

    _pref?.setStringList(_KEY_LOCATIONS, jsonList);
  }
}
