import 'package:flutter/material.dart';
import 'package:flutter_echat/src/shared/widgets/t_avatar_widget.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: TAvatarWidget)
Widget buildTAvatarInteractive(BuildContext context) {
  return Center(
    child: TAvatarWidget(
      name: context.knobs.string(label: 'name', initialValue: 'Анна Иванова'),
      size: context.knobs.double.slider(
        label: 'size',
        initialValue: 48,
        min: 24,
        max: 96,
        divisions: 18,
      ),
      showOnlineDot: context.knobs.boolean(
        label: 'showOnlineDot',
        initialValue: true,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Default', type: TAvatarWidget)
Widget buildTAvatarDefault(BuildContext context) {
  return const Center(
    child: TAvatarWidget(name: 'Анна Иванова'),
  );
}

@widgetbook.UseCase(name: 'Online', type: TAvatarWidget)
Widget buildTAvatarOnline(BuildContext context) {
  return const Center(
    child: TAvatarWidget(name: 'Иван Петров', showOnlineDot: true),
  );
}
