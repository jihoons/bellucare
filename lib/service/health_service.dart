import 'dart:io';

import 'package:bellucare/utils/logger.dart';
import 'package:health/health.dart';

class HealthService {
  static final HealthService _instance = HealthService._postConstructor();

  static HealthService get instance => _instance;

  final health = Health();
  HealthService._postConstructor() {
    configure();
  }

  Future<void> configure() async {
    await health.configure();
    await checkStatus();
  }

  Future<int> getSteps() async {
    bool requested = await health.requestAuthorization([
      HealthDataType.STEPS,
    ], permissions: [HealthDataAccess.READ_WRITE]);
    if (requested) {
      debug("permission ${await (health.hasPermissions([HealthDataType.STEPS]))}");
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      // health.getTotalStepsInInterval(startTime, endTime)
      List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(startTime: today, endTime: now, types: [HealthDataType.STEPS]);
      debug("health data[0] ${healthData[0].value}");
      if (healthData.isNotEmpty && healthData[0].type == HealthDataType.STEPS) {
        var numericValue = healthData[0].value as NumericHealthValue;
        return numericValue.numericValue as int;
      }

      debug("$today ~ $now");
      var steps = await health.getTotalStepsInInterval(today, now);

      debug("steps $steps");
      return steps ?? 0;
    }
    return 0;
  }

  Future<void> checkStatus() async {
    final status = await health.getHealthConnectSdkStatus();
    debug("getHealthConnectSdkStatus $status");
  }

  Future<void> installSdk() async {
    if (needInstall) {
      await health.installHealthConnect();
    }
  }

  bool get needInstall => (Platform.isAndroid && health.healthConnectSdkStatus == HealthConnectSdkStatus.sdkUnavailable);
}