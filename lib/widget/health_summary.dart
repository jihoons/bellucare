import 'package:bellucare/style/text.dart';
import 'package:flutter/material.dart';

class HealthSummary extends StatelessWidget {
  const HealthSummary({
    super.key,
    required this.text,
    required this.icon,
    required this.value,
    this.onTap,
  });
  final String text;
  final IconData icon;
  final String value;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
        child: Material(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () {
              onTap?.call();
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, size: 36, color: Colors.white,),
                  Text(value, style: MyTextStyle.healthText,),
                  Text(text, style: MyTextStyle.subTitleText,)
                ],
              ),
            ),
          ),
        ),
    );
  }
}