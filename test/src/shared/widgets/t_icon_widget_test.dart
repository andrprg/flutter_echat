import 'package:flutter/material.dart';
import 'package:flutter_echat/src/shared/widgets/t_icon_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics/vector_graphics.dart';

void main() {
  Widget wrap(Widget child, {IconThemeData? iconTheme}) {
    return MaterialApp(
      home: Scaffold(
        body: iconTheme == null
            ? child
            : IconTheme(data: iconTheme, child: child),
      ),
    );
  }

  VectorGraphic findVectorGraphic(WidgetTester tester) {
    return tester.widget<VectorGraphic>(find.byType(VectorGraphic));
  }

  AssetBytesLoader findLoader(WidgetTester tester) {
    return findVectorGraphic(tester).loader as AssetBytesLoader;
  }

  group('TIconWidget', () {
    testWidgets('передаёт размер по умолчанию 24×24 в VectorGraphic', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(const TIconWidget(icon: 'outline_search_magnifer')),
      );

      final graphic = findVectorGraphic(tester);
      expect(graphic.width, 24);
      expect(graphic.height, 24);
    });

    testWidgets('передаёт кастомные width и height', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          const TIconWidget(
            icon: 'outline_search_magnifer',
            width: 32,
            height: 40,
          ),
        ),
      );

      final graphic = findVectorGraphic(tester);
      expect(graphic.width, 32);
      expect(graphic.height, 40);
    });

    testWidgets('добавляет .svg к имени иконки без расширения', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(const TIconWidget(icon: 'outline_search_magnifer')),
      );

      expect(
        findLoader(tester).assetName,
        'assets/icons/outline_search_magnifer.svg',
      );
    });

    testWidgets('не дублирует .svg, если расширение уже указано', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(const TIconWidget(icon: 'outline_search_magnifer.svg')),
      );

      expect(
        findLoader(tester).assetName,
        'assets/icons/outline_search_magnifer.svg',
      );
    });

    testWidgets('применяет ColorFilter, если задан color', (
      WidgetTester tester,
    ) async {
      const color = Color(0xFF112233);

      await tester.pumpWidget(
        wrap(
          const TIconWidget(
            icon: 'outline_search_magnifer',
            color: color,
          ),
        ),
      );

      expect(
        findVectorGraphic(tester).colorFilter,
        const ColorFilter.mode(color, BlendMode.srcIn),
      );
    });

    testWidgets('берёт цвет из IconTheme, если color не задан', (
      WidgetTester tester,
    ) async {
      const themeColor = Color(0xFFAABBCC);

      await tester.pumpWidget(
        wrap(
          const TIconWidget(icon: 'outline_search_magnifer'),
          iconTheme: const IconThemeData(color: themeColor),
        ),
      );

      expect(
        findVectorGraphic(tester).colorFilter,
        const ColorFilter.mode(themeColor, BlendMode.srcIn),
      );
    });

    testWidgets('не применяет ColorFilter, если applyColorFilter = false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const TIconWidget(
            icon: 'outline_search_magnifer',
            color: Color(0xFF112233),
            applyColorFilter: false,
          ),
        ),
      );

      expect(findVectorGraphic(tester).colorFilter, isNull);
    });

    testWidgets(
      'без color применяет чёрный ColorFilter из fallback IconTheme',
      (WidgetTester tester) async {
        // IconTheme.of всегда мержит IconThemeData.fallback() (чёрный).
        await tester.pumpWidget(
          const Directionality(
            textDirection: TextDirection.ltr,
            child: TIconWidget(icon: 'outline_search_magnifer'),
          ),
        );

        expect(
          findVectorGraphic(tester).colorFilter,
          const ColorFilter.mode(Color(0xFF000000), BlendMode.srcIn),
        );
      },
    );

    testWidgets(
      'показывает Icons.broken_image_outlined, если ассет не найден',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          wrap(
            const TIconWidget(
              icon: 'definitely_missing_icon',
              width: 48,
              color: Color(0xFF334455),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);

        final icon = tester.widget<Icon>(
          find.byIcon(Icons.broken_image_outlined),
        );
        expect(icon.size, 48);
        expect(icon.color, const Color(0xFF334455));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'fallback-иконка использует цвет из IconTheme',
      (WidgetTester tester) async {
        const themeColor = Color(0xFF556677);

        await tester.pumpWidget(
          wrap(
            const TIconWidget(icon: 'definitely_missing_icon'),
            iconTheme: const IconThemeData(color: themeColor),
          ),
        );
        await tester.pumpAndSettle();

        final icon = tester.widget<Icon>(
          find.byIcon(Icons.broken_image_outlined),
        );
        expect(icon.color, themeColor);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
