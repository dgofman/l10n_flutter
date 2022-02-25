# Flutter Localization Framework.

This single framework will help you localize your Flutter application without the headache. You can reorganize and rename keys in the contact variable as well as in local files without breaking the application. Later, when you run the builder, you'll get auto-generated locale output files for all supported locales.


## Compile and test
```
git clone https://github.com/dgofman/l10n_flutter.git

cd l10n_flutter

flutter create --org l10n_flutter -i objc -a java -t app .

flutter run -d chrome -t lib/examples/l10n_demo3_app.dart

```

## Getting Started

```
flutter create myapp

cd myapp
```

- Add access to app resource directory in pubspec.yaml

```
dependencies:
  flutter:
    sdk: flutter
    
  # Copy and paste
  l10n_flutter: ^1.0.0
```

- Create a locale model file - models/app_ln10.dart

```
import 'package:l10n_flutter/l10n_core.dart';

// Supported locales
const AppL10nSettings = L10nSettings(locales: [
  L10nLocale('en', 'US', 'English, (US)'),
  L10nLocale('en', 'GB', 'English (United Kingdom)'),
]);

@AppL10nSettings
class AppL10n {
  static const truck = L10nSet('app_truck', 'Truck');  // where "app_truck" is the key in the locale file
}
```

- Replace code in lib/main.dart

```
import 'package:flutter/material.dart';
import 'package:l10n_flutter/l10n_material_app.dart';
import './models/app_ln10.dart';

void main() => runApp(L10nMaterialApp(
    locale: const Locale('en', 'GB'), // Set a default locale
    supportedLocales: AppL10nSettings.supportedLocales, // Provide a list of supported locales
    builder: (BuildContext context, Widget? child) => Scaffold(body: Text(AppL10n.truck.$)) // or AppL10n.truck.toString()
));
```

- Note. These are the minimum requirements to run the application. However, your app is showing the default values as we are getting loading errors:

```
L10nLoader Error: Unable to load asset: l10n/en_GB.json
```

------------

## Generate Assets

- Create build.yaml file

```
builders:
  l10n_builder:
    import: "package:l10n_flutter/builder/builder.dart"
    builder_factories: ["l10nBuilderFactory"]
    build_extensions: {".dart:": [".json"]}
    build_to: source

targets:
  $default:
    builders:
      'l10n_flutter|l10n_builder':
        enabled: true
        generate_for: # the directory specified
          - lib/models/app_ln10.dart
```

- Include path to the locale output directory in pubspec.yaml

```
flutter:

  # To add assets to your application, add an assets section, like this:
  assets:
    - assets/l10n/
```

- Include the latest version of the build into dev dependencies https://pub.dev/packages/build_runner

```
dev_dependencies:
  flutter_test:
    sdk: flutter

  build_runner: ^2.1.7
```

- Generate files

```
flutter pub run build_runner build --delete-conflicting-outputs
```

- Finally update content in assets/l10n/en_GB.json

```
{
	"app_truck": "Lorry"
}
```

# Examples

https://github.com/dgofman/l10n_flutter/tree/main/lib/examples