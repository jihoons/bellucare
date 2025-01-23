import 'package:bellucare/screen/maintabs/health.dart';
import 'package:bellucare/screen/maintabs/medication.dart';
import 'package:bellucare/service/call_service.dart';
import 'package:bellucare/service/health_service.dart';
import 'package:bellucare/service/tts_service.dart';
import 'package:bellucare/style/text.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  String? _currentUuid;
  int _selectedIndex = 0;
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      debug("change tabIndex ${_tabController.index}");
      if (_selectedIndex != _tabController.index) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    },);
    WidgetsBinding.instance.addObserver(this);
    checkAndNavigationCallingPage();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      var provider = ref.watch(healthProvider);
      if (provider.hasValue) {
        debug("resumed ${provider.value?.lastCheckTime}");
        if (provider.hasValue && (DateTime.now().millisecondsSinceEpoch - provider.value!.lastCheckTime) / 1000 > 30) {
          ref.read(healthProvider.notifier).getStatus();
        }
        if (provider.value!.needInstallHealthConnect) {
          ref.read(healthProvider.notifier).checkInstall();
        }
      }
      checkAndNavigationCallingPage(isResumed: true);
    }
  }

  Future<void> checkAndNavigationCallingPage({bool isResumed = false}) async {
    debug("checkAndNavigationCallingPage");
    // IsolateNameServer.lookupPortByName("background")?.send("get state");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var currentCall = await getCurrentCall();
      if (currentCall != null) {
        debug("call state: ${CallService.instance.callState}");
        var callState = await CallService.instance.getCallState(_currentUuid!);
        debug("call state shared: $callState");
        if (CallService.instance.callState == CallState.Connected || callState == "Connected") {
          context.push("/calling", extra: currentCall);
        }
      }
    });
  }

  Future<dynamic> getCurrentCall() async {
    //check current call from pushkit if possible
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        _currentUuid = calls[0]['id'];
        return calls[0];
      } else {
        // _currentUuid = "";
        return null;
      }
    }
  }

  Widget getFloatingButton() {
    if (_selectedIndex == 1) {
      var medication = ref.watch(medicationProvider);
      if (medication.hasValue) {
        return FloatingActionButton.extended(
          onPressed: () {
            debug("add medication");
            ref.read(medicationProvider.notifier).addMedication(Medication(name: "혈압약"));
          },
          shape: const CircleBorder(),
          label: Icon(Icons.medication, size: 24, color: Colors.white,),
        );
      }
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(ttsServiceProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("벨유케어", style: MyTextStyle.titleText,),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          HealthMainTab(),
          MedicationMainTab(),
        ]
      ),
      floatingActionButton: getFloatingButton(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black12,
        onTap: (index) {
          debug("log $index");
          if (_selectedIndex == index) {
            return;
          }
          setState(() {
            _selectedIndex = index;
            _tabController.index = index;
          });
        },
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.white,),
            label: '홈',
            // activeIcon: Icon(Icons.home_outlined, color: Colors.red,),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication, color: Colors.white),
            label: '복용약',
            // activeIcon: Icon(Icons.medication, color: Colors.red,),
          ),
        ]
      ),
    );
  }
}
