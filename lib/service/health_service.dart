import 'dart:async';
import 'dart:io';

import 'package:appcheck/appcheck.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

class HealthStatus {
  const HealthStatus({
    this.steps = 0,
  });
  final int steps;
}

const _emptyStatus = HealthStatus();
class HealthState {
  HealthState({
    this.status = _emptyStatus,
    this.needInstallHealthConnect = false,
    this.lastCheckTime = 0,
    this.availableSdkStatus = false,
  });
  HealthStatus status = HealthStatus();
  int lastCheckTime = 0;
  bool needInstallHealthConnect = false;
  bool availableSdkStatus = false;

  HealthState copyWith({
    HealthStatus? status,
    bool? needInstallHealthConnect,
    int? lastCheckTime,
    bool? availableSdkStatus,
  }) {
    return HealthState(
      status: status ?? this.status,
      needInstallHealthConnect: needInstallHealthConnect ?? this.needInstallHealthConnect,
      lastCheckTime: lastCheckTime ?? this.lastCheckTime,
      availableSdkStatus: availableSdkStatus ?? this.availableSdkStatus,
    );
  }
}

class HealthStateNotifier extends AsyncNotifier<HealthState> {
  final _health = Health();
  final _appChecker = AppCheck();
  final _healthConnectionPackage = "com.google.android.apps.healthdata";
  Future<void> checkHealthConnectionStatus() async {
    state = await AsyncValue.guard(() async {
      var status = await _health.getHealthConnectSdkStatus();
      return state.value!.copyWith(
        needInstallHealthConnect: status == HealthConnectSdkStatus.sdkUnavailable,
      );
    },);
  }

  Future<void> getStatus() async {
    state = await AsyncValue.guard(() async {
      var status = await getStatusFromHealthKit();
      return state.value!.copyWith(status: status);
    });
  }

  final androidTypes = [HealthDataType.STEPS, HealthDataType.ACTIVE_ENERGY_BURNED];
  final iosTypes = [HealthDataType.STEPS, HealthDataType.ACTIVE_ENERGY_BURNED];

  List<HealthDataType> get _dataTypes => Platform.isAndroid ? androidTypes : iosTypes;
  Future<HealthStatus> getStatusFromHealthKit() async {
    debug("request permission");
    bool requested = false;
    var dataTypes = _dataTypes;
    var permissions = dataTypes.map((e) => HealthDataAccess.READ,).toList();
    try {
      requested = await _health.requestAuthorization(dataTypes, permissions: permissions);
    } catch (e) {
      debug("error $e");
    }
    debug("request permission result $requested");
    int steps = 0;
    if (requested) {
      var hasPermission = await _health.hasPermissions(dataTypes);
      debug("has permission $hasPermission");
      DateTime now = DateTime.now();
      if (state.value != null) {
        state.value!.lastCheckTime = now.millisecondsSinceEpoch;
      }

      DateTime today = DateTime(now.year, now.month, now.day);

      // ACTIVE_ENERGY_BURNED 칼로리
      // EXERCISE_TIME 활동 시간
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(startTime: today, endTime: now, types: dataTypes);
      debug("health data ${healthData.isEmpty}");
      if (healthData.isNotEmpty) {
        debug("health data count ${healthData.length}");
        for (var data in healthData) {
          debug("health data $data");
          if (data.type == HealthDataType.STEPS) {
            steps = (data.value as NumericHealthValue).numericValue as int;
          }
        }
      }
      return HealthStatus(steps: steps);
    }
    return state.value!.status;
  }

  Future<void> installSdk() async {
    if (state.value!.needInstallHealthConnect) {
      await _health.installHealthConnect();
    }
  }

  Future<void> checkInstall() async {
    if (Platform.isAndroid) {
      state = await AsyncValue.guard(() async {
        debug("checkInstall");
        var isAppInstalled = await _appChecker.isAppInstalled("com.google.android.apps.healthdata");
        debug("checkInstall result ${isAppInstalled}");
        return state.value!.copyWith(needInstallHealthConnect: !isAppInstalled);
      },);
    }
  }

  @override
  FutureOr<HealthState> build() async {
    debug("build start");
    await _health.configure();
    debug("health configure");
    bool needInstallHealthConnect = false;
    bool availableSdkStatus = false;
    if (Platform.isAndroid) {
      var isAppInstalled = await _appChecker.isAppInstalled(_healthConnectionPackage);
      debug("isAppInstalled: $isAppInstalled");
      if (!isAppInstalled) {
        needInstallHealthConnect = true;
      }
      var status = await _health.getHealthConnectSdkStatus();
      debug("health connect status : $status");
      availableSdkStatus = status == HealthConnectSdkStatus.sdkAvailable;
    }
    debug("health connect $needInstallHealthConnect");

    var status = _emptyStatus;
    var lastCheckTime = 0;
    if (!needInstallHealthConnect && availableSdkStatus) {
      status = await getStatusFromHealthKit();
      if (status.steps > 0) {
        lastCheckTime = DateTime.now().millisecondsSinceEpoch;
      }
    }

    HealthState state = HealthState(
      status: status,
      needInstallHealthConnect: needInstallHealthConnect,
      lastCheckTime: lastCheckTime,
    );
    return state;
  }
}

final healthProvider = AsyncNotifierProvider<HealthStateNotifier, HealthState>(
  () => HealthStateNotifier(),
);
