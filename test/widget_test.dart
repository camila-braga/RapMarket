import 'package:flutter_test/flutter_test.dart';
import 'package:rap_market/main.dart';

void main() {
  testWidgets('Smoke test - App start', (WidgetTester tester) async {
    await tester.pumpWidget(const RapMarketApp());

    expect(find.text('RapMarket'), findsWidgets);
  });
}
