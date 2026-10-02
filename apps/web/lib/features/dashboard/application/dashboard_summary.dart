import '../../motors/domain/motor.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.totalMotors,
    required this.totalKilometer,
    required this.latestMotor,
  });

  final int totalMotors;
  final int totalKilometer;
  final Motor? latestMotor;

  factory DashboardSummary.fromMotors(List<Motor> motors) {
    return DashboardSummary(
      totalMotors: motors.length,
      totalKilometer: motors.fold(0, (sum, motor) => sum + motor.currentKilometer),
      latestMotor: motors.isEmpty ? null : motors.first,
    );
  }
}
