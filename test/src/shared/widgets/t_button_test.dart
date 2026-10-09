import 'package:flutter/material.dart';
import 'package:flutter_echat/src/shared/widgets/t_button.dart';
import 'package:flutter_echat/src/shared/widgets/t_icon_widget.dart';
import 'package:flutter_echat/src/utils/constants/colors.dart';
import 'package:flutter_echat/src/utils/constants/sizes.dart';
import 'package:flutter_echat/src/utils/theme/theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(
    Widget child, {
    ThemeData? theme,
    Brightness brightness = Brightness.light,
  }) {
    return MaterialApp(
      theme: theme ??
          (brightness == Brightness.dark
              ? TAppTheme.darkTheme
              : TAppTheme.lightTheme),
      home: Scaffold(body: child),
    );
  }

  ElevatedButton findElevatedButton(WidgetTester tester) {
    return tester.widget<ElevatedButton>(find.byType(ElevatedButton));
  }

  BoxDecoration findDecoration(WidgetTester tester) {
    return tester
        .widget<DecoratedBox>(
          find.descendant(
            of: find.byType(TButton),
            matching: find.byType(DecoratedBox),
          ),
        )
        .decoration as BoxDecoration;
  }

  Color? resolveBackground(
    ElevatedButton button, [
    Set<WidgetState> states = const {},
  ]) {
    return button.style?.backgroundColor?.resolve(states);
  }

  RoundedRectangleBorder? resolveShape(ElevatedButton button) {
    return button.style?.shape?.resolve({}) as RoundedRectangleBorder?;
  }

  group('TButton', () {
    testWidgets('отображает label', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(TButton(label: 'Войти', onTap: () {})),
      );

      expect(find.text('Войти'), findsOneWidget);
    });

    testWidgets('вызывает onTap при нажатии', (WidgetTester tester) async {
      var taps = 0;

      await tester.pumpWidget(
        wrap(TButton(label: 'Войти', onTap: () => taps++)),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('при onTap: null кнопка отключена', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(const TButton(label: 'Войти')),
      );

      expect(findElevatedButton(tester).onPressed, isNull);
    });

    testWidgets(
      'при isLoading показывает индикатор и скрывает текст',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(
            TButton(label: 'Войти', isLoading: true, onTap: () {}),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Войти'), findsNothing);
      },
    );

    testWidgets(
      'при isLoading не вызывает onTap и onPressed == null',
      (WidgetTester tester) async {
        var taps = 0;

        await tester.pumpWidget(
          wrap(
            TButton(
              label: 'Войти',
              isLoading: true,
              onTap: () => taps++,
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(taps, 0);
        expect(findElevatedButton(tester).onPressed, isNull);
      },
    );

    testWidgets(
      'при isLoading primary сохраняет градиент (не disabled-фон)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(
            TButton(
              label: 'Войти',
              variant: TButtonVariant.primary,
              isLoading: true,
              onTap: () {},
            ),
          ),
        );
        await tester.pump();

        final decoration = findDecoration(tester);
        expect(decoration.gradient, TColors.gradientLightBlue);
        expect(decoration.color, isNull);
        expect(findElevatedButton(tester).onPressed, isNull);
      },
    );

    testWidgets(
      'при isLoading danger сохраняет error500 (не disabled-фон)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(
            TButton(
              label: 'Удалить',
              variant: TButtonVariant.danger,
              isLoading: true,
              onTap: () {},
            ),
          ),
        );
        await tester.pump();

        final decoration = findDecoration(tester);
        expect(decoration.color, TColors.error500);
        expect(decoration.gradient, isNull);
      },
    );

    testWidgets(
      'primary задаёт градиент gradientLightBlue на DecoratedBox',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(
            TButton(
              label: 'Войти',
              variant: TButtonVariant.primary,
              onTap: () {},
            ),
          ),
        );

        final decoration = findDecoration(tester);
        expect(decoration.gradient, TColors.gradientLightBlue);
        expect(decoration.color, isNull);
        expect(resolveBackground(findElevatedButton(tester)), Colors.transparent);
      },
    );

    testWidgets(
      'danger задаёт цвет error500 на DecoratedBox',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(
            TButton(
              label: 'Удалить',
              variant: TButtonVariant.danger,
              onTap: () {},
            ),
          ),
        );

        final decoration = findDecoration(tester);
        expect(decoration.color, TColors.error500);
        expect(decoration.gradient, isNull);
        expect(resolveBackground(findElevatedButton(tester)), Colors.transparent);
      },
    );

    testWidgets(
      'в disabled-состоянии DecoratedBox — нейтральный фон',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(const TButton(label: 'Войти')),
        );

        final decoration = findDecoration(tester);
        expect(decoration.color, TColors.neutral100);
        expect(decoration.gradient, isNull);
        expect(
          resolveBackground(
            findElevatedButton(tester),
            {WidgetState.disabled},
          ),
          Colors.transparent,
        );
      },
    );

    testWidgets(
      'в disabled тёмной теме DecoratedBox — neutral800',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(
            const TButton(label: 'Войти'),
            brightness: Brightness.dark,
          ),
        );

        expect(findDecoration(tester).color, TColors.neutral800);
      },
    );

    testWidgets(
      'по умолчанию использует radius из TSizes.buttonRadius',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(TButton(label: 'Войти', onTap: () {})),
        );

        expect(
          resolveShape(findElevatedButton(tester))?.borderRadius,
          BorderRadius.circular(TSizes.buttonRadius),
        );
        expect(
          findDecoration(tester).borderRadius,
          BorderRadius.circular(TSizes.buttonRadius),
        );
      },
    );

    testWidgets('применяет кастомный radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(TButton(label: 'Войти', radius: 12, onTap: () {})),
      );

      expect(
        resolveShape(findElevatedButton(tester))?.borderRadius,
        BorderRadius.circular(12),
      );
      expect(findDecoration(tester).borderRadius, BorderRadius.circular(12));
    });

    testWidgets('применяет кастомную width', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          Center(
            child: TButton(label: 'Войти', width: 200, onTap: () {}),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(TButton),
          matching: find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.child is DecoratedBox,
          ),
        ),
      );

      expect(sizedBox.width, 200);
    });

    testWidgets(
      'показывает иконку, если icon задан и не isLoading',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(
            TButton(
              label: 'Войти',
              icon: 'outline_search_magnifer',
              onTap: () {},
            ),
          ),
        );

        expect(find.byType(TIconWidget), findsOneWidget);
        expect(find.text('Войти'), findsOneWidget);
      },
    );

    testWidgets(
      'скрывает иконку при isLoading',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(
            TButton(
              label: 'Войти',
              icon: 'outline_search_magnifer',
              isLoading: true,
              onTap: () {},
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(TIconWidget), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'в светлой теме текст белый',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(
            TButton(label: 'Войти', onTap: () {}),
            brightness: Brightness.light,
          ),
        );

        final text = tester.widget<Text>(find.text('Войти'));
        expect(text.style?.color, TColors.white);
      },
    );

    testWidgets(
      'в тёмной теме текст neutral900',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(
            TButton(label: 'Войти', onTap: () {}),
            brightness: Brightness.dark,
          ),
        );

        final text = tester.widget<Text>(find.text('Войти'));
        expect(text.style?.color, TColors.neutral900);
      },
    );
  });
}
