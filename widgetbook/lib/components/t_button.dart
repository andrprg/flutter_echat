import 'package:flutter/material.dart';
import 'package:flutter_echat/src/shared/widgets/t_button_widget.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: TButtonWidget)
Widget buildTButtonInteractive(BuildContext context) {
  final enabled = context.knobs.boolean(label: 'enabled', initialValue: true);
  final showIcon = context.knobs.boolean(label: 'showIcon', initialValue: true);

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: TButtonWidget(
        label: context.knobs.string(label: 'label', initialValue: 'Войти'),
        variant: context.knobs.object.dropdown(
          label: 'variant',
          options: TButtonVariant.values,
          labelBuilder: (value) => value.name,
        ),
        isLoading: context.knobs.boolean(label: 'isLoading'),
        icon: showIcon
            ? context.knobs.string(
                label: 'icon',
                initialValue: 'outline_arrows_action_login_3',
              )
            : null,
        onTap: enabled ? () {} : null,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Primary', type: TButtonWidget)
Widget buildTButtonPrimary(BuildContext context) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: TButtonWidget(
        label: 'Войти',
        icon: 'outline_arrows_action_login_3',
        onTap: _noop,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Danger', type: TButtonWidget)
Widget buildTButtonDanger(BuildContext context) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: TButtonWidget(
        label: 'Удалить',
        variant: TButtonVariant.danger,
        onTap: _noop,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Loading', type: TButtonWidget)
Widget buildTButtonLoading(BuildContext context) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: TButtonWidget(
        label: 'Войти',
        isLoading: true,
        onTap: _noop,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Disabled', type: TButtonWidget)
Widget buildTButtonDisabled(BuildContext context) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: TButtonWidget(label: 'Войти'),
    ),
  );
}

void _noop() {}
