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

import 'dart:async';
import 'dart:convert' show jsonDecode, JsonEncoder, utf8;
import 'dart:developer' as logger;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

class L10nLoader {
  static String _resourceDir = 'l10n/';
  static final Map<String, dynamic> _dynamicLocaleDictionary = {};
  static final Map<Locale, Map<String, dynamic>> _loadedLocales = {};
  static final Map<Locale, Future<void> Function()> _loadingLocales = {};

  // ignore: prefer_function_declarations_over_variables
  static Function getPath = (String languageCode, [String? countryCode]) {
    if (countryCode != null) {
      return '$_resourceDir${languageCode}_$countryCode.json';
    }
    return '$_resourceDir$languageCode.json';
  };

  // ignore: prefer_function_declarations_over_variables
  static Function bundleLoader =
      (Map<String, dynamic> map, Locale locale, String path) async {
    try {
      ByteData data = await rootBundle.load(path);
      map.addAll(jsonDecode(utf8.decode(data.buffer.asUint8List())) as Map<String, dynamic>);
    } catch (error) {
      logger.log('L10nLoader Error: $error');
    }
  };

  // ignore: prefer_function_declarations_over_variables
  static final Function _changeLocale = (Locale locale,
      [List<Locale>? supportedLocales, bool clear = true]) async {
    if (!clear || !_isLoaded(locale)) {
      await _loadLocale(locale, clear);
    }
    if (_loadingLocales[locale] != null) {
      await _loadingLocales[locale]!();
    }
    _loadedLocales[locale]?.forEach((String key, dynamic value) {
      _dynamicLocaleDictionary[key] = value.toString();
    });
    return locale;
  };

  static bool _isLoaded(Locale locale) =>
      _loadedLocales[locale] != null && _loadedLocales[locale]!.isNotEmpty;

  static Future<void> _loadLocale(Locale locale, bool clear) async {
    if (!clear || !_loadedLocales.containsKey(locale)) {
      _loadingLocales[locale] = () async {
        if (!clear) {
          logger.log('Loading Locale $locale');
        }
        Map<String, dynamic> map = (clear ? {} : _loadedLocales[locale] ?? {});
        await bundleLoader(map, locale, getPath(locale.languageCode));
        if (locale.countryCode != null && locale.countryCode != '') {
          await bundleLoader(
              map, locale, getPath(locale.languageCode, locale.countryCode));
        }
        if (map.isNotEmpty) {
          _loadedLocales[locale] = map;
        }
        _loadingLocales.remove(locale);
      };
    }
  }

  static LocalizationsDelegate<Locale> delegate = _L10nDelegate();
}

class L10nSettings {
  final String? path;
  final List<L10nLocale> locales;

  const L10nSettings(
      {this.path,
      this.locales = const <L10nLocale>[L10nLocale('en', 'US', 'English')]});

  List<Locale> get supportedLocales {
    if (path != null) {
      String p = path!;
      L10nLoader._resourceDir = p.endsWith('/') ? p : p + '/';
    }
    return locales;
  }

  int indexOf(Locale? locale) {
    if (locale == null) {
      return -1;
    }
    return supportedLocales.indexWhere((l) =>
        l.languageCode == locale.languageCode &&
        l.countryCode == locale.countryCode);
  }

  Future<Locale> selectLocale(Locale? newLocale, [bool clear = true]) =>
      L10nLoader._changeLocale(newLocale, supportedLocales, clear);

  bool isLoaded(Locale locale) => L10nLoader._isLoaded(locale);

  LocalizationsDelegate<void> get delegate => L10nLoader.delegate;

  String get json {
    return const JsonEncoder.withIndent('  ')
        .convert(L10nLoader._dynamicLocaleDictionary);
  }

  void printJson([String? str]) {
    logger.log(str ?? json);
  }
}

class L10nSet {
  // Dictionary locale key
  final String _key;
  // Dictionary locale value (for undefined locale display as default value)
  final String _value;
  // If true - define key only in  ${languageCode}.json, otherwise ${languageCode}_${countryCode}.json
  final bool common;
  const L10nSet(this._key, this._value, {this.common = false});

  get $ => toString();

  // Performs the template substitution, returning a new string. mapping is any dictionary-like object with keys that match the placeholders in the template.
  String sub(List<dynamic> keys) {
    String str = toString();
    for (int i = 0; i < keys.length; i++) {
      str = str.replaceAll('{N}'.replaceFirst('N', i.toString()), '${keys[i]}');
    }
    return str;
  }

  @override
  String toString() {
    return L10nLoader._dynamicLocaleDictionary[_key] ?? _value;
  }
}

class _L10nDelegate extends LocalizationsDelegate<Locale> {
  @override
  Future<Locale> load(Locale locale) async {
    await L10nLoader._changeLocale(locale);
    return Future.value(locale);
  }

  @override
  bool isSupported(Locale locale) => true;

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

class L10nLocale extends Locale {
  final String? label;
  @override
  final String languageCode;
  @override
  final String? countryCode;
  const L10nLocale(this.languageCode, [this.countryCode, this.label])
      : super(languageCode, countryCode);

  bool get isLTR =>
      GlobalWidgetsLocalizations(this).textDirection == TextDirection.ltr;
  bool get isRTL => !isLTR;
}
