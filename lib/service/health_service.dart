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
      // health.getTotalStepsInInterval(startTime, endTime)
      // List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(startTime: now.subtract(Duration(days: 2)), endTime: now, types: [HealthDataType.STEPS], recordingMethodsToFilter: [
      //   RecordingMethod.manual,
      //   RecordingMethod.automatic,
      //   RecordingMethod.active,
      //   RecordingMethod.unknown,
      // ]);
      // debug("health data $healthData");
      DateTime today = DateTime(now.year, now.month, now.day);
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