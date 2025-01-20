import 'package:bellucare/screen/maintabs/medication.dart';
import 'package:bellucare/style/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicationSummary extends ConsumerWidget {
  const MedicationSummary(this.medication, {
    super.key,
    this.onTap,
  });
  final Medication medication;
  final Function? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => onTap?.call(),
      child: Container(
        width: MediaQuery.sizeOf(context).width - 32,
        height: 102,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey,
        ),
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          children: [
            Text(medication.name, style: MyTextStyle.titleText,)
          ],
        ),
      ),
    );
  }
}