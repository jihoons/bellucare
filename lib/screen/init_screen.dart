import 'package:bellucare/api/user_api.dart';
import 'package:bellucare/model/user.dart';
import 'package:bellucare/provider/user_provider.dart';
import 'package:bellucare/service/storage_service.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class InitScreen extends ConsumerStatefulWidget {
  const InitScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _InitScreenState();
  }
}

class _InitScreenState extends ConsumerState<InitScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    var response = await getUserInfo();
    if (response == null && mounted) {
      context.replace("/login");
    }
    ref.read(userProvider.notifier).setUser(response!);
    if (mounted) {
      context.replace("/");
    }
  }

  Future<LogInResponse?> getUserInfo() async {
    String token = await StorageService().getData(StorageService.refreshTokenKey);
    if (token.isEmpty) {
      return null;
    }
    var pushToken = await FirebaseMessaging.instance.getToken();
    debug("====> $pushToken");
    var response = await UserApi().fetchUserByToken(token, pushToken!);
    return response;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
