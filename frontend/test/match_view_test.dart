import 'package:appdev_frontend/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows matched workers and booking buttons', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Matched Workers'), findsOneWidget);
    expect(find.text('Juan (Aircon Tech)'), findsOneWidget);
    expect(find.text('Rate: ₱500 - ₱800'), findsOneWidget);
    expect(find.text('Pedro (Plumber)'), findsOneWidget);
    expect(find.text('Rate: ₱300 - ₱500'), findsOneWidget);
    expect(find.text('Book'), findsNWidgets(2));
  });
}
