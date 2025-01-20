import 'package:bellucare/service/health_service.dart';
import 'package:bellucare/style/colors.dart';
import 'package:bellucare/widget/Health_summary.dart';
import 'package:bellucare/widget/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          state.needInstallHealthConnect ?
          Button(
              text: "Health Connect 설치",
              onTap: () {
                ref.read(healthProvider.notifier).installSdk();
              }) : SizedBox.shrink(),
          HealthSummary(
            text: "걸음수",
            value: formatter.format(state.steps),
            icon: Icons.directions_walk,
            // onTap: () {
            //   ref.read(healthProvider.notifier).getSteps();
            // },
          ),
        ],
      ),
    );
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