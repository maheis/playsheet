import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'pages.dart';
import 'settings.dart';

class PlaySheetApp extends StatelessWidget {
  const PlaySheetApp({
    super.key,
    required this.controller,
    required this.settingsController,
  });
  final AppController controller;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: settingsController,
    builder: (context, _) {
      final settings = settingsController.settings;
      return MaterialApp(
        title: 'PlaySheet',
        debugShowCheckedModeBanner: false,
        theme: _theme(settings, Brightness.light),
        darkTheme: _theme(settings, Brightness.dark),
        themeMode: settings.useLightTheme ? ThemeMode.light : ThemeMode.dark,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(settings.textScaleFactor)),
          child: child ?? const SizedBox.shrink(),
        ),
        home: HomePage(
          controller: controller,
          settingsController: settingsController,
        ),
      );
    },
  );

  ThemeData _theme(AppSettings settings, Brightness brightness) {
    final accent = Color(settings.accentColorValue);
    final highlight = Color(settings.highlightColorValue);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: brightness,
        ).copyWith(
          primary: accent,
          secondary: highlight,
          tertiary: const Color(0xFF8FDCBE),
        );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: settings.fontFamily,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(iconTheme: IconThemeData(color: highlight)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highlight,
          foregroundColor: Colors.black,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: highlight,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}

Future<void> pushPage(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
