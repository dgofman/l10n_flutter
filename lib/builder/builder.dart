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
import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:io';

import 'package:build/build.dart';

Builder l10nBuilderFactory([BuilderOptions? options]) => L10nBuilder();

class L10nBuilder extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final library = await buildStep.inputLibrary;
    final Map<String, Set<String>> _locales = {};
    final Map<String, Map<String, String>> _usedKeys = {};
    final Map<String, Map<String, String>> _commonKeys = {};
    final Map<String, Map<String, String>> _langKeys = {};
    final Map<String, String> _outputDir = {};
    for (var u in library.units) {
      for (var t in u.classes) {
        //class level
        for (var m in t.metadata) {
          String an = m.element!.name!; // Map by annotation name
          if (!_usedKeys.containsKey(an)) {
            _usedKeys[an] = {};
          }
          if (!_commonKeys.containsKey(an)) {
            _commonKeys[an] = {};
          }
          if (!_langKeys.containsKey(an)) {
            _langKeys[an] = {};
          }
          if ('${m.element}'.startsWith(RegExp(r'L10nSettings*'))) {
            if (!_locales.containsKey(an)) {
              _locales[an] = {};
              final settings = m.computeConstantValue()!;
              if (settings.getField('path') != null && !settings.getField('path')!.isNull) {
                _outputDir[an] = settings.getField('path')!.toStringValue()!;
              }
              for (var el in settings.getField('locales')!.toListValue()!) {
                log.fine('Locale: $el');
                if (el.getField('countryCode') != null && el.getField('countryCode')!.isNull) {
                  _locales[an]?.add(el.getField('languageCode')!.toStringValue()!);
                } else {
                  _locales[an]?.add(
                      el.getField('languageCode')!.toStringValue()! +
                          '_' +
                          el.getField('countryCode')!.toStringValue()!);
                }
              }
            }
            for (var f in t.fields) {
              final val = f.computeConstantValue()!;
              log.fine('${t.name}::${f.name} = $val');
              if (val.type.toString().startsWith(RegExp(r'L10nSet*'))) {
                findKeyAndvalue('${t.name}::${f.name}', val, _usedKeys[an], _commonKeys[an], _langKeys[an]);
              } else if (val.type.toString().startsWith(RegExp(r'Map<String*?, L10nSet*?>*'))) {
                val.toMapValue()!.forEach((key, val) {
                  findKeyAndvalue('${t.name}::${f.name}::${key!.toStringValue()}', val, _usedKeys[an], _commonKeys[an], _langKeys[an]);
                });
              }
            }
          }
        }
      }
    }
    _locales.forEach((an, locales) {
      //generate report for each L10nSettings
      createReport(
          _outputDir[an],
          locales,
          _commonKeys[an],
          _langKeys[an]);
    });
  }

  void findKeyAndvalue(varName, val, usedKeys, commonKeys, langKeys) {
    final key = val.getField('_key').toStringValue();
    if (usedKeys.containsKey(key)) {
      throw Exception(
          'Duplicated key "$key" defined in "${usedKeys[key]}" and "$varName"');
    }
    usedKeys[key] = varName;
    if (val.getField('common').toBoolValue()) {
      commonKeys[key] = val.getField('_value').toStringValue();
    } else {
      langKeys[key] = val.getField('_value').toStringValue();
    }
  }

  void createReport(String? outputDir, Set<String> locales,
      Map<String, String>? commonKeys, Map<String, String>? langKeys) {
    outputDir = outputDir ?? 'assets/l10n/';
    if (!outputDir.endsWith('/')) {
      outputDir += '/';
    }
    if (!File(outputDir).existsSync()) {
      Directory(outputDir).createSync(recursive: true);
    }
    Map<String, dynamic> report = {"new_keys_file": [], "del_keys_file": []};
    final common = {};
    locales.toList()
      ..sort()
      ..forEach((code) {
        final pair = code.split('_');
        File file;
        // common keys
        if (!common.containsKey(pair[0])) {
          common[pair[0]] = true;
          file = File(outputDir! + pair[0] + '.json');
          createJson(file, commonKeys, report);
        }
        if (pair.length == 2) {
          file = File(
              outputDir! + (pair.length == 1 ? pair[0] : code) + '.json');
          createJson(file, langKeys, report);
        }
      });
    StringBuffer sb = StringBuffer();
    sb.write('''
<!doctype html>
<html lang='en'>
<head>
<meta charset='utf-8'>
<meta http-equiv='Cache-control' content='no-cache'>
<title>L10n Report</title>
<style>
html {background: lightblue}
li {padding: 2px 5px; margin: 2px 0}
h3 {padding: 3px; margin: 0; color: darkblue}
pre { white-space: pre-wrap;}
.accordion input {display: none;}
.accordion label {background: #eee; cursor: pointer; display: block; margin-bottom: .125em; padding: .25em 1em;}
.accordion label:hover {background: #ccc;}
.accordion input:checked + label {background: #ccc; color: white;}
.accordion article {background: #f7f7f7; height:0px;overflow:hidden;}
.accordion input:checked ~ article {height: auto;}
</style>
</head>
<body>
<h1>L10n Report</h1>
<h4>Release Date: ${DateTime.now().toIso8601String().replaceAll('T', '   ').split('.').first}</h4>
<h2 style="color: darkgreen; margin-top: 1em">New Keys:</h2>
''');

    int index = 0;
    report['new_keys_file'].forEach((file) => {
          sb.write('''
          <h3>${file[0]}</h3>
<section class='accordion'>
<input type='checkbox' id='check-$index'/>
<label for='check-${index++}'><b>Total:</b> ${file[2]}</label>
<article>
<pre>
${file[1].join('\n')}
</pre>
</article>
</section>
      ''')
        });
    sb.write('<h2 style="color: darkred; margin-top: 3em;">Deleted Keys:</h2>');
    report['del_keys_file'].forEach((file) => {
          sb.write('''
          <h3>${file[0]}</h3>
<section class='accordion'>
<input type='checkbox' id='check-$index'/>
<label for='check-${index++}'><b>Total:</b> ${file[2]}</label>
<article>
<pre>
${file[1].join('\n')}
</pre>
</article>
</section>
      ''')
        });
    sb.write('</body>\n</html>');
    File(outputDir + 'report.html').writeAsString(sb.toString());
    return;
  }

  String createJson(
      File file, Map<String, dynamic>? dict, Map<String, dynamic> report) {
    Map<String, dynamic> content = {};
    List newKeys = [];
    List delKeys = [];
    if (file.existsSync()) {
      try {
        content = jsonDecode(file.readAsStringSync());
      // ignore: empty_catches
      } catch (err) {}
    }
    List<String> lines = [];
    for (var key in dict!.keys.toList()..sort()) {
      if (!content.containsKey(key)) {
        newKeys.add(key);
      }
      lines.add('\t"$key": ${jsonEncode(content[key] ?? dict[key])}');
      content.remove(key);
    }
    for (var key in content.keys) {
      delKeys.add('$key = ${content[key]}');
    }
    if (newKeys.isNotEmpty) {
      report['new_keys_file'].add([file.path, newKeys, newKeys.length]);
    }
    if (delKeys.isNotEmpty) {
      report['del_keys_file'].add([file.path, delKeys, delKeys.length]);
    }
    String json = '{\n${lines.join(',\n')}\n}';
    file.writeAsString(json);
    return json;
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        'dart': ['json']
      };
}
