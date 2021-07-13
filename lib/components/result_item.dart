import 'package:barcode_scanning/utils/constants.dart';
import 'package:flutter/material.dart';

class ResultItem extends StatelessWidget {
  final String text;
  const ResultItem({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
      decoration: BoxDecoration(
        color: Constants.dialogColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.22),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(4, 6),
          ),
        ],
      ),
      child: SelectableText(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Constants.textColor,
          fontSize: 20,
        ),
      ),
    );
  }
}
