import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/strings.dart';
import 'providers/monitoring_provider.dart';
import 'providers/risk_provider.dart';
import 'providers/device_provider.dart';
import 'widgets/bottom_navigation.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MonitoringProvider()),
        ChangeNotifierProvider(create: (_) => RiskProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
      ],
      child: const SobiApp(),
    ),
  );
}

class SobiApp extends StatelessWidget {
  const SobiApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
