import 'package:bellucare/service/device_info_service.dart';
import 'package:bellucare/service/health_service.dart';
import 'package:bellucare/service/permission_service.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initCurrentState();
  runApp(const MyApp());
}

Future<void> initCurrentState() async {
  await PermissionService.instance.checkPermission();
  if (await DeviceInfoService.instance.canUseHealth()) {
    if (await PermissionService.instance.requestActivity()) {
      await HealthService.instance.configure();
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int steps = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: <Widget>[
            Text(
              'You have pushed the button this many times: $steps',
            ),
            HealthService.instance.needInstall ?
              InkWell(
                onTap: () {
                  HealthService.instance.installSdk();
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(8),
                  width: MediaQuery.sizeOf(context).width - 32,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue,
                  ),
                  child: Text("Install"),
                ),
              ) : SizedBox.shrink(),
            InkWell(
              onTap: () async {
                var steps = await HealthService.instance.getSteps();
                debug("steps $steps");
                setState(() {
                  this.steps = steps;
                });
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(8),
                width: MediaQuery.sizeOf(context).width - 32,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue,
                ),
                child: Text("Get Steps"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
