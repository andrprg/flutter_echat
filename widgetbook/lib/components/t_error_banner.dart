import 'package:flutter/material.dart';
import 'package:flutter_echat/src/shared/widgets/t_error_banner_widget.dart';
import 'package:flutter_echat/src/utils/exceptions/auth_failure_reason.dart';
import 'package:flutter_echat/src/utils/exceptions/failures.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(name: 'Interactive', type: TErrorBannerWidget)
Widget buildTErrorBannerInteractive(BuildContext context) {
  final failure = _failureFromKnob(
    context.knobs.object.dropdown(
      label: 'failure',
      options: _FailureKnob.values,
      initialOption: _FailureKnob.network,
      labelBuilder: (value) => value?.name ?? '',
    ),
  );

  return _ErrorBannerPreview(
    message: failure.displayMessage,
    leftMargin: context.knobs.double.slider(
      label: 'leftMargin',
      initialValue: 0,
      min: 0,
      max: 48,
      divisions: 12,
    ),
    rightMargin: context.knobs.double.slider(
      label: 'rightMargin',
      initialValue: 0,
      min: 0,
      max: 48,
      divisions: 12,
    ),
  );
}

@widgetbook.UseCase(name: 'Network', type: TErrorBannerWidget)
Widget buildTErrorBannerNetwork(BuildContext context) {
  return _ErrorBannerPreview(
    message: const Failure.network().displayMessage,
  );
}

@widgetbook.UseCase(name: 'Auth', type: TErrorBannerWidget)
Widget buildTErrorBannerAuth(BuildContext context) {
  return _ErrorBannerPreview(
    message: const Failure.auth(AuthFailureReason.wrongPassword).displayMessage,
    leftMargin: 16,
    rightMargin: 16,
  );
}

@widgetbook.UseCase(name: 'Unexpected', type: TErrorBannerWidget)
Widget buildTErrorBannerUnexpected(BuildContext context) {
  return _ErrorBannerPreview(
    message: const Failure.unexpected('demo').displayMessage,
  );
}

@widgetbook.UseCase(name: 'Long message', type: TErrorBannerWidget)
Widget buildTErrorBannerLongMessage(BuildContext context) {
  return const _ErrorBannerPreview(
    message:
        'Не удалось отправить сообщение: нет соединения с сетью. '
        'Проверьте Wi‑Fi или мобильный интернет и повторите попытку.',
    leftMargin: 16,
    rightMargin: 16,
  );
}

/// Превью dumb-карточки: без Riverpod — закрытие через локальный State.
class _ErrorBannerPreview extends StatefulWidget {
  const _ErrorBannerPreview({
    required this.message,
    this.leftMargin = 0,
    this.rightMargin = 0,
  });

  final String message;
  final double leftMargin;
  final double rightMargin;

  @override
  State<_ErrorBannerPreview> createState() => _ErrorBannerPreviewState();
}

class _ErrorBannerPreviewState extends State<_ErrorBannerPreview> {
  var _visible = true;
  /// Меняется только при повторном «Показать» (не на каждый rebuild).
  Key _bannerKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return Center(
        child: TextButton(
          onPressed: () => setState(() {
            _bannerKey = UniqueKey();
            _visible = true;
          }),
          child: const Text('Показать баннер'),
        ),
      );
    }

    return Align(
      alignment: Alignment.topCenter,
      child: TErrorBannerWidget(
        key: _bannerKey,
        message: widget.message,
        leftMargin: widget.leftMargin,
        rightMargin: widget.rightMargin,
        onClose: () => setState(() => _visible = false),
      ),
    );
  }
}

enum _FailureKnob {
  network,
  auth,
  firestore,
  notFound,
  unexpected,
}

Failure _failureFromKnob(_FailureKnob? knob) {
  return switch (knob ?? _FailureKnob.network) {
    _FailureKnob.network => const Failure.network(),
    _FailureKnob.auth =>
      const Failure.auth(AuthFailureReason.wrongPassword),
    _FailureKnob.firestore => const Failure.firestore('permission-denied'),
    _FailureKnob.notFound => const Failure.notFound(),
    _FailureKnob.unexpected => const Failure.unexpected('demo'),
  };
}
