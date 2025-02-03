import 'package:bellucare/api/user_api.dart';
import 'package:bellucare/model/user.dart';
import 'package:bellucare/provider/user_provider.dart';
import 'package:bellucare/screen/login/login.dart';
import 'package:bellucare/style/text.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:bellucare/widget/button.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AgreeTerms {
  AgreeTerms({
    required this.terms,
    this.agree = false,
  });
  bool agree;
  Terms terms;
}

class NewUserScreen extends ConsumerStatefulWidget {
  const NewUserScreen({
    required this.state,
    super.key,
  });
  final GoRouterState state;

  @override
  ConsumerState<NewUserScreen> createState() => _NewUserScreenState();
}

class _NewUserScreenState extends ConsumerState<NewUserScreen> {
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();

  late TemporaryInfo temporaryInfo;
  List<AgreeTerms> termsList = [];

  @override
  void initState() {
    super.initState();
    temporaryInfo = widget.state.extra as TemporaryInfo;
    debug("token ${temporaryInfo.token}");
    UserApi().getTerms(temporaryInfo.token).then((terms) {
      debug("terms: ${terms.length}");
      setState(() {
        termsList = List.empty(growable: true);
        for (var term in terms) {
          termsList.add(AgreeTerms(terms: term, agree: term.required));
        }
      });
    },);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  void signup() async {
    var pushToken = await FirebaseMessaging.instance.getToken();
    var response = await UserApi().signup(token: temporaryInfo.token,
        phoneNumber: temporaryInfo.phoneNumber,
        name: _nameController.text,
        gender: "",
        birthDay: _birthdayController.text,
        agreeTerms: termsList.where((element) => element.agree,).map((e) => {"id": e.terms.termsId, "termsType": e.terms.termsType},).toList(),
        pushToken: pushToken!,
    );
    if (response == null) {
      return;
    }
    ref.read(userProvider.notifier).setUser(response);
    if (mounted) {
      context.push("/");
    }
  }

  List<Widget> getTermsWidgets() {
    if (termsList.isEmpty) {
      return [SizedBox.shrink()];
    } else {
      return termsList.map((e) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 8,
              children: [
                Checkbox(value: e.agree, onChanged: (value) {
                  setState(() {
                    e.agree = !e.agree;
                  });
                },),
                Text(e.terms.title, style: MyTextStyle.voiceName,)
              ],
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: Icon(Icons.arrow_forward_ios_outlined, color: Colors.white, size: 24,),
            )
          ],
        );
      },).toList();
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
            Text('이름', style: MyTextStyle.titleText,),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(

              ),
              keyboardType: TextInputType.name,
              style: MyTextStyle.subTitleText,
              onChanged: (value) {

              },
            ),

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
            ...getTermsWidgets(),
            Button(
                text: "확인",
                onTap: signup
            ),
          ],
        ),
      ),
    );
  }
}
