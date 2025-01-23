import 'package:bellucare/service/storage_service.dart';
import 'package:bellucare/widget/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingMainTab extends ConsumerWidget {
  const SettingMainTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Button(
          text: "가족 보기",
          onTap: () {

          },
        ),
        Button(
          text: "로그아웃",
          onTap: () async {
            await StorageService().removeData(StorageService.userTokenKey);
            context.replace("/login");
          }
        ),
      ],
    );
  }
}