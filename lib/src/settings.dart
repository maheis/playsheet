import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    required this.fontFamily,
    required this.textScaleFactor,
    required this.useLightTheme,
    required this.accentColorValue,
    required this.highlightColorValue,
  });

  static const defaults = AppSettings(
    fontFamily: 'OpenDyslexic',
    textScaleFactor: 1,
    useLightTheme: false,
    accentColorValue: 0xFFE57373,
    highlightColorValue: 0xFFFFB74D,
  );

  static const availableColors = <Color>[
    Color(0xFFE57373),
    Color(0xFFFFB74D),
    Color(0xFFAED581),
    Color(0xFFFFF176),
    Color(0xFF64B5F6),
    Color(0xFF8FDCBE),
    Color(0xFF9575CD),
  ];

  static const colorNames = <String>[
    'Rot',
    'Orange',
    'Grün',
    'Gelb',
    'Blau',
    'Mint',
    'Lila',
  ];

  static const playerColors = <Color>[
    ...availableColors,
    Colors.black,
    Colors.white,
  ];

  final String fontFamily;
  final double textScaleFactor;
  final bool useLightTheme;
  final int accentColorValue;
  final int highlightColorValue;

  AppSettings copyWith({
    String? fontFamily,
    double? textScaleFactor,
    bool? useLightTheme,
    int? accentColorValue,
    int? highlightColorValue,
  }) => AppSettings(
    fontFamily: fontFamily ?? this.fontFamily,
    textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    useLightTheme: useLightTheme ?? this.useLightTheme,
    accentColorValue: accentColorValue ?? this.accentColorValue,
    highlightColorValue: highlightColorValue ?? this.highlightColorValue,
  );
}

class SettingsController extends ChangeNotifier {
  SettingsController(this._preferences);
  final SharedPreferences _preferences;
  AppSettings settings = AppSettings.defaults;
  void load() {
    settings = AppSettings(
      fontFamily: _preferences.getString('fontFamily') ?? 'OpenDyslexic',
      textScaleFactor: (_preferences.getDouble('textScaleFactor') ?? 1).clamp(
        0.5,
        1.6,
      ),
      useLightTheme: _preferences.getBool('useLightTheme') ?? false,
      accentColorValue: _validColorValue(
        _preferences.getInt('accentColorValue'),
        AppSettings.defaults.accentColorValue,
      ),
      highlightColorValue: _validColorValue(
        _preferences.getInt('highlightColorValue'),
        AppSettings.defaults.highlightColorValue,
      ),
    );
  }

  Future<void> update(AppSettings value) async {
    settings = value;
    notifyListeners();
    await _preferences.setString('fontFamily', value.fontFamily);
    await _preferences.setDouble('textScaleFactor', value.textScaleFactor);
    await _preferences.setBool('useLightTheme', value.useLightTheme);
    await _preferences.setInt('accentColorValue', value.accentColorValue);
    await _preferences.setInt('highlightColorValue', value.highlightColorValue);
  }

  int _validColorValue(int? value, int fallback) =>
      value != null &&
          AppSettings.availableColors.any((color) => color.toARGB32() == value)
      ? value
      : fallback;
}
