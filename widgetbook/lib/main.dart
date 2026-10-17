import 'package:flutter/material.dart';
import 'package:flutter_echat/src/utils/theme/theme.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

/// Entry point песочницы Widgetbook для dumb-виджетов E-Chat.
@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: TAppTheme.lightTheme),
            WidgetbookTheme(name: 'Dark', data: TAppTheme.darkTheme),
          ],
        ),
        ViewportAddon([
          Viewports.none,
          IosViewports.iPhoneSE,
          IosViewports.iPhone13,
          AndroidViewports.samsungGalaxyS20,
          AndroidViewports.samsungGalaxyNote20,
        ]),
        AlignmentAddon(),
        InspectorAddon(),
      ],
    );
  }
}
