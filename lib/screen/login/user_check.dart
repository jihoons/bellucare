import 'package:bellucare/api/user_api.dart';
import 'package:bellucare/provider/user_provider.dart';
import 'package:bellucare/screen/login/login.dart';
import 'package:bellucare/style/text.dart';
import 'package:bellucare/widget/button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class UserCheckScreen extends ConsumerStatefulWidget {
  const UserCheckScreen({
    required this.state,
    super.key
  });

  final GoRouterState state;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _UserCheckScreenState();
  }
}

class _UserCheckScreenState extends ConsumerState<UserCheckScreen> {
  final _birthdayController = TextEditingController();
  late TemporaryInfo temporaryInfo;
  @override
  void initState() {
    super.initState();
    temporaryInfo = widget.state.extra as TemporaryInfo;
  }

  @override
  void dispose() {
    _birthdayController.dispose();
    super.dispose();
  }

  void login() async {
    var pushToken = await FirebaseMessaging.instance.getToken();
    var response = await UserApi().checkUser(temporaryInfo.token, _birthdayController.text, pushToken!);
    if (response != null) {
      ref.read(userProvider.notifier).setUser(response);
      if (mounted) {
        context.push("/");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Text('생년월일', style: MyTextStyle.titleText,),
            TextField(
              controller: _birthdayController,
              decoration: InputDecoration(

              ),
              keyboardType: TextInputType.datetime,
              style: MyTextStyle.subTitleText,
              onChanged: (value) {

              },
            ),
            Button(
              text: "확인",
              onTap: login
            ),
          ],
        ),
      ),
    );
  }
}
