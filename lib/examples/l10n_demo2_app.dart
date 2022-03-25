/*
 * Copyright 2022 Developed by David Gofman
 *
 * Dynamic locale change with L10nCupertinoApp widget
 */

import 'package:flutter/cupertino.dart';
import 'package:l10n_flutter/l10n_cupertino_app.dart';

import 'models/l10n.dart';
import 'l10n_widget_helper.dart';

class CupertinoAppDemo extends StatefulWidget {
  const CupertinoAppDemo({Key? key}) : super(key: key);

  @override
  _CupertinoAppDemoState createState() => _CupertinoAppDemoState();
}

class _CupertinoAppDemoState extends State<CupertinoAppDemo> {
  Locale? _locale = const Locale('he', 'IL');

  Future<void> changeLocale(Locale? newLocale) async {
    await l10nSettings.selectLocale(newLocale);
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return L10nCupertinoApp(
      locale: _locale, // Dynamic locale
      supportedLocales:
          l10nSettings.supportedLocales, // Provide a list of supported locales
      theme: theme.copyWith(
          primaryColor: CupertinoColors.white,
          barBackgroundColor: CupertinoColors.systemTeal,
          textTheme: theme.textTheme.copyWith(
              navTitleTextStyle: theme.textTheme.navTitleTextStyle
                  .copyWith(color: CupertinoColors.white))),
      home: MyPage(this),
    );
  }
}

class MyPage extends StatelessWidget {
  final _CupertinoAppDemoState parent;

  const MyPage(this.parent, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WidgetHelper.createCupertinoScaffold(
        context, l10nSettings.indexOf(parent._locale), parent.changeLocale);
  }
}

void main() => runApp(const CupertinoAppDemo());
