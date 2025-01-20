import 'dart:async';
import 'dart:io';

import 'package:bellucare/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

class HealthState {
  HealthState({
    this.steps = 0,
    this.needInstallHealthConnect = false,
    this.lastCheckTime = 0,
  });
  int steps = 0;
  int lastCheckTime = 0;
  bool needInstallHealthConnect = false;

  HealthState copyWith({
    int? steps,
    bool? needInstallHealthConnect,
    int? lastCheckTime,
  }) {
    return HealthState(
      steps: steps ?? this.steps,
      needInstallHealthConnect: needInstallHealthConnect ?? this.needInstallHealthConnect,
      lastCheckTime: lastCheckTime ?? this.lastCheckTime,
    );
  }
}

class HealthStateNotifier extends AsyncNotifier<HealthState> {
  final _health = Health();
  Future<void> checkHealthConnectionStatus() async {
    state = await AsyncValue.guard(() async {
      var status = await _health.getHealthConnectSdkStatus();
      return state.value!.copyWith(
        needInstallHealthConnect: status == HealthConnectSdkStatus.sdkUnavailable,
      );
    },);
  }

  Future<void> getSteps() async {
    state = await AsyncValue.guard(() async {
      var steps = await getStepsFromHealthKit();
      if (steps == state.value!.steps) {
        return state.value!;
      }
      return state.value!.copyWith(steps: steps);
    });
  }

  Future<int> getStepsFromHealthKit() async {
    bool requested = await _health.requestAuthorization([
      HealthDataType.STEPS,
    ], permissions: [HealthDataAccess.READ]);
    if (requested) {
      debug("permission ${await (_health.hasPermissions([HealthDataType.STEPS]))}");
      DateTime now = DateTime.now();
      if (state.value != null) {
        state.value!.lastCheckTime = now.millisecondsSinceEpoch;
      }

      DateTime today = DateTime(now.year, now.month, now.day);
      // health.getTotalStepsInInterval(startTime, endTime)
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(startTime: today, endTime: now, types: [HealthDataType.STEPS]);
      debug("health data[0] ${healthData[0].value}");
      if (healthData.isNotEmpty && healthData[0].type == HealthDataType.STEPS) {
        var numericValue = healthData[0].value as NumericHealthValue;
        return numericValue.numericValue as int;
      }

      debug("$today ~ $now");
      var steps = await _health.getTotalStepsInInterval(today, now);

      debug("steps $steps");
      return steps ?? 0;
    }
    return state.value!.steps;
  }

  Future<void> installSdk() async {
    if (state.value!.needInstallHealthConnect) {
      await _health.installHealthConnect();
    }
  }

  @override
  FutureOr<HealthState> build() async {
    debug("----- call build ---->");
    await _health.configure();
    bool needInstallHealthConnect = false;
    if (Platform.isAndroid) {
      var status = await _health.getHealthConnectSdkStatus();
      needInstallHealthConnect = status == HealthConnectSdkStatus.sdkUnavailable;
    }

    var steps = 0;
    var lastCheckTime = 0;
    if (!needInstallHealthConnect) {
      steps = await getStepsFromHealthKit();
      if (steps > 0) {
        lastCheckTime = DateTime.now().millisecondsSinceEpoch;
      }
    }

    HealthState state = HealthState(
      steps: steps,
      needInstallHealthConnect: needInstallHealthConnect,
      lastCheckTime: lastCheckTime,
    );
    return state;
  }
}

final healthProvider = AsyncNotifierProvider<HealthStateNotifier, HealthState>(
  () => HealthStateNotifier(),
);

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