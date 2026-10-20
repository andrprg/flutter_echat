import 'package:flutter/material.dart';
import 'package:flutter_echat/src/shared/widgets/t_bottom_nav_bar.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: TBottomNavBar)
Widget buildTBottomNavBarInteractive(BuildContext context) {
  return _BottomNavBarPreview(
    initialIndex: context.knobs.int.slider(
      label: 'currentIndex',
      initialValue: 0,
      min: 0,
      max: 3,
    ),
  );
}

@widgetbook.UseCase(name: 'Чаты', type: TBottomNavBar)
Widget buildTBottomNavBarChats(BuildContext context) {
  return const _BottomNavBarPreview(initialIndex: 0);
}

@widgetbook.UseCase(name: 'Группы', type: TBottomNavBar)
Widget buildTBottomNavBarGroups(BuildContext context) {
  return const _BottomNavBarPreview(initialIndex: 1);
}

@widgetbook.UseCase(name: 'Профиль', type: TBottomNavBar)
Widget buildTBottomNavBarProfile(BuildContext context) {
  return const _BottomNavBarPreview(initialIndex: 2);
}

@widgetbook.UseCase(name: 'Ещё', type: TBottomNavBar)
Widget buildTBottomNavBarMore(BuildContext context) {
  return const _BottomNavBarPreview(initialIndex: 3);
}

/// Превью dumb-бара: выбор вкладки через локальный State (без go_router).
class _BottomNavBarPreview extends StatefulWidget {
  const _BottomNavBarPreview({required this.initialIndex});

  final int initialIndex;

  @override
  State<_BottomNavBarPreview> createState() => _BottomNavBarPreviewState();
}

class _BottomNavBarPreviewState extends State<_BottomNavBarPreview> {
  late int _currentIndex = widget.initialIndex;

  @override
  void didUpdateWidget(covariant _BottomNavBarPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['Чаты', 'Группы', 'Профиль', 'Ещё'];

    return Scaffold(
      body: Center(
        child: Text(
          labels[_currentIndex],
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      bottomNavigationBar: TBottomNavBar(
        currentIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
