import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TAsyncValueWidget<T> extends StatelessWidget {
  const TAsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.errorWidget,
    this.loadingWidget,
    this.skipLoadingOnReload = true,
  });
  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget? errorWidget;
  final Widget? loadingWidget;
  final bool skipLoadingOnReload;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: (e, st) => errorWidget ?? const SizedBox.shrink(),
      loading: () => loadingWidget ?? const SizedBox.shrink(),
      skipLoadingOnReload: skipLoadingOnReload,
    );
  }
}
