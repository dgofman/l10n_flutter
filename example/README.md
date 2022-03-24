```

import 'package:flutter/cupertino.dart';
import 'package:l10n_flutter/l10n_material_app.dart';

import 'models/l10n.dart';
import 'l10n_widget_helper.dart';

class MaterialAppDemo extends StatefulWidget {
  const MaterialAppDemo({Key? key}) : super(key: key);

  @override
  _MaterialAppDemoState createState() => _MaterialAppDemoState();
}

class _MaterialAppDemoState extends State<MaterialAppDemo> {
  Locale? _locale = const Locale('he', 'IL');

  void changeLocale(Locale? newLocale) async {
    await l10nSettings.selectLocale(newLocale);
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  void initState() {
    changeLocale(_locale);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return L10nMaterialApp(
      locale: _locale, // Dynamic locale
      supportedLocales: l10nSettings.supportedLocales, // Provide a list of supported locales
      home: WidgetHelper.createMaterialScaffold(context, l10nSettings.indexOf(_locale), changeLocale),
    );
  }
}
void main() => runApp(const MaterialAppDemo());
```

# Examples

https://github.com/dgofman/l10n_flutter/tree/main/lib/examples

## See Also

- https://pub.dev/packages/framework
- https://pub.dev/packages/l10n_flutter
- https://pub.dev/packages/form_components
- https://pub.dev/packages/expansion_datagrid