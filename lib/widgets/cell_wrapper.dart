import 'package:flutter/material.dart';

class CellWrapper extends StatelessWidget {
  const CellWrapper({
    super.key,
    required this.width,
    required this.height,
    required this.child,
    this.border,
  });

  final double width;
  final double height;
  final Widget child;
  final BorderSide? border;

  @override
  Widget build(BuildContext context) {
    if (border == null) {
      return SizedBox(width: width, height: height, child: child);
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: border!.color, width: border!.width),
      ),
      child: child,
    );
  }
}
