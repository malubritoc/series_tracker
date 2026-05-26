import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:series_tracker/main.dart';

void main() {
  testWidgets('App renderiza navigation bar com Populares e Favoritos',
      (tester) async {
    await tester.pumpWidget(const SeriesTrackerApp());
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Populares'), findsWidgets);
    expect(find.text('Favoritos'), findsWidgets);
  });
}
