import 'package:derin_deniz_murettebati/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App başlıyor', (WidgetTester tester) async {
    await tester.pumpWidget(const DerinDenizApp());
    await tester.pump();
    expect(find.textContaining('Derin Deniz'), findsOneWidget);
  });
}
