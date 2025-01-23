import 'package:bellucare/service/health_service.dart';
import 'package:bellucare/service/stt_service.dart';
import 'package:bellucare/service/tts_service.dart';
import 'package:bellucare/style/colors.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:bellucare/widget/Health_summary.dart';
import 'package:bellucare/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

final healthTabProvider = StateProvider<bool>((ref) {
  return false;
});

class HealthMainTab extends ConsumerWidget {
  HealthMainTab({super.key});

  final formatter = NumberFormat('###,###,###,###');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var health = ref.watch(healthProvider);
    return health.when(
      data: (data) => getHome(context, ref, data),
      error: (error, stackTrace) => getSkeleton(context),
      loading: () => getSkeleton(context),
    );
  }

  Widget getHome(BuildContext context, WidgetRef ref, HealthState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          state.needInstallHealthConnect ?
          Button(
              text: "Health Connect 설치",
              onTap: () {
                ref.read(healthProvider.notifier).installSdk();
              }) : SizedBox.shrink(),
          HealthSummary(
            text: "걸음수",
            value: formatter.format(state.status.steps),
            icon: Icons.directions_walk,
            onTap: () {
              ref.read(healthProvider.notifier).getStatus();
            },
          ),
          getSTTButton(ref),
        ],
      ),
    );
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

  void listen(WidgetRef ref) async {
    ref.read(sttProvider.notifier).startListening((text) async {
      ref.read(healthTabProvider.notifier).state = false;
      var positive = ["먹었어", "어", "응", "그래", "당연하지", "먹었습니다", "먹었어요", "예", "먹었지"];
      var negative = ["아니", "아직", "안 먹었어", "안 먹었어요", "안 먹었습니다", "먹을께요", "먹을께", "먹겠습니다", "안 먹었지"];
      if (contains(text, negative)) {
        await ref.read(ttsServiceProvider.notifier).speak("약은 꼭 드셔야죠");
      } else if (contains(text, positive)) {
        await ref.read(ttsServiceProvider.notifier).speak("네 잘하셨어요.");
      } else {
        await ref.read(ttsServiceProvider.notifier).speak("다시 한번 말씀해 주세요.");
        ref.read(healthTabProvider.notifier).state = true;
        listen(ref);
      }
    },);
  }

  Widget getSTTButton(WidgetRef ref) {
    var stt = ref.watch(sttProvider);
    var health = ref.watch(healthTabProvider);
    if (health) {
      return stt.when(
        data: (data) {
          if (data.canListen) {
            return Button(
                text: "다시 말하기",
                onTap: () {
                  listen(ref);
                }
            );
          } else {
            return SizedBox.shrink();
          }
        } ,
        error: (a, b) => SizedBox.shrink(),
        loading: () => SizedBox.shrink(),
      );
    } else {
      return Button(
        text: "시작",
        onTap: () async {
          await ref.read(ttsServiceProvider.notifier).speak("오늘 혈압약을 드셨는지 먹었어, 안먹었어로 대답해 주세요.");
          ref.read(healthTabProvider.notifier).state = true;
          listen(ref);
        }
      );
    }
  }

  Widget getSkeleton(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: skeletonBaseColor,
        highlightColor: skeletonHighlightColor,
        child: Container(
          width: MediaQuery.sizeOf(context).width - 32,
          height: 480,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: skeletonBaseColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        )
    );
  }
}