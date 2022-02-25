/*
 * Copyright 2022 Developed by David Gofman
 *
 * An example of using the flutter_localizations framework
 */

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/l10n.dart';
import 'l10n_widget_helper.dart';

class MaterialDelegatesApp extends StatelessWidget {
  const MaterialDelegatesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        locale: const Locale('he', 'IL'), // Set a default locale
        supportedLocales: l10nSettings.supportedLocales, // Provide a list of supported locales
        localizationsDelegates: [
          l10nSettings.delegate, // Enable l10n_flutter delegate
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        builder: (BuildContext context, Widget? child) => WidgetHelper.createTestBody() // Rebuild widgets with new locale
    );
  }
}

void main() => runApp(const MaterialDelegatesApp());