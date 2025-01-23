import 'dart:async';
import 'dart:convert';

import 'package:bellucare/service/call_service.dart';
import 'package:bellucare/service/stt_service.dart';
import 'package:bellucare/service/tts_service.dart';
import 'package:bellucare/style/text.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:bellucare/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CallReceiveScreen extends ConsumerStatefulWidget {
  const CallReceiveScreen({
    required this.state,
    super.key
  });
  final GoRouterState state;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CallReceiveScreenState();
  }
}

class _CallReceiveScreenState extends ConsumerState<CallReceiveScreen> {
  late CallKitParams? calling;
  late Map<String, dynamic> params;
  Timer? _timer;
  int _start = 0;
  late _ActionInfo actionInfo;
  final ImagePicker picker = ImagePicker();

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        setState(() {
          _start++;
        });
      },
    );
  }

  String intToTimeLeft(int value) {
    int h, m, s;
    h = value ~/ 3600;
    m = ((value - h * 3600)) ~/ 60;
    s = value - (h * 3600) - (m * 60);
    String hourLeft = h.toString().length < 2 ? '0$h' : h.toString();
    String minuteLeft = m.toString().length < 2 ? '0$m' : m.toString();
    String secondsLeft = s.toString().length < 2 ? '0$s' : s.toString();
    String result = "$hourLeft:$minuteLeft:$secondsLeft";
    return result;
  }

  bool contains(String text, List<String> words) {
    var tokens = text.split(" ");
    for (var word in words) {
      var find = false;
      if (word.length > 2) {
        find = text.contains(word);
      } else {
        find = tokens.where((token) => token == word,).isNotEmpty;
      }
      if (find) {
        debug("find word $word in text");
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    params = jsonDecode(jsonEncode(widget.state.extra));
    calling = CallKitParams.fromJson(params);
    if (calling?.extra != null) {
      actionInfo = _ActionInfo.fromMap(calling!.extra!);
    } else {
      actionInfo = _ActionInfo.fromMap({});
    }

    Future.delayed(Duration(milliseconds: 200), () async {
      await ref.read(ttsServiceProvider.notifier).speak(actionInfo.voice);
      if (mounted) {
        listen();
      }
    },);

    receive();
  }

  void listen() async {
    ref.read(sttProvider.notifier).startListening((text) async {
      if (actionInfo.needConfirm) {
        if (contains(text, actionInfo.negative)) {
          await ref.read(ttsServiceProvider.notifier).speak("약은 꼭 드셔야죠");
          endCall();
        } else if (contains(text, actionInfo.positive)) {
          await ref.read(ttsServiceProvider.notifier).speak("네 잘하셨어요.");
          endCall();
        } else {
          await ref.read(ttsServiceProvider.notifier).speak("다시 한번 ${actionInfo.voice}");
          listen();
        }
      } else {
        if (text.length > 3) {
          await ref.read(ttsServiceProvider.notifier).speak("그렇군요. 오늘도 좋은 하루 보내세요.");
          endCall();
        } else {
          await ref.read(ttsServiceProvider.notifier).speak("조금 더 길게 애기해 주세요.");
          listen();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> receive() async {
    await CallService.instance.setState(calling!.id!, CallState.Playing) ;
    await FlutterCallkitIncoming.setCallConnected(calling!.id!);
    startTimer();
  }

  void endCall() async {
    if (calling != null) {
      await FlutterCallkitIncoming.endAllCalls();
      calling = null;
    }
    if (mounted) {
      context.pop();
    }
  }

  Widget getSubTypeWidget() {
    if (actionInfo.subType == SubType.Unknown) {
      return Button(
          text: "종료",
          onTap: () {
            endCall();
          }
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 6,
      children: [
        Text(actionInfo.question, style: MyTextStyle.titleText,),
        ...actionInfo.buttons.map((text) {
          return Button(
              text: text,
              onTap: () async {
                debug("click $text");
                await ref.read(ttsServiceProvider.notifier).speak("그렇군요");
                endCall();
              }
          );
        }),
        ButtonGroups(
          children: [
            Button(
                text: "카메라 찍기",
                onTap: () async {
                  final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    debug("photho $photo");
                  }
                }
            ),
            Button(
                text: "사진 선택",
                onTap: () async {
                  final List<XFile> images = await picker.pickMultiImage();
                  if (images.isNotEmpty) {
                    debug("image count: ${images.length}");
                  }
                }
            )
          ]
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    var timeDisplay = intToTimeLeft(_start);
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: double.infinity,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 16,
              children: [
                Text(timeDisplay, style: MyTextStyle.timeWatchText,),
                SizedBox(height: 80,),
                getSubTypeWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum SubType {
  Greeting,
  Medication,
  Unknown;

  static SubType fromString(String value) {
    switch (value.toLowerCase()) {
      case "greeting":
        return SubType.Greeting;
      case "medication":
        return SubType.Medication;
      default:
        return SubType.Unknown;
    }
  }
}

class _ActionInfo {
  _ActionInfo({
    required this.subType,
    required this.buttons,
    required this.positive,
    required this.negative,
    this.needConfirm = false,
    this.question = "",
    this.voice = "",
  });

  final SubType subType;
  final String question;
  final String voice;
  final bool needConfirm;
  final List<String> buttons;
  final List<String> positive;
  final List<String> negative;

  factory _ActionInfo.fromMap(Map<String, dynamic> map) {
    debug("map: $map");
    var value = map["subType"] as String? ?? "";
    var subType = SubType.fromString(value);
    if (subType == SubType.Unknown) {
      return _ActionInfo(
        subType: subType,
        buttons: <String>[],
        positive: <String>[],
        negative: <String>[],
      );
    }

    var question = "";
    var voice = "";
    var buttons = List<String>.empty(growable: true);
    var positive = List<String>.empty(growable: true);
    var negative = List<String>.empty(growable: true);
    var needConfirm = false;
    if (subType == SubType.Greeting) {
      question = "지금 기분이 어떠세요?";
      voice = question;
      buttons.addAll(["좋아요", "별로예요", "그냥 그래요"]);
    } else if (subType == SubType.Medication) {
      question = "${map["medication"] as String? ?? "약"}을 드셨나요?";
      voice = "${map["medication"] as String? ?? "약"}을 드셨는지 먹었어, 안먹었어로 대답해주세요.";
      positive.addAll(["먹었어", "어", "응", "그래", "당연하지", "먹었습니다", "먹었어요", "예", "먹었지"]);
      negative.addAll(["아니", "아직", "안 먹었어", "안 먹었어요", "안 먹었습니다", "먹을께요", "먹을께", "먹겠습니다", "안 먹었지"]);
      buttons.addAll(["먹었어", "안먹었어"]);
      needConfirm = true;
    }

    return _ActionInfo(
      subType: subType,
      question: question,
      needConfirm: needConfirm,
      positive: positive,
      negative: negative,
      voice: voice,
      buttons: buttons,
    );
  }
}
