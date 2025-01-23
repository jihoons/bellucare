import 'package:bellucare/model/medication.dart';
import 'package:bellucare/screen/maintabs/medication.dart';
import 'package:bellucare/style/text.dart';
import 'package:bellucare/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MedicationScreen extends ConsumerStatefulWidget {
  const MedicationScreen({
    super.key,
    required this.state,
  });
  final GoRouterState? state;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends ConsumerState<MedicationScreen> {
  late Medication _medication;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    if (widget.state?.extra == null) {
      _medication = Medication();
    } else {
      _medication = widget.state!.extra as Medication;
      _nameController.value = TextEditingValue(text: _medication.name);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.sizeOf(context).width - 32 - 8) / 2;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_medication.id == 0 ? "복용약 추가" : _medication.name, style: MyTextStyle.titleText,),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("이름", style: MyTextStyle.titleText,),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(

            ),
            keyboardType: TextInputType.text,
            style: MyTextStyle.subTitleText,
            onChanged: (value) {

            },
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: [
          Button(
            text: "취소",
            width: width,
            onTap: () {
              context.pop();
            },
          ),
          Button(
            text: "저장",
            width: width,
            onTap: () {
              if (_medication.id == 0) {
                ref.read(medicationProvider.notifier).saveMedication(Medication(name: _nameController.text));
              } else {
                ref.read(medicationProvider.notifier).saveMedication(_medication.copyWith(
                  name: _nameController.text
                ));
              }
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}

