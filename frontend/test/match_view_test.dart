import 'package:appdev_frontend/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows matched workers and booking buttons', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Matched Workers'), findsOneWidget);
    expect(find.text('Juan'), findsOneWidget);
    expect(find.text('Skill: Aircon Technician'), findsOneWidget);
    expect(find.text('Rate Range: ₱500 - ₱800'), findsOneWidget);
    expect(find.text('Pedro'), findsOneWidget);
    expect(find.text('Skill: Plumber'), findsOneWidget);
    expect(find.text('Rate Range: ₱300 - ₱500'), findsOneWidget);
    expect(find.text('Book Now'), findsNWidgets(2));
  });
}
