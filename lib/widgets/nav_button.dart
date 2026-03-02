import 'package:flutter/material.dart';

/// Simple navigation button with tap feedback.
class NavButton extends StatelessWidget {
  const NavButton({required this.child, super.key, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(padding: const EdgeInsets.all(8), child: child),
    );
  }
}
