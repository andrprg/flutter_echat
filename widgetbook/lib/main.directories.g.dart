// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:flutter_echat_widgetbook/components/t_avatar.dart'
    as _flutter_echat_widgetbook_components_t_avatar;
import 'package:flutter_echat_widgetbook/components/t_button.dart'
    as _flutter_echat_widgetbook_components_t_button;
import 'package:flutter_echat_widgetbook/components/t_error_banner.dart'
    as _flutter_echat_widgetbook_components_t_error_banner;
import 'package:widgetbook/widgetbook.dart' as _widgetbook;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookFolder(
    name: 'shared',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'widgets',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'TAvatarWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Default',
                builder: _flutter_echat_widgetbook_components_t_avatar
                    .buildTAvatarDefault,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Interactive',
                builder: _flutter_echat_widgetbook_components_t_avatar
                    .buildTAvatarInteractive,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Online',
                builder: _flutter_echat_widgetbook_components_t_avatar
                    .buildTAvatarOnline,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'TButtonWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Danger',
                builder: _flutter_echat_widgetbook_components_t_button
                    .buildTButtonDanger,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Disabled',
                builder: _flutter_echat_widgetbook_components_t_button
                    .buildTButtonDisabled,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Interactive',
                builder: _flutter_echat_widgetbook_components_t_button
                    .buildTButtonInteractive,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Loading',
                builder: _flutter_echat_widgetbook_components_t_button
                    .buildTButtonLoading,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Primary',
                builder: _flutter_echat_widgetbook_components_t_button
                    .buildTButtonPrimary,
              ),
            ],
          ),
          _widgetbook.WidgetbookComponent(
            name: 'TErrorBannerWidget',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Auth',
                builder: _flutter_echat_widgetbook_components_t_error_banner
                    .buildTErrorBannerAuth,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Interactive',
                builder: _flutter_echat_widgetbook_components_t_error_banner
                    .buildTErrorBannerInteractive,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Long message',
                builder: _flutter_echat_widgetbook_components_t_error_banner
                    .buildTErrorBannerLongMessage,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Network',
                builder: _flutter_echat_widgetbook_components_t_error_banner
                    .buildTErrorBannerNetwork,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Unexpected',
                builder: _flutter_echat_widgetbook_components_t_error_banner
                    .buildTErrorBannerUnexpected,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
