import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
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
    fontFamily: 'Ubuntu',
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
  }) =>
      AppSettings(
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
  late final File _settingsFile;

  Future<void> load() async {
    final directory = await getApplicationDocumentsDirectory();
    _settingsFile = File(path.join(directory.path, 'playsheet_settings.json'));
    final legacy = <String, dynamic>{
      'fontFamily': _preferences.getString('fontFamily'),
      'textScaleFactor': _preferences.getDouble('textScaleFactor'),
      'useLightTheme': _preferences.getBool('useLightTheme'),
      'accentColorValue': _preferences.getInt('accentColorValue'),
      'highlightColorValue': _preferences.getInt('highlightColorValue'),
    };
    Map<String, dynamic> data = {};
    if (await _settingsFile.exists()) {
      try {
        final decoded = jsonDecode(await _settingsFile.readAsString());
        if (decoded is Map) data = Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    if (data.isEmpty) {
      data = {
        for (final entry in legacy.entries)
          if (entry.value != null) entry.key: entry.value,
      };
    }
    settings = _fromJson(data);
  }

  Future<void> update(AppSettings value) async {
    settings = value;
    notifyListeners();
    await _settingsFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(_toJson(value)),
    );
  }

  AppSettings _fromJson(Map<String, dynamic> data) => AppSettings(
        fontFamily: data['fontFamily'] as String? ?? 'Ubuntu',
        textScaleFactor: ((data['textScaleFactor'] as num?)?.toDouble() ?? 1)
            .clamp(0.5, 1.6),
        useLightTheme: data['useLightTheme'] as bool? ?? false,
        accentColorValue: _validColorValue(
          (data['accentColorValue'] as num?)?.toInt(),
          AppSettings.defaults.accentColorValue,
        ),
        highlightColorValue: _validColorValue(
          (data['highlightColorValue'] as num?)?.toInt(),
          AppSettings.defaults.highlightColorValue,
        ),
      );

  static Map<String, dynamic> _toJson(AppSettings value) => {
        'fontFamily': value.fontFamily,
        'textScaleFactor': value.textScaleFactor,
        'useLightTheme': value.useLightTheme,
        'accentColorValue': value.accentColorValue,
        'highlightColorValue': value.highlightColorValue,
      };

  int _validColorValue(int? value, int fallback) => value != null &&
          AppSettings.availableColors.any((color) => color.toARGB32() == value)
      ? value
      : fallback;
}
