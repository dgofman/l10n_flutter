/*
 * Copyright 2022 Developed by David Gofman
 *
 * Dynamic change of locale and routes
 */

import 'package:flutter/material.dart';
import 'package:l10n_flutter/examples/models/l10n.dart';
import 'package:l10n_flutter/l10n_core.dart';
import 'package:l10n_flutter/l10n_material_app.dart';

import 'models/demo3.dart';
import 'l10n_widget_helper.dart';

const _home = 'home', _about = 'about', _login = 'login';

class AppRouteDemo extends StatefulWidget {
  static Map<String, Function> routes = {
    // Enable UniqueKey to change locale at runtime
    _home: () =>
        MaterialPageRoute(builder: (_) => HomePage(_home, key: UniqueKey())),
    _about: () =>
        MaterialPageRoute(builder: (_) => AboutPage(_about, key: UniqueKey())),
    _login: () =>
        MaterialPageRoute(builder: (_) => LoginPage(_login, key: UniqueKey()))
  };

  const AppRouteDemo({Key? key}) : super(key: key);

  @override
  _AppRouteDemoState createState() => _AppRouteDemoState();
}

class _AppRouteDemoState extends State<AppRouteDemo> {
  L10nLocale? _locale;

  void changeLocale(L10nLocale? locale) async {
    await demo3Settings.selectLocale(locale);
    await l10nSettings.selectLocale(
        locale, false); // Combining values from multiple settings
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    changeLocale(const L10nLocale('he', 'IL'));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return L10nMaterialApp(
        locale: _locale, // Dynamic locale
        supportedLocales: demo3Settings
            .supportedLocales, // Provide a list of supported locales
        onGenerateRoute: (RouteSettings settings) =>
            AppRouteDemo.routes[settings.name]!(),
        initialRoute: _home);
  }
}

abstract class BasePage extends StatelessWidget {
  final String route;
  final L10nSet content;

  const BasePage(this.route, this.content, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stateWidget = context.findAncestorStateOfType<_AppRouteDemoState>()!;
    return FutureBuilder<L10nLocale?>(
        future: Future<L10nLocale?>.delayed(
            const Duration(milliseconds: 500), () => stateWidget._locale),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return createScaffold(context, stateWidget, snapshot.data);
          } else {
            return const Center(
              child: SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }

  Widget createScaffold(BuildContext context, _AppRouteDemoState stateWidget,
      L10nLocale currentLocale) {
    final isLTR = currentLocale.isLTR;
    return Scaffold(
        appBar: AppBar(
          title: Stack(
            children: <Widget>[
              Container(
                height: kToolbarHeight,
                alignment: isLTR ? Alignment.centerLeft : Alignment.centerRight,
                child: const Text(L10nApp.title,
                    style: TextStyle(color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                alignment: isLTR ? Alignment.centerRight : Alignment.centerLeft,
                child: DropdownButton<L10nLocale>(
                  underline: const Text(''),
                  icon: const Icon(
                    Icons.language,
                    color: Colors.white,
                  ),
                  onChanged: (L10nLocale? locale) {
                    stateWidget.changeLocale(locale);
                  },
                  value: currentLocale,
                  items: demo3Settings.locales
                      .map<DropdownMenuItem<L10nLocale>>(
                        (l) => DropdownMenuItem<L10nLocale>(
                          value: l,
                          child: Row(
                            children: <Widget>[WidgetHelper.getLocaleText(l)],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: AppRouteDemo.routes.keys
                .map<ListTile>((key) => ListTile(
                    enabled: key != route,
                    title: Text(L10nApp.titles[key]!.$),
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pushReplacementNamed(context, key);
                      }
                    }))
                .toList(),
          ),
        ),
        body: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                    child:
                        Text(content.$, style: const TextStyle(fontSize: 20))),
                const SizedBox(height: 30),
                createBody()
              ],
            ),
          ),
        ));
  }

  Widget createBody() => WidgetHelper.createTestBody();
}

class HomePage extends BasePage {
  const HomePage(String route, {Key? key})
      : super(route, L10nHome.content, key: key);
}

class AboutPage extends BasePage {
  const AboutPage(String route, {Key? key})
      : super(route, L10nAbout.content, key: key);

  @override
  Widget createBody() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text('''
${L10n.gasoline}
${L10n.coat}
${L10n.mailbox}
     '''),
    );
  }
}

class LoginPage extends BasePage {
  const LoginPage(String route, {Key? key})
      : super(route, L10nLogin.content, key: key);

  @override
  Widget createBody() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text('''
${L10n.highway}
${L10n.elevator}
${L10n.apartment}
     '''),
    );
  }
}

void main() => runApp(const AppRouteDemo());
