/*
 * Copyright 2021 Developed by David Gofman
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n_core.dart';

class L10nCupertinoApp extends CupertinoApp {

  L10nCupertinoApp({
    Key? key,
    Widget? home,
    Locale? locale,
    CupertinoThemeData? theme,
    String? initialRoute,
    TransitionBuilder? builder,
    RouteFactory? onGenerateRoute,
    Iterable<Locale>? supportedLocales,
    bool debugShowCheckedModeBanner = false,
    Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates
  }) : assert(supportedLocales != null),

    super(
      key: key,
      home: home,
      builder: builder,
      initialRoute: initialRoute,
      onGenerateRoute: onGenerateRoute,
      theme: theme,
      locale: locale,
      localizationsDelegates:  localizationsDelegates ?? [
        L10nLoader.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: supportedLocales!,
      debugShowCheckedModeBanner: debugShowCheckedModeBanner);
}