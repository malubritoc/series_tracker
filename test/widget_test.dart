import 'package:flutter_test/flutter_test.dart';

import 'package:series_tracker/main.dart';

void main() {
  testWidgets('App renderiza a AppBar de Populares', (tester) async {
    await tester.pumpWidget(const SeriesTrackerApp());
    expect(find.text('Populares'), findsOneWidget);
  });
}
