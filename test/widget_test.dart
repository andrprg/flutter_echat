import 'package:flutter_echat/src/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EChatApp показывает заголовок', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EChatApp(),
      ),
    );

    expect(find.text('E-Chat'), findsOneWidget);
  });
}
