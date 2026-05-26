import 'package:flutter_test/flutter_test.dart';

import 'package:series_tracker/main.dart';

void main() {
  testWidgets('App renderiza sem crashar', (tester) async {
    await tester.pumpWidget(const SeriesTrackerApp());
  });
}
