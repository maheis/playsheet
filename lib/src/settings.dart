import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    required this.fontFamily,
    required this.textScaleFactor,
    required this.useLightTheme,
  });
  static const defaults = AppSettings(
    fontFamily: 'Ubuntu',
    textScaleFactor: 1,
    useLightTheme: false,
  );
  final String fontFamily;
  final double textScaleFactor;
  final bool useLightTheme;
  AppSettings copyWith({
    String? fontFamily,
    double? textScaleFactor,
    bool? useLightTheme,
  }) => AppSettings(
    fontFamily: fontFamily ?? this.fontFamily,
    textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    useLightTheme: useLightTheme ?? this.useLightTheme,
  );
}

class SettingsController extends ChangeNotifier {
  SettingsController(this._preferences);
  final SharedPreferences _preferences;
  AppSettings settings = AppSettings.defaults;
  void load() {
    settings = AppSettings(
      fontFamily: _preferences.getString('fontFamily') ?? 'Ubuntu',
      textScaleFactor: (_preferences.getDouble('textScaleFactor') ?? 1).clamp(
        0.5,
        1.6,
      ),
      useLightTheme: _preferences.getBool('useLightTheme') ?? false,
    );
  }

  Future<void> update(AppSettings value) async {
    settings = value;
    notifyListeners();
    await _preferences.setString('fontFamily', value.fontFamily);
    await _preferences.setDouble('textScaleFactor', value.textScaleFactor);
    await _preferences.setBool('useLightTheme', value.useLightTheme);
  }
}
