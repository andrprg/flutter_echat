import 'package:flutter/material.dart';
import 'package:flutter_echat/src/shared/widgets/t_avatar.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: TAvatar)
Widget buildTAvatarInteractive(BuildContext context) {
  return Center(
    child: TAvatar(
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

@widgetbook.UseCase(name: 'Default', type: TAvatar)
Widget buildTAvatarDefault(BuildContext context) {
  return const Center(
    child: TAvatar(name: 'Анна Иванова'),
  );
}

@widgetbook.UseCase(name: 'Online', type: TAvatar)
Widget buildTAvatarOnline(BuildContext context) {
  return const Center(
    child: TAvatar(name: 'Иван Петров', showOnlineDot: true),
  );
}
