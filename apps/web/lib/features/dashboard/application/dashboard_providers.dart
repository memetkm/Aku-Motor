import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motors/application/motor_providers.dart';
import 'dashboard_summary.dart';

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  return ref.watch(motorListProvider).whenData(DashboardSummary.fromMotors);
});
