// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';
import 'package:sobi/providers/monitoring_provider.dart';
import 'package:sobi/providers/risk_provider.dart';
import 'package:sobi/providers/device_provider.dart';

import 'package:sobi/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MonitoringProvider()),
          ChangeNotifierProvider(create: (_) => RiskProvider()),
          ChangeNotifierProvider(create: (_) => DeviceProvider()),
        ],
        child: const SobiApp(),
      ),
    );
    expect(find.byType(SobiApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
