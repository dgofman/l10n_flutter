/*
 * Copyright 2022 Developed by David Gofman
 *
 * L10nCupertinoApp - the easiest step to localize an application using the cupertino widgets
 */

import 'package:flutter/cupertino.dart';
import 'package:l10n_flutter/l10n_cupertino_app.dart';

import 'models/l10n.dart';
import 'l10n_widget_helper.dart';

class CupertinoDemoApp extends StatelessWidget {
  const CupertinoDemoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return L10nCupertinoApp(
        locale: const Locale('he', 'IL'), // Set a default locale
        supportedLocales: l10nSettings.supportedLocales, // Provide a list of supported locales
        builder: (BuildContext context, Widget? child) => WidgetHelper.createTestBody() // Rebuild widgets with new locale
    );
  }
}

void main() => runApp(const CupertinoDemoApp());