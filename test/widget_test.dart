import 'package:flutter_test/flutter_test.dart';
import 'package:pr2_hotel/main.dart';

void main() {
  testWidgets('App starts without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const HotelApp());
    expect(find.byType(HotelApp), findsOneWidget);
  });
}
