import 'dart:async';
import 'dart:convert';

import 'package:bellucare/service/call_service.dart';
import 'package:bellucare/style/text.dart';
import 'package:bellucare/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  late String subType;

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

  @override
  void initState() {
    super.initState();
    params = jsonDecode(jsonEncode(widget.state.extra));
    calling = CallKitParams.fromJson(params);
    if (calling?.extra != null) {
      subType = calling!.extra!["subType"] ?? "";
    }

    receive();
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
    if (context.mounted) {
      context.pop();
    }
  }

  Widget getSubTypeWidget() {
    switch(subType) {
      case "greeting":
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 6,
          children: [
            Text("오늘 기분이 어떠신가요?", style: MyTextStyle.titleText,),
            Button(
              text: "좋아요.",
              onTap: () {

              }
            ),
            Button(
                text: "별로예요.",
                onTap: () {

                }
            )
          ],
        );
      case "medication":
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 6,
          children: [
            Text("약은 다 드셨나요?", style: MyTextStyle.titleText,),
            Button(
                text: "네.",
                onTap: () {

                }
            ),
            Button(
                text: "아니요.",
                onTap: () {

                }
            )
          ],
        );
      default:
        return SizedBox.shrink();
    }
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
                Button(
                  text: "종료",
                  onTap: () {
                    endCall();
                  }
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
