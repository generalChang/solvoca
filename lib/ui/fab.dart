import 'package:flutter/material.dart';
import 'package:solvoca/ui/lift.dart';
import 'package:solvoca/ui/tokens.dart';

class SolvocaFab extends StatelessWidget {
  const SolvocaFab({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add_outlined,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SolvocaLift(
      radius: SolvocaTokens.radiusButton,
      color: SolvocaTokens.accent,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: SolvocaTokens.onAccent, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: SolvocaTokens.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: SolvocaTokens.onAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
