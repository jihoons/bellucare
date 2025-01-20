import 'package:bellucare/service/health_service.dart';
import 'package:bellucare/style/colors.dart';
import 'package:bellucare/style/text.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:bellucare/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      var provider = ref.watch(healthProvider);
      debug("resumed ${provider.value?.lastCheckTime}");
      if (provider.hasValue && (DateTime.now().millisecondsSinceEpoch - provider.value!.lastCheckTime) / 1000 > 30) {
          ref.read(healthProvider.notifier).getSteps();
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("벨유케어", style: MyTextStyle.titleText,),
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    var health = ref.watch(healthProvider);
    return health.when(
        data: (data) => getHome(data),
        error: (error, stackTrace) => getSkeleton(),
        loading: () => getSkeleton(),
    );
  }

  Widget getHome(HealthState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        state.needInstallHealthConnect ?
          Button(
            text: "Health Connect 설치",
            onTap: () {
              ref.read(healthProvider.notifier).installSdk();
            }) : SizedBox.shrink(),
        Text("걸음수 ${state.steps}", style: MyTextStyle.titleText,)
      ],
    );
  }

  Widget getSkeleton() {
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
