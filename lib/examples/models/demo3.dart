import 'package:l10n_flutter/l10n_core.dart';

// Supported locales
const demo3Settings =
    L10nSettings(path: 'lib/examples/resources/demo3', locales: [
  L10nLocale('en', 'US', 'English, (US)'),
  L10nLocale('en', 'GB', 'English (United Kingdom)'),
  L10nLocale('ru', 'RU', 'Russian (Russia)'),
  L10nLocale('he', 'IL', 'Hebrew, (Israel)'),
]);

@demo3Settings
class L10nApp {
  static const title = 'Demo App',
      titles = {
        'home': L10nSet('home_title', 'Home', common: true),
        'about': L10nSet('about_title', 'About', common: true),
        'login': L10nSet('login_title', 'Login', common: true)
      };
}

@demo3Settings
class L10nHome {
  static const content = L10nSet('home_page', 'Demo page 1');
}

@demo3Settings
class L10nAbout {
  static const content = L10nSet('about_page', 'Demo page 2');
}

@demo3Settings
class L10nLogin {
  static const content = L10nSet('login_page', 'Demo page 3');
}
