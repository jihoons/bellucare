import 'package:bellucare/service/telephone_serivce.dart';
import 'package:bellucare/style/text.dart';
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

  @override
  void initState() {
    super.initState();
    TelephoneService.instance.getPhoneNumbers().then((value) {
      if (value.isNotEmpty && value.length == 1) {
        _phoneNumberController.value = TextEditingValue(text: value[0]);
      }
    },);
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _verificationController.dispose();
    super.dispose();
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
            ),
            message == "" ? SizedBox.shrink() : SizedBox(height: 8,),
            message == "" ? SizedBox.shrink() : Text(message, style: MyTextStyle.errorText,),

            SizedBox(height: 32,),
            Button(
              text: "로그인",
              onTap: () {
                if (_verificationController.text == "123456") {
                  context.replace("/");
                } else {
                  setState(() {
                    message = "인증 번호를 확인해 주세요.";
                  });
                }
              }
            ),
          ],
        ),
      ),
    );
  }
}
