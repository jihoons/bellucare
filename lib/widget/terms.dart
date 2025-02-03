import 'package:flutter/material.dart';

class Terms extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TermsState();
  }
}

class _TermsState extends State<Terms> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

      ],
    );
  }
}

class _TermLine extends StatelessWidget {
  const _TermLine({
    required this.checked,
    required this.title,
    super.key,
  });
  final bool checked;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

      ],
    );
  }
}