import 'package:flutter_test/flutter_test.dart';
import 'package:markme/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('MarkMe Core Initialized'), findsOneWidget);
  });
}
