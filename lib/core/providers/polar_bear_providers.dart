import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ecoloop_providers.dart';

enum PolarBearCondition {
  healthy,    // <= 2.0 kg CO2/day (cool, happy, snowflakes)
  moderate,   // 2.0 - 5.0 kg CO2/day (concerned, slightly warm)
  highCarbon, // 5.0 - 10.0 kg CO2/day (worried, warning aura, melting cue)
  critical,   // > 10.0 kg CO2/day (very worried, melting ice, red warning)
}

class PolarBearStatus {
  final PolarBearCondition condition;
  final double dailyCo2Kg;
  final double weeklyCo2Kg;
  final double weeklyReductionPct;
  final String speechMessage;
  final String statusHeadline;

  const PolarBearStatus({
    required this.condition,
    required this.dailyCo2Kg,
    required this.weeklyCo2Kg,
    required this.weeklyReductionPct,
    required this.speechMessage,
    required this.statusHeadline,
  });

  bool get isCool => condition == PolarBearCondition.healthy;
  bool get hasWarning => condition == PolarBearCondition.highCarbon || condition == PolarBearCondition.critical;
}

final polarBearStatusProvider = Provider<PolarBearStatus>((ref) {
  final activitiesAsync = ref.watch(userActivitiesProvider);
  final activities = activitiesAsync.value ?? [];

  if (activities.isEmpty) {
    return const PolarBearStatus(
      condition: PolarBearCondition.healthy,
      dailyCo2Kg: 1.2,
      weeklyCo2Kg: 8.4,
      weeklyReductionPct: 15.0,
      speechMessage: "Hey! Let's keep our planet cool together! ❄️",
      statusHeadline: "LOW CARBON STATUS",
    );
  }

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final sevenDaysAgo = now.subtract(const Duration(days: 7));

  // Today's activities
  final todayActivities = activities.where((a) => a.createdAt.isAfter(todayStart)).toList();
  final double todayCo2 = todayActivities.fold(0.0, (sum, a) => sum + a.co2Kg);

  // Past 7 days activities
  final weekActivities = activities.where((a) => a.createdAt.isAfter(sevenDaysAgo)).toList();
  final double weekCo2 = weekActivities.fold(0.0, (sum, a) => sum + a.co2Kg);

  // Effective daily CO2 (use today if recorded, or 7-day daily average)
  final double effectiveDailyCo2 = todayActivities.isNotEmpty
      ? todayCo2
      : (weekActivities.isNotEmpty ? (weekCo2 / 7.0) : 1.2);

  // Determine condition based on scientific carbon threshold
  final PolarBearCondition condition;
  final String message;
  final String headline;

  if (effectiveDailyCo2 <= 2.0) {
    condition = PolarBearCondition.healthy;
    headline = "LOW CARBON • ARCTIC COOL";
    message = "You're keeping my home cool! ❄️ Great job!";
  } else if (effectiveDailyCo2 <= 5.0) {
    condition = PolarBearCondition.moderate;
    headline = "MODERATE FOOTPRINT";
    message = "We can do better together 🌱 Try a greener commute!";
  } else if (effectiveDailyCo2 <= 10.0) {
    condition = PolarBearCondition.highCarbon;
    headline = "HIGH CARBON EMISSIONS";
    message = "Uh oh! My home is getting warmer! 🥺 Let's cut emissions.";
  } else {
    condition = PolarBearCondition.critical;
    headline = "CRITICAL CARBON ALERT";
    message = "My ice is melting! 🌡️ Let's choose cleaner alternatives!";
  }

  // Calculate percentage reduction benchmark (against typical 4.5 kg daily baseline)
  final double baselineDaily = 4.5;
  final double reductionPct = (((baselineDaily - effectiveDailyCo2) / baselineDaily) * 100).clamp(-50.0, 95.0);

  return PolarBearStatus(
    condition: condition,
    dailyCo2Kg: effectiveDailyCo2,
    weeklyCo2Kg: weekCo2,
    weeklyReductionPct: reductionPct,
    speechMessage: message,
    statusHeadline: headline,
  );
});
