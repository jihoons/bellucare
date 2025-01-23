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
    this.background,
  });
  final String text;
  final Function onTap;
  final double? width;
  final double? height;
  final Color? background;

  Button copyWith({
    String? text,
    Function? onTap,
    double? width,
    double? height,
    Color? background,
  }) {
    return Button(
      text: text ?? this.text,
      onTap: onTap ?? this.onTap,
      width: width ?? this.width,
      height: height ?? this.height,
      background: background ?? this.background,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        alignment: Alignment.center,
        width: width ?? MediaQuery.sizeOf(context).width - 32,
        height: height ?? 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: background ?? Colors.white,
        ),
        child: Text(text, style: MyTextStyle.actionButtonText,),
      ),
    );
  }
}

class ButtonGroups extends StatelessWidget {
  const ButtonGroups({
    super.key, 
    required this.children,
  });
  final List<Button> children;
  
  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.sizeOf(context).width - 32 - (8 * (children.length - 1))) / children.length;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 8,
        children: children.map((e) => e.copyWith(width: width)).toList(),
      ),
    );
  }
}