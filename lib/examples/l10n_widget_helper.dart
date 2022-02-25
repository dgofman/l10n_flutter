import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:l10n_flutter/examples/models/l10n.dart';
import 'package:l10n_flutter/l10n_core.dart';

class WidgetHelper {
  static Widget createTestBody() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 10),
        color: Colors.white,
        child: Text(
          '''
${L10n.gasoline}
${L10n.coat}
${L10n.mailbox}
${L10n.highway}
${L10n.elevator}
${L10n.apartment}

${L10n.whatIsLP.sub([L10n.loremIpsum, L10n.pageMaker])}
      ''',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.normal, fontSize: 18, decoration: TextDecoration.none),
        ),
      ),
    );
  }

  static Widget createMaterialScaffold(BuildContext context, int menuIndex, Function(Locale? locale) changeLocale) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(L10n.title),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: DropdownButtonHideUnderline(
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButton<L10nLocale>(
                    icon: const Icon(
                      Icons.language,
                      color: Colors.white,
                    ),
                    onChanged: changeLocale,
                    value: l10nSettings.locales[menuIndex],
                    items: l10nSettings.locales
                        .map<DropdownMenuItem<L10nLocale>>(
                          (l) => DropdownMenuItem<L10nLocale>(
                            value: l,
                            child: Row(
                              children: <Widget>[getLocaleText(l)],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: createTestBody());
  }

  static Widget createCupertinoScaffold(BuildContext context, int menuIndex, Function(Locale? locale) changeLocale) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: DefaultTextStyle(
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
                child: const Text(L10n.title),
              )),
          trailing: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: const MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Icon(CupertinoIcons.globe),
              ),
              onPressed: () {
                showCupertinoModalPopup(
                    context: context,
                    builder: (_) => Container(
                          height: 150,
                          decoration: const BoxDecoration(
                            color: CupertinoColors.lightBackgroundGray,
                            border: Border(
                              top: BorderSide(
                                color: Color(0xff999999),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: CupertinoPicker(
                            itemExtent: 30,
                            scrollController: FixedExtentScrollController(initialItem: menuIndex),
                            children: l10nSettings.locales.map((l) => getLocaleText(l)).toList(),
                            onSelectedItemChanged: (index) {
                              changeLocale(l10nSettings.locales[index]);
                            },
                          ),
                        ));
              }),
        ),
        child: WidgetHelper.createTestBody());
  }

  static Text getLocaleText(L10nLocale l) =>
      Text(l.label != null ? l.label! : l.languageCode + (l.countryCode != null ? '_' + l.countryCode! : ''));
}
