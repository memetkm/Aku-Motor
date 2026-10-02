import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/motors/presentation/motor_list_screen.dart';

class AkuMotorApp extends StatelessWidget {
  const AkuMotorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aku Motor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: DashboardScreen.routeName,
      routes: {
        DashboardScreen.routeName: (_) => const DashboardScreen(),
        MotorListScreen.routeName: (_) => const MotorListScreen(),
      },
    );
  }
}
