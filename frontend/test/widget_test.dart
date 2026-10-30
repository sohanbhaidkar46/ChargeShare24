import 'package:flutter_test/flutter_test.dart';
import 'package:chargeshare/main.dart';

void main() {
  testWidgets('ChargeShare login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ChargeShareApp());
    expect(find.text('ChargeShare'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
