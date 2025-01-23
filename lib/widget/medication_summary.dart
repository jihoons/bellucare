import 'package:bellucare/model/medication.dart';
import 'package:bellucare/style/text.dart';
import 'package:bellucare/utils/logger.dart';
import 'package:bellucare/widget/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicationSummary extends ConsumerStatefulWidget {
  const MedicationSummary(
    this.medication, {
    super.key,
    this.onTap,
    this.onDelete,
  });

  final Medication medication;
  final Function? onTap;
  final Function? onDelete;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MedicationSummaryState();
}

class _MedicationSummaryState extends ConsumerState<MedicationSummary> {
  bool editState = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap?.call(),
      onHorizontalDragEnd: (details) {
        var velocity = details.primaryVelocity ?? 0.0;
        if (velocity > 0) {
          debug("swiped right");
          if (editState) {
            setState(() {
              editState = false;
            });
          }
        } else if (velocity < 0) {
          debug("swiped left");
          setState(() {
            editState = true;
          });
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          getInfoWidget(),
          editState ? Button(text: "삭제", width: 64, height: 102, background: Colors.red, onTap: () async {
            if (widget.onDelete == null) {
              setState(() {
                editState = false;
              });
            } else {
              widget.onDelete?.call();
            }
          }) : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget getInfoWidget() {
    return Container(
      width: (MediaQuery.sizeOf(context).width - 32) - (editState ? 64 : 0),
      height: 102,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey,
      ),
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.medication.name,
            style: MyTextStyle.titleText,
          ),
        ],
      ),
    );
  }
}