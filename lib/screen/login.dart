import 'package:bellucare/api/user_api.dart';
import 'package:bellucare/provider/user_provider.dart';
import 'package:bellucare/service/storage_service.dart';
import 'package:bellucare/service/telephone_serivce.dart';
import 'package:bellucare/style/text.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:bellucare/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _verificationController = TextEditingController();
  String phoneNumber = "";
  String message = "";
  String sessionKey = "";
  bool requestAuthenticationCode = false;
  
  @override
  void initState() {
    super.initState();
    TelephoneService.instance.getPhoneNumbers().then((value) {
      if (value.isNotEmpty && value.length == 1) {
        _phoneNumberController.value = TextEditingValue(text: value[0]);
        requestCode();
      }
      debug("requestAuthenticationCode value is $requestAuthenticationCode ");
    },);
  }

  void requestCode() async {
    sessionKey = await UserApi().requestAuthenticationCode(_phoneNumberController.text);
    if (!requestAuthenticationCode) {
      setState(() {
        requestAuthenticationCode = true;
      });
    }
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _verificationController.dispose();
    super.dispose();
  }

  Widget getButtons() {
    if (!requestAuthenticationCode) {
      return Button(
        text: "인증번호 요청",
        onTap: () {
          requestCode();
        }
      );
    }
    double width = (MediaQuery.sizeOf(context).width - 32 - 8) / 2;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Button(
          text: "재요청",
          width: width,
          onTap: () {
            requestCode();
          }
        ),
        Button(
            text: "확인",
            width: width,
            onTap: () async {
              var result = await UserApi().validateAuthenticationCode(phoneNumber, sessionKey, _verificationController.text);
              if (result == null) {
                setState(() {
                  message = "인증 번호를 확인해 주세요.";
                });
              } else {
                ref.read(userProvider.notifier).state = result.user;
                TokenManager().accessToken = result.accessToken;
                TokenManager().refreshToken = result.refreshToken;
                await StorageService().saveData(StorageService.userTokenKey, result.refreshToken);
                context.replace("/");
              }
            }
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          // spacing: 4,
          children: [
            Text("전화번호", style: MyTextStyle.titleText,),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(

              ),
              keyboardType: TextInputType.phone,
              style: MyTextStyle.subTitleText,
              onChanged: (value) {

              },
            ),
            requestAuthenticationCode ?
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32,),
                  Text("인증번호", style: MyTextStyle.titleText,),
                  TextField(
                    controller: _verificationController,
                    decoration: InputDecoration(

                    ),
                    keyboardType: TextInputType.phone,
                    style: MyTextStyle.subTitleText,
                    onChanged: (value) {

                    },
                  )
                ],
            ) : SizedBox.shrink(),
            message == "" ? SizedBox.shrink() : SizedBox(height: 8,),
            message == "" ? SizedBox.shrink() : Text(message, style: MyTextStyle.errorText,),

            SizedBox(height: 32,),
            getButtons(),
          ],
        ),
      ),
    );
  }
}
