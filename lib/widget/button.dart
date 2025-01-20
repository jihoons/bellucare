import 'package:bellucare/style/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.text,
    required this.onTap,
    this.width,
    this.height,
  });
  final String text;
  final Function onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        width: width ?? MediaQuery.sizeOf(context).width - 32,
        height: height ?? 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Text(text, style: MyTextStyle.actionButtonText,),
      ),
    );
  }
}