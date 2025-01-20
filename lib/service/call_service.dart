import 'dart:io';
import 'dart:isolate';

import 'package:bellucare/utils/logger.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final _uuid = const Uuid();

enum CallState {
  Wait, // 대기
  Calling, // 요청
  Connected, // 수신
  Playing, // 통화중
}

class CallService {
  CallState _callState = CallState.Wait;
  CallService._privateConstructor() {
    debug("call service init ${Isolate.current.hashCode} pid: $pid");
    FlutterCallkitIncoming.onEvent.listen((event) async {
      var id = event!.body["id"];
      if (event.event == Event.actionCallAccept) {
        setState(id, CallState.Connected);
      } else if (event.event == Event.actionCallDecline) {
        setState(id, CallState.Wait);
      } else if (event.event == Event.actionCallTimeout) {
        setState(id, CallState.Wait);
      } else if (event.event == Event.actionCallEnded) {
        setState(id, CallState.Wait);
      } else if (event.event == Event.actionCallIncoming) {
        setState(id, CallState.Calling);

        // resetAlarms();
      }
      debug("call event: ${event.event} state: ${callState}, id: ${event.body["id"]}");
    },);
  }

  String getKey(String id) {
    return "call_$id";
  }

  Future<void> setState(String id, CallState callState) async {
    _callState = callState;
    var prefs = await SharedPreferences.getInstance();
    debug("====================");
    debug("set state $id $callState");
    if (callState == CallState.Wait) {
      debug("remove wait");
      await prefs.remove(getKey(id));
    } else {
      debug("set ${callState.name}");
      await prefs.setString(getKey(id), callState.name);
    }
    debug("====================");
  }

  Future<String?> getCallState(String id) async {
    debug("===============");
    debug("get state $id");
    debug("===============");
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(getKey(id));
  }

  Future<void> call(Map<String, dynamic> extra) async {
    if (callState != CallState.Wait) {
      return;
    }

    var currentUuid = _uuid.v4();
    debug("make call call uuid : $currentUuid");

    final params = CallKitParams(
      id: currentUuid,
      nameCaller: "벨류케어",
      appName: "벨류케어",
      avatar: 'https://i.pravatar.cc/100',
      handle: '0123456789',
      type: 0,
      duration: 30000,
      textAccept: Platform.localeName.startsWith("en") ? 'Accept' : "받기",
      textDecline: Platform.localeName.startsWith("en") ? 'Decline' : "거절",
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: false,
        subtitle: Platform.localeName.startsWith("en") ? 'missed alarm' : "알람이 왔어요",
        callbackText: 'Call back',
      ),
      extra: extra,
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        ringtonePath: "empty_ringtone",
        backgroundColor: '#0F295F',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
        incomingCallNotificationChannelName: 'Incoming Call',
        missedCallNotificationChannelName: 'Missed Call',
        isImportant: true,
        isBot: false,
        isShowFullLockedScreen: true,
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'spokenAudio',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  CallState get callState => _callState;
  static final CallService _instance = CallService._privateConstructor();
  static CallService get instance => _instance;
}
