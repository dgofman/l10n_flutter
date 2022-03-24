import 'package:l10n_flutter/l10n_core.dart';

// Supported locales
const l10nSettings =
    L10nSettings(path: 'lib/examples/resources/l10n', locales: [
  L10nLocale('en', 'US', 'English, (US)'),
  L10nLocale('en', 'GB', 'English (United Kingdom)'),
  L10nLocale('ru', 'RU', 'Russian (Russia)'),
  L10nLocale('he', 'IL', 'Hebrew, (Israel)'),
]);

@l10nSettings
class L10n {
  static const title = 'L10n Demo App', //exclude from translation this variable
      // ignore: prefer_adjacent_string_concatenation
      whatIsLP = L10nSet(
          'what_is_lorem_ipsum',
          '{0} is simply dummy text of the printing and typesetting industry. ' +
              '{0} has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type ' +
              'and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic ' +
              'typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets ' +
              'containing {0} passages, and more recently with desktop publishing software like {1} including versions of {0}.',
          common: true),
      loremIpsum = L10nSet('lorem_ipsum', 'Lorem Ipsum', common: true),
      pageMaker = L10nSet('page_maker', 'Aldus PageMaker', common: true),
      car = L10nSet('car', 'Car'),
      truck = L10nSet('truck', 'Truck'),
      gasoline = L10nSet('gasoline', 'Gasoline'),
      coat = L10nSet('coat', 'Coat'),
      mailbox = L10nSet('mailbox', 'Mailbox'),
      highway = L10nSet('highway', 'Highway'),
      elevator = L10nSet('elevator', 'Elevator'),
      apartment = L10nSet('apartment', 'Apartment');
}
